//
//  realTimeDetector.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-29.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//


import UIKit
import AVFoundation

class realTimeDetectorVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let predictNetName = "predict_net"
    let initNetNamed = "exec_net"
    let foundNilErrorMsg = "[Error] Thrown \n"
    let processingErrorMsg = "[Error] Processing Error \n"
    var result = ""
    @IBOutlet weak var resultDisplayer: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCameraSession()
        print("Initializing ...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.addSublayer(previewLayer)
        self.view.addSubview(self.resultDisplayer)
        self.view.bringSubview(toFront: self.resultDisplayer)
        cameraSession.startRunning()
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    
    func classifier(img: UIImage){
        do{
            let caffe = try Caffe2(initNetNamed: self.initNetNamed, predictNetNamed: self.predictNetName)
            if let result = caffe.prediction(regarding: img){
                let sorted = result.map{$0.floatValue}.enumerated().sorted(by: {$0.element > $1.element})[0...10]
                let finalResult = sorted.map{"\($0.element*100)% chance to be: \(classMapping[$0.offset]!)"}.joined(separator: "\n\n")
                
                print("Result is \n\(finalResult)")
                self.result = finalResult
            }
        } catch _ {
            print(self.foundNilErrorMsg, "classifier function went wrong")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetLow
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    
    
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let img = sampleBuffer.image()
        do {
            self.classifier(img: img!)
           
        } catch _ {
            print(self.processingErrorMsg)
        }
        // Force UI work to be done in main thread
        DispatchQueue.main.async(execute: {
            self.resultDisplayer.text = self.result
        })
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
    
    
}

extension CMSampleBuffer {
    func image(orientation: UIImageOrientation = .up, scale: CGFloat = 1.0) -> UIImage? {
        guard let buffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        let image = UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        
        let resizedImg = resizeImage(image: image, widthRatio: CGFloat(2.0), heightRatio: CGFloat(2.0))
        
        return resizedImg
    }
    
    func resizeImage(image: UIImage, widthRatio: CGFloat, heightRatio: CGFloat) -> UIImage {
        let size = image.size
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

