//
//  PrizeDrawRecordProvider.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/24.
//

import Combine

protocol PrizeDrawRecordProvider {
    var recordPublisher: AnyPublisher<[PrizeDrawRecord], Never> { get }

    func insertRecord(_ record: PrizeDrawRecord)
}

class PrizeDrawRecordDataProvider: PrizeDrawRecordProvider {
    var recordPublisher: AnyPublisher<[PrizeDrawRecord], Never> {
        $records.eraseToAnyPublisher()
    }

    @Published private var records: [PrizeDrawRecord] = []

    private let repository: PrizeDrawRecordRepository

    init(repository: PrizeDrawRecordRepository) {
        self.repository = repository

        Task {
            do {
                self.records = try await repository.fetchAllRecords()
            } catch {
                print("Failed to fetch records: \(error)")
            }
        }
    }

    func insertRecord(_ record: PrizeDrawRecord) {
        self.records.append(record)
        Task {
            await repository.insertRecord(record)
        }
    }
}
