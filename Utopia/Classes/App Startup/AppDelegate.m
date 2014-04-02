//
//  AppDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameViewController.h"
#import "SocketCommunication.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "SoundEngine.h"
#import "Downloader.h"
#import "Amplitude.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import "Chartboost.h"
#import "TestFlight.h"
#import <Kamcord/Kamcord.h>
#import "FacebookDelegate.h"
#import "MSWindow.h"
#import "GameCenterDelegate.h"

#define APSALAR_API_KEY      @"lvl6"
#define APSALAR_SECRET       @"K7kbMwwF"
#define TEST_FLIGHT_APP_TOKEN  @"13d8fb3e-81ac-4d22-842f-1fd7dd4a512b"

#define MAT_ADVERTISER_ID    @"885"
#define MAT_APP_KEY          @"ba62d2918dc7b537cbeaca833085ce89"
#define MAT_VERSION_KEY      @"MATVersionKey"

#ifdef LEGENDS_OF_CHAOS
#define GIRAFFE_GRAPH_KEY    @"eaf66fffc083c9a0628b23925815faa8"
#else
#define GIRAFFE_GRAPH_KEY    @"eee3b73ca3f9fc3322e11be77275c13a"
#endif

#define CHARTBOOST_APP_ID    @"50d29b2216ba47b230000046"
#define CHARTBOOST_APP_SIG   @"5f72ac2d97bf7a6d7835b8a72b207f50bba0d68b"

#define PA_INSTALL_KEY       @"PxlAddictInstallKey"

#define KAMCORD_DEV_KEY      @"whYswvPukXavib0gs7RbrWE3BU9TXdxAbpIbHF8v15W"
#define KAMCORD_SECRET       @"AjmSH6fWejpFdnzGTOBItZHAOE91tEOUr7AxkspVUOZ"

@implementation AppDelegate

@synthesize window;

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [FacebookDelegate handleOpenURL:url sourceApplication:sourceApplication];
}

- (void) setUpMobileAppTracker {
//  [[MobileAppTracker sharedManager] setDebugMode:NO];
//  [[MobileAppTracker sharedManager] setDelegate:self];
//  
//  [[MobileAppTracker sharedManager]  startTrackerWithMATAdvertiserId:MAT_ADVERTISER_ID MATConversionKey:MAT_APP_KEY];
//  
//  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//  float versionNum = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
//  
//  if (![userDefaults valueForKey:MAT_VERSION_KEY]) {
//    [[MobileAppTracker sharedManager] trackInstall];
//    
//    LNLog(@"MAT: Tracking install");
//    
//    [userDefaults setFloat:versionNum forKey:MAT_VERSION_KEY];
//  } else if ([userDefaults floatForKey:MAT_VERSION_KEY] != versionNum) {
//    [[MobileAppTracker sharedManager] trackUpdate];
//    
//    LNLog(@"MAT: Tracking update");
//    
//    [userDefaults setFloat:versionNum forKey:MAT_VERSION_KEY];
//  }
}

- (void)mobileAppTracker:(MobileAppTracker *)tracker didSucceedWithData:(NSData *)data {
  LNLog(@"MAT.didSucceed:");
  LNLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)mobileAppTracker:(MobileAppTracker *)tracker didFailWithError:(NSError *)error {
  LNLog(@"MAT.didFail:");
  LNLog(@"%@", error);
}

- (void) setUpChartboost {
//  Chartboost *cb = [Chartboost sharedChartboost];
//  cb.appId = CHARTBOOST_APP_ID;
//  cb.appSignature = CHARTBOOST_APP_SIG;
//  
//  [cb startSession];
//  [cb showInterstitial];
}

