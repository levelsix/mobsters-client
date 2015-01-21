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
#import <Kamcord/Kamcord.h>
#import "FacebookDelegate.h"
#import "MSWindow.h"
#import "GameCenterDelegate.h"
#import <BugSense-iOS/BugSenseController.h>
#import <Crashlytics/Crashlytics.h>
#import <cocos2d-ui.h>
#import "ChartboostDelegate.h"

#import "TangoDelegate.h"

#define TEST_FLIGHT_APP_TOKEN  @"13d8fb3e-81ac-4d22-842f-1fd7dd4a512b"

//#define KAMCORD_DEV_KEY      @"whYswvPukXavib0gs7RbrWE3BU9TXdxAbpIbHF8v15W"
//#define KAMCORD_SECRET       @"AjmSH6fWejpFdnzGTOBItZHAOE91tEOUr7AxkspVUOZ"
#define KAMCORD_DEV_KEY      @"1GX8i6n2ooTy6dw2sXV7mcTxol4YUDVzCWQlyvQNiPP"
#define KAMCORD_SECRET       @"VHeSPx2Ux15I2pi8dJ7ygFsSSKn7zhDIAw1qr9Zi9L1"

#define NEW_RELIC_TOKEN      @"AA01b4a84c5c83bc8345d534eb4910b3a323b70b5b"

#define BUG_SENSE_API_KEY    @"ff946ee1"

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

- (BOOL)shouldRequestInterstitialsInFirstSession {
  return NO;
}

- (void) forcePurgeCache {
  // Change key everytime we want to force purge
  NSString *key = @"ClearCache1";
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  if (![def boolForKey:key]) {
    LNLog(@"Force purging cache!");
    [[Downloader sharedDownloader] purgeAllDownloadedData];
    [def setBool:YES forKey:key];
  }
}

