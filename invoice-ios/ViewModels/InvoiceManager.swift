//
//  InvoiceManager.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

import Foundation
import SwiftData
import Combine

@MainActor protocol InvoiceServiceable {
    func getInvoicePublisher(byMonth month: Int, year: Int) -> AnyPublisher<[Invoice], Never>
    func addInvoice(_ invoice: Invoice) async throws
    func deleteInvoice(_ invoice: Invoice) async throws
    func updateInvoice(_ invoice: Invoice, newDetails: [InvoiceDetail]) async throws
}

final class InvoiceManager: InvoiceServiceable {
    static let shared = InvoiceManager()

    @Published private var isSaving = false

    private let container: ModelContainer
    private var cancellables = Set<AnyCancellable>()
    private var publishers: [String: WeakBox<CurrentValueSubject<[Invoice],Never>>] = [:]

    init(container: ModelContainer? = nil) {
        if let container = container {
            self.container = container
        } else {
            do {
                self.container = try ModelContainer(for: Invoice.self, InvoiceDetail.self)
                let context = self.container.mainContext
                let existingInvoices = try? context.fetch(FetchDescriptor<Invoice>())
                if existingInvoices?.isEmpty ?? true {
                    Invoice.sampleData.forEach { context.insert($0) }
                    do {
                        try context.save()
                    } catch {
                        fatalError("Could not save sample data: \(error)")
                    }
                }
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }

        self.setupContextListener()
    }

    // MARK: - Listen Context Change
    private func setupContextListener() {
        NotificationCenter.default.publisher(for: ModelContext.didSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.notifyAllPublishers()
                self.isSaving = false
            }
            .store(in: &cancellables)
    }

    private func fetchInvoices(forYear year: Int, month: Int) -> [Invoice] {
        let fetchDescriptor = FetchDescriptor<Invoice>(
            predicate: #Predicate { $0.year == year && $0.month == month },
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )
        do {
            return try container.mainContext.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch invoices: \(error)")
            return []
        }
    }

    private func notifyAllPublishers() {
        for key in publishers.keys {
            if let subject = publishers[key]?.value {
                let components = key.split(separator: "-").compactMap { Int($0) }
                if components.count == 2 {
                    let year = components[0]
                    let month = components[1]
                    let filteredInvoices = fetchInvoices(forYear: year, month: month)
                    subject.send(filteredInvoices)
                }
            }
        }
    }

    private func saveContext() async throws {
        do {
            try container.mainContext.save()
            self.isSaving = true

            for await value in self.$isSaving.values where value {
                break
            }
        } catch {
            print("Failed to save context: \(error)")
            throw error
        }
    }

    // MARK: - Public Methods
    func getInvoicePublisher(byMonth month: Int, year: Int) -> AnyPublisher<[Invoice], Never> {
        let key = "\(year)-\(month)"

        if let existingSubject = publishers[key]?.value {
            return existingSubject.eraseToAnyPublisher()
        }

        let filteredInvoices = fetchInvoices(forYear: year, month: month)
        let subject = CurrentValueSubject<[Invoice], Never>(filteredInvoices)
        publishers[key] = WeakBox(subject)

        return subject
            .handleEvents(receiveCancel: { [weak self] in
                self?.publishers.removeValue(forKey: key)
            })
            .share()
            .eraseToAnyPublisher()
    }

    func addInvoice(_ invoice: Invoice) async throws {
        container.mainContext.insert(invoice)
        try await saveContext()
    }

    func deleteInvoice(_ invoice: Invoice) async throws {
        container.mainContext.delete(invoice)
        try await saveContext()
    }

    func updateInvoice(_ invoice: Invoice, newDetails: [InvoiceDetail]) async throws {
        let removedDetails = invoice.details.filter { !newDetails.contains($0) }
        removedDetails.forEach { container.mainContext.delete($0) }

        invoice.details = newDetails

        try await saveContext()
    }
}
