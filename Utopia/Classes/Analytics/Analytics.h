//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

// App
//+ (void) openedApp;
//+ (void) beganApp;
//+ (void) resumedApp;
//+ (void) suspendedApp;
//+ (void) terminatedApp;
//
//// Monetization
+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold;
//+ (void) cancelledGoldPackage:(NSString *)package;
//+ (void) inAppPurchaseFailed;
//+ (void) viewedGoldShopFromTopMenu;
//
//+ (void) clickedGetMoreGold:(int)goldAmt;
//+ (void) clickedGetMoreCash;
//
//+ (void) notEnoughCashForUpgrade:(int)structId cost:(int)cost;
//+ (void) notEnoughGoldForUpgrade:(int)structId cost:(int)cost;
//
//+ (void) notEnoughCashInCarpenter:(int)structId;
//+ (void) notEnoughGoldInCarpenter:(int)structId;
//
//+ (void) notEnoughGoldForInstaUpgrade:(int)structId level:(int)level cost:(int)cost;
//
//// Engagement events
//+ (void) levelUp:(int)level;
//
//+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth;
//
//+ (void) questAccept:(int)questId;
//+ (void) questComplete:(int)questId;
//+ (void) questRedeem:(int)questId;
//
//+ (void) taskViewed:(int)taskId;
//+ (void) taskExecuted:(int)taskId;
//+ (void) taskClosed:(int)taskId;
//
//+ (void) normStructUpgrade:(int)structId level:(int)level;
//+ (void) normStructPurchase:(int)structId;
//+ (void) normStructSell:(int)structId level:(int)level;
//+ (void) normStructInstaUpgrade:(int)structId level:(int)level;
//+ (void) normStructInstaBuild:(int)structId;
//
//+ (void) openedPathMenu;
//+ (void) openedNotifications;
//+ (void) openedQuestLog;
//+ (void) openedMyProfile;
//
//+ (void) clickedVisit;
//+ (void) receivedNotification;
//+ (void) clickedRevenge;
//+ (void) clickedCollect;
//
//+ (void) enemyProfileFromBattle;
//+ (void) enemyProfileFromSprite;
//+ (void) enemyProfileFromAttackMap;
//+ (void) postedToEnemyProfile;
//+ (void) postedToAllyProfile;

@end
