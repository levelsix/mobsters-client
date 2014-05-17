//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#ifdef LEGENDS_OF_CHAOS
#define FACEBOOK_APP_ID      @"160187864152452"
#else
#define FACEBOOK_APP_ID      @"626969100686621"
#endif

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	UIWindow *window;
}

@property (nonatomic, assign) BOOL hasTrackedVisit;

@property (nonatomic, retain) NSString *apnsToken;

@property (nonatomic, retain) UIWindow *window;

- (void) registerForPushNotifications;
- (void) removeLocalNotifications;

@end