- (void) setUpKamcord:(UIViewController *)vc {
  [Kamcord setDeveloperKey:KAMCORD_DEV_KEY developerSecret:KAMCORD_SECRET appName:@"Mob Squad" parentViewController:vc];
  [Kamcord setFacebookAppID:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"] sharedAuth:YES];
  [Kamcord setShouldPauseGameEngine:NO];
}

- (void) registerAppOpen {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int numOpens = (int)[def integerForKey:APP_OPEN_KEY];
  numOpens++;
  [def setInteger:numOpens forKey:APP_OPEN_KEY];
  LNLog(@"Registering num opens: %d", numOpens);
  [Analytics appOpen:numOpens];
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  //Init the window
  window = [[MSWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self forcePurgeCache];
  
  GameViewController *gvc = [[GameViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gvc];
  nav.navigationBarHidden = YES;
  window.rootViewController = nav;
  [gvc view];
  
  [window makeKeyAndVisible];
  
  [Analytics initAnalytics];
  [Analytics checkInstall];
  
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
  
  [[CCDirector sharedDirector] pause];
  
  [ChartboostDelegate setUpChartboost];
  
  return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application {
  LNLog(@"will resign active");
  
  [[CCDirector sharedDirector] pause];
  
  [[SocketCommunication sharedSocketCommunication] flush];
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
  LNLog(@"did become active");
  //if ([[CCDirector sharedDirector] runningScene]) {
  [[CCDirector sharedDirector] resume];
  //}
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected) {
    GameViewController *gvc = [GameViewController baseController];
    [[SocketCommunication sharedSocketCommunication] initNetworkCommunicationWithDelegate:gvc];
  }
  
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

- (void) applicationDidEnterBackground:(UIApplication *)application {
  LNLog(@"did enter background");
  [[CCDirector sharedDirector] stopAnimation];
  [self registerLocalNotifications];
  
  [[GameViewController baseController] invalidateAllTimers];
  
  GameState *gs = [GameState sharedGameState];
  FacebookDelegate *fd = [FacebookDelegate sharedFacebookDelegate];
  if (gs.connected && !fd.timeOfLastLoginAttempt) {
    [[OutgoingEventController sharedOutgoingEventController] logout];
    [[SocketCommunication sharedSocketCommunication] closeDownConnection];
    [[GameState sharedGameState] setConnected:NO];
  }
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
  LNLog(@"will enter foreground");
  self.hasTrackedVisit = NO;
  
  [[CCDirector sharedDirector] startAnimation];
  
  // Fix to prevent chat from being unable to touch keyboard on going to bgd and coming back
  // http://stackoverflow.com/questions/8072984/hittest-fires-when-uikeyboard-is-tapped
  for (UIWindow *testWindow in [UIApplication sharedApplication].windows) {
    if (!testWindow.opaque && [NSStringFromClass(testWindow.class) hasPrefix:@"UIText"]) {
      BOOL wasHidden = testWindow.hidden;
      testWindow.hidden = YES;
      
      if (!wasHidden) {
        testWindow.hidden = NO;
      }
      
      break;
    }
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

- (void) applicationSignificantTimeChange:(UIApplication *)application {
  LNLog(@"sig time change");
  [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
  
  GameViewController *gvc = [GameViewController baseController];
  [gvc handleSignificantTimeChange];
}

#pragma mark - Push notifications

- (void) registerForPushNotifications {
  UIApplication *app = [UIApplication sharedApplication];
  
  // Let the device know we want to receive push notifications
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
    [app registerUserNotificationSettings:
     [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    
    [app registerForRemoteNotifications];
  } else {
    [app registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  }
}

- (void) application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
  LNLog(@"My token is: %@", deviceToken);
  
  NSString *str = @"";
  if (deviceToken) {
    str = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
  }
  self.apnsToken = str;
  [[OutgoingEventController sharedOutgoingEventController] enableApns:self.apnsToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
  LNLog(@"Failed to get token, error: %@", error);
  [[OutgoingEventController sharedOutgoingEventController] enableApns:nil];
}

- (void) scheduleNotificationWithText:(NSString *)text badge:(int)badge date:(MSDate *)date {
  UILocalNotification *ln = [[UILocalNotification alloc] init];
  
  if ([UIApplication instancesRespondToSelector:@selector(currentUserNotificationSettings)]) {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (settings.types & UIUserNotificationTypeAlert) {
      ln.alertBody = text;
    }
    
    if (settings.types & UIUserNotificationTypeBadge) {
      ln.applicationIconBadgeNumber = badge;
    }
    
    if (settings.types & UIUserNotificationTypeSound) {
      ln.soundName = UILocalNotificationDefaultSoundName;
    }
  } else {
    ln.alertBody = text;
    ln.applicationIconBadgeNumber = badge;
    ln.soundName = UILocalNotificationDefaultSoundName;
  }
  
  ln.fireDate = date.actualNSDate;
  [[UIApplication sharedApplication] scheduleLocalNotification:ln];
}

- (void) registerLocalNotifications {
  GameState *gs = [GameState sharedGameState];
  //Globals *gl = [Globals sharedGlobals];
  
  if (!gs.connected || gs.isTutorial) {
    return;
  }
  
  if ([UIApplication instancesRespondToSelector:@selector(currentUserNotificationSettings)]) {
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (!settings.types) {
      return;
    }
  }
  
  MSDate *oilFullDate = nil, *cashFullDate = nil;
  NSString *oilStr = nil, *cashStr = nil;
  for (UserStruct *us in gs.myStructs) {
    StructureInfoProto *fsp = [[gs structWithId:us.structId] structInfo];
    if (!us.isComplete) {
      NSString *text = [NSString stringWithFormat:@"Your Level %d %@ has finished building.", fsp.level, fsp.name];
      [self scheduleNotificationWithText:text badge:1 date:us.buildCompleteDate];
    }
    
    // If it's an oil/cash generator, check when last one will be done
    else if (fsp.structType == StructureInfoProto_StructTypeResourceGenerator) {
      ResourceGeneratorProto *rgp = (ResourceGeneratorProto *)[gs structWithId:us.structId];
      
      float secsTillFull = rgp.capacity/rgp.productionRate*3600.f;
      MSDate *finishDate = [us.lastRetrieved dateByAddingTimeInterval:secsTillFull];
      // Check when it will be full
      if (finishDate.timeIntervalSinceNow > 0) {
        if (rgp.resourceType == ResourceTypeOil) {
          if (!oilFullDate || [finishDate compare:oilFullDate] == NSOrderedDescending) {
            oilFullDate = finishDate;
            oilStr = fsp.name;
          }
        } else if (rgp.resourceType == ResourceTypeCash) {
          if (!cashFullDate || [finishDate compare:cashFullDate] == NSOrderedDescending) {
            cashFullDate = finishDate;
            cashStr = fsp.name;
          }
        }
      }
    }
  }
  
  if (oilFullDate) {
    NSString *text = [NSString stringWithFormat:@"Your %@s have just filled up. Collect them now!", oilStr];
    [self scheduleNotificationWithText:text badge:1 date:oilFullDate];
  }
  if (cashFullDate) {
    NSString *text = [NSString stringWithFormat:@"Your %@s have just filled up. Collect them now!", cashStr];
    [self scheduleNotificationWithText:text badge:1 date:cashFullDate];
  }
  
  if (gs.monsterHealingQueues.count) {
    MSDate *date = nil;
    
    for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
      if (hq.queueEndTime && (!date || [date compare:hq.queueEndTime] == NSOrderedAscending)) {
        date = hq.queueEndTime;
      }
    }
    
    if (date) {
      [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have finished healing.", MONSTER_NAME] badge:1 date:date];
    }
  }
  
  if (gs.userEvolution) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"%@ has finished evolving.", gs.userEvolution.evoItem.userMonster1.staticEvolutionMonster.displayName] badge:1 date:gs.userEvolution.endTime];
  }
  
  if (gs.userEnhancement && !gs.userEnhancement.isComplete) {
    [self scheduleNotificationWithText:[NSString stringWithFormat:@"%@ has finished enhancing.", gs.userEnhancement.baseMonster.userMonster.staticMonster.displayName] badge:1 date:gs.userEnhancement.expectedEndTime];
  }
  
  for (UserMiniJob *miniJob in gs.myMiniJobs) {
    if (miniJob.timeStarted && !miniJob.timeCompleted) {
      [self scheduleNotificationWithText:[NSString stringWithFormat:@"Your %@s have come back from their %@.", MONSTER_NAME, miniJob.miniJob.name] badge:1 date:miniJob.tentativeCompletionDate];
    }
  }
  
  MSDate *secretGiftDate = [gs nextSecretGiftOpenDate];
  if (secretGiftDate && secretGiftDate.timeIntervalSinceNow > 0) {
    [self scheduleNotificationWithText:@"Your Secret Gift just became available. Collect it now!" badge:1 date:secretGiftDate];
  }
  
  NSString *text = [NSString stringWithFormat:@"Hey %@, come back! Your %@s need a leader.", gs.name, MONSTER_NAME];
  MSDate *date = [MSDate dateWithTimeIntervalSinceNow:24*60*60];
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
