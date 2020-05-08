//
//  ScannerViewController.swift
//  CodeScannerApp
//
//  Created by BrotherSoft on 27/04/2020.
//  Copyright © 2020 BrotherSoft. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
  
    var scannedCode: String?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        ScannerManager.sharedInstance.delegate = self
        ScannerManager.sharedInstance.startCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ScannerManager.sharedInstance.startCaptureSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ScannerManager.sharedInstance.stopCaptureSession()
    }
    
    //MARK: - UI & Action methods
    
    /// Configures the start UI
    func setupUI() {
        guard let previewLayer = ScannerManager.sharedInstance.previewLayer else { return }
               
        view.layer.addSublayer(previewLayer)
    }
    
    /// Present an alert when the scan is not supported
    func presentFailedAlert() {
        let alertViewController = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .destructive))
        
        present(alertViewController, animated: true)
    }
    
    /// Present an alert when the scan vas successfully, with the scanned code
    func presentSuccessAlert() {
        let alertViewController = UIAlertController(title: "Code scanned", message: scannedCode, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            ScannerManager.sharedInstance.startCaptureSession()
        }
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true)
    }
}

//MARK: - ScannerManagerDelegate methods

extension ScannerViewController: ScannerManagerDelegate {
    func scannerManager(_ scannerManager: ScannerManager, didScanCode code: String) {
        scannedCode = code
        presentSuccessAlert()
    }
    
    func scannerManagerDidFailToScan(_ scannermanager: ScannerManager) {
         presentFailedAlert()
    }
}
