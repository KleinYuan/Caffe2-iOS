//
//  advancedTesterVC.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-05-04.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class advancedTesterVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var initNetUrlTextField: UITextField!
    @IBOutlet weak var predictNetUrlTextField: UITextField!
    let imagePickerController = UIImagePickerController()
    var pickedImages = [UIImage]()
    let invalidModelName = "invalid"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
        print("Initializing ...")
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
    
    @IBAction func loadModelsFromUrlBtn(_ sender: UIButton) {
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
    
}

