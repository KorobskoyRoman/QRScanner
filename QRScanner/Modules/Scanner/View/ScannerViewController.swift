//
//  ScannerViewController.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import UIKit
import AVFoundation
import WebKit

protocol ScannerViewInput {
    func setupCamera()
    func setupOutputs()
    func setupVideoPreview()
}

final class ScannerViewController: UIViewController, ScannerViewInput {
    private var presenter: ScannerPresenterType
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let qrCodeFrameView = CodeFrameView()

    init(presenter: ScannerPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        presenter.viewDidLoad()
    }

    func setupCamera() {
        presenter.setupCamera(captureSession: captureSession)
    }

    func setupOutputs() {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
    }

    func setupVideoPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer ?? CALayer())
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            self.captureSession.startRunning()
        }
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }

        guard let metadataObj = metadataObjects[0]
                as? AVMetadataMachineReadableCodeObject else { return }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                presenter.open(url: metadataObj.stringValue ?? "")
                videoPreviewLayer?.session?.stopRunning()
            }
        }
    }
}
