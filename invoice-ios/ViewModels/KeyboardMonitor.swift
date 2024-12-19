//
//  KeyboardMonitor.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/19.
//

import Foundation
import Combine
import UIKit

final class KeyboardMonitor: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
            .sink { _ in
                self.isKeyboardVisible = true
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
            .sink { _ in
                self.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
}
