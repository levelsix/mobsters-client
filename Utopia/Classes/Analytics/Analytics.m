//
//  Analytics.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Analytics.h"
//#import "Apsalar.h"
#import "Globals.h"
#import "GameState.h"
#import <StoreKit/StoreKit.h>
//#import "Crittercism.h"
#import "Amplitude.h"

#define OPENED_APP @"App: Opened"
#define BEGAN_APP @"App: Began"
#define RESUMED_APP @"App: Resumed"
#define SUSPENDED_APP @"App: Suspended"
#define TERMINATED_APP @"App: Terminated"

#define PURCHASED_GOLD @"Purchased %@"
#define CANCELLED_IAP @"Cancelled gold purchase"
#define IAP_FAILED @"Gold Shoppe: In app purchase failed"
#define TOP_BAR_SHOP @"Viewed gold shop from top bar"

#define GET_MORE_GOLD @"Clicked \"Get more gold\""
#define GET_MORE_SILVER @"Clicked \"Go to Aviary\""
#define NOT_ENOUGH_SILVER_ARMORY @"Armory: Not enough silver"
#define NOT_ENOUGH_GOLD_ARMORY @"Armory: Not enough gold"
#define NOT_ENOUGH_SILVER_UPGRADE @"Upgrade: Not enough silver"
#define NOT_ENOUGH_GOLD_UPGRADE @"Upgrade: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_POPUP @"Stamina Popup: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_POPUP @"Energy Popup: Not enough gold"
#define NOT_ENOUGH_SILVER_CARPENTER @"Carpenter: Not enough silver"
#define NOT_ENOUGH_GOLD_CARPENTER @"Carpenter: Not enough gold"
#define NOT_ENOUGH_GOLD_INSTA_BUILD @"Insta Build: Not enough gold"
#define NOT_ENOUGH_GOLD_INSTA_UPGRADE @"Insta Upgrade: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_TOPBAR @"Stamina Top Bar: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_TOPBAR @"Energy Top Bar: Not enough gold"

#define LEVEL_UP @"Level up"
#define PLACE_CRIT_STRUCT @"Placed crit struct"
#define ATTACK_AGAIN @"Battle: Attack again"
#define FLEE @"Battle: Flee"
#define QUEST_ACCEPT @"Quest: Accept"
#define QUEST_COMPLETE @"Quest: Complete"
#define QUEST_REDEEM @"Quest: Redeem"
#define TASK_OPENED @"Task: Opened"
#define TASK_EXECUTED @"Task: Executed"
#define TASK_CLOSED @"Task: Closed"
#define NORM_STRUCT_UPGRADE @"Norm struct: Upgrade"
#define NORM_STRUCT_PURCHASE @"Norm struct: Purchase"
#define NORM_STRUCT_SELL @"Norm struct: Sell"
#define NORM_STRUCT_INSTA_BUILD @"Norm struct: Insta build"
#define NORM_STRUCT_INSTA_UPGRADE @"Norm struct: Insta upgrade"
#define OPENED_PATH_MENU @"Path Menu: Opened"
#define OPENED_QUEST_LOG @"Path Menu: Clicked quest log"
#define OPENED_NOTIFICATIONS @"Path Menu: Clicked notifications"
#define OPENED_PROFILE @"Path Menu: Clicked profile"
#define CLICKED_VISIT @"Quest Log: Clicked visit"
#define RECEIVED_NOTIFICATION @"Notifications: Received"
#define CLICKED_REVENGE @"Notifications: Clicked revenge"
#define CLICKED_COLLECT @"Notifications: Clicked collect"
#define CLICKED_FILL_ENERGY @"Top bar: Clicked fill energy"
#define CLICKED_FILL_STAMINA @"Top bar: Clicked fill stamina"
#define ENEMY_PROFILE_BATTLE @"Enemy Profile: Battle"
#define ENEMY_PROFILE_ATTACK_MAP @"Enemy Profile: Location map"
#define ENEMY_PROFILE_SPRITE @"Enemy Profile: Sprite"
#define POSTED_TO_ENEMY_PROFILE @"Wall: Posted to Enemy Profile"
#define POSTED_TO_ALLY_PROFILE @"Wall: Posted to Ally Profile"

