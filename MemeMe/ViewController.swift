//
//  ViewController.swift
//  MemeMe
//
//  Created by Austin Tooley on 10/22/16.
//  Copyright © 2016 Tooley. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    let defaultTopText = "FRESHEST"
    let defaultBottomText = "MEME"
    
    let memeTextDelegate = MemeTextDelegate()
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white ,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ] as [String : Any]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        
        // Set delegates for text fields
        self.topTextField.delegate = self.memeTextDelegate
        self.bottomTextField.delegate = self.memeTextDelegate
        
        // Setup text fields
        configureTextFields(textField: topTextField)
        configureTextFields(textField: bottomTextField)
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
        
        // Hide camera button if device doesn't have camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        // Subscribe to keyboard notification
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func configureTextFields(textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = UITextBorderStyle.none
    }
    
    // Pop view controller
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    // MARK: Keyboard shifting
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // following suggestion found https://discussions.udacity.com/t/better-way-to-shift-the-view-for-keyboardwillshow-and-keyboardwillhide/36558
    func keyboardWillShow(notification: NSNotification) {
        if (bottomTextField.isFirstResponder) {
            if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
                toolBar.isHidden = true
                view.frame.origin.y =  getKeyboardHeight(notification: notification) * -0.9
            }
            else {
                view.frame.origin.y =  getKeyboardHeight(notification: notification) * -1
            }
        }
        else if (topTextField.isFirstResponder) {
            if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
                view.frame.origin.y =  getKeyboardHeight(notification: notification) * -0.2
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
            toolBar.isHidden = false
            view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: Getting a photo
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        memeImageView.image = image
        memeImageView.contentMode = .scaleAspectFit
        shareButton.isEnabled = true
            
        } else {
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    // Get photo from photo picker
    @IBAction func pickImageFromAlbum(_ sender: AnyObject) {
        pickAnImageFromSource(source: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    // Get photo from camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
             pickAnImageFromSource(source: UIImagePickerControllerSourceType.camera)
        }
    }
    
    // Pick from source
    func pickAnImageFromSource(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Memeing
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        // Generate meme
        let memedImage = [generateMemedImage()]
        
        // Define ActivityViewController
        let activityViewController = UIActivityViewController(activityItems: memedImage, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = {
            (s, ok, items, error) in
            if ok {
                // Save the meme
                self.save()
                // Pop view
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            }
        }
        
        // Present ActivityViewController
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func save() {
        //Create the meme
        print("Saving")
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImageView.image!, memedImage: generateMemedImage())
        
        // Add to memes array
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage
    {
        // Hide toolbar/navbar
        toggleBars(areBarsHidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar/navbar
        toggleBars(areBarsHidden: false)
        
        return memedImage
    }
    
    func toggleBars(areBarsHidden: Bool) {
        toolBar.isHidden = areBarsHidden
        self.navigationController?.isNavigationBarHidden = areBarsHidden
    }
}

