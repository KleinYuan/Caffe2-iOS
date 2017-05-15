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
    @IBOutlet weak var deleteModelButtonDisplay: UIButton!
    var pickedImages = [UIImage]()
    var downloadedModelNames : [String] = []
    var downloadedModelInitPaths : [String] = []
    var downloadedModelPredictPaths : [String] = []
    
    var didPickDownloaded = false
    var pickedDownloadedModelIndex = 0
    var elapse = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
        self._reloadModels()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        self.modelPickerView.delegate = self
        self.modelPickerView.dataSource = self
        self.imageDisplayer.image = self.demoImg
        self.deleteModelButtonDisplay.isEnabled = false
        self.deleteModelButtonDisplay.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self._reloadModels()
        self.modelPickerView.reloadAllComponents()
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    @IBAction func deleteModelButton(_ sender: UIButton) {
        if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first{
            var locationToBeDeleted = NSURL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("\(modelPicked)Predict.pb")
            do {
                try FileManager.default.removeItem(at: locationToBeDeleted!)
                UserDefaults.standard.removeObject(forKey: kDownloadedModelPredictPaths)
                print("\(modelPicked)Predict.pb deleted")
            } catch {
                print("error deleting \(modelPicked)Predict.pb ")
            }
            
            locationToBeDeleted = NSURL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent("\(modelPicked)Init.pb")
            do {
                try FileManager.default.removeItem(at: locationToBeDeleted!)
                UserDefaults.standard.removeObject(forKey: kDownloadedModelInitPaths)
                print("\(modelPicked)Init.pb deleted")
            } catch {
                print("error deleting \(modelPicked)Init.pb ")
            }
            UserDefaults.standard.removeObject(forKey: kDownloadedModelNames)
        }
        self._reloadModels()
        self.modelPickerView.reloadAllComponents()
        
    }
    @IBAction func demoButton(_ sender: UIButton) {
        self.classifier(image: demoImg!)
    }
    
    @IBAction func pickPhotoFromLibrary(_ sender: UIButton) {
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func reloadModel(_ sender: UIButton) {
        if self.didPickDownloaded {
            try! caffe.loadDownloadedModel(initNetFilePath: self.downloadedModelInitPaths[self.pickedDownloadedModelIndex],
                                           predictNetFilePath: self.downloadedModelPredictPaths[self.pickedDownloadedModelIndex])
        } else {
            try! caffe.reloadModel(initNetNamed: "\(modelPicked)Init", predictNetNamed: "\(modelPicked)Predict")
        }
        print("Switched the model to \(modelPicked)!")
    }
    func classifier(image: UIImage){
        let start = CACurrentMediaTime()
        self.imageDisplayer.image = image
        let resizedImage = resizeImage(image: image, newWidth: CGFloat(500))
        if let result = caffe.prediction(regarding: resizedImage!){
            let end = CACurrentMediaTime()
            self.elapse = "\(end - start) seconds"
            
            switch modelPicked {
            case "squeezeNet":
                let sorted = result.map{$0.floatValue}.enumerated().sorted(by: {$0.element > $1.element})[0...10]
                let finalResult = sorted.map{"\($0.element*100)% chance to be: \(squeezenetClassMapping[$0.offset]!)"}.joined(separator: "\n\n")
                
                self.resultDisplayer.text = "Time consumption: \n\(self.elapse)\n \nResults: \n\(finalResult)"
                print("Result is \n\(finalResult)")
            default:
                print("Result is \n\(result)")
                self.resultDisplayer.text = "Time consumption: \n\(self.elapse)\n \nResults: \n\(result)"
            }
            print("Time consumption: \(self.elapse)")
            
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
        return builtInModels.count + self.downloadedModelNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < builtInModels.count {
            return builtInModels[row]
        } else {
            return self.downloadedModelNames[row - builtInModels.count]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row < builtInModels.count {
            return NSAttributedString(string: builtInModels[row], attributes: [NSForegroundColorAttributeName : UIColor.green])
        }
        return NSAttributedString(string: self.downloadedModelNames[row - builtInModels.count], attributes: [NSForegroundColorAttributeName : UIColor.blue])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < builtInModels.count {
            modelPicked = builtInModels[row]
            self.didPickDownloaded = false
            print("built in model chosen")
            self.deleteModelButtonDisplay.isEnabled = false
            self.deleteModelButtonDisplay.alpha = 0.5
        } else {
            self.pickedDownloadedModelIndex = row - builtInModels.count
            self.didPickDownloaded = true
            modelPicked = self.downloadedModelNames[self.pickedDownloadedModelIndex]
            print("downloaded in model chosen")
            self.deleteModelButtonDisplay.isEnabled = true
            self.deleteModelButtonDisplay.alpha = 1.0
        }
        print("\(modelPicked) is chosen")
    }
    
    private func _reloadModels() {
        self.downloadedModelNames = UserDefaults.standard.stringArray(forKey: kDownloadedModelNames) ?? []
        self.downloadedModelInitPaths = UserDefaults.standard.stringArray(forKey: kDownloadedModelInitPaths) ?? []
        self.downloadedModelPredictPaths = UserDefaults.standard.stringArray(forKey: kDownloadedModelPredictPaths) ?? []
    }
}

