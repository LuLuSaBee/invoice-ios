//
//  TextFieldViewModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/18.
//

import Combine

class TextFieldViewModel<T>: ObservableObject {
    @Published var value: T
    @Published var errorMessage: String?

    private let validator: ((T) -> String?)?
    private var cancellables = Set<AnyCancellable>()

    init(initialValue: T, validator: ((T) -> String?)? = nil) {
        self.value = initialValue
        self.validator = validator

        $value
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.errorMessage = self.validator?(newValue)
            }
            .store(in: &cancellables)
    }
}
