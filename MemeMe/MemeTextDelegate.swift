//
//  MemeTextDelegate.swift
//  MemeMe
//
//  Created by Austin Tooley on 10/22/16.
//  Copyright © 2016 Tooley. All rights reserved.
//

import Foundation
import UIKit

class MemeTextDelegate: NSObject, UITextFieldDelegate{
    
    // Clear text if default
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == "FRESHEST" || textField.text == "MEME") {
            textField.text = ""
            print("Clearing text field")
        } else {
            print("Did not clear text field")
        }
    }
    
    // Return hides keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
