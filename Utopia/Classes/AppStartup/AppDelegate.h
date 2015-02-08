//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <cocos2d.h>

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	UIWindow *window;
  
  BOOL _attemptedTango;
}

@property (nonatomic, assign) BOOL hasTrackedVisit;

@property (nonatomic, retain) NSString *apnsToken;

@property (nonatomic, retain) UIWindow *window;

- (void) registerForPushNotifications;
- (void) removeLocalNotifications;

@end
