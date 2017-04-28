//
//  WelcomeVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class WelcomeVC: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

        setupGoogleButton()


    }

    override func viewDidAppear(_ animated: Bool) {
        guard let FirebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        if FIRAuth.auth()?.currentUser != nil {
            print("User is signed in.")
            print("User email: ", FirebaseUserEmail)
            performSegue(withIdentifier: SegueIdentifier.toMeVC, sender: self)
        }
    }

    @IBAction func createAccountPressed(_ sender: Any) {
        createUser()
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField { passwordTextField.becomeFirstResponder() }
        else { createUser() }
        return true
    }

    func createUser() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let createUserError = error {
                    self.createAlert(title: "Error", message: createUserError.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "toMeVC", sender: self)
                print("User did sign up.")
                print("User email: ", email)
            })
        }
    }

    @IBAction func userHasAccountPressed(_ sender: Any) {
        performSegue(withIdentifier: "toLogInVC", sender: self)
    }

    //Here is how you pass data between VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            preconditionFailure("Segue should have a valid identifier")
        }

        if id == SegueIdentifier.toMeVC {
            guard let newVC = segue.destination as? MeVC, let username = FIRAuth.auth()?.currentUser?.email else {
                print("Invalid Target VC")
                return
            }
            newVC.userName = username
        }
    }
}
