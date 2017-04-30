//
//  RoundButton.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-04-30.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor as! CGColor?
        }
    }

}
