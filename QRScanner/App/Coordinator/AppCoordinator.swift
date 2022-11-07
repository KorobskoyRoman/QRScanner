//
//  AppCoordinator.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = getViewControllerByType(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    func performTransition(with type: Transition,
                           url: String = "") {
        switch type {
        case .perform(let vc):
            let viewController = getViewControllerByType(type: vc)

            if let controller = viewController as? WebViewController {
                controller.presenter.urlString = url
            }

            viewController.modalPresentationStyle = .fullScreen
            window.rootViewController?.present(viewController, animated: true)
        case .pop(let vc):
            let viewController = getViewControllerByType(type: vc)
            viewController.dismiss(animated: true)
        }
    }

    private func getViewControllerByType(
        type: ViewControllers,
        url: String = ""
    ) -> UIViewController {
        var viewController: UIViewController

        switch type {
        case .main:
            let presenter = ScannerPresenter()
            presenter.coordinator = self
            viewController = ScannerViewController(presenter: presenter)
            presenter.view = viewController as? ScannerViewController
            return viewController
        case .web:
            let presenter = WebPresenter(urlString: url)
            viewController = WebViewController(presenter: presenter)
            presenter.view = viewController as? WebViewController
            return viewController
        }
    }
}
