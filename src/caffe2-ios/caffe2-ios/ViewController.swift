//
//  ViewController.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let predictNetName = "predict_net"
    let initNetNamed = "exec_net"
    let FoundNilErrorMsg = "[Error] Thrown"
    let testImg = "panda.jpeg"
    
    @IBOutlet weak var imageDisplayer: UIImageView!
    @IBOutlet weak var resultDisplayer: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Initializing ...")
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    @IBAction func runButton(_ sender: UIButton) {
        self.classifier(name: testImg)
    }
    func classifier(name: String){
        self.imageDisplayer.image = UIImage(named: testImg)
        do{
            let caffe = try Caffe2(initNetNamed: self.initNetNamed, predictNetNamed: self.predictNetName)
            guard let testImage = #imageLiteral(resourceName: name) as? UIImage else {
                print("Trying to load Image ...")
                throw CommonError.FoundNil(self.FoundNilErrorMsg)
            }
            if let result = caffe.prediction(regarding: testImage){
                let resultString = result.flatMap{$0.floatValue}[0...10].description
                print("Result is \n\(result)")
                self.resultDisplayer.text = resultString
            }
        } catch _ {
            print(self.FoundNilErrorMsg, "classifier function went wrong")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

