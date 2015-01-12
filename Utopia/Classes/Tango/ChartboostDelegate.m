//
//  ChartboostDelegate.m
//  Utopia
//
//  Created by Ashwin on 10/15/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ChartboostDelegate.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"

#define CHARTBOOST_APP_ID    @"53fd3148c26ee4751b3a354e"
#define CHARTBOOST_APP_SIG   @"91b5231f8da2a3f7698c29e2692b4addf8102a12"

@implementation ChartboostDelegate

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(ChartboostDelegate);

+ (void) setUpChartboost {
//#ifdef TOONSQUAD
//#ifndef DEBUG
  [Chartboost startWithAppId:CHARTBOOST_APP_ID appSignature:CHARTBOOST_APP_SIG delegate:[ChartboostDelegate sharedChartboostDelegate]];
  [self showInterstitial:@"toonsquad_bootup_ad"];
//#endif
//#endif
}

+ (void) showInterstitial:(NSString *)str {
//#ifdef TOONSQUAD
//#ifndef DEBUG
  GameState *gs = [GameState sharedGameState];
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int numOpens = (int)[def integerForKey:APP_OPEN_KEY];
  if (!gs.playerHasBoughtInAppPurchase && numOpens > 5) {
    [Chartboost showInterstitial:str];
  }
//#endif
//#endif
}

+ (void) firePvpMatch {
  [self showInterstitial:@"toonsquad_pvpmatch"];
}

+ (void) firePveMatch {
  [self showInterstitial:@"toonsquad_pvematch"];
}

+ (void) fireAchievementRedeemed {
  [self showInterstitial:@"toonsquad_achievement"];
}

+ (void) fireMiniJobSent {
  [self showInterstitial:@"toonsquad_minijob"];
}

- (BOOL)shouldRequestInterstitial:(CBLocation)location {
  LNLog(@"request interstitial");
  return YES;
}

- (BOOL)shouldDisplayInterstitial:(CBLocation)location {
  LNLog(@"should display interstitial");
  return YES;
}

- (void)didDisplayInterstitial:(CBLocation)location {
  LNLog(@"did display interstitial");
}

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
  switch(error){
    case CBLoadErrorInternetUnavailable: {
      LNLog(@"Failed to load Interstitial, no Internet connection !");
    } break;
    case CBLoadErrorInternal: {
      LNLog(@"Failed to load Interstitial, internal error !");
    } break;
    case CBLoadErrorNetworkFailure: {
      LNLog(@"Failed to load Interstitial, network error !");
    } break;
    case CBLoadErrorWrongOrientation: {
      LNLog(@"Failed to load Interstitial, wrong orientation !");
    } break;
    case CBLoadErrorTooManyConnections: {
      LNLog(@"Failed to load Interstitial, too many connections !");
    } break;
    case CBLoadErrorFirstSessionInterstitialsDisabled: {
      LNLog(@"Failed to load Interstitial, first session !");
    } break;
    case CBLoadErrorNoAdFound : {
      LNLog(@"Failed to load Interstitial, no ad found !");
    } break;
    case CBLoadErrorSessionNotStarted : {
      LNLog(@"Failed to load Interstitial, session not started !");
    } break;
    default: {
      LNLog(@"Failed to load Interstitial, unknown error !");
    }
  }
}
@end
