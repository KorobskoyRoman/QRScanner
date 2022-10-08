//
//  AlertView.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 08.10.2022.
//

import UIKit

final class AlertView: UIView {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!

    private static var sharedView: AlertView!

    static func loadFromNib() -> AlertView {
        let nibName = "\(self)".split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! AlertView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = frame.size.height / 4
        self.layer.cornerRadius = cornerRadius
    }

    static func showIn(viewController: UIViewController,
                       message: String) {

        var displayVC = viewController

        if let tabController = viewController as? UITabBarController {
            displayVC = tabController.selectedViewController ?? viewController
        }

        if sharedView == nil {
            sharedView = loadFromNib()

            sharedView.layer.masksToBounds = false
            sharedView.layer.shadowColor = UIColor.darkGray.cgColor
            sharedView.layer.shadowOpacity = 1
            sharedView.layer.shadowOffset = CGSize(width: 0, height: 3)
        }

        sharedView.textLabel.text = message

        if sharedView?.superview == nil {
            let y = displayVC.view.frame.height - sharedView.frame.size.height - 30
            sharedView.frame = CGRect(x: 12, y: y, width: displayVC.view.frame.size.width - 24, height: sharedView.frame.size.height)
            sharedView.alpha = 0.0

            displayVC.view.addSubview(sharedView)
            sharedView.fadeIn()
            sharedView.perform(#selector(fadeOut), with: nil, afterDelay: 3.0)
        }
    }

    @IBAction
    private func closePressed(_ sender: UIButton) {
        fadeOut()
    }

    private func fadeIn() {
        UIView.animate(withDuration: 0.33, animations: {
            self.alpha = 1.0
        })
    }

    @objc
    private func fadeOut() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        UIView.animate(withDuration: 0.33, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

