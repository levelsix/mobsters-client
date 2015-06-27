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

+ (void) connectStep:(int)connectStep;

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

+ (void) setUserUuid:(NSString *)userUuid name:(NSString *)name email:(NSString *)email level:(int)level segmentationGroup:(int)group createTime:(NSDate *)createTime;
+ (void) newAccountCreated;
+ (void) tutorialComplete;
+ (void) appOpen:(int)numTimesOpened;
+ (void) inviteFacebook;
+ (void) connectedToServerWithLevel:(int)level gems:(int)gems cash:(int)cash oil:(int)oil;

+ (void) sentFbSpam:(int)numUsers;

+ (void) tutorialStep:(int)tutorialStep;
+ (void) checkInstall;
+ (void) levelUpWithPrevLevel:(int)prevLevel curLevel:(int)curLevel;
+ (void) connectedToFacebookWithData:(NSDictionary *)fbData;
+ (void) redeemedAchievement:(int)achievementId;
+ (void) iapWithSKProduct:(id)product forTransacton:(id)transaction amountUS:(float)amountUS uuid:(NSString *)uuid;
+ (void) iapFailedWithSKProduct:(id)product error:(NSString *)error;

+ (void) foundMatch:(NSString *)action;
+ (void) openChat;
+ (void) createSquad:(NSString *)squadName;
+ (void) joinSquad:(NSString *)squadName isRequestType:(BOOL)isRequestType;

+ (void) pveHit:(int)dungeonId isEnemyAttack:(BOOL)isEnemyAttack attackerMonsterId:(int)attackerMonsterId attackerLevel:(int)attackerLevel attackerHp:(int)attackerHp defenderMonsterId:(int)defenderMonsterId defenderLevel:(int)defenderLevel defenderHp:(int)defenderHp damageDealt:(int)damageDealt hitOrder:(int)hitOrder isKill:(BOOL)isKill isFinalBlow:(BOOL)isFinalBlow skillId:(int)skillId numContinues:(int)numContinues;
+ (void) pveMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated type:(NSString *)type mobstersUsed:(NSArray *)mobstersUsed numPiecesGained:(int)numPieces mobsterIdsGained:(NSArray *)mobsterIdsGained totalRounds:(int)totalRounds dungeonId:(int)dungeonId numContinues:(int)numContinues outcome:(NSString *)outcome;
+ (void) pvpMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated mobstersUsed:(NSArray *)mobstersUsed totalRounds:(int)totalRounds elo:(int)elo oppElo:(int)oppElo oppId:(NSString *)oppId outcome:(NSString *)outcome league:(NSString *)league;


+ (void) userCreateWithCashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance tokenChange:(int)tokenChange tokenBalance:(int)tokenBalance;

+ (void) instantFinish:(NSString *)waitType gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) buyBuilding:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) upgradeBuilding:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) removeObstacle:(int)obstacleId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) retrieveCurrency:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) donateMonsters:(int)monsterId amountDonated:(int)amountDonated numLeft:(int)numLeft questJobId:(int)questJobId;
+ (void) redeemQuest:(int)questId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) redeemAchievement:(int)achievementId gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) iapPurchased:(NSString *)productId gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) fillStorage:(NSString *)resourceType percAmount:(int)percAmount cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) createClan:(NSString *)clanName cashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) buyGacha:(int)machineId monsterList:(NSArray*)monsterList itemId:(int)itemId itemQuantity:(int)itemQuantity highRoller:(BOOL)highRoller gemChange:(int)gemChange gemBalance:(int)gemBalance tokenChange:(int)tokenChange tokenBalance:(int)tokenBalance;

+ (void) enterDungeon:(int)dungeonId gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) endDungeon:(int)dungeonId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance;
+ (void) continueDungeon:(int)dungeonId gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) nextPvpWithCashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) endPvpWithCashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance;

+ (void) bonusSlots:(NSString *)position askedFriends:(BOOL)askedFriends invChange:(int)invChange invBalance:(int)invBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) healMonster:(int)monsterId cashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) cancelHealMonster:(int)monsterId cashChange:(int)cashChange cashBalance:(int)cashBalance;

+ (void) enhanceMonster:(int)baseMonsterId feederId:(int)feederId oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;
+ (void) cancelEnhanceMonster:(int)baseMonsterId feederId:(int)feederId oilChange:(int)oilChange oilBalance:(int)oilBalance;

+ (void) evolveMonster:(int)monsterId oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance;

+ (void) redeemMiniJob:(int)miniJobId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance;

+ (void) eventTier:(int)currentPoints eventId:(int)eventId eventTimeId:(int)eventTimeId tier1threshold:(int)tier1Threshold tier2threshold:(int)tier2Threshold tier3threshold:(int)tier3Threshold tierReached:(int)tierReached;

@end
