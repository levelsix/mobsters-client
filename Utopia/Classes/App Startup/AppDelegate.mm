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
#import "TestFlight.h"
#import <Kamcord/Kamcord.h>
#import "FacebookDelegate.h"
#import "MSWindow.h"
#import "GameCenterDelegate.h"
#import <NewRelicAgent/NewRelic.h>
#import <BugSense-iOS/BugSenseController.h>
#import <Crashlytics/Crashlytics.h>

#import "TangoDelegate.h"

#import "Chartboost.h"

#define TEST_FLIGHT_APP_TOKEN  @"13d8fb3e-81ac-4d22-842f-1fd7dd4a512b"

#define CHARTBOOST_APP_ID    @"53fd3148c26ee4751b3a354e"
#define CHARTBOOST_APP_SIG   @"91b5231f8da2a3f7698c29e2692b4addf8102a12"

//#define KAMCORD_DEV_KEY      @"whYswvPukXavib0gs7RbrWE3BU9TXdxAbpIbHF8v15W"
//#define KAMCORD_SECRET       @"AjmSH6fWejpFdnzGTOBItZHAOE91tEOUr7AxkspVUOZ"
#define KAMCORD_DEV_KEY      @"1GX8i6n2ooTy6dw2sXV7mcTxol4YUDVzCWQlyvQNiPP"
#define KAMCORD_SECRET       @"VHeSPx2Ux15I2pi8dJ7ygFsSSKn7zhDIAw1qr9Zi9L1"

#define NEW_RELIC_TOKEN      @"AA01b4a84c5c83bc8345d534eb4910b3a323b70b5b"

#define BUG_SENSE_API_KEY    @"ff946ee1"

#define APP_OPEN_KEY         @"AppOpenKey"

@implementation AppDelegate

@synthesize window;

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  LNLog(@"open url");
  BOOL success = [FacebookDelegate handleOpenURL:url sourceApplication:sourceApplication];
  
#ifdef TOONSQUAD
  success = success || [TangoDelegate handleOpenURL:url sourceApplication:sourceApplication];
#endif
  
  return success;
}

- (void) setUpChartboost {
#ifdef TOONSQUAD
  //[Chartboost startWithAppId:CHARTBOOST_APP_ID appSignature:CHARTBOOST_APP_SIG delegate:self];
  //[[Chartboost sharedChartboost] showInterstitial:CBLocationHomeScreen];
#endif
}

- (BOOL)shouldRequestInterstitialsInFirstSession {
  return NO;
}

- (void) setUpKamcord:(UIViewController *)vc {
  [Kamcord setDeveloperKey:KAMCORD_DEV_KEY developerSecret:KAMCORD_SECRET appName:@"Mob Squad" parentViewController:vc];
  [Kamcord setFacebookAppID:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"] sharedAuth:YES];
}

- (void) registerAppOpen {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int numOpens = (int)[def integerForKey:APP_OPEN_KEY];
  numOpens++;
  [def setInteger:numOpens forKey:APP_OPEN_KEY];
  LNLog(@"Registering num opens: %d", numOpens);
  [Analytics appOpen:numOpens];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //Init the window
	window = [[MSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  [self setUpChartboost];
  
  GameViewController *gvc = [[GameViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gvc];
  nav.navigationBarHidden = YES;
  window.rootViewController = nav;
  
	[window makeKeyAndVisible];
  
  [Analytics initAnalytics];
  [Analytics checkInstall];
  
  // New relic
  [NewRelicAgent startWithApplicationToken:NEW_RELIC_TOKEN];
  [NRLogger setLogLevels:NRLogLevelNone];
  
#ifdef MOBSTERS
  // Bug sense
  [BugSenseController sharedControllerWithBugSenseAPIKey:BUG_SENSE_API_KEY];
#endif
  
  // Publish install
  [FacebookDelegate activateApp];
  
  // Game center
  [GameCenterDelegate authenticateGameCenter];
  
  [self setUpKamcord:nav];
  
  [self registerAppOpen];
  
  // Crashlytics
  [Crashlytics startWithAPIKey:@"5001803420c4d8732cf317109988902188f28beb"];
  
  [self removeLocalNotifications];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:gvc];
  
  return YES;
}

- (void) registerForPushNotifications {
	// Let the device know we want to receive push notifications
//	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//   (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  LNLog(@"will resign active");
	[[CCDirector sharedDirector] pause];
  [[SocketCommunication sharedSocketCommunication] flush];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  LNLog(@"did become active");
	[[CCDirector sharedDirector] resume];
  
  // This will restart loading screen
  // Must put this here instead of willEnterForeground because the ordering is foreground, openURL, active
  // This is required for Facebook App Switch
  GameViewController *gvc = [GameViewController baseController];
  [gvc handleSignificantTimeChange];
  
  [FacebookDelegate handleDidBecomeActive];
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
  NSLog(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
}

-(void) applicationDidEnterBackground:(UIApplication *)application {
  LNLog(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    [[OutgoingEventController sharedOutgoingEventController] logout];
    [[SocketCommunication sharedSocketCommunication] closeDownConnection];
    [[GameState sharedGameState] setConnected:NO];
  }
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
  LNLog(@"will enter foreground");
  self.hasTrackedVisit = NO;
  
    [[CCDirector sharedDirector] startAnimation];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected) {
    GameViewController *gvc = [GameViewController baseController];
    [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:gvc];
  }
  
  [self registerAppOpen];
}

- (void) applicationWillTerminate:(UIApplication *)application {
  LNLog(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
  [self registerLocalNotifications];
	
	[[director view] removeFromSuperview];
	
	[director end];
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
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
  
  if (gs.monsterHealingQueue.count && gs.monsterHealingQueueEndTime) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have finished healing.", MONSTER_NAME] badge:1 date:gs.monsterHealingQueueEndTime];
  }
  
  if (gs.userEvolution) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"%@ has finished evolving.", gs.userEvolution.evoItem.userMonster1.staticEvolutionMonster.displayName] badge:1 date:gs.userEvolution.endTime];
  }
  
  for (UserMiniJob *miniJob in gs.myMiniJobs) {
    if (miniJob.timeStarted && !miniJob.timeCompleted) {
      MSDate *date = [miniJob.timeStarted dateByAddingTimeInterval:miniJob.durationMinutes*60];
      [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have come back from their %@.", MONSTER_NAME, miniJob.miniJob.name] badge:1 date:date];
    }
  }
  
  NSString *text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s need a leader.", gs.name, MONSTER_NAME];
  MSDate *date = [MSDate dateWithTimeIntervalSinceNow:12*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really need a leader.", gs.name, MONSTER_NAME];
  date = [MSDate dateWithTimeIntervalSinceNow:3*24*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really, really need a leader.", gs.name, MONSTER_NAME];
  date = [MSDate dateWithTimeIntervalSinceNow:7*24*60*60];
  [self scheduleNotificationWithText:text badge:1 date:date];
  
  text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s really, really, REALLY need a leader.", gs.name, MONSTER_NAME];
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
