//
//  PrizeDrawRecordRepository.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/23.
//

import Foundation
import SwiftData

protocol PrizeDrawRecordRepository {
    func fetchAllRecords() async throws -> [PrizeDrawRecord]
    func insertRecord(_ record: PrizeDrawRecord) async
}

@ModelActor
actor SwiftDataPrizeDrawRecordRepository: PrizeDrawRecordRepository {
    private var context: ModelContext { modelExecutor.modelContext }

    init(config: ModelConfiguration) {
        let container = try! ModelContainer(for: PrizeDrawRecord.self, configurations: config)
        let modelContext = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = container
        modelContext.autosaveEnabled = true
    }

    func fetchAllRecords() async throws -> [PrizeDrawRecord] {
        return try context.fetch(.init())
    }

    func insertRecord(_ record: PrizeDrawRecord) async {
        context.insert(record)
    }
}
