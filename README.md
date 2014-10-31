# MUKUserNotificationController

[![CI Status](http://img.shields.io/travis/Muccy/MUKUserNotificationController.svg?style=flat)](https://travis-ci.org/Muccy/MUKUserNotificationController)
[![Version](https://img.shields.io/cocoapods/v/MUKUserNotificationController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationController)
[![License](https://img.shields.io/cocoapods/l/MUKUserNotificationController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationController)
[![Platform](https://img.shields.io/cocoapods/p/MUKUserNotificationController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationController)

`MUKUserNotificationController` is a controller (but not a view controller) which displays user notifications where status bar lives. Its functionality is highly inspired by Tweetbot. You will have features like:
* sticky notifications;
* temporary notifications with a custom duration;
* queue of notifications with rate limiting;
* customizable colors and text;
* tap and pan up gestures support.

It is thought to be small, compact and easy. If you need ways more configuration I suggest you the superb [CRToast](https://github.com/cruffenach/CRToast).

## Usage

`MUKUserNotificationController` is easy to use. Probabily you want to use it with your root view controller, or just 
use the convenience singleton. 
You instance a notification (`MUKUserNotification`), you configure it with texts and colors, then you feed 
controller instance with that model object.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Screenshots

[![Portrait Sticky Notification](http://i.imgur.com/K2uiyTyl.png)](http://i.imgur.com/K2uiyTy) [![Portrait Notification](http://i.imgur.com/gCnSEvLl.png)](http://imgur.com/gCnSEvL)

[![Landscape Notification](http://i.imgur.com/t9bLMB9l.png)](http://imgur.com/t9bLMB9)

## Installation

MUKUserNotificationController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKUserNotificationController"

## Author

Marco Muccinelli, muccymac@gmail.com

## License

MUKUserNotificationController is available under the MIT license. See the LICENSE file for more info.

