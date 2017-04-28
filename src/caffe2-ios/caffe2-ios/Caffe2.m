//
//  Caffe2.m
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//
//

#import "Caffe2.h"

// Caffe2 Headers
#include "caffe2/core/flags.h"
#include "caffe2/core/init.h"
#include "caffe2/core/predictor.h"
#include "caffe2/utils/proto_utils.h"

// OpenCV
#import <opencv2/opencv.hpp>

namespace caffe2 {
    void run(const string& net_path, const string& predict_net_path) {
        caffe2::NetDef init_net, predict_net;
        CAFFE_ENFORCE(ReadProtoFromFile(net_path, &init_net));
        CAFFE_ENFORCE(ReadProtoFromFile(predict_net_path, &predict_net));
        
        // Can be large due to constant fills
        VLOG(1) << "Init net: " << ProtoDebugString(init_net);
        LOG(INFO) << "Predict net: " << ProtoDebugString(predict_net);
        auto predictor = caffe2::make_unique<Predictor>(init_net, predict_net);
        LOG(INFO) << "Checking that a null forward-pass works";
        Predictor::TensorVector inputVec, outputVec;
        predictor->run(inputVec, &outputVec);
        NSLog(@"outputVec size: %lu", outputVec.size());
        NSLog(@"Done running caffe2");
    }
}

@implementation Caffe2

- (instancetype) init {
    self = [super init];
    if(self != nil) {
        [self initCaffe];
    }
    return self;
}

- (void) initCaffe {
    int argc = 0;
    char** argv;
    caffe2::GlobalInit(&argc, &argv);
    
    NSString *net_path = [NSBundle.mainBundle pathForResource:@"exec_net" ofType:@"pb"];
    NSString *predict_net_path = [NSBundle.mainBundle pathForResource:@"predict_net" ofType:@"pb"];
    
    caffe2::run([net_path UTF8String], [predict_net_path UTF8String]);
    // This is to allow us to use memory leak checks.
    google::protobuf::ShutdownProtobufLibrary();
}

@end
