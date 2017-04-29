//
//  ViewController.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let predictNetName = "predict_net.pb"
    let initNetNamed = "exec_net.pb"
    let FoundNilErrorMsg = "[Error] Thrown"
    let testImg = "pugs.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.classifier(name: testImg)
    }
    
    enum CommonError: Error{
        case FoundNil(String)
    }
    
    func classifier(name: String){
        do{
            let caffe = try Caffe2(initNetNamed: self.initNetNamed, predictNetNamed: self.predictNetName)
            guard let testImage = #imageLiteral(resourceName: name) as? UIImage else {
                print("Trying to load Image ...")
                throw CommonError.FoundNil(self.FoundNilErrorMsg)
            }
            if let result = caffe.prediction(regarding: testImage){
                print("Result is \n\(result)")
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

