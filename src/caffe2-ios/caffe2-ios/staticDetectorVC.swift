//
//  ViewController.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class staticDetectorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var modelPickerView: UIPickerView!
    let foundNilErrorMsg = "[Error] Thrown"
    let demoImg = UIImage(named:"panda.jpeg")
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var imageDisplayer: UIImageView!
    @IBOutlet weak var resultDisplayer: UITextView!
    var pickedImages = [UIImage]()
    var allModels : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
        self.allModels = builtInModels
        self.allModels.append(contentsOf: downloadedModels)
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        self.modelPickerView.delegate = self
        self.modelPickerView.dataSource = self
        self.imageDisplayer.image = self.demoImg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.allModels = builtInModels
        self.allModels.append(contentsOf: downloadedModels)
        self.modelPickerView.reloadAllComponents()
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    @IBAction func demoButton(_ sender: UIButton) {
        self.classifier(image: demoImg!)
    }
    
    @IBAction func pickPhotoFromLibrary(_ sender: UIButton) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func reloadModel(_ sender: UIButton) {
        try! caffe.reloadModel(initNetNamed: "\(modelPicked)Init", predictNetNamed: "\(modelPicked)Predict")
        print("Switched the model to \(modelPicked)!")
    }
    func classifier(image: UIImage){
        self.imageDisplayer.image = image
        let resizedImage = resizeImage(image: image, newWidth: CGFloat(500))
        if let result = caffe.prediction(regarding: resizedImage!){
            switch modelPicked {
            case "squeezeNet":
                let sorted = result.map{$0.floatValue}.enumerated().sorted(by: {$0.element > $1.element})[0...10]
                let finalResult = sorted.map{"\($0.element*100)% chance to be: \(squeezenetClassMapping[$0.offset]!)"}.joined(separator: "\n\n")
                
                print("Result is \n\(finalResult)")
                self.resultDisplayer.text = finalResult
            default:
                print("Result is \n\(result)")
                self.resultDisplayer.text = "\(result)"
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Image Picker Controller Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Remove previous images to save memory, or it might explode
        self.pickedImages.removeAll()
        if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.pickedImages.append(possibleImage)
        } else {
            return
        }
        self.classifier(image: self.pickedImages[0])
        dismiss(animated: true, completion: nil)
    }

    // MARK: PickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.allModels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.allModels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row < builtInModels.count {
            return NSAttributedString(string: self.allModels[row], attributes: [NSForegroundColorAttributeName : UIColor.green])
        }
        return NSAttributedString(string: self.allModels[row], attributes: [NSForegroundColorAttributeName : UIColor.blue])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        modelPicked = self.allModels[row]
        print("\(allModels[row]) is chosen")
    }
}

