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

    var userName: String! //This will be passed to this VC when loading
    var userEmailLblText = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        userEmailLbl.text = userEmailLblText
        userEmailLbl.text = userName
    }

    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            dismiss(animated: true, completion: nil)
            print("User: \(FIRAuth.auth()?.currentUser?.email) signed out")
        } catch let error {
            print("Error: ", error)
        }
    }
    
    
}
