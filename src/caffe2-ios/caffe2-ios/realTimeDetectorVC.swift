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
    
    let foundNilErrorMsg = "[Error] Thrown \n"
    let processingErrorMsg = "[Error] Processing Error \n"
    var result = ""
    var memUsage = 0 as Float
    var elapse = ""
    
    @IBOutlet weak var resultDisplayer: UITextView!
    @IBOutlet weak var memUsageDisplayer: UITextView!
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCameraSession()
        print("Initializing ...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.addSublayer(previewLayer)
        self.view.addSubview(self.resultDisplayer)
        self.view.addSubview(self.memUsageDisplayer)
        self.view.bringSubview(toFront: self.resultDisplayer)
        self.view.bringSubview(toFront: self.memUsageDisplayer)
        cameraSession.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraSession.stopRunning()
    }
    
    func getMemory()
    {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info))/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info)
        {
            
            task_info(mach_task_self_,
                      task_flavor_t(MACH_TASK_BASIC_INFO),
                      $0.withMemoryRebound(to: Int32.self, capacity: 1) { zeroPtr in
                        task_info_t(zeroPtr)
                },
                      &count)
            
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
            self.memUsage = Float(info.resident_size)/(1024 * 1024)
        }
        else {
            print("Error with task_info(): " +
                (String.init(validatingUTF8: mach_error_string(kerr)) ?? "unknown error"))
        }
    }
    
    func classifier(img: UIImage){
        let start = CACurrentMediaTime()
        if let predictedResult = caffe.prediction(regarding: img){
            switch modelPicked {
            case "squeezeNet":
                let sorted = predictedResult.map{$0.floatValue}.enumerated().sorted(by: {$0.element > $1.element})[0...10]
                let finalResult = sorted.map{"\($0.element*100)% chance to be: \(squeezenetClassMapping[$0.offset]!)"}.joined(separator: "\n\n")
                
                print("Result is \n\(finalResult)")
                self.result = finalResult
            default:
                print("Result is \n\(predictedResult)")
                self.result = "\(predictedResult)"
            }
            self.getMemory()
        }
        
        let end = CACurrentMediaTime()
        self.elapse = "\(end - start) seconds"
        print("Time elapsed of function (classifier): \(self.elapse) seconds")
    }
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetHigh
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
        self.classifier(img: img!)
        // Force UI work to be done in main thread
        DispatchQueue.main.async(execute: {
            self.resultDisplayer.text = self.result
            self.memUsageDisplayer.text = "Memory usage: \(self.memUsage) MB \nTime elapsed: \(self.elapse) \nModel: \(modelPicked)"
        })
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
}

extension CMSampleBuffer {
    func image(orientation: UIImageOrientation = .up, scale: CGFloat = 1.0) -> UIImage! {
        guard let buffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        let image = UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        
        let resizedImg = resizeBufferImage(image: image, widthRatio: CGFloat(sizeForRealTimeDetector / image.size.width), heightRatio: CGFloat(sizeForRealTimeDetector / image.size.height))
        
        return resizedImg
    }
    
    func resizeBufferImage(image: UIImage, widthRatio: CGFloat, heightRatio: CGFloat) -> UIImage {
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

