//
//  ChartboostDelegate.m
//  Utopia
//
//  Created by Ashwin on 10/15/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ChartboostDelegate.h"
#import "GameState.h"

#define CHARTBOOST_APP_ID    @"53fd3148c26ee4751b3a354e"
#define CHARTBOOST_APP_SIG   @"91b5231f8da2a3f7698c29e2692b4addf8102a12"

@implementation ChartboostDelegate

+ (void) setUpChartboost {
#ifdef TOONSQUAD
#ifndef DEBUG
  [Chartboost startWithAppId:CHARTBOOST_APP_ID appSignature:CHARTBOOST_APP_SIG delegate:nil];
  [self showInterstitial:@"bootup_ad"];
#endif
#endif
}

+ (void) showInterstitial:(NSString *)str {
#ifdef TOONSQUAD
#ifndef DEBUG
  GameState *gs = [GameState sharedGameState];
  if (!gs.playerHasBoughtInAppPurchase) {
    [Chartboost showInterstitial:str];
  }
#endif
#endif
}

+ (void) firePvpMatch {
  [self showInterstitial:@"gameplay_ad"];
}

+ (void) firePveMatch {
  [self showInterstitial:@"gameplay_ad2"];
}

+ (void) fireAchievementRedeemed {
  [self showInterstitial:@"gameplay_ad3"];
}

+ (void) fireMiniJobSent {
  [self showInterstitial:@"gameplay_ad4"];
}

@end
