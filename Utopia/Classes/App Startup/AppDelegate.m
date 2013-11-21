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
#import "GameLayer.h"
#import "GameViewController.h"
#import "SocketCommunication.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
//#import "Apsalar.h"
#import "SoundEngine.h"
//#import "Crittercism.h"
#import "Downloader.h"
#import "Amplitude.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import "FBConnect.h"
#import "Chartboost.h"

#define APSALAR_API_KEY      @"lvl6"
#define APSALAR_SECRET       @"K7kbMwwF"
#define TEST_FLIGHT_API_KEY  @"83db3d95fe7af4e3511206c3e7254a5f_MTExODM4MjAxMi0wNy0xOCAyMTowNjoxOC41MjUzMjc"

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

@implementation AppDelegate

@synthesize window;

- (void) setUpMobileAppTracker {
  [[MobileAppTracker sharedManager] setDebugMode:NO];
  [[MobileAppTracker sharedManager] setDelegate:self];
  
  [[MobileAppTracker sharedManager]  startTrackerWithMATAdvertiserId:MAT_ADVERTISER_ID MATConversionKey:MAT_APP_KEY];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  float versionNum = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
  
  if (![userDefaults valueForKey:MAT_VERSION_KEY]) {
    [[MobileAppTracker sharedManager] trackInstall];
    
    LNLog(@"MAT: Tracking install");
    
    [userDefaults setFloat:versionNum forKey:MAT_VERSION_KEY];
  } else if ([userDefaults floatForKey:MAT_VERSION_KEY] != versionNum) {
    [[MobileAppTracker sharedManager] trackUpdate];
    
    LNLog(@"MAT: Tracking update");
    
    [userDefaults setFloat:versionNum forKey:MAT_VERSION_KEY];
  }
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
  Chartboost *cb = [Chartboost sharedChartboost];
  cb.appId = CHARTBOOST_APP_ID;
  cb.appSignature = CHARTBOOST_APP_SIG;
  
  [cb startSession];
  [cb showInterstitial];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
#ifndef DEBUG
  [self setUpCrittercism];
#endif
	
  /*
   // Init the View Controller
   viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
   viewController.wantsFullScreenLayout = YES;
   
   //
   // Create the EAGLView manually
   //  1. Create a RGB565 format. Alternative: RGBA8
   //	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
   //
   //
   EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
   pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
   ];
   
   // attach the openglView to the director
   [director setOpenGLView:glView];
   */
  
  GameViewController *gvc = [[GameViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gvc];
  nav.navigationBarHidden = YES;
  window.rootViewController = nav;
  
	/*
   // make the OpenGLView a child of the view controller
   [viewController setView:glView];
   
   // make the View Controller a child of the main window
   [window addSubview: viewController.view];
   */
  
	[window makeKeyAndVisible];
  
  //  if (![[LocationManager alloc] initWithDelegate:self]) {
  //    // Inform of location services off
  //  }
#ifndef DEBUG
  [Amplitude initializeApiKey:GIRAFFE_GRAPH_KEY trackCampaignSource:YES];
  //  [Apsalar startSession:APSALAR_API_KEY withKey:APSALAR_SECRET andLaunchOptions:launchOptions];
#endif
  [Analytics beganApp];
  [Analytics openedApp];
  
  // Publish install
  [FBSettings publishInstall:FACEBOOK_APP_ID];
  
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
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];

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
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	LNLog(@"My token is: %@", deviceToken);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	LNLog(@"Failed to get token, error: %@", error);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:nil];
}

- (void) scheduleNotificationWithText:(NSString *)text badge:(int)badge date:(NSDate *)date {
  UILocalNotification *ln = [[UILocalNotification alloc] init];
  ln.alertBody = text;
  ln.applicationIconBadgeNumber = badge;
  ln.soundName = UILocalNotificationDefaultSoundName;
  ln.fireDate = date;
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
    if (us.state == kBuilding) {
      FullStructureProto *fsp = [gs structWithId:us.structId];
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
