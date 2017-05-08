//
//  advancedTesterVC.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-05-04.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class advancedTesterVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var initNetUrlTextField: UITextField!
    @IBOutlet weak var predictNetUrlTextField: UITextField!
    let imagePickerController = UIImagePickerController()
    var pickedImages = [UIImage]()
    let invalidModelName = "invalid"
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
        self.initNetUrlTextField.delegate = self
        self.predictNetUrlTextField.delegate = self
        self.registerForKeyboardNotifications()
        print("Initializing ...")
    }
    
    deinit {
        self.deregisterFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func downloadModelsFromUrlBtn(_ sender: UIButton) {
        let modelName = self.downloadModels()
        try! caffe.reloadModel(initNetNamed: "\(modelName)Init", predictNetNamed: "\(modelName)Predict")
        print("Switched the model to \(modelName)!")
    }
    
    @IBAction func uploadPhotoBtn(_ sender: UIButton) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func runBtn(_ sender: UIButton) {
        self.classifier(image: self.pickedImages[0])

    }
    
    func classifier(image: UIImage){
        let resizedImage = resizeImage(image: image, newWidth: CGFloat(500))
        if let result = caffe.prediction(regarding: resizedImage!){
            print("Result is \n\(result)")
            self.resultsTextView.text = "\(result)"
        }
        
    }
    
    func downloadModels() -> (String) {
        guard let initText = self.initNetUrlTextField.text, !initText.isEmpty else {
            return self.invalidModelName
        }
        guard let predictText = self.predictNetUrlTextField.text, !predictText.isEmpty else {
            return self.invalidModelName
        }
        // TODO: downloading process should be done here and need to make sure to rename them correctly
        
        let modelName = "stub"
        return modelName
        
    }
    
    // MARK: Image Picker Controller Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Remove previous images to save memory, or it might explode
        self.pickedImages.removeAll()
        if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.pickedImages.append(possibleImage)
            self.targetImageView.image = possibleImage
        } else {
            return
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Move keyboard view
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        print("registering")
        NotificationCenter.default.addObserver(self, selector: #selector(advancedTesterVC.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(advancedTesterVC.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        print("deregistering")
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        print("keyboard was shown")
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(65.0, 0.0, keyboardSize!.height + 10, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.scrollView.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil
        {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        print("keyboard will hide")
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(65.0, 0.0, -keyboardSize!.height - 10, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: Text field delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        activeField = nil
    }
}