#define TUTORIAL_STEP @"tut_step"
#define TUTORIAL_STEP_NUM @"step_num"
#define TUTORIAL_FACEBOOK_POPUP @"tut_fb_popup"
#define TUTORIAL_FACEBOOK_POPUP_CONNECT @"tut_fb_popup_cnct"
#define TUTORIAL_FACEBOOK_POPUP_CONNECT_SUCCESS @"tut_fb_popup_cnct_success"
#define TUTORIAL_FACEBOOK_POPUP_CONNECT_FAIL @"tut_fb_popup_cnct_fail"
#define TUTORIAL_FACEBOOK_POPUP_SKIP @"tut_fb_popup_skip"
#define TUTORIAL_FACEBOOK_CONFIRM_CONNECT @"tut_fb_cnfrm_cnct"
#define TUTORIAL_FACEBOOK_CONFIRM_CONNECT_SUCCESS @"tut_fb_cnfrm_cnct_success"
#define TUTORIAL_FACEBOOK_CONFIRM_CONNECT_FAIL @"tut_fb_cnfrm_cnct_fail"
#define TUTORIAL_FACEBOOK_CONFIRM_SKIP @"tut_fb_cnfrm_skip"

@implementation Analytics

+ (void) event:(NSString *)event {
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial && [event rangeOfString:@"Tut"].length == 0) {
    return;
  }
  
#ifndef DEBUG
//  [Crittercism leaveBreadcrumb:event];
#endif
  [Amplitude logEvent:event];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args {
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial && [event rangeOfString:@"Tut"].length == 0) {
    return;
  }
  
#ifndef DEBUG
//  [Crittercism leaveBreadcrumb:event];
#endif
  [Amplitude logEvent:event withEventProperties:args];
}

+ (void) logRevenue:(NSNumber *)num {
#ifndef DEBUG
#endif
  [Amplitude logRevenue:num];
}

+ (void) openedApp {
  [Analytics event:OPENED_APP];
}

+ (void) beganApp {
  [Analytics event:BEGAN_APP];
}

+ (void) resumedApp {
  [Analytics event:RESUMED_APP];
}

+ (void) suspendedApp {
  [Analytics event:SUSPENDED_APP];
}

+ (void) terminatedApp {
  [Analytics event:TERMINATED_APP];
}

+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        [NSNumber numberWithFloat:price], @"price",
                        [NSNumber numberWithInt:gold], @"gems",
                        nil];
  
  [Analytics event:[NSString stringWithFormat:PURCHASED_GOLD, package] withArgs:args];
  [Analytics logRevenue:[NSNumber numberWithFloat:price]];
}

+ (void) cancelledGoldPackage:(NSString *)package {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        nil];
  
  [Analytics event:CANCELLED_IAP withArgs:args];
}

+ (void) inAppPurchaseFailed {
  [Analytics event:IAP_FAILED];
}

+ (void) viewedGoldShopFromTopMenu {
  [Analytics event:TOP_BAR_SHOP];
}

+ (void) clickedGetMoreGold:(int)goldAmt {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:goldAmt], @"gold needed",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:GET_MORE_GOLD withArgs:args];
}

// Engagement events

+ (void) levelUp:(int)level {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.level], @"level",
                        nil];
  
  [Analytics event:LEVEL_UP withArgs:args];
}

+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:curHealth], @"current health",
                        [NSNumber numberWithInt:enemyHealth], @"enemyHealth",
                        nil];
  
  [Analytics event:FLEE withArgs:args];
}

+ (void) questAccept:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_ACCEPT withArgs:args];
}

