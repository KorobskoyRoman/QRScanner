//
//  AppCoordinator.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit

final class AppCoodrinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = getViewControllerByType(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    func performTransition(with type: Transition) {
        switch type {
        case .perform(let vc):
            let viewController = getViewControllerByType(type: vc)
            viewController.present(viewController, animated: true)
        case .pop(let vc):
            let viewController = getViewControllerByType(type: vc)
            viewController.dismiss(animated: true)
        }
    }

    private func getViewControllerByType(type: ViewControllers) -> UIViewController {
        var viewController: UIViewController

        switch type {
        case .main:
            let presenter = ScannerPresenter()
            viewController = ScannerViewController(presenter: presenter)
            return viewController
        }
    }
}
