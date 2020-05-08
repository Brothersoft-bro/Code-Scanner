//
//  ScannerManager.swift
//  CodeScannerApp
//
//  Created by BrotherSoft on 06/05/2020.
//  Copyright © 2020 BrotherSoft. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol ScannerManagerDelegate: class {
    func scannerManager(_ scannerManager: ScannerManager, didScanCode code: String)
    func scannerManagerDidFailToScan(_ scannermanager: ScannerManager)
}

class ScannerManager: NSObject {
    typealias MetaDataType = [AVMetadataObject.ObjectType]
    
    static let sharedInstance = ScannerManager()
    
    weak var delegate: ScannerManagerDelegate?
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    private var captureSession: AVCaptureSession!
    private let scannerObjectTypes: MetaDataType = [.qr,
                                                    .code128,
                                                    .code39,
                                                    .code39Mod43,
                                                    .code93,
                                                    .ean13,
                                                    .ean8,
                                                    .interleaved2of5,
                                                    .itf14,
                                                    .pdf417,
                                                    .upce]
    
    private var scanningSupported = true
    
    //MARK: - Lifecycle methods
    
    /// Initializing all required properties to start the capture session
    private override init() {
        super.init()
        
        captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard
            let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput),
            captureSession.canAddOutput(metadataOutput) else {
                scanningSupported = false
                
                return
        }
        
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = scannerObjectTypes
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    //MARK: - Public methods
    
    /// Generatint the QR Code
    /// - Parameter text: The text to generate the QR code
    /// - Returns: The QR Code image
    public func generateQRCode(text: String) -> UIImage? {
        guard let qrFilter = CIFilter(name: Constants.ScannerKey.filterName) else { return nil}
        
        let data = text.data(using: String.Encoding.ascii)
        qrFilter.setValue(data, forKey: Constants.ScannerKey.inputMessage)
        
        guard let qrImage = qrFilter.outputImage else { return nil}
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil}
        let processedImage = UIImage(cgImage: cgImage)
        
        return processedImage
    }
    
    /// Starting to scan
    public func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        guard scanningSupported else {
            delegate?.scannerManagerDidFailToScan(self)
            
            return
        }
        
        captureSession.startRunning()
    }
    
    /// Stop scan
    public func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        
        captureSession.stopRunning()
    }
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate methods

extension ScannerManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        guard
            let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            var stringValue = readableObject.stringValue else {
                delegate?.scannerManagerDidFailToScan(self)
                
                return
        }
        stringValue = stringValue.replacingOccurrences(of: ";", with: " ")
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        delegate?.scannerManager(self, didScanCode: stringValue)
    }
}
