//
//  GameCenterDelegate.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "GameCenterDelegate.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "GameViewController.h"

@implementation GameCenterDelegate

// Check for the availability of Game Center API.
BOOL isGameCenterAPIAvailable()
{
  // Check for presence of GKLocalPlayer API.
  Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
  
  // The device must be running running iOS 4.1 or later.
  NSString *reqSysVer = @"4.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
  
  return (gcClass && osVersionSupported);
}

+ (void) authenticateGameCenter {
  if (isGameCenterAPIAvailable()) {
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *vc, NSError *error) {
      GKLocalPlayer *player = [GKLocalPlayer localPlayer];
      if (player.isAuthenticated) {
        [[OutgoingEventController sharedOutgoingEventController] setGameCenterId:player.playerID];
        
        LNLog(@"Connected to Game Center.");
      }
//      else if (vc) {
//        [[GameViewController baseController] presentViewController:vc animated:YES completion:nil];
//      }
    }];
  }
}

+ (NSString *) gameCenterName {
  GKLocalPlayer *player = [GKLocalPlayer localPlayer];
  if (player.isAuthenticated) {
    return player.alias;
  }
  return nil;
}

+ (NSString *) gameCenterId {
  GKLocalPlayer *player = [GKLocalPlayer localPlayer];
  if (player.isAuthenticated) {
    return player.playerID;
  }
  return nil;
}

@end
