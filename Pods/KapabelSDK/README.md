# KapabelSDK


[![Version](https://img.shields.io/cocoapods/v/KapabelSDK.svg?style=flat)](https://cocoapods.org/pods/KapabelSDK)
[![License](https://img.shields.io/cocoapods/l/KapabelSDK.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/cocoapods/p/KapabelSDK.svg?style=flat)](http://www.apple.com/ios/ios-10/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Website](https://img.shields.io/badge/Website-Kapabel.io-green.svg)](http://kapabel.io)

UPDATE: Contact us at oyvind@kvanes.no before integrating this in your app.

Kapabel is very easy to integrate in your app. Login happens through our app, similar to "Login with Facebook".

All you need is to add a "Login with Kapabel" button somewhere in your app and add our SDK.

Check out the [Kapabel App here](http://itunes.apple.com/no/app/kapabel-for-students-parents/id1140067858?mt=8
                                 ) and test it out with the [Norway Quiz demo app.](https://itunes.apple.com/kg/app/norway-quiz/id1072687157?mt=8)

## Table of contents
1. [Quick Integration.](#quick-integration)
2. [Parental Gates.](#parental-gates)
3. [Localization.](#localization)
4. [Step by step integration.](#step-by-step-integration)



![Integrate Kapabel](http://kapabel.io/gitimg/git-header2.png)


#Quick Integration.


###1. Install with [CocoaPods](https://cocoapods.org)
Add this to your Podfile:
```swift
pod 'KapabelSDK'
```
For installing without CocoaPods check the [detailed instructions here.](#1-download-the-kapabel-sdk)

###2. Import KapabelSDK in classes you wish to use it
```swift
import KapabelSDK
```
###3. Copy CFBundleURLTypes from the [kapabel.plist](https://github.com/oyvkva/KapabelSDK/blob/master/Source/kapabel.plist) to your app’s Info.plist
![Paste Kapabel](http://kapabel.io/gitimg/paste-small.png)
###4. Add to your AppDelegate:

```swift
    // Runs after logging in from Kapabel App
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Kapabel.instance.saveInfo(userInfo: url.absoluteString)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    	// Update Kapabel information
    	let YOUR_APP_ID = 0 // You create apps in the developer dashboard
    	let YOUR_API_TOKEN = "some-token-here" // You get this when signing up
    	let YOUR_APP_GROUP_NAME = "group.your.own.group.here" // Create this in Target/Capabilities
    	Kapabel.instance.update(id: YOUR_APP_ID, token: YOUR_API_TOKEN, appGroup: YOUR_APP_GROUP_NAME) 
    }
```

NOTE: Make sure you have no spaces in your project name. The Kapabel SDK does not work in that case due to the way deep linking is set up in iOS.

###5. Add the "login with Kapabel" button

If your app is in the "Made for Kids" category you can use the following:
```swift
Kapabel.instance.KAPGATE = true
Kapabel.instance.logInWithKapabel(sender: self)
```

This needs to be sent from a UIViewController that will open up a UIAlertController with a parental gate. Once the parental gate is solved the user will be able to log in from the Kapabel app. They download the app if it is not already installed.

![Parental Gate with Kapabel](http://kapabel.io/gitimg/apple-parental-gate.jpg)


If your app is not in the "Made for Kids" category, or if you want to implement your own parental gate, use this:


```swift     
Kapabel.instance.logInWithKapabel(sender: self)
```

This takes them to the Kapabel App or App Store directly.

![Login with Kapabel](http://kapabel.io/gitimg/login-with-kapabel.jpg)

###6. Start a task in your app:
```swift
let MY_APP_TASK_ID = 122 // You create AppTaskIDs in the developer panel.
Kapabel.instance.startTask(MY_APP_TASK_ID)
```
###7. Close a task in your app:
```swift
var THE_SCORE = 0.75 // Score between 0.00 and 1.00
Kapabel.instance.endTask(THE_SCORE)
```
###8. Submit your update to Apple.

![Developer Kapabel](http://kapabel.io/gitimg/git-dev2.png)



#Parental Gates

Apple's App Store Review Guidelines says the following about safety for apps in the kids category:

*The Kids Category is a great way for people to easily find apps that are appropriate for children. If you want to participate in the Kids Category, you should focus on creating a great experience specifically for younger users. These apps must not include links out of the app, purchasing opportunities, or other distractions to kids unless reserved for a designated area behind a parental gate.*

Because of this you have to include a parental gate in your app before users gets taken to the app store to download the Kapabel app. A parental gate is already included with this SDK, it's a UIAlertController that looks like this:

![Ask your parents](http://kapabel.io/gitimg/ask-your-parents.png)


If you want to use this in your app before logging in with Kapabel, you can use the following code:

```swift
Kapabel.instance.KAPGATE = true
Kapabel.instance.logInWithKapabel(sender: self)
```

You can of course implement your own parental gate if you prefer that, but logging in with Kapabel needs to happen after a parental gate if your app is in the kids category.

#Localization

The Kapabel SDK uses a few strings in the parental gate the toasts confirming that students have been logged in successfully. You can find all these strings in the [Kapabel.strings file.](https://github.com/oyvkva/KapabelSDK/blob/master/Localization/Base.lproj/Kapabel.strings)

If you install Kapabel with Cocoapods you need to add the localizations you want to your project, you can find the localizations of Kapabel.strings in the [localization folder.](https://github.com/oyvkva/KapabelSDK/tree/master/Localization)



#Step by step integration

This goes over how to integrate KapabelSDK into a new app. It’s very much in detail to help developers with limited experience.

If you use [CocoaPods](https://cocoapods.org) you can skip part 1 - 3 and add this to your Podfile instead:
```swift
pod 'KapabelSDK'
```

###1. Download the Kapabel SDK
###2. Drag the SDK into your project
![Drag to project](http://kapabel.io/gitimg/2-drag-to-project-2.png)
###3. Install [Alamofire](https://github.com/Alamofire/Alamofire#installation)
###4. Copy CFBundleURLTypes from the kapabel.plist file that you can find in KapabelSDK-master folder
![CFBundle URL Types](http://kapabel.io/gitimg/4-copy-CFBundleURL.png)

###5.Paste this in your Info.plist file, usually found under resources.
![Paste in pList](http://kapabel.io/gitimg/5-paste-in-pList-2.png)

This sets up your bundle identifier as your custom URL scheme for your app. This is needed so that the Kapabel App can send information back to your app. This happens when users log in.

You can read more about [deep-linking and Inter-App Communication here.](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html)


### 6. Go to the Kapabel Developer panel - Contact Us. 
At the developer panel you will create your ApiToken, AppIDs and your AppTaskIDs.

The Kapabel Developer panel is currently under development, so please contact us at support@kapabel.io and we will create this manually for you.

### 7. Add startKapabel to your AppDelegate
First you import the KapabelSDK in classes you want to use it:
```swift
import KapabelSDK
```

![Update AppDelegate](http://kapabel.io/gitimg/6-app-delegate-2.png)
Add the following method to your AppDelegate:

```swift
// Runs after logging in from Kapabel App
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
let YOUR_APP_ID = 1 // You create apps in the developer dashboard
let YOUR_API_TOKEN = "something-something" // You get this when signing up
Kapabel.instance.startKapabel(YOUR_APP_ID, apiToken: YOUR_API_TOKEN, userInfo: url.absoluteString)
return true
}
```
What this does is to register the user token with your app. This is needed to send in results to Kapabel.

By default Kapabel uses toasts to show when a user have logged in. The toast is also shown if login failed or if the user for some reason have been logged out. Users stay logged in until they go to the Kapabel App to log out.

You can stop the toast from being shown if you wish:
```swift
Kapabel.instance.KAPTOAST = false
```

If you want more log information about that Kapabel is doing to can use:
```swift
Kapabel.instance.KAPLOG = true
```

###8. Add a “Log in with Kapabel” button.
For your app to start sending data to Kapabel, the users need to log in. The users log in through the Kapabel app. This works similar to logging in with Facebook, Twitter, Google, etc.

![Add Kapabel Button](http://kapabel.io/gitimg/7-add-Kapabel-button-2.png)

When this button is tapped you call the following method:

If your app is in the "Made for Kids" category you can use the following:
```swift
Kapabel.instance.KAPGATE = true
Kapabel.instance.logInWithKapabel(sender: self)
```

This needs to be sent from a UIViewController that will open up a UIAlertController with a parental gate. Once the parental gate is solved the user will be able to log in from the Kapabel app. They download the app if it is not already installed.

![Parental Gate with Kapabel](http://kapabel.io/gitimg/apple-parental-gate.jpg)


If your app is not in the "Made for Kids" category, or if you want to implement your own parental gate, use this:


```swift
Kapabel.instance.logInWithKapabel(sender: self)
```

This takes them to the Kapabel App or App Store directly.

###9. Test logging in with Kapabel.

I suggest testing that logging in with Kapabel works as shown in the image below. When you tap on the “Log in with Kapabel” button you should be taken to the Kapabel app as long as you have it installed on your device. If it is not installed, you will be taken to the App Store to download it.

In the Kapabel App you will be able to log in or create a new account. Once you are logged in, you will get a popup asking if you want to log in to your app with this account. Tap “OK” and you will be taken back to your app. You are now logged in with Kapabel in your app.

![Login with Kapabel](http://kapabel.io/gitimg/8-login-with-kapabel-2.jpg)

Users will stay logged in with Kapabel in your app until they actively go to the Kapabel App to log out. Users will also be logged out if they log out from Kapabel on other devices.


###10. Starting Kapabel tasks in your app.



Now you have to decide where in your app you want to start Kapabel tasks. This could be one or more places in your app, depending on how your app is built. I will use my Decimals app to show you how it is done.

Decimals has a startNewRound() method that runs at the start of each round, and this is a good place to start a new task. To start a new task you paste this code:

```swift
let MY_APP_TASK_ID = 122 // You create AppTaskIDs in the developer panel.
Kapabel.instance.startTask(MY_APP_TASK_ID)
```

The App task IDs are created in your developer panel. For Decimals I have the following app tasks:

![App tasks](http://kapabel.io/gitimg/9-app_tasks_1-2.png)

Decimals has 6 different activities so I used 6 different AppTaskIDs to reflect this. The app deals with 3 different topics in mathematic. That is addition, subtraction and multiplication. Choosing the right topic for your AppTaskIDs is important as it helps teachers figuring out what parts of the subjects the students are struggling with.

Now my startNewRound() method looks like this:
```swift
// Starts a new round
func startNewRound() {
let MY_APP_TASK_ID = SettingsManager.sharedInstance.taskID
Kapabel.instance.startTask(MY_APP_TASK_ID)
round += 1
attemptsAtCurrentQuestion = 0
updateLabels()
setUpNewQuestion()
}
```

I get the correct AppTaskID from my SettingsManager and then start a task.

###11. Sending in results for Kapabel tasks.

When users of your app have completed an activity you want to send in the result to Kapabel. You do this with the following code:
```swift
var THE_SCORE = 0.75
Kapabel.instance.endTask(THE_SCORE)   
```
The score that is sent in has to be a value between 0.0 and 1.0, and how you chose to score the activity is up to you. In addition to the score you sent in, Kapabel will also register how long it took to complete the task. This affects how much experience points students get for completing the task.

In my Decimals app I send in results in my checkAnswer() method:
```swift
func checkAnswer(){
var currentTaskScore = (4.0 - Double(attemptsAtCurrentQuestion)) / 4.0
if (currentTaskScore < 0.0){
currentTaskScore = 0.0
}
Kapabel.instance.endTask(currentTaskScore)
}
```

![Results](http://kapabel.io/gitimg/alternatives-results-2.jpg)

In this app the student have to choose the correct answer among 5 options. They get 1.0 if they answer correct right away, 0.75 with one mistake, etc.

![Dashboard](http://kapabel.io/gitimg/10-results-2.png)

Here you can see what some results from a student using the Decimals app will look like in the Kapabel dashboard. You can see a few tasks under each AppTask as well as the start and stop time of them.

###12. Check your account in the Kapabel App.

![Statistics](http://kapabel.io/gitimg/11-statistics-2.jpg)

After you have used your app for a while and completed some tasks, you can go to the Kapabel App and check the results. You should see that the number of tasks you have done has increased and that you have gotten experience points in the correct topics.

###13. Submit your app update.

Now everything is finished and you can send in your update to Apple. Also please let us know that your app has been integrated so that we can add it to our app catalogue and send students your way.


## Contact:

Please contact us at support@kapabel.io if you would like to use Kapabel in your app. You can also sign up for our newsletter and read more about Kapabel here: http://kapabel.io

To run the example project, clone the repo, and run `pod install` from the Example directory first.


### Carthage installation

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate KapabelSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "oyvkva/KapabelSDK" ~> 0.1
```

Run `carthage update` to build the framework and drag the built `KapabelSDK.framework` into your Xcode project.
