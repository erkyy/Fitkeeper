//
//  WelcomeVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

class WelcomeVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldSettings()

        setupGoogleButton()

    }

    override func viewDidAppear(_ animated: Bool) {
        
        guard let FirebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        
        if FIRAuth.auth()?.currentUser != nil {
            
            performSegue(withIdentifier: SegueIdentifier.toMeVC, sender: FirebaseUserEmail)
            print("User is already signed in with email: \(FirebaseUserEmail)")
        }
    }

    @IBAction func createAccountPressed(_ sender: Any) {
        if (emailTextField.text?.characters.count)! <= 30 {
            createUser()
        } else {
            createAlert(title: "Error", message: "Email address is too long")
        }
    }

    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func setupGoogleButton() {
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.colorScheme = .light
        googleSignInButton.style = .wide
    }

    func textFieldSettings() {
        
        emailTextField.delegate = self
        emailTextField.text = ""
        passwordTextField.delegate = self
        passwordTextField.text = ""
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == emailTextField { passwordTextField.becomeFirstResponder() }
            else { createUser() }
            return true
        }
    }

    func createUser() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let createUserError = error {
                    self.createAlert(title: "Error", message: createUserError.localizedDescription)
                    return
                }
                
                guard let uid = user?.uid else { return }
                let ref = FIRDatabase.database().reference(fromURL: "https://fitkeeper-af477.firebaseio.com/")
                let usersRef = ref.child("Users").child(uid)
                
                let values = ["email": email, "password": password]
                usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print("Error with Firebase Database: \(err)")
                    }
                })
                
                self.performSegue(withIdentifier: SegueIdentifier.toMeVC, sender: email)
                print("User signed up with email:", email)
            })
        }
    }

    @IBAction func userHasAccountPressed(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifier.toLogInVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
}
