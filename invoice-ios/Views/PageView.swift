//
//  PageView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/23.
//

import SwiftUI
import UIKit

struct PageView<Page: View, T: Identifiable>: UIViewControllerRepresentable {
    private class ModelViewController: UIHostingController<Page?> {
        var id: T.ID?

        init(id: T.ID?, rootView: Page?) {
            self.id = id
            super.init(rootView: rootView)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
    }

    var data: [T]
    @Binding var currentID: T.ID?
    @ViewBuilder var pageBuilder: (T) -> Page
    let loadMore: () -> Void

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        let model = data.first(where: { $0.id == currentID })
        let hostingController = ModelViewController(id: currentID, rootView: model.map(pageBuilder))
        pageViewController.setViewControllers([hostingController], direction: .reverse, animated: false)
        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        context.coordinator.parent.data = self.data
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageView

        init(parent: PageView) {
            self.parent = parent
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            print(parent.data.count)
            guard
                let viewController = viewController as? ModelViewController,
                let index = parent.data.firstIndex(where: { $0.id == viewController.id })
            else {
                return nil
            }

            if index == parent.data.count - 2 {
                DispatchQueue.main.async {
                    self.parent.loadMore()
                }
            }

            let model = parent.data[index + 1]
            return ModelViewController(id: model.id, rootView: parent.pageBuilder(model))
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard
                let viewController = viewController as? ModelViewController,
                let index = parent.data.firstIndex(where: { $0.id == viewController.id }),
                index != 0
            else {
                return nil
            }
            let model = parent.data[index - 1]
            return ModelViewController(id: model.id, rootView: parent.pageBuilder(model))
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed,
                  let currentViewController = pageViewController.viewControllers?.first as? ModelViewController else {
                return
            }
            parent.currentID = currentViewController.id
        }
    }
}
