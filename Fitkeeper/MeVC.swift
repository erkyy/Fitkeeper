//
//  MeVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RSKImageCropper

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userPhotoImgView: UIImageView!
    @IBOutlet weak var changeProfilePhotoBtn: UIButton!
    @IBOutlet weak var userEmailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userPhotoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailNotVerifiedLbl: UILabel!
    @IBOutlet weak var emailPopupTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserImage()
        setupUserEmailLbl()
        setupChangeProfilePictureButton()
        setupProfilePicture()
        setupVerificationPopup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupEmailVerificationSize()
    }
    
    func setupUserImage() {
        guard let firebaseUserPhotoURL = FIRAuth.auth()?.currentUser?.photoURL else {
            print("User has no Google Photo.")
            return }
        
        if FIRAuth.auth()?.currentUser?.photoURL != nil {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: firebaseUserPhotoURL)
                DispatchQueue.main.async {
                    self.userPhotoImgView.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func setupUserEmailLbl() {
        
        guard let firebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        
        userEmailLbl.text = firebaseUserEmail
        
        let characters = firebaseUserEmail.characters.count
        if characters <= 10 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 39)
        } else if characters <= 15 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 26)
        } else if characters <= 21 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 19)
        } else if characters <= 25 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 15)
        } else if characters <= 29 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 12)
        }
    }
    
    func setupEmailVerificationSize() {
    
        if (emailNotVerifiedLbl.text?.characters.count)! > 22 {
            emailNotVerifiedLbl.font = UIFont(name: "Avenir", size: 15)
        }
    }
    
    func setupVerificationPopup() {
        guard let FirebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        if FIRAuth.auth()?.currentUser?.isEmailVerified == false {
            print("User email is not verified.")
            emailNotVerifiedLbl.text = FirebaseUserEmail
            showVerifyEmailPopup()
        } else {
            print("User email is verified.")
            hideVerifyEmailPop()
        }
    }
    
    func showVerifyEmailPopup() {
        
        userPhotoTopConstraint.constant = 8
        userEmailTopConstraint.constant = 0
        emailPopupTopConstraint.constant = -45
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseIn, animations: { 
            self.userPhotoTopConstraint.constant = 50
            self.userEmailTopConstraint.constant = 42
            self.emailPopupTopConstraint.constant = 0
        }, completion: nil)
    }
    
    func hideVerifyEmailPop() {
        userPhotoTopConstraint.constant = 50
        userEmailTopConstraint.constant = 42
        emailPopupTopConstraint.constant = 0
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseIn, animations: {
            self.userPhotoTopConstraint.constant = 8
            self.userEmailTopConstraint.constant = 0
            self.emailPopupTopConstraint.constant = -45
        }, completion: nil)
    }
    
    func setupProfilePicture() {
        let FirebaseUID = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference(fromURL: "https://fitkeeper-af477.firebaseio.com/")
        
        ref.child("Users").child(FirebaseUID!).child("photoURL").observe(.value, with: { (snapshot) in
            
            guard let photoURLValue = snapshot.value else { return }
            let photoURLStr = String(describing: photoURLValue)
            guard let photoURL = URL(string: photoURLStr) else { return }
            
            DispatchQueue.global().async {
                let userImageData = try? Data(contentsOf: photoURL)
                DispatchQueue.main.async {
                    self.userPhotoImgView.image = UIImage(data: userImageData!)
                }
            }
        })
    }
    
    func setupChangeProfilePictureButton() {
        
        changeProfilePhotoBtn.isUserInteractionEnabled = false
        changeProfilePhotoBtn.isHidden = true
        
        guard (FIRAuth.auth()?.currentUser?.displayName) != nil else {
            changeProfilePhotoBtn.isHidden = false
            changeProfilePhotoBtn.isUserInteractionEnabled = true
            return
        }
    }

    @IBAction func sendVerificationEmailPressed(_ sender: UIButton) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil {
                print("Error: \(error)")
                self.errorAlert(message: (error?.localizedDescription)!)
                return
            }
            print("User received verification.")
            self.hideVerifyEmailPop()
        })
        
    }
        
    @IBAction func logOutPressed(_ sender: Any) {
        logOutAlert()
    }
    
    @IBAction func changeProfilePicturePressed(_ sender: Any) {
        changeProfilePictureMenu()
    }
    
    func changeProfilePictureMenu() {
        
        let changePhotoAlert = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .actionSheet)
        
        let removeCurrentPhoto = UIAlertAction(title: "Remove Current Photo", style: .destructive) { (action) in
            
            guard let FirebaseUID = FIRAuth.auth()?.currentUser?.uid else { return }
            
            let ref = FIRDatabase.database().reference(fromURL: "https://fitkeeper-af477.firebaseio.com/")
            ref.child("Users").child(FirebaseUID).child("photoURL").setValue(nil)
            
            self.userPhotoImgView.image = UIImage(named: "defaultphoto-img")
        }
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            //TODO : Present camera
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }
        
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if userPhotoImgView.image != UIImage(named: "defaultphoto-img") {
            changePhotoAlert.addAction(removeCurrentPhoto)
        }
        changePhotoAlert.addAction(takePhoto)
        changePhotoAlert.addAction(chooseFromLibrary)
        changePhotoAlert.addAction(Cancel)
        self.present(changePhotoAlert, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        deleteUserAlert()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            dismiss(animated: true, completion: nil)
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
            dismiss(animated: true, completion: nil)
        }
        
        if let selectedImage = selectedImageFromPicker {
            userPhotoImgView.image = selectedImage
        }
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("Profile-Photos").child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.userPhotoImgView.image!) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Error DB Storage: \(error?.localizedDescription)")
                    print("Error DB Storage Debug: \(error.debugDescription)")
                }
                
                guard let downloadURL = metadata?.downloadURL() else { return }
                let downloadURLStr = String(describing: downloadURL)
                guard let FirebaseUID = FIRAuth.auth()?.currentUser?.uid else { return }
                
                let ref = FIRDatabase.database().reference(fromURL: "https://fitkeeper-af477.firebaseio.com/")
                let usersRef = ref.child("Users").child(FirebaseUID)
                let values = ["photoURL": downloadURLStr]
                usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print("Error with Firebase Database: \(err)")
                    }
                        DispatchQueue.global().async {
                            let downloadURLData = try? Data(contentsOf: downloadURL)
                            DispatchQueue.main.async {
                                self.userPhotoImgView.image = UIImage(data: downloadURLData!)
                            }
                        }
                })
                print("User set profile picture.")
            })
        }
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
    
    func deleteUser() {
        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
            if error != nil {
                guard let errDescription = error?.localizedDescription else { return }
                self.errorAlert(message: errDescription)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUserAlert() {
        let alert = UIAlertController(title: "Warning", message: "If you delete your account, unsaved progress will be lost!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete account", style: .destructive, handler: { (action) in
            self.deleteUser()
        }))
        self.present(alert, animated: true, completion: nil)
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
