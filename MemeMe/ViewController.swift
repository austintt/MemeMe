//
//  ViewController.swift
//  MemeMe
//
//  Created by Austin Tooley on 10/22/16.
//  Copyright © 2016 Tooley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
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
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "FRESHEST"
        topTextField.textAlignment = .center
        topTextField.backgroundColor = UIColor.clear
        topTextField.borderStyle = UITextBorderStyle.none
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "MEME"
        bottomTextField.textAlignment = .center
        bottomTextField.backgroundColor = UIColor.clear
        bottomTextField.borderStyle = UITextBorderStyle.none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide camera button if device doesn't have camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        // Subscribe to keyboard notification
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard shifting
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y =  getKeyboardHeight(notification: notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = 0
        }
        
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
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Get photo from camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
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
            self.save()
        }
        
        // Pass meme to ActivityViewController
        
        // Present ActivityViewController
        self.present(activityViewController, animated: true, completion: nil)
    
    }
    
    func save() {
        //Create the meme
        print("Saving")
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImageView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage
    {
        // TODO: Hide toolbar/navbar
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar/navbar
        
        return memedImage
    }

    func completeSharing(activityType:String!, completed:Bool, items:[AnyObject]!, error:NSError!){
        save()
        self.dismiss(animated: true, completion: nil)
    }

}

