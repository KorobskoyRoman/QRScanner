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
}

final class WebViewController: UIViewController {
    private let presenter: WebPresenterType
    private var webView = WKWebView()

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        return button
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
        view.backgroundColor = .red
        setupView()
        setConstraints()
        startDownload()
    }

    private func setupView() {
        view = webView
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
    }

    private func setConstraints() {
        webView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false

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
            print(progressView.progress) // Отследить прогресс
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = URL(string: presenter.urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                let activityView = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                self.present(activityView, animated: true)
                activityView.completionWithItemsHandler  = { activity, success, items, error in
                    if activity?.rawValue == "com.apple.DocumentManagerUICore.SaveToFiles" {
                        switch success {
                        case true:
                            AlertView.showIn(viewController: self, message: "Saved successfully")
                        case false:
                            AlertView.showIn(viewController: self, message: "Something wrong. Try again later")
                        }
                    }
                }
            }
        }.resume()
    }

    private func documentDirectory() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
}

extension WebViewController: WebViewType {
    func startDownload() {
        presenter.startDownload(with: webView)
    }
}