+ (void) questComplete:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_COMPLETE withArgs:args];
}

+ (void) questRedeem:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_REDEEM withArgs:args];
}

+ (void) taskViewed:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_OPENED withArgs:args];
}

+ (void) taskExecuted:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_EXECUTED withArgs:args];
}

+ (void) taskClosed:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_CLOSED withArgs:args];
}

+ (void) normStructUpgrade:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_UPGRADE withArgs:args];
}

+ (void) normStructPurchase:(int)structId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        nil];
  
  [Analytics event:NORM_STRUCT_PURCHASE withArgs:args];
}

+ (void) normStructSell:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_SELL withArgs:args];
}

+ (void) normStructInstaUpgrade:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_INSTA_UPGRADE withArgs:args];
}

+ (void) normStructInstaBuild:(int)structId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        nil];
  
  [Analytics event:NORM_STRUCT_INSTA_BUILD withArgs:args];
}

+ (void) openedPathMenu {
  [Analytics event:OPENED_PATH_MENU];
}

+ (void) openedNotifications {
  [Analytics event:OPENED_NOTIFICATIONS];
}

+ (void) openedQuestLog {
  [Analytics event:OPENED_QUEST_LOG];
}

+ (void) openedMyProfile {
  [Analytics event:OPENED_PROFILE];
}

+ (void) clickedVisit {
  [Analytics event:CLICKED_VISIT];
}

+ (void) receivedNotification {
  [Analytics event:RECEIVED_NOTIFICATION];
}

+ (void) clickedRevenge {
  [Analytics event:CLICKED_REVENGE];
}

+ (void) clickedCollect {
  [Analytics event:CLICKED_COLLECT];
}

+ (void) enemyProfileFromBattle {
  [Analytics event:ENEMY_PROFILE_BATTLE];
}

+ (void) enemyProfileFromSprite {
  [Analytics event:ENEMY_PROFILE_SPRITE];
}

+ (void) enemyProfileFromAttackMap {
  [Analytics event:ENEMY_PROFILE_ATTACK_MAP];
}

+ (void) postedToEnemyProfile {
  [Analytics event:POSTED_TO_ENEMY_PROFILE];
}

+ (void) postedToAllyProfile {
  [Analytics event:POSTED_TO_ALLY_PROFILE];
}

+ (void) tutorialStep:(int)tutorialStep {
  [Analytics event:TUTORIAL_STEP withArgs:@{TUTORIAL_STEP_NUM: @(tutorialStep)}];
}

+ (void) tutorialFbPopup {
  [Analytics event:TUTORIAL_FACEBOOK_POPUP];
}

+ (void) tutorialFbPopupConnect {
  [Analytics event:TUTORIAL_FACEBOOK_POPUP_CONNECT];
}

+ (void) tutorialFbPopupConnectSuccess {
  [Analytics event:TUTORIAL_FACEBOOK_POPUP_CONNECT_SUCCESS];
}

+ (void) tutorialFbPopupConnectFail {
  [Analytics event:TUTORIAL_FACEBOOK_POPUP_CONNECT_FAIL];
}

+ (void) tutorialFbPopupConnectSkip {
  [Analytics event:TUTORIAL_FACEBOOK_POPUP_SKIP];
}

+ (void) tutorialFbConfirmConnect {
  [Analytics event:TUTORIAL_FACEBOOK_CONFIRM_CONNECT];
}

+ (void) tutorialFbConfirmConnectSuccess {
  [Analytics event:TUTORIAL_FACEBOOK_CONFIRM_CONNECT_SUCCESS];
}

+ (void) tutorialFbConfirmConnectFail {
  [Analytics event:TUTORIAL_FACEBOOK_CONFIRM_CONNECT_FAIL];
}

+ (void) tutorialFbConfirmSkip {
  [Analytics event:TUTORIAL_FACEBOOK_CONFIRM_SKIP];
}

@end
