//
//  MeVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import FirebaseAuth

class MeVC: UIViewController {

    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userPhotoImgView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserImage()
        setupUserEmailLbl()
    }
    
    func setupUserImage() {
        guard let firebaseUserPhotoURL = FIRAuth.auth()?.currentUser?.photoURL else {
            activityIndicator.isHidden = true
            print("User has no photo.")
            return }
        
        print("User photo URL: \(firebaseUserPhotoURL)")
        
        if FIRAuth.auth()?.currentUser?.photoURL != nil {
            
            // TODO: The firebaseUserPhotoURL contains a https URL with the user image. Convert URL to Image and put it in userPhotoImgView.
            
            
        }
    }
    
    fileprivate func setupUserEmailLbl() {
        
        guard let firebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        
        userEmailLbl.text = firebaseUserEmail
        
        if firebaseUserEmail.characters.count <= 19 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 20)
        } else if firebaseUserEmail.characters.count <= 24 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 17)
        } else {
            userEmailLbl.font = UIFont(name: "Avenir", size: 14)
        }
    }

    @IBAction func logOutPressed(_ sender: Any) {
        logOutAlert()
    }
    
    func logOutUser() {
        do {
            try FIRAuth.auth()?.signOut()
            dismiss(animated: true, completion: nil)
            print("User signed out")
        } catch let error {
            print("Error:", error)
        }
    }
    
    func logOutAlert() {
        let alert = UIAlertController(title: "Warning", message: "If you sign out, unsaved progress will be lost!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { (action) in
            self.logOutUser()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
}
