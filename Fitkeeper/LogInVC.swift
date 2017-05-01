//
//  LogInVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFieldSettings()
    }

    func setupTextFieldSettings() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        logInUser()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField { passwordTextField.becomeFirstResponder() }
        else { logInUser() }
        return true
    }
    
    func logInUser() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let err = error {
                    self.createAlert(title: "Error", message: err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: SegueIdentifier.toMeVC, sender: self)
                print("User signed in with email:", email)
            })
        }
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        setupForgotPasswordView()
    }
    
    func setupForgotPasswordView() {
        let alertController = UIAlertController(title: "Forgot Password", message: "Enter your email.", preferredStyle: .alert)
        
        alertController.addTextField { (userEmailTextField) in
            userEmailTextField.placeholder = "johnsmith@gmail.com"
            userEmailTextField.keyboardType = .emailAddress
        }
        
        let yesAction = UIAlertAction(title: "Send email", style: .default) {
            UIAlertAction in
            
            if let alertTextField = alertController.textFields?.first, alertTextField.text != nil {

                FIRAuth.auth()?.sendPasswordReset(withEmail: alertTextField.text!, completion: { (error) in
                    if error != nil {
                        self.createAlert(title: "Error", message: (error?.localizedDescription)!)
                    }
                    self.createAlert(title: "Success", message: "Sent password reset to: \(alertTextField.text)")
                })
                
            }
        }
        
        let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            //Do you No button Stuff here, like dismissAlertView
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let id = segue.identifier else {
//            preconditionFailure("Segue should have a valid identifier")
//        }
        
        
    }
}
