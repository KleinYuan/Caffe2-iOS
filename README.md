# Caffe2-iOS

This is a project to demo how to use `Caffe2`/`OpenCV 2` to build an iOS application doing real time object classification.

### Dependencies

*You have to use a macbook with Xcode > 8.0 (macOS Sierra) to keep going*

[iOS 10](https://www.apple.com/ca/ios/ios-10/)
[Caffe2](https://caffe2.ai/docs/getting-started.html?platform=ios&configuration=compile) 
[OpenCV 2](http://docs.opencv.org/2.4/doc/tutorials/introduction/ios_install/ios_install.html) 


# Step by Step Tutorial

*I will try to elaborate below for more details and screenshotsl*


- [ ] Clone this repo

- [ ] Navigate to `Caffe2-iOS/src` folder and run `bash ./setup.sh`

- [ ] When last step is done, open `Caffe2-iOS/src/caffe2-ios` with Xcode

- [ ] Disable `Bitcode`

- [ ] *(by default shoud be done)* Adding `-force_load caffe2-ios/libCaffe2_CPU.a` to `Build Settings/Linking/Other Linker Flags` . For this [issue](https://github.com/caffe2/caffe2/issues/347)

- [ ] Build


##### Note: Using a large picture may result in memory issue and if you want to see it, just try the `pugs.jpg` which will crash the app.
