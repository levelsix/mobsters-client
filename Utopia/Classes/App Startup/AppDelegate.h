//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileAppTracker/MobileAppTracker.h>

#ifdef LEGENDS_OF_CHAOS
#define FACEBOOK_APP_ID      @"160187864152452"
#else
#define FACEBOOK_APP_ID      @"308804055902016"
#endif

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, MobileAppTrackerDelegate> {
	UIWindow *window;
}

@property (nonatomic, assign) BOOL hasTrackedVisit;

@property (nonatomic, retain) UIWindow *window;

- (void) registerForPushNotifications;
- (void) removeLocalNotifications;

@end
