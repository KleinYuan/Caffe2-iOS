//
//  Caffe2.h
//  caffe2-ios
//
//  Created by Kaiwen Yuan on 2017-04-28.
//
//

#import <UIKit/UIKit.h>

@interface Caffe2: NSObject

// set the networks enforced image input size. If not set, the images dimensions will be used.
@property (atomic, assign) CGSize imageInputDimensions;

- (null_unspecified instancetype)init UNAVAILABLE_ATTRIBUTE;

- (null_unspecified instancetype) init:(nonnull NSString*)initNetFilename predict:(nonnull NSString*)predictNetFilename error:(NSError * _Nullable * _Nullable)error
NS_SWIFT_NAME(init(initNetNamed:predictNetNamed:));

- (nullable NSArray<NSNumber*>*) predict:(nonnull UIImage*) image
NS_SWIFT_NAME(prediction(regarding:));

- (nullable) reloadModel:(nonnull NSString*)initNetFilename predict:(nonnull NSString*)predictNetFilename error:(NSError * _Nullable * _Nullable)error
NS_SWIFT_NAME(reloadModel(initNetNamed:predictNetNamed:));

- (nullable) loadDownloadedModel:(nonnull NSString*)initNetFilePath predict:(nonnull NSString*)predictNetFilePath error:(NSError * _Nullable * _Nullable)error
NS_SWIFT_NAME(loadDownloadedModel(initNetFilePath:predictNetFilePath:));

@end
