//
//  LoginController.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/14/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SQLite3

import MobileCoreServices

class LoginController: UIViewController {
    
    //IBOutlet connections
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var PasswordField: UITextField!
    
    // Load screen
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make passwords hidden
        PasswordField.isSecureTextEntry = true
        view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]

    }
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
    
    // Load Signup view if the user has not made a password yet.
    override func viewDidAppear(_ animated: Bool) {
        view.autoresizingMask = [ .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]

       // self.view.frame = self.view.bounds;

        let realPass: String! = UserDefaults.standard.string(forKey: "User")
        if (realPass == nil) {
            self.performSegue(withIdentifier: "First", sender: nil)
        }
    }
    
    // Login segue
    @IBAction func ContinueAction(_ sender: UIButton) {
        let realPass: String! = UserDefaults.standard.string(forKey: "User")
        if (realPass == nil) {
            ErrorLabel.text = "No password has been set yet."
            self.performSegue(withIdentifier: "First", sender: sender)
        }
        else {
            if realPass != PasswordField.text {
                ErrorLabel.text = "Password is incorrect."
            }
            else {
                performSegue(withIdentifier: "Login", sender: sender)
            }
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

