//
//  ViewController.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class staticDetectorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let foundNilErrorMsg = "[Error] Thrown"
    let testImg = "panda.jpeg"
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var imageDisplayer: UIImageView!
    @IBOutlet weak var resultDisplayer: UITextView!
    var pickedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    @IBAction func demoButton(_ sender: UIButton) {
        let demoImage = UIImage(named: testImg)!
        self.classifier(image: demoImage)
    }
    
    @IBAction func pickPhotoFromLibrary(_ sender: UIButton) {
        self.present(self.imagePickerController, animated: false, completion: nil)
    }
    
    func classifier(image: UIImage){
        self.imageDisplayer.image = image
        let resizedImage = self.resizeImage(image: image, newWidth: CGFloat(500))
        do{
            if let result = caffe.prediction(regarding: resizedImage!){
                let sorted = result.map{$0.floatValue}.enumerated().sorted(by: {$0.element > $1.element})[0...10]
                let finalResult = sorted.map{"\($0.element*100)% chance to be: \(classMapping[$0.offset]!)"}.joined(separator: "\n\n")
                
                print("Result is \n\(finalResult)")
                self.resultDisplayer.text = finalResult
            }
        } catch _ {
            print(self.foundNilErrorMsg, "classifier function went wrong")
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
    // MARK: Help functions
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

