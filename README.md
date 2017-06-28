
# Slack Channel for Deep Learning Communication:

```
https://deep-learning-geeks-slack.herokuapp.com/
```

# Caffe2-iOS

This is a project to demo how to use `Caffe2`/`OpenCV 2` to build an iOS application doing real time object classification.

- [X] iOS (Swift/Objective-C/C++) with Caffe2

- [X] Test build in models (tinyYolo, SqueezeNet) with your own photo

- [X] Memory Consumption and Time Elapse Data

- [X] Live (Real Time) detection

- [X] Download your own model on the fly! And test it!

- [X] Manage models locally on your iPhone

- [X] Overall control on every layer (from beginger to expert)

- [X] Warm community and welcome to contribute

- [X] Star us if you like

# Demo

If you are too lazy to build this repo, I also put this in App Store:

[Check it out](https://itunes.apple.com/ca/app/deep-learning-pro/id1239155582)

<img src="https://user-images.githubusercontent.com/8921629/27619097-1847c7f6-5b75-11e7-8b08-f5065978e4c0.jpg" width="50%">


* If it navigates you to a different country's app store, you just search `Deep Learning Pro`.


# Wiki

Check our [Wiki](https://github.com/KleinYuan/Caffe2-iOS/wiki)

Feel free to ask any questions from prepare environment to debug on Xcode and we are happy to help you.


# For both Beginners and Experts

We provide two stable versions in here with:

- [X] [Exper stable version](https://github.com/KleinYuan/Caffe2-iOS/wiki/Versions#experts) for experts to explore more possibilities

**Static Classifier**             |  **Real Time Classifier**     |**Model Downloader**
:-------------------------:|:-------------------------:|:-------------------------:
![static](https://cloud.githubusercontent.com/assets/8921629/26028288/41835f84-37d2-11e7-83da-8a4e39613459.PNG)  | ![realtime](https://user-images.githubusercontent.com/8921629/27619593-6dc446fc-5b78-11e7-9297-c19fb22ae774.PNG) | ![downloader](https://cloud.githubusercontent.com/assets/8921629/26028283/3627edf8-37d2-11e7-9d45-0b7c6575ede1.PNG)


- [X] [Lite stable version](https://github.com/KleinYuan/Caffe2-iOS/wiki/Versions#beginners) for beginners to experience how the wrapper work and play with the demo

**Static Classifier**             |  **Real Time Classifier**
:-------------------------:|:-------------------------:
![static](https://cloud.githubusercontent.com/assets/8921629/25570968/37b26e02-2ddf-11e7-806f-20c8e2b0d844.PNG)  | ![realtime](https://cloud.githubusercontent.com/assets/8921629/25570965/32d0b43e-2ddf-11e7-816a-925a2adbc579.PNG)


* Note that the number of FPS is subjective to the size you send to the device as well as type of the device. Those numbers were obtained with Height*Width = 227 * 227 on an iPhone 7 Plus.

### Dependencies

*You have to use a Mac with Xcode >= 8.0 (macOS Sierra) to keep going*

[iOS 10](https://www.apple.com/ca/ios/ios-10/)

[Caffe2](https://caffe2.ai/docs/getting-started.html?platform=ios&configuration=compile) 

[OpenCV 2](http://docs.opencv.org/2.4/doc/tutorials/introduction/ios_install/ios_install.html) 

### LFS Clone

	brew install git-lfs
	git lfs install
	git lfs clone https://github.com/KleinYuan/Caffe2-iOS

# Step by Step Tutorial

- [X] Notice, after this [commit](https://github.com/KleinYuan/Caffe2-iOS/commit/e2f05754c296201e43ff52beba0231ae4d392cc1), I put all large files in git LFS and make sure when you clone use [lfs clone](https://github.com/KleinYuan/Caffe2-iOS#LFS-Clone) 

- [X] Clone this repo into a folder, let's say `~/Desktop/`, then you will have `~/Desktop/Caffe2-iOS` when clone is done

- [X] Navigate to `~/Desktop/Caffe2-iOS/src` folder and run `bash ./setup.sh`, which will automatically download and build iOS Caffe2 in a paralleled folder besides  `~/Desktop/Caffe2-iOS/src/caffe2-ios` called `caffe2` (it's important to make sure this step is done and it may take around 20-30 min to finish)

- [X] When previous step is done, open `~/DesktopCaffe2-iOS/src/caffe2-ios` with Xcode (>8.0)

- [X] Disable `Bitcode` like [this](http://stackoverflow.com/questions/31205133/how-to-enable-bitcode-in-xcode-7)

- [X] *(by default should be done)* Adding `$(inherited) -force_load caffe2-ios/libCaffe2_CPU.a` to `Build Settings/Linking/Other Linker Flags` . For this [issue](https://github.com/caffe2/caffe2/issues/347)

- [X] Build with your iPhone plugged in

- [X] Open the app and press `Run` to check the result of a pre-loaded image (cute Panda!) and press `live` to go to live mode


# Validation and debug

There are some potential issues that you will have (I will keep adding if I sense some in issues):

### Caffe2 iOS Build failed

1-a. [Error Message 1](https://github.com/KleinYuan/Caffe2-iOS/issues/11): When build project in Xcode you see this error `Cannot find caffe2/proto/caffe2.pb.h`

1-b. Error Message 2: When running setup.sh you see this in terminal `${YOUR_PATH}/Caffe2-iOS/src/caffe2/third_party/protobuf/cmake: is a directory`

2. Description: Those two are related and all because that you failed to build the caffe2 ios and check this folder [architecture](https://cloud.githubusercontent.com/assets/8921629/26027802/86d4fb6e-37c9-11e7-9f08-1c771dd236f9.png) to validate your build (you should be able to see the `caffe2.pb.h`)

3. Debug and how to fix it: Mostly, the root cause is that your `cmake` is broken (not broken broken, more like configuration/path changed by other services/software) and you probably wanna run `brew install cmake` to reinstall it


### Load model failed or thread killed in the mid

1. Error Message:  ```Reading dangerously large protocol message. If the message turns out to be larger than 67108864 bytes, parsing will be halted for security reasons. To increase the limit (or to disable these warnings), see CodedInputStream::SetTotalBytesLimit() in google/protobuf/io/coded_stream.h.```

2. Description: As you can see in the caffe2 [repo](https://github.com/caffe2/caffe2/commit/d9e90a968d29116d9a60e61f7f358de7aef84498), that they reduced the [protobuf](https://github.com/google/protobuf/tree/a428e42072765993ff674fda72863c9f1aa2d268), which is the tool they use to hanlde the communication down to version 3.1.0 and only have [64MB](https://github.com/google/protobuf/blob/a428e42072765993ff674fda72863c9f1aa2d268/src/google/protobuf/io/coded_stream.h#L625) limit. Therefore, when you load a model larger than that, boooooomb, memory exploed and thread got killed.

3. Debug and how to fix it: 
	- [X] After you [download](https://github.com/KleinYuan/Caffe2-iOS/blob/master/src/setup.sh#L2) and build the caffe2, hold on and modify something to increase the limit first

	- [X] Find this [file](https://github.com/google/protobuf/tree/a428e42072765993ff674fda72863c9f1aa2d268), which is the tool they use to hanlde the communication down to version 3.1.0 and only have [64MB](https://github.com/google/protobuf/blob/a428e42072765993ff674fda72863c9f1aa2d268/src/google/protobuf/io/coded_stream.h#L625) and change the limit to whatever you want (also change the warning limit)

	- [X] Then build caffe2-ios and Tada

	- [X] Alternative method see [here](https://github.com/caffe2/caffe2/issues/474#issuecomment-298965440)


# Performance 

*The initial slope is for a static 4KB image, around 50 MB and Note that memory usage in live mode might not be the same as the one shown in Xcode (slightly different). And also, remember the memory data in the app is aggregated and therefore, if you are really interested in checking performance of a specific process, open Xcode :)*

![memorycomsuptionhighres](https://cloud.githubusercontent.com/assets/8921629/25568321/066329ec-2db5-11e7-9a65-de6861ed2f25.png)


# More Caffe2 Mobile Models

Check [here](https://github.com/KleinYuan/caffe2-yolo)


# Future Work

We have a clear scope for this repo below:

[Scope](https://github.com/KleinYuan/Caffe2-iOS/wiki#scope)

# OtherUseful resources links

[Caffe2-on-iOS-install](https://caffe2.ai/docs/getting-started.html?platform=ios&configuration=compile)

[Caffe2-repo](https://github.com/caffe2/caffe2)

# License
[License](LICENSE)
