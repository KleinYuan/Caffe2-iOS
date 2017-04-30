//
//  ViewController.swift
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//  Copyright © 2017 Kaiwen Yuan. All rights reserved.
//

import UIKit

class staticDetectorVC: UIViewController {
    
    let predictNetName = "predict_net"
    let initNetNamed = "exec_net"
    let foundNilErrorMsg = "[Error] Thrown"
    let testImg = "panda.jpeg"
    
    @IBOutlet weak var imageDisplayer: UIImageView!
    @IBOutlet weak var resultDisplayer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Initializing ...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                throw CommonError.FoundNil(self.foundNilErrorMsg)
            }
            if let result = caffe.prediction(regarding: testImage){

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
    


}

