# Caffe2-iOS

This is a project to demo how to use `Caffe2`/`OpenCV 2` to build an iOS application doing real time object classification.

![image1](https://cloud.githubusercontent.com/assets/8921629/25560651/28e0d7e0-2d0f-11e7-8d49-9dcf48f91b4e.PNG)

![realtime](https://cloud.githubusercontent.com/assets/8921629/25568328/394f19c4-2db5-11e7-9922-727818f7dcab.PNG)

### Dependencies

*You have to use a Mac with Xcode >= 8.0 (macOS Sierra) to keep going*

[iOS 10](https://www.apple.com/ca/ios/ios-10/)

[Caffe2](https://caffe2.ai/docs/getting-started.html?platform=ios&configuration=compile) 

[OpenCV 2](http://docs.opencv.org/2.4/doc/tutorials/introduction/ios_install/ios_install.html) 


# Step by Step Tutorial

*I will try to elaborate below for more details and screenshots!*

- [X] Clone this repo into a folder, let's say `~/Desktop/`, then you will have `~/Desktop/Caffe2-iOS` when clone is done

- [X] Navigate to `~/Desktop/Caffe2-iOS/src` folder and run `bash ./setup.sh`, which will automatically download and build iOS Caffe2 in a paralleled folder besides  `~/Desktop/Caffe2-iOS/src/caffe2-ios` called `caffe2`

- [X] When previous step is done, open `~/DesktopCaffe2-iOS/src/caffe2-ios` with Xcode (>8.0)

- [X] Disable `Bitcode` like [this](http://stackoverflow.com/questions/31205133/how-to-enable-bitcode-in-xcode-7)

- [X] *(by default should be done)* Adding `$(inherited) -force_load caffe2-ios/libCaffe2_CPU.a` to `Build Settings/Linking/Other Linker Flags` . For this [issue](https://github.com/caffe2/caffe2/issues/347)

- [X] Build with your iPhone plugged in

- [X] Open the app and press `Run` to check the result of a pre-loaded image (cute Panda!) and press `live` to go to live mode

# Performance 

*The initial slope is for a static 4KB image, around 50 MB and Note that memory usage in live mode might not be the same as the one shown in Xcode (slightly different)*

### For low res version
![memorycomsuption](https://cloud.githubusercontent.com/assets/8921629/25562545/29e545f8-2d3d-11e7-9ab8-f780de05ddeb.png)

### For high res version
![memorycomsuptionhighres](https://cloud.githubusercontent.com/assets/8921629/25568321/066329ec-2db5-11e7-9a65-de6861ed2f25.png)

# Future Work (meaning that it will be here in a few days)

We have a clear scope for this repo below:

[Scope](https://github.com/KleinYuan/Caffe2-iOS/wiki#scope)

# OtherUseful resources links

[Caffe2-on-iOS-install](https://caffe2.ai/docs/getting-started.html?platform=ios&configuration=compile)

[Caffe2-repo](https://github.com/caffe2/caffe2)

# License
[License](LICENSE)

##### Note: Using a large picture may result in memory issue (because Caffe2.mm will load a super big vector and thus memory exploded) and if you want to see it, just try the `pugs.jpg` which will crash the app.
