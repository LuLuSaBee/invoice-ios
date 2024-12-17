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
    func addInvoice(_ invoice: Invoice)
    func deleteInvoice(_ invoice: Invoice)
    func updateInvoice(_ invoice: Invoice)
}

final class InvoiceManager: InvoiceServiceable {
    static let shared = InvoiceManager()

    private let container: ModelContainer
    private var cancellables = Set<AnyCancellable>()
    private var publishers: [String: WeakBox<CurrentValueSubject<[Invoice],Never>>] = [:]

    private init() {
        do {
            container = try ModelContainer(for: Invoice.self, InvoiceDetail.self)
            setupContextListener()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        let context = container.mainContext
        let existingInvoices = try? context.fetch(FetchDescriptor<Invoice>())
        if existingInvoices?.isEmpty ?? true {
            Invoice.sampleData.forEach { context.insert($0) }
            do {
                try context.save()
            } catch {
                fatalError("Could not save sample data: \(error)")
            }
        }
    }

    // MARK: - Listen Context Change
    private func setupContextListener() {
        NotificationCenter.default.publisher(for: ModelContext.didSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.notifyAllPublishers()
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

    private func saveContext() {
        do {
            try container.mainContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        notifyAllPublishers()
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

    func addInvoice(_ invoice: Invoice) {
        container.mainContext.insert(invoice)
        saveContext()
    }

    func deleteInvoice(_ invoice: Invoice) {
        container.mainContext.delete(invoice)
        saveContext()
    }

    func updateInvoice(_ invoice: Invoice) {
        saveContext()
    }
}
