//
//  GenerateViewController.swift
//  CodeScannerApp
//
//  Created by BrotherSoft on 06/05/2020.
//  Copyright © 2020 BrotherSoft. All rights reserved.
//

import UIKit

class GenerateViewController: UIViewController {

    @IBOutlet weak var qrTextField: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var qrImageView: UIImageView!
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - UI & Action methods
    
    @IBAction func generateButtonTapped(_ sender: UIButton) {
        guard
            qrTextField.text?.count ?? 0 > 0,
            let image = ScannerManager.sharedInstance.generateQRCode(text: qrTextField.text ?? "") else { return }
        
        qrTextField.resignFirstResponder()
        qrImageView.image = image
    }
}

//MARK: - UITextFieldDelegate methods

extension GenerateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        generateButton.isEnabled = textField.text?.count ?? 0 > 0
        
        if textField.text?.count ?? 0 == 0 {
            qrImageView.image = nil
        }
    }
}
