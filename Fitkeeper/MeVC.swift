//
//  MeVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-26.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userPhotoImgView: UIImageView!
    @IBOutlet weak var changeProfilePhotoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserImage()
        setupUserEmailLbl()
        setupChangeProfilePictureButton()
        
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
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            self.present(camera, animated: true, completion: nil)
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
        
    }
    
    func setupUserImage() {
        guard let firebaseUserPhotoURL = FIRAuth.auth()?.currentUser?.photoURL else {
            print("Nil - User has no photo.")
            return }
        
        print("User photo URL: \(firebaseUserPhotoURL)")
        
        if FIRAuth.auth()?.currentUser?.photoURL != nil {
            print("User has a photo")
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
