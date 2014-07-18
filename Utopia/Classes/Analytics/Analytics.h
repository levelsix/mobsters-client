//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

+ (void) initAnalytics;

+ (void) equipTutorialStep:(int)tutorialStep;

+ (void) tutorialFbPopup;
+ (void) tutorialFbPopupConnect;
+ (void) tutorialFbPopupConnectSuccess;
+ (void) tutorialFbPopupConnectFail;
+ (void) tutorialFbPopupConnectSkip;
+ (void) tutorialFbConfirmConnect;
+ (void) tutorialFbConfirmConnectSuccess;
+ (void) tutorialFbConfirmConnectFail;
+ (void) tutorialFbConfirmSkip;
+ (void) tutorialWaitingOnUserCreate;

+ (void) setUserId:(int)userId name:(NSString *)name email:(NSString *)email;
+ (void) newAccountCreated;
+ (void) tutorialComplete;
+ (void) appOpen:(int)numTimesOpened;
+ (void) inviteFacebook;
+ (void) connectedToServerWithLevel:(int)level gems:(int)gems cash:(int)cash oil:(int)oil;

+ (void) tutorialStep:(int)tutorialStep;
+ (void) checkInstall;
+ (void) levelUpWithPrevLevel:(int)prevLevel curLevel:(int)curLevel;
+ (void) connectedToFacebookWithData:(NSDictionary *)fbData;
+ (void) redeemedAchievement:(int)achievementId;
+ (void) iapWithSKProduct:(id)product forTransacton:(id)transaction amountUS:(float)amountUS;
+ (void) iapFailedWithSKProduct:(id)product error:(NSString *)error;

+ (void) foundMatch:(NSString *)action;
+ (void) openChat;
+ (void) createSquad:(NSString *)squadName;
+ (void) joinSquad:(NSString *)squadName isRequestType:(BOOL)isRequestType;
+ (void) pveMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated type:(NSString *)type mobsterIdsUsed:(NSArray *)mobsterIdsUsed numPiecesGained:(int)numPieces mobsterIdsGained:(NSArray *)mobsterIdsGained totalRounds:(int)totalRounds dungeonId:(int)dungeonId numContinues:(int)numContinues outcome:(NSString *)outcome;
+ (void) pvpMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated mobsterIdsUsed:(NSArray *)mobsterIdsUsed totalRounds:(int)totalRounds elo:(int)elo oppElo:(int)oppElo oppId:(int)oppId numContinues:(int)numContinues outcome:(NSString *)outcome league:(NSString *)league;

@end
