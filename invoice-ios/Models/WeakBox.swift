//
//  WeakBox.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

class WeakBox<T: AnyObject> {
    var value: T?

    init(_ value: T? = nil) {
        self.value = value
    }
}
