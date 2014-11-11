//
//  WBAnalyticDeviceInfo.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 3/25/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <WithBuddiesAnalytics/WBAnalyticGender.h>
#import <WithBuddiesAnalytics/WBAnalyticBuildType.h>
#import <WithBuddiesBase/WBObject.h>
/*!
 * class that represents the device, assign properties meaningful values
 */
@class WBAnalyticSettings;
@interface WBAnalyticDeviceInfo : WBPersistedObject <NSCopying>

@property (nonatomic, strong, readonly) NSString *os;
@property (nonatomic, strong, readonly) NSString *osVersion; //7.1.1
@property (nonatomic, strong, readonly) NSString *sdkVersion; //version of WBAnalyticSDK
@property (nonatomic, strong, readonly) NSString *session;
@property (nonatomic, strong, readonly) NSString *locale; //en_us
@property (nonatomic, strong, readonly) NSString *advertisingIdentifier;
@property (nonatomic, strong, readonly) NSString *identifierForVendor;
@property (nonatomic, strong, readonly) NSString *platform;
@property (nonatomic, strong, readonly) NSString *bundle;
@property (nonatomic, strong, readonly) NSString *model; //ipad, ipod, etc
@property (nonatomic, strong, readonly) NSString *appVersion; //version of the application as found CFBundleShortVersionString
@property (nonatomic, strong, readonly) NSString *store;
@property (nonatomic, readonly) WBAnalyticBuildType buildType;
@property (nonatomic, readonly) BOOL pushEnabled;

@property (nonatomic, strong) NSString *email;
@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lng;
@property (nonatomic) NSUInteger age;
@property (nonatomic) WBAnalyticGender gender;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *pushToken;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *gameCenterPlayerId;

@end
