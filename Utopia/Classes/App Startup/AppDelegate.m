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
#import "TestFlight.h"
#import <Kamcord/Kamcord.h>
#import "FacebookDelegate.h"
#import "MSWindow.h"
#import "GameCenterDelegate.h"
#import <NewRelicAgent/NewRelic.h>
#import <BugSense-iOS/BugSenseController.h>
#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>
#import <Adjust/Adjust.h>

#define TEST_FLIGHT_APP_TOKEN  @"13d8fb3e-81ac-4d22-842f-1fd7dd4a512b"

#define MAT_ADVERTISER_ID    @"21754"
#define MAT_APP_KEY          @"f2f5c8b9c43496e4e0f988fa9f8827f4"
#define MAT_VERSION_KEY      @"MATVersionKey"

#define AMPLITUDE_KEY        @"4a7dcc75209c734285e4eae85142936b"

#define ADJUST_APP_TOKEN     @"53jsdw73785p"

#define CHARTBOOST_APP_ID    @"50d29b2216ba47b230000046"
#define CHARTBOOST_APP_SIG   @"5f72ac2d97bf7a6d7835b8a72b207f50bba0d68b"

//#define KAMCORD_DEV_KEY      @"whYswvPukXavib0gs7RbrWE3BU9TXdxAbpIbHF8v15W"
//#define KAMCORD_SECRET       @"AjmSH6fWejpFdnzGTOBItZHAOE91tEOUr7AxkspVUOZ"
#define KAMCORD_DEV_KEY      @"1GX8i6n2ooTy6dw2sXV7mcTxol4YUDVzCWQlyvQNiPP"
#define KAMCORD_SECRET       @"VHeSPx2Ux15I2pi8dJ7ygFsSSKn7zhDIAw1qr9Zi9L1"

#define NEW_RELIC_TOKEN      @"AA01b4a84c5c83bc8345d534eb4910b3a323b70b5b"

#define BUG_SENSE_API_KEY    @"ff946ee1"

@implementation AppDelegate

@synthesize window;

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];
  return [FacebookDelegate handleOpenURL:url sourceApplication:sourceApplication];
}

- (void) setUpMobileAppTracker {
  [MobileAppTracker initializeWithMATAdvertiserId:MAT_ADVERTISER_ID
                                 MATConversionKey:MAT_APP_KEY];
  
  // Used to pass us the IFA, enabling highly accurate 1-to-1 attribution.
  // Required for many advertising networks.
  [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                       advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
}

//- (void)mobileAppTracker:(MobileAppTracker *)tracker didSucceedWithData:(NSData *)data {
//  LNLog(@"MAT.didSucceed:");
//  LNLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//}
//
//- (void)mobileAppTracker:(MobileAppTracker *)tracker didFailWithError:(NSError *)error {
//  LNLog(@"MAT.didFail:");
//  LNLog(@"%@", error);
//}

- (void) setUpChartboost {
//  Chartboost *cb = [Chartboost sharedChartboost];
//  cb.appId = CHARTBOOST_APP_ID;
//  cb.appSignature = CHARTBOOST_APP_SIG;
//  
//  [cb startSession];
//  [cb showInterstitial];
}

- (void) setUpAdjust {
  [Adjust appDidLaunch:ADJUST_APP_TOKEN];
  [Adjust setLogLevel:AILogLevelInfo];
#ifdef DEBUG
  [Adjust setEnvironment:AIEnvironmentSandbox];
#else
  [Adjust setEnvironment:AIEnvironmentProduction];
#endif
}

- (void) setUpKamcord:(UIViewController *)vc {
  [Kamcord setDeveloperKey:KAMCORD_DEV_KEY developerSecret:KAMCORD_SECRET appName:@"Mob Squad" parentViewController:vc];
  [Kamcord setFacebookAppID:FACEBOOK_APP_ID sharedAuth:YES];
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
#endif
  [Amplitude initializeApiKey:AMPLITUDE_KEY];
  [Analytics beganApp];
  [Analytics openedApp];
  
  // New relic
  [NewRelicAgent startWithApplicationToken:NEW_RELIC_TOKEN];
  [NRLogger setLogLevels:NRLogLevelNone];
  
  // Bug sense
  //[BugSenseController sharedControllerWithBugSenseAPIKey:BUG_SENSE_API_KEY];
  
  // Publish install
  [FacebookDelegate activateApp];
  
  // Game center
  [GameCenterDelegate authenticateGameCenter];
  
//  [TestFlight takeOff:TEST_FLIGHT_APP_TOKEN];
  
  [self setUpKamcord:nav];
  
  [self setUpMobileAppTracker];
  [self setUpAdjust];
  
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
  [[SocketCommunication sharedSocketCommunication] flush];
  [MobileAppTracker measureSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  LNLog(@"did become active");
	[[CCDirector sharedDirector] resume];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected) {
    GameViewController *gvc = [GameViewController baseController];
    [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:gvc];
  }
  
  // This will restart loading screen
  GameViewController *gvc = [GameViewController baseController];
  [gvc handleSignificantTimeChange];
  
  [FacebookDelegate handleDidBecomeActive];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  NSLog(@"did receive mem warning");
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
  //Globals *gl = [Globals sharedGlobals];
  
  if (!gs.connected || gs.isTutorial) {
    return;
  }
  
  for (UserStruct *us in gs.myStructs) {
    if (!us.isComplete) {
      StructureInfoProto *fsp = [[gs structWithId:us.structId] structInfo];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished building.", fsp.name];
      int minutes = fsp.minutesToBuild;
      [self scheduleNotificationWithText:text badge:1 date:[us.purchaseTime dateByAddingTimeInterval:minutes*60.f]];
    }
  }
  
  if (gs.monsterHealingQueueEndTime) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have finished healing.", MONSTER_NAME.lowercaseString] badge:1 date:gs.monsterHealingQueueEndTime];
  }
  
  if (gs.userEvolution) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"%@ has finished evolving.", gs.userEvolution.evoItem.userMonster1.staticEvolutionMonster.displayName] badge:1 date:gs.userEvolution.endTime];
  }
  
  if (gs.userEnhancement.feeders.count) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"%@ has finished enhancing.", gs.userEnhancement.baseMonster.userMonster.staticMonster.displayName] badge:1 date:gs.userEnhancement.expectedEndTime];
  }
  
  for (UserMiniJob *miniJob in gs.myMiniJobs) {
    if (miniJob.timeStarted && !miniJob.timeCompleted) {
      MSDate *date = [miniJob.timeStarted dateByAddingTimeInterval:miniJob.durationMinutes*60];
      [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have come back from their %@.", MONSTER_NAME.lowercaseString, miniJob.miniJob.name] badge:1 date:date];
    }
  }
  
  NSString *text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s need a leader.", gs.name, MONSTER_NAME.lowercaseString];
  MSDate *date = [MSDate dateWithTimeIntervalSinceNow:12*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really need a leader.", gs.name, MONSTER_NAME.lowercaseString];
  date = [MSDate dateWithTimeIntervalSinceNow:3*24*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really, really need a leader.", gs.name, MONSTER_NAME.lowercaseString];
  date = [MSDate dateWithTimeIntervalSinceNow:7*24*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really, really, REALLY need a leader.", gs.name, MONSTER_NAME.lowercaseString];
  date = [MSDate dateWithTimeIntervalSinceNow:30*24*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
}

- (void) removeLocalNotifications {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
}

@end
