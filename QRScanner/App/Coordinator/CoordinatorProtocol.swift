//
//  AppCoodrinator.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit

protocol Coordinator {
    func start()
    func performTransition(with type: Transition, url: String)
}

enum Transition {
    case perform(ViewControllers)
    case pop(ViewControllers)
}

enum ViewControllers {
    case main
    case web

    var viewController: UIViewController {
        switch self {
        case .main:
            let presenter = ScannerPresenter()
            return ScannerViewController(presenter: presenter)
        case .web:
            let presenter = WebPresenter(urlString: "")
            return WebViewController(presenter: presenter)
        }
    }
}
