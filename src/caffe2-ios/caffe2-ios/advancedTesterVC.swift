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
    @IBOutlet weak var modelNameTextField: UITextField!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var initNetUrlTextField: UITextField!
    @IBOutlet weak var predictNetUrlTextField: UITextField!
    let imagePickerController = UIImagePickerController()
    var pickedImages = [UIImage]()
    let invalidModelName = "invalid"
    var activeField: UITextField?
    let demoImage = UIImage(named: "panda.jpeg")
    var modelName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        self.targetImageView.image = self.demoImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
        self.modelNameTextField.delegate = self
        self.initNetUrlTextField.delegate = self
        self.predictNetUrlTextField.delegate = self
        self.registerForKeyboardNotifications()
    }
    
    deinit {
        self.deregisterFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pickedImages.append(self.demoImage!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func downloadModelsFromUrlBtn(_ sender: UIButton) {
        self.modelName = self.downloadModels()
        if self.modelName == self.invalidModelName {
            self.resultsTextView.text = "Some field is empty."
            return
        }
        try! caffe.reloadModel(initNetNamed: "\(modelName)Init", predictNetNamed: "\(modelName)Predict")
        print("Switched the model to \(modelName)!")
    }
    
    @IBAction func uploadPhotoBtn(_ sender: UIButton) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func runBtn(_ sender: UIButton) {
        if (self.modelName == "") {
            self.resultsTextView.text = "Please download model first"
            return
        }
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
        let initText = self.initNetUrlTextField.text
        let predictText = self.predictNetUrlTextField.text
        let name = self.modelNameTextField.text
        if initText == "" || predictText == "" || name == "" {
            return self.invalidModelName
        }
        // TODO: downloading process should be done here and need to make sure to rename them correctly
        
        let modelName = "stub"
        return modelName
        
    }
    
    // MARK: Image Picker Controller Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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

