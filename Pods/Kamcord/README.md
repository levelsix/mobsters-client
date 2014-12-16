Kamcord iOS Framework
======================
[![Pod Version](http://img.shields.io/cocoapods/v/Kamcord.svg?style=flat)](http://cocoadocs.org/docsets/Kamcord/)
[![Pod Platform](http://img.shields.io/cocoapods/p/Kamcord.svg?style=flat)](http://cocoadocs.org/docsets/Kamcord/)
[![Pod License](http://img.shields.io/cocoapods/l/Kamcord.svg?style=flat)](http://kamcord.com/developers/terms)

**The documentation can be found at the <a href="https://github.com/kamcord/kamcord-ios-sdk/wiki">wiki</a>.**

## Installation via CocoaPods
The recommended way to integrate Kamcord is CocoaPods. This makes the
process pretty easy, and enables automatic updating as well.

 * Add `pod 'Kamcord'` to your `Podfile`
 * Execute `pod install` to download the framework and integrate it with
   your project.
 * Ensure you have added the <a href="https://github.com/kamcord/kamcord-ios-sdk/wiki/Getting-Started#framework-dependencies">framework dependencies</a> as well.

## Details
This repository contains a build of Kamcord for integrating into cocos2d/cocosd-x and native iOS game engines. The current version is 1.8.8. If you are updating from an older version, please visit the <a href="https://github.com/kamcord/kamcord-ios-sdk/wiki/Change-log">Change Log</a>.

If you'd like to enable WeChat support in Kamcord, please add <code>WeChat/libWeChatSDK.a</code> as a link target of your application and add <code>-ObjC</code> as a linker flag in <code>Build Settings => Other Linker Flags</code>. 

If you are looking for the Kamcord Unity Plugin, please visit this repository: <a href="https://github.com/kamcord/Unity-Kamcord">https://github.com/kamcord/Unity-Kamcord</a>.

