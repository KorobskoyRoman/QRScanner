//
//  CodeFrameView.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit

final class CodeFrameView: UIView {
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = self.frame.height / 10
    }
}
