//
//  ChangePasswordController.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/16/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class ChangePasswordController: UIViewController {

    //IBOutlet connections
    @IBOutlet weak var ChangeErrorLabel: UILabel!
    @IBOutlet weak var OldPasswordField: UITextField!
    @IBOutlet weak var ChangePasswordField: UITextField!
    @IBOutlet weak var ChangePasswordConfirmField: UITextField!
    // Load Screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make password fields hidden
        OldPasswordField.isSecureTextEntry = true
        ChangePasswordField.isSecureTextEntry = true
        ChangePasswordConfirmField.isSecureTextEntry = true
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
    
    // Sign up Segue
    @IBAction func Continue(_ sender: Any) {
        let realPass: String! = UserDefaults.standard.string(forKey: "User")
        if (realPass != OldPasswordField.text) {
            ChangeErrorLabel.text = "Old password is incorrect."
        }
        else if (ChangePasswordField.text != ChangePasswordConfirmField.text) {
            ChangeErrorLabel.text = "New passwords do not match."
        }
        else {
            UserDefaults.standard.set(ChangePasswordField.text as String?, forKey: "User")
            performSegue(withIdentifier: "ChangePassword", sender: sender)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Memory warnings
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


