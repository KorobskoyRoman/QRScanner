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
    func viewDidLoad()
    func startDownload(with webView: WKWebView)
    func getData()
}

final class WebPresenter: WebPresenterType {
    var urlString: String
    weak var view: WebViewController?

    init(urlString: String) {
        self.urlString = urlString
    }

    func viewDidLoad() {
        view?.startDownload()
    }

    func startDownload(with webView: WKWebView) {
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }

    func getData() {
        guard let url = URL(string: urlString) else { return }

        NetworkService.shared.getData(url: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                self.view?.getData(data: data)
            case .failure(let error):
                print(error)
                self.view?.showError()
            }
        }
    }
}
