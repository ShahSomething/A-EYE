<p align="center">
    <br>
    <img src="https://github.com/ShahSomething/A-EYE/blob/main/assets/A-EYE-logos_black-removebg-preview.png"/>
    </br>
</p>
<p align="center">
 
   <a href="https://flutter.dev">
     <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
       alt="Platform" />
   </a>
   <a href=". ">
        <img alt="Docs" src="https://readthedocs.org/projects/hubdb/badge/?version=latest">
   </a>
   <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg"></a>


</a>
</p>

# Overview

A-EYE provides a platform where the visually impaired users of our app can easily do their daily work without depending upon their sighted friends or family members. The App has voice instructions feature that helps the users navigate to different parts of the App without any difficulty. A-EYE provides three main features: Object Detection, Face Recognition, and Currency Recognition (Pakistani Currency). Apart from these main features, the App also has an Emergency shake feature which sends the location of the user to their emergency contacts when the user shakes their mobile phone.

## Key Features

* Multi-platform Support for Android, iOS, Windows, Mac, Linux.
* Object Detection.
* Face Recognition.
* Currency Recognition.
* Voice Instructions.
* Emergency Shake.

## (Important) Initial setup : Add dynamic libraries to your app

### Android

1. Place the script [install.sh](https://github.com/ShahSomething/A-EYE/blob/main/install.sh) (Linux/Mac) or [install.bat](https://github.com/ShahSomething/A-EYE/blob/main/install.bat) (Windows) at the root of your project.

2. Execute `sh install.sh` (Linux) / `install.bat` (Windows) at the root of your project to automatically download and place binaries at appropriate folders.

   Note: *The binaries installed will **not** include support for `GpuDelegateV2` and `NnApiDelegate` however `InterpreterOptions().useNnApiForAndroid` can still be used.* 

3. Use **`sh install.sh -d`** (Linux) or **`install.bat -d`** (Windows) instead if you wish to use these `GpuDelegateV2` and `NnApiDelegate`.

These scripts install pre-built binaries based on latest stable tensorflow release. For info about using other tensorflow versions follow [instructions in wiki](https://github.com/am15h/tflite_flutter_plugin/wiki/). 

### iOS

1. Download [`TensorFlowLiteC.framework`](https://github.com/am15h/tflite_flutter_plugin/releases/download/v0.5.0/TensorFlowLiteC.framework.zip). For building a custom version of tensorflow, follow [instructions in wiki](https://github.com/am15h/tflite_flutter_plugin/wiki/). 
2. Place the `TensorFlowLiteC.framework` in the pub-cache folder of this package.

 Pub-Cache folder location: [(ref)](https://dart.dev/tools/pub/cmd/pub-get#the-system-package-cache)

 - `~/.pub-cache/hosted/pub.dartlang.org/tflite_flutter-<plugin-version>/ios/` (Linux/ Mac) 
 - `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dartlang.org\tflite_flutter-<plugin-version>\ios\` (Windows)
 
 ## Examples
 
 ### Object Detection
 The very first screen that appears on the app is Object Detection Screen. The app informs the visually impaired user about the current screen and how to navigate to another screen using Voice instructions. It also tells the user how to activate the Object Detection Model.
 
 #### View
 <img src="https://lh5.googleusercontent.com/n4RGPXxbVie4AuT9tIJPtwCwhcuAIjfAFBv4UCuoEcN4KbsU3TNlPCpX72yU9hD6V_S0Wx86dayiTebXhyeuc5R4qvZ7ip3DXTUJ-S9g-qqMnKz4rHeKF-JXvrAK0t1_ereNdtpx9Lw5GuTwAeQmTLxCPeXVvraJBu0Ol2fIFi58XIQJgpb-c5rYuQ" width=200/> <img align="right" src="https://lh3.googleusercontent.com/2j7jgSkD7z8wxTOTY2xTCJILitwDTgWQgZDynXKJuuYrN9udFwUJ4JXoLDvepZPxs3nY8PqgvPghkYUfIHYEzIsY8RVeYDvX5sm9MjqJMiRtgOQgqq-QrlSZhJyEDVaxQ2fX0c62BP_Olh250jwNvMxWO_IY-F2dBU_vnsADqccCGcZDk4RheFrkOQ" width=200/>

When the user taps on the Object Detection screen, a camera view is opened and it starts  detecting the objects in front of the camera and the app starts to speak the results out loud to the visually impaired user. 
 
 ### Currency Recognition
 The second screen in the app is the Currency Recognition Screen. The app informs the visually impaired user about the current screen and how to navigate to another screen using Voice instructions. It also tells the user how to activate the Currency Recognition Model.
 
 #### View
 <img src="https://lh5.googleusercontent.com/2qv6c1C76r8BY2XkL6a0UGELuAaj9cgCKjkdVM-PwkFvSRxptOoyDPk0ZmK8Je1DhAU5ZVs5VQes1BPXWPk7ZzjQKvfFFv9N7iE5Xvi322kjG4Avf7Rpt7mRvsUnrqUKBJ4rJbeKL2fylre2Yrnq14UPOASfLAX2YyTy8q9XxlBW1KXVn8tG0cO4ZA" width=200/> <img align="right" src="https://lh6.googleusercontent.com/JV01ENxC0mbVcGJdh5eQWge6suwTFzR7lqWOXrUqZtJK2OX6v6zQcT-aRqR-iLb6JtIpM4PjgsE5sLjPCz-mhqfYT68miEzD2ABLgmFIgp-9cweo1i5suJIWWP03TfB1AUAOuS98G-1E-2Udju7rsFqqaIy9gYVjp-6-uFe6MDGwKYP8TCU36xXEug" width=200/>

When the user taps on the Currency Recognition screen, a camera view is opened and the app asks the user to tap anywhere on the screen to take a picture of the currency note. When the picture is taken, the app comes back to the home screen with the results and speaks it out loud.

### Face Recognition
The third and final screen in the app is the Face Recognition Screen. The app informs the visually impaired user about the current screen and how to navigate to another screen using Voice instructions. It also tells the user how to activate the Face Recognition Model.
 
 #### View
 <img src="https://lh6.googleusercontent.com/sobLbbRE9kCmpKALTmB5N4Ztz9AKuFbeVLd7bEpEbCgmoo268bD4Yx-ryqrsib9mT2r4jdNScVsBY5b0NnZvU7RsBJtOhnMBcQMaVvX3IOSpUBysYjKMaWzGPVgVhjxH-wwzIoV2-wLu_jej6KmHBTgtI-Z3x9wAHir6l-r1NepA5f4-2f-a0vhAlQ" width=200/> <img align="right" src="https://lh4.googleusercontent.com/t6Nm8DCBdXMEYUkqyWJclQf9QhaDoWEvA2p6VYGMfmWVIgjZbFgYZbL95CCdPemBGRfUvZ41jOzUGuiiYxuqRW9oVFEgEcotd3jtlJ3k0M8oICz2ingl-FgbI9VC0GKvIJodVFtyzh2Hhfabl0HP6Y5k04Gda5gtryWlh1F7OXdkPTs5ALtr3-_1hw" width=200/>

When the user taps on the Face Recognition screen, a camera view is opened and the app starts to recognize faces in front of the camera and the app starts to speak the results out loud to the visually impaired user.

##  Emergency Shake
The app saves emergency contacts of the user and in case of emergency, if the user shakes their mobile phone, it will send the time and location of the user to the emergency contacts.

The message feature is added through shake detection because the visually impaired person will have to just shake their phone to send a text instead of manually typing a message.




