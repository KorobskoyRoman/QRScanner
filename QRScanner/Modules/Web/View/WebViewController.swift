//
//  WebViewController.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 07.10.2022.
//

import UIKit
import WebKit

protocol WebViewType {
    func startDownload()
    func showError()
    func getData(data: Data)
}

final class WebViewController: UIViewController {
    var presenter: WebPresenterType
    private var webView = WKWebView()

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()

    init(presenter: WebPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
        presenter.viewDidLoad()
    }

    private func setupView() {
        view = webView
        webView.navigationDelegate = self
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
    }

    private func setConstraints() {
        webView.addSubview(progressView)
        webView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 5)
        ])
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            print(progressView.progress)
        }
    }

    private func hideContent() {
        UIView.animate(withDuration: 0.3, delay: 1) {
            self.progressView.alpha = 0
            self.progressView.removeFromSuperview()
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        hideContent()
        presenter.getData()
    }
}

extension WebViewController: WebViewType {
    func showError() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            AlertView.showIn(viewController: self,
                             message: "Something wrong. Try again later")
        }
    }

    func getData(data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let activityView = UIActivityViewController(activityItems: [data], applicationActivities: nil)

            self.present(activityView, animated: true)
            activityView.completionWithItemsHandler  = { activity, success, items, error in
                if activity?.rawValue == "com.apple.DocumentManagerUICore.SaveToFiles" {
                    switch success {
                    case true:
                        AlertView.showIn(viewController: self,
                                         message: "Saved successfully")
                    case false:
                        self.showError()
                    }
                }
            }
        }
    }

    func startDownload() {
        presenter.startDownload(with: webView)
    }
}
