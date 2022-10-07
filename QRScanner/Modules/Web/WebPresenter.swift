//
//  WebPresenter.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 07.10.2022.
//

import Foundation
import WebKit

protocol WebPresenterType {
    var urlString: String { get set }
    var reload: (() -> Void)? { get set }
    func startDownload(with webView: WKWebView)
}

final class WebPresenter: WebPresenterType {
    var reload: (() -> Void)?
//    var urlString: String = ""
    var urlString: String = "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf"

    func startDownload(with webView: WKWebView) {
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }
}
