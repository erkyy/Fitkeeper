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

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userPhotoImgView: UIImageView!
    @IBOutlet weak var changeProfilePhotoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserImage()
        setupUserEmailLbl()
        setupChangeProfilePictureButton()
        
        //In Firebase Database: If User UID has a child with photoURL: Set that URL to display in the image.
        
        let FirebaseUID = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference(fromURL: "https://fitkeeper-af477.firebaseio.com/")
        let usersRef = ref.child("Users").child(FirebaseUID!).child("photoURL")
        
        
    }
    
    func setupChangeProfilePictureButton() {
        
        changeProfilePhotoBtn.isUserInteractionEnabled = false
        changeProfilePhotoBtn.isHidden = true
        
        guard (FIRAuth.auth()?.currentUser?.displayName) != nil else {
            changeProfilePhotoBtn.isHidden = false
            changeProfilePhotoBtn.isUserInteractionEnabled = true
            return }
    }

    @IBAction func logOutPressed(_ sender: Any) {
        logOutAlert()
    }
    
    @IBAction func changeProfilePicturePressed(_ sender: Any) {
        changeProfilePictureMenu()
    }
    
    func changeProfilePictureMenu() {
        
        let changePhotoAlert = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            //TODO : Present camera
            
        }
        
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .default) { (action) in
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            
            self.present(picker, animated: true, completion: nil)
        }
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        changePhotoAlert.addAction(takePhoto)
        changePhotoAlert.addAction(chooseFromLibrary)
        changePhotoAlert.addAction(Cancel)
        self.present(changePhotoAlert, animated: true, completion: nil)
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
                
                print("User: \(FirebaseUID)")
                
                print("User profile picture URL: \(downloadURL)")
                
                
                
            })
        }
        
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
    
    fileprivate func setupUserEmailLbl() {
        
        guard let firebaseUserEmail = FIRAuth.auth()?.currentUser?.email else { return }
        
        userEmailLbl.text = firebaseUserEmail
        
        if firebaseUserEmail.characters.count <= 18 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 20)
        } else if firebaseUserEmail.characters.count <= 23 {
            userEmailLbl.font = UIFont(name: "Avenir", size: 17)
        } else {
            userEmailLbl.font = UIFont(name: "Avenir", size: 14)
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
