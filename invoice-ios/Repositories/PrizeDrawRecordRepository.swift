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

actor SwiftDataPrizeDrawRecordRepository: PrizeDrawRecordRepository, Sendable, ModelActor {
    nonisolated let modelExecutor: any SwiftData.ModelExecutor
    nonisolated let modelContainer: SwiftData.ModelContainer
    private var context: ModelContext { modelExecutor.modelContext }

    init(modelContainer: SwiftData.ModelContainer) {
        let modelContext = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
        modelContext.autosaveEnabled = true
    }

    func fetchAllRecords() async throws -> [PrizeDrawRecord] {
        let fetchDescriptor = FetchDescriptor<PrizeDrawRecord>()

        return try context.fetch(fetchDescriptor)
    }

    func insertRecord(_ record: PrizeDrawRecord) async {
        context.insert(record)
    }
}
