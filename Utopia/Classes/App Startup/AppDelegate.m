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

#define SHOULD_VIDEO_USER    0

@implementation AppDelegate

@synthesize window;
@synthesize isActive;
@synthesize facebookDelegate;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [facebookDelegate application:application
                               openURL:url
                     sourceApplication:sourceApplication
                            annotation:annotation];
}

-(void) setUpAlauMeRefferalTracking
{
  //  AMConnect *alaume = [AMConnect sharedInstance];
  //
  //  // Set to YES for debugging purposes. Trace info will be written to console.
  //  alaume.isLoggingEnabled = NO;
  //
  //  // Set to YES for Lite SKU.
  //  alaume.isFreeSKU = NO;
  //
  //  [alaume initializeWithAppId:ALAUME_APP_ID apiKey:ALAUME_API_KEY];
}

-(void) setUpFlurryAnalytics
{
  //  [FlurryAnalytics startSession:FLURRY_API_KEY];
  //  [FlurryAnalytics setUserID:[NSString stringWithFormat:@"%d",
  //                              [GameState sharedGameState].userId]];
}

-(void) setUpCrittercism
{
//  [Crittercism enableWithAppID:@"5029a2f0eeaf4125dd000001"];
}

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
  LNLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
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

-(void) setUpDelightio
{
#if SHOULD_VIDEO_USER
#import <Delight/Delight.h>
  [Delight startWithAppToken:@"6a7116a21a57eacaeaafd07c133"];
#endif
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
  //	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  self.isActive = YES;
	
	CCDirector *director = [CCDirector sharedDirector];
  
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
	
	[director setAnimationInterval:1.0/60];
  
#ifdef DEBUG
	[director setDisplayStats:YES];
#else
	[director setDisplayStats:NO];
#endif
	/*
   // make the OpenGLView a child of the view controller
   [viewController setView:glView];
   
   // make the View Controller a child of the main window
   [window addSubview: viewController.view];
   */
  
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
  
  //  if (![[LocationManager alloc] initWithDelegate:self]) {
  //    // Inform of location services off
  //  }
#ifndef DEBUG
  [Amplitude initializeApiKey:GIRAFFE_GRAPH_KEY trackCampaignSource:YES];
  //  [Apsalar startSession:APSALAR_API_KEY withKey:APSALAR_SECRET andLaunchOptions:launchOptions];
#endif
  [Analytics beganApp];
  [Analytics openedApp];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  
  // Alau.Me
  [self setUpAlauMeRefferalTracking];
  
  // Delight.io
  [self setUpDelightio];
  
  // Mobile App Tracker
#ifdef AGE_OF_CHAOS
  [self setUpMobileAppTracker];
#endif
  
  // Publish install
  [FBSettings publishInstall:FACEBOOK_APP_ID];
  
  // AdColony
  //  adColonyDelegate = [[AdColonyDelegate createAdColonyDelegate] retain];
  
  // TapJoy
  //  tapJoyDelegate = [[TapjoyDelegate createTapJoyDelegate] retain];
  /*
   * Disabled Sponsored offers:(Short Term)
   
   // FlurryClips
   flurryClipsDelegate = [[FlurryClipsDelegate createFlurryClipsDelegate] retain];
   
   // FlurryAnalytics
   [self setUpFlurryAnalytics];
   *
   */
  
  // Facebook
  facebookDelegate = [[FacebookDelegate createFacebookDelegate] retain];
  
  // TestFlight SDK
  //  [TestFlight takeOff:TEST_FLIGHT_API_KEY];
  
  // Kiip.me
  //  kiipDelegate = [[KiipDelegate create] retain];
  
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
  
#ifdef AGE_OF_CHAOS
  [self setUpChartboost];
#else
  [self registerPixelAddictsOpen];
#endif
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  LNLog(@"did receive mem warning");
	[[CCDirector sharedDirector] purgeCachedData];
  [[[Globals sharedGlobals] imageCache] removeAllObjects];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [[GameState sharedGameState] purgeStaticData];
  }
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
  LNLog(@"did enter background");
	[[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  self.isActive = NO;
  
  [[OutgoingEventController sharedOutgoingEventController] logout];
  [[SocketCommunication sharedSocketCommunication] closeDownConnection];
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  
  [NSObject cancelPreviousPerformRequestsWithTarget:[Downloader sharedDownloader]];

  [Analytics suspendedApp];
#ifndef DEBUG
  //  [Apsalar endSession];
#endif
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
  LNLog(@"will enter foreground");
  self.isActive = YES;
  self.hasTrackedVisit = NO;
  
#ifndef DEBUG
  //  [Apsalar reStartSession:APSALAR_API_KEY withKey:APSALAR_SECRET];
#endif
  [Analytics beganApp];
  [Analytics resumedApp];
  
  [[SocketCommunication sharedSocketCommunication] initNetworkCommunication];
  if ([[CCDirector sharedDirector] runningScene]) {
    [[CCDirector sharedDirector] startAnimation];
    
    if (![[GameState sharedGameState] isTutorial]) {
      [[GameState sharedGameState] clearAllData];
      [[GameViewController sharedGameViewController] fadeToLoadingScreen];
    }
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  LNLog(@"will terminate");
	CCDirector *director = [CCDirector sharedDirector];
  [self registerLocalNotifications];
	
	[[director view] removeFromSuperview];
	
	[window release];
	
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
  [ln release];
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
    if (us.state == kUpgrading) {
      FullStructureProto *fsp = [gs structWithId:us.structId];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished upgrading to Level %d!", fsp.name, us.level+1];
      int minutes = [gl calculateMinutesToUpgrade:us];
      [self scheduleNotificationWithText:text badge:1 date:[us.lastUpgradeTime dateByAddingTimeInterval:minutes*60.f]];
    } else if (us.state == kBuilding) {
      FullStructureProto *fsp = [gs structWithId:us.structId];
      NSString *text = [NSString stringWithFormat:@"Your %@ has finished building!", fsp.name];
      int minutes = fsp.minutesToUpgradeBase;
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
  //  [adColonyDelegate release];
  //  [tapJoyDelegate      release];
  //  [flurryClipsDelegate release];
  [facebookDelegate    release];
  //  [kiipDelegate        release];
	[window release];
	[super dealloc];
}

@end