- (void) setUpKamcord:(UIViewController *)vc {
  [Kamcord setDeveloperKey:KAMCORD_DEV_KEY developerSecret:KAMCORD_SECRET appName:@"Mob Squad" parentViewController:vc];
  [Kamcord setFacebookAppID:FACEBOOK_APP_ID];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //Init the window
	window = [[MSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  GameViewController *gvc = [[GameViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gvc];
  nav.navigationBarHidden = YES;
  window.rootViewController = nav;
  
	[window makeKeyAndVisible];
  
#ifndef DEBUG
  [Amplitude initializeApiKey:GIRAFFE_GRAPH_KEY];
#endif
  [Analytics beganApp];
  [Analytics openedApp];
  
  // Publish install
  [FacebookDelegate activateApp];
  
  // Game center
  [GameCenterDelegate authenticateGameCenter];
  
  [TestFlight takeOff:TEST_FLIGHT_APP_TOKEN];
  
  [self setUpKamcord:nav];
  
  [self removeLocalNotifications];
  
  return YES;
}

- (void) registerForPushNotifications {
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
   (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  LNLog(@"will resign active");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  LNLog(@"did become active");
	[[CCDirector sharedDirector] resume];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected) {
    GameViewController *gvc = [GameViewController baseController];
    [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:gvc];
  }
  
  [FacebookDelegate handleDidBecomeActive];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  LNLog(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  LNLog(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  [[GameState sharedGameState] setConnected:NO];

  [Analytics suspendedApp];
#ifndef DEBUG
  //  [Apsalar endSession];
#endif
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  LNLog(@"will enter foreground");
  self.hasTrackedVisit = NO;
  
#ifndef DEBUG
  //  [Apsalar reStartSession:APSALAR_API_KEY withKey:APSALAR_SECRET];
#endif
  [Analytics beganApp];
  [Analytics resumedApp];
  if ([[CCDirector sharedDirector] runningScene]) {
    [[CCDirector sharedDirector] startAnimation];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  LNLog(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
  [self registerLocalNotifications];
	
	[[director view] removeFromSuperview];
	
	[director end];
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  
  [Analytics terminatedApp];
#ifndef DEBUG
  //  [Apsalar endSession];
#endif
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  LNLog(@"sig time change");
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
  
  GameViewController *gvc = [GameViewController baseController];
  [gvc handleSignificantTimeChange];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	LNLog(@"My token is: %@", deviceToken);
  
  NSString *str = @"";
  if (deviceToken) {
    str = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
  }
  self.apnsToken = str;
  [[OutgoingEventController sharedOutgoingEventController] enableApns:self.apnsToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	LNLog(@"Failed to get token, error: %@", error);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:nil];
}

- (void) scheduleNotificationWithText:(NSString *)text badge:(int)badge date:(MSDate *)date {
  UILocalNotification *ln = [[UILocalNotification alloc] init];
  ln.alertBody = text;
  ln.applicationIconBadgeNumber = badge;
  ln.soundName = UILocalNotificationDefaultSoundName;
  ln.fireDate = date.actualNSDate;
  [[UIApplication sharedApplication] scheduleLocalNotification:ln];
}

- (void) registerLocalNotifications {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.connected || gs.isTutorial) {
    return;
  }
  
  for (UserExpansion *exp in gs.userExpansions) {
    if (exp.isExpanding) {
      NSString *text = @"Your expansion has completed! Come back to build a bigger city!";
      int minutes = [gl calculateNumMinutesForNewExpansion];
      [self scheduleNotificationWithText:text badge:1 date:[exp.lastExpandTime dateByAddingTimeInterval:minutes*60.f]];
    }
  }
  
  for (UserStruct *us in gs.myStructs) {
    if (!us.isComplete) {
      StructureInfoProto *fsp = [[gs structWithId:us.structId] structInfo];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished building!", fsp.name];
      int minutes = fsp.minutesToBuild;
      [self scheduleNotificationWithText:text badge:1 date:[us.purchaseTime dateByAddingTimeInterval:minutes*60.f]];
    }
  }
}

- (void) removeLocalNotifications {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
}

@end
