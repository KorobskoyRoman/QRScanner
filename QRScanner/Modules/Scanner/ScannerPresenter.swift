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

    func push() {
//        coordinator?.performTransition(with: .perform())
    }
}
