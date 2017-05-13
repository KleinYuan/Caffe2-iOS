//
//  advancedTesterVC.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-05-04.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class advancedTesterVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, URLSessionDownloadDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var modelNameTextField: UITextField!
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var initNetUrlTextField: UITextField!
    @IBOutlet weak var predictNetUrlTextField: UITextField!
    let imagePickerController = UIImagePickerController()
    var pickedImages = [UIImage]()
    var activeField: UITextField?
    let demoImage = UIImage(named: "panda.jpeg")
    var modelName = ""
    var downloadingInit = false
    var downloadingPredict = false
    var initNetFilePath = ""
    var predictNetFilePath = ""
    
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
        if self.downloadingPredict || self.downloadingInit {
            self.resultsTextView.text = "Downloading!!!!!!"
            return
        }
        let initText = self.initNetUrlTextField.text
        let predictText = self.predictNetUrlTextField.text
        let name = self.modelNameTextField.text
        if initText == "" || predictText == "" || name == "" {
            print("Must fill in all fields")
            return
        }
        self.modelName = self.modelNameTextField.text!
        self.downloadModelWith(url: initText!)
        self.downloadingInit = true
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
    
    func downloadModelWith(url: String) {
        let config = URLSessionConfiguration.background(withIdentifier: "Download init \(self.modelName)")
        if let url = NSURL(string: url) {
            
            // create session by instantiating with configuration and delegate
            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            
            let downloadTask = session.downloadTask(with: url as URL)
            self.resultsTextView.text = "Downloading started....."
            downloadTask.resume()
            
        }
//        let modelName = "stub"
//        return modelName
//        
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
    
    // MARK: download delegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var result = ""
        if self.downloadingInit {
            result = "Downloading init model \n"
        } else if self.downloadingPredict {
            result = "Downloading predict model \n"
        }
        print("did write data")
        print("\(totalBytesWritten)/\(totalBytesExpectedToWrite)")
        let perc : Int = Int(Double(totalBytesWritten * 100) / Double(totalBytesExpectedToWrite))
        result.append(String(perc) + "%" + " of \(totalBytesExpectedToWrite) bytes")
        self.resultsTextView.text = result
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        {
            // next we retrieve the suggested name for the file
            // now we can create the NSURL (including filename) - a file shouldn't already exist at this location
            var newLocation = NSURL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent(self.modelName + "Init.pb")
            if self.downloadingPredict {
                newLocation = NSURL(fileURLWithPath: documentsDirectoryPath).appendingPathComponent(self.modelName + "Predict.pb")
            }
            do {
                try FileManager.default.removeItem(at: newLocation!)
            } catch {
                print("error deleting file")
            }
            
            do {
                // now we attempt to move the file from its temporary download location to the required location
                try FileManager.default.moveItem(at: location, to: newLocation!)
                if self.downloadingInit {
                    self.downloadingInit = false
                    self.initNetFilePath = newLocation!.path
                    self.downloadModelWith(url: self.predictNetUrlTextField.text!)
                    self.downloadingPredict = true
                } else if self.downloadingPredict {
                    self.downloadingPredict = false
                    self.predictNetFilePath = newLocation!.path
                    self.resultsTextView.text = "Model \(self.modelName) downloaded"
                    do {
                        try caffe.loadDownloadedModel(initNetFilePath: self.initNetFilePath, predictNetFilePath: self.predictNetFilePath)
                        var downloadedModelNames : [String] = UserDefaults.standard.stringArray(forKey: kDownloadedModelNames) ?? []
                        var downloadedModelInitPaths : [String] = UserDefaults.standard.stringArray(forKey: kDownloadedModelInitPaths) ?? []
                        var downloadedModelPredictPaths : [String] = UserDefaults.standard.stringArray(forKey: kDownloadedModelPredictPaths) ?? []
                        
                        if let index = downloadedModelNames.index(of: self.modelName) {
                            downloadedModelNames.remove(at: index)
                            downloadedModelInitPaths.remove(at: index)
                            downloadedModelPredictPaths.remove(at: index)
                        }
                        downloadedModelNames.append(self.modelName)
                        downloadedModelInitPaths.append(self.initNetFilePath)
                        downloadedModelPredictPaths.append(self.predictNetFilePath)
                        UserDefaults.standard.setValue(downloadedModelNames, forKeyPath: kDownloadedModelNames)
                        UserDefaults.standard.setValue(downloadedModelInitPaths, forKeyPath: kDownloadedModelInitPaths)
                        UserDefaults.standard.setValue(downloadedModelPredictPaths, forKeyPath: kDownloadedModelPredictPaths)
                    } catch {
                        print("reload model failed")
                    }
                }
            }
            catch {
                print("error moving file")
            }
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.downloadingInit = false
            self.downloadingPredict = false
            self.resultsTextView.text = "Download completed with error" + error!.localizedDescription
        }
    }
}

