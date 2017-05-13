//
//  advancedTesterVC.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-05-04.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class advancedTesterVC: UIViewController,UINavigationControllerDelegate, URLSessionDownloadDelegate {
    


    @IBOutlet weak var downloadProgressResult: UILabel!
    @IBOutlet weak var modelNameTextField: UITextField!
    @IBOutlet weak var initNetUrlTextField: UITextField!
    @IBOutlet weak var predictNetUrlTextField: UITextField!
    var activeField: UITextField?
    var modelName = ""
    var downloadingInit = false
    var downloadingPredict = false
    var initNetFilePath = ""
    var predictNetFilePath = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
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
        if self.downloadingPredict || self.downloadingInit {
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
    
    
    func downloadModelWith(url: String) {
        let config = URLSessionConfiguration.background(withIdentifier: "Download init \(self.modelName)")
        if let url = NSURL(string: url) {
            session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            let downloadTask = session.downloadTask(with: url as URL)
            downloadTask.resume()
            
        }
    }
    
    
    // MARK: download delegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var result = ""
        print("did write data")
        print("\(totalBytesWritten)/\(totalBytesExpectedToWrite)")
        let perc : Int = Int(Double(totalBytesWritten * 100) / Double(totalBytesExpectedToWrite))
        result = String(perc) + "%" + " of \(totalBytesExpectedToWrite) bytes"
        self.downloadProgressResult.text = result
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
            self.downloadProgressResult.text = "Error" + error!.localizedDescription
        }
    }
}

