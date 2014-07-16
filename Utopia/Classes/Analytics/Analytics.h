//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

// Monetization
+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold;
+ (void) cancelledGoldPackage:(NSString *)package;
+ (void) inAppPurchaseFailed;
+ (void) viewedGoldShopFromTopMenu;

// Engagement events
+ (void) levelUp:(int)level;

+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth;

+ (void) questAccept:(int)questId;
+ (void) questComplete:(int)questId;
+ (void) questRedeem:(int)questId;

+ (void) taskViewed:(int)taskId;
+ (void) taskExecuted:(int)taskId;
+ (void) taskClosed:(int)taskId;

+ (void) normStructUpgrade:(int)structId level:(int)level;
+ (void) normStructPurchase:(int)structId;
+ (void) normStructSell:(int)structId level:(int)level;
+ (void) normStructInstaUpgrade:(int)structId level:(int)level;
+ (void) normStructInstaBuild:(int)structId;

+ (void) openedPathMenu;
+ (void) openedNotifications;
+ (void) openedQuestLog;
+ (void) openedMyProfile;

+ (void) clickedVisit;
+ (void) receivedNotification;
+ (void) clickedRevenge;
+ (void) clickedCollect;

+ (void) enemyProfileFromBattle;
+ (void) enemyProfileFromSprite;
+ (void) enemyProfileFromAttackMap;
+ (void) postedToEnemyProfile;
+ (void) postedToAllyProfile;

+ (void) equipTutorialStep:(int)tutorialStep;
+ (void) tutorialStep:(int)tutorialStep;

+ (void) tutorialFbPopup;
+ (void) tutorialFbPopupConnect;
+ (void) tutorialFbPopupConnectSuccess;
+ (void) tutorialFbPopupConnectFail;
+ (void) tutorialFbPopupConnectSkip;
+ (void) tutorialFbConfirmConnect;
+ (void) tutorialFbConfirmConnectSuccess;
+ (void) tutorialFbConfirmConnectFail;
+ (void) tutorialFbConfirmSkip;

+ (void) setUserId:(int)userId name:(NSString *)name email:(NSString *)email;
+ (void) newAccountCreated;
+ (void) tutorialComplete;
+ (void) appOpen:(int)numTimesOpened;
+ (void) inviteFacebook;
+ (void) iapWithSKProduct:(id)product forTransacton:(id)transaction;

@end
