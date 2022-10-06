//
//  ScannerPresenter.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 06.10.2022.
//

import AVFoundation // зависимость
import UIKit // зависимость от UIKit - плохо

protocol ScannerPresenterType {
    func setupCamera(captureSession: AVCaptureSession)
    func setupOutputs(captureSession: AVCaptureSession,
                      delegate: UIViewController)
    func setupVideoPreview(videoPreviewLayer: AVCaptureVideoPreviewLayer?,
                           captureSession: AVCaptureSession,
                           delegate: UIViewController,
                           qrCodeFrameView: CodeFrameView)
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection,
                        videoPreviewLayer: AVCaptureVideoPreviewLayer?,
                        qrCodeFrameView: CodeFrameView)
    func push()
}

final class ScannerPresenter: ScannerPresenterType {
    weak var coordinator: AppCoodrinator?

    func setupCamera(captureSession: AVCaptureSession) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print(error)
            return
        }
    }

    func setupOutputs(captureSession: AVCaptureSession,
                      delegate: UIViewController) {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(delegate as? AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
//        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
    }

    func setupVideoPreview(videoPreviewLayer: AVCaptureVideoPreviewLayer?,
                           captureSession: AVCaptureSession,
                           delegate: UIViewController,
                           qrCodeFrameView: CodeFrameView) {
        var videoPreviewLayer = videoPreviewLayer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = delegate.view.layer.bounds
        delegate.view.layer.addSublayer(videoPreviewLayer ?? CALayer())
        delegate.view.addSubview(qrCodeFrameView)
        delegate.view.bringSubviewToFront(qrCodeFrameView)

        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }

    func push() {
//        coordinator?.performTransition(with: .perform())
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection,
                        videoPreviewLayer: AVCaptureVideoPreviewLayer?,
                        qrCodeFrameView: CodeFrameView) {
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }

        guard let metadataObj = metadataObjects[0]
                as? AVMetadataMachineReadableCodeObject else { return }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView.frame = barCodeObject?.bounds ?? CGRect()

            if metadataObj.stringValue != nil {
                print(metadataObj.stringValue)
                // push
//                let webView = WKWebView()
//                let url = URL(string: metadataObj.stringValue ?? "")
//                webView.load(URLRequest(url: url!))
//                webView.allowsBackForwardNavigationGestures = true
            }
        }
    }
}
