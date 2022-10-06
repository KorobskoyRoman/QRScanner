//
//  AppCoodrinator.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit

protocol Coordinator {
    func start()
    func performTransition(with type: Transition)
}

enum Transition {
    case perform(ViewControllers)
    case pop(ViewControllers)
}

enum ViewControllers {
    case main

    var viewController: UIViewController {
        switch self {
        case .main:
            let presenter = ScannerPresenter()
            return ScannerViewController(presenter: presenter)
        }
    }
}
