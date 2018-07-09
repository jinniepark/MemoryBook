//
//  SignupController.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/14/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class SignupController: UIViewController {
    
    //IBOutlet connections
    @IBOutlet weak var SignupErrorLabel: UILabel!
    @IBOutlet weak var SignupPasswordField: UITextField!
    @IBOutlet weak var SignupPasswordConfirmField: UITextField!
    
    // Load Screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make password fields hidden
        SignupPasswordField.isSecureTextEntry = true
        SignupPasswordConfirmField.isSecureTextEntry = true
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
         view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
    override func viewDidAppear(_ animated: Bool) {
        view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    }
    // Sign up Segue
    @IBAction func Continue(_ sender: Any) {
        if (SignupPasswordField.text != SignupPasswordConfirmField.text) {
            SignupErrorLabel.text = "Passwords do not match"
        }
        else {
            UserDefaults.standard.set(SignupPasswordField.text as String?, forKey: "User")
            performSegue(withIdentifier: "Signup", sender: sender)
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

