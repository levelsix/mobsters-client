//
//  OutgoingEventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>
#import "StoreKit/StoreKit.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) createUser;

- (void) vaultWithdrawal:(int)amount;
- (void) vaultDeposit:(int)amount;

- (BOOL) taskAction:(int)taskId curTimesActed:(int)numTimesActed;

- (void) battle:(FullUserProto *)defender result:(BattleResult)result city:(int)city equips:(NSArray *)equips isTutorialBattle:(BOOL)isTutorialBattle;
- (BOOL) wearEquip:(uint64_t)userEquipId forPrestigeSlot:(BOOL)forPrestigeSlot;

- (void) generateAttackList:(int)numEnemies realPlayersOnly:(BOOL)realPlayersOnly;
- (void) generateAttackList:(int)numEnemies bounds:(CGRect)bounds;

- (void) startup;
- (void) logout;
- (void) reconnect;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product;

- (void) addAttackSkillPoint;
- (void) addDefenseSkillPoint;
- (void) addEnergySkillPoint;
- (void) addStaminaSkillPoint;
- (void) addHealthSkillPoint;

- (void) refillEnergyWaitComplete;
- (void) refillStaminaWaitComplete;
- (void) refillEnergyWithDiamonds;
- (void) refillStaminaWithDiamonds;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) sellNormStruct:(UserStruct *)userStruct;
- (void) instaBuild:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct;
- (void) retrieveAllStaticData;
- (void) retrieveStaticEquip:(int)equipId;
- (void) retrieveStaticEquips:(NSArray *)equipIds;
- (void) retrieveStaticEquipsForUser:(FullUserProto *)fup;
- (void) retrieveStaticEquipsForUsers:(NSArray *)users;
- (void) retrieveStructStore;
- (void) retrieveEquipStore;
- (void) retrieveBoosterPacks;

- (void) loadPlayerCity:(int)userId;
- (void) loadNeutralCity:(int)cityId;
- (void) loadNeutralCity:(int)cityId enemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type;
- (void) loadNeutralCity:(int)cityId asset:(int)assetId;

- (void) levelUp;

- (void) changeUserLocationWithCoordinate:(CLLocationCoordinate2D)coord;

- (void) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId;
- (void) retrieveQuestLog;
- (void) retrieveQuestDetails:(int)questId;

- (void) retrieveEquipsForUser:(int)userId;
- (void) retrieveUsersForUserIds:(NSArray *)userIds;
- (void) retrieveUsersForUserIdsWithPoints:(NSArray *)userIds;

- (void) retrieveMostRecentWallPostsForPlayer:(int)playerId;
- (void) retrieveWallPostsForPlayer:(int)playerId beforePostId:(int)postId;
- (PlayerWallPostProto *) postToPlayerWall:(int)playerId withContent:(NSString *)content;

- (void) enableApns:(NSData *)deviceToken;

- (void) kiipReward:(int)gold receipt:(NSString *)string;
- (void) adColonyRewardWithAmount:(int)amount type:(EarnFreeDiamondsRequestProto_AdColonyRewardType)type;
- (void) fbConnectReward;

- (BOOL) submitEquipsToBlacksmithWithUserEquipId:(int)equipOne userEquipId:(int)equipTwo guaranteed:(BOOL)guaranteed slotNumber:(int)slotNumber;
- (void) forgeAttemptWaitComplete:(int)blacksmithId;
- (void) finishForgeAttemptWaittimeWithDiamonds:(int)blacksmithId;
- (void) collectForgeEquips:(int)blacksmithId;
- (void) purchaseForgeSlot;

- (void) resetStats;
- (void) resetName:(NSString *)name;
- (void) changeUserType:(UserType)type;
- (void) resetGame;
- (void) prestige;

- (void) retrieveLeaderboardForType:(LeaderboardType)type;
- (void) retrieveLeaderboardForType:(LeaderboardType)type afterRank:(int)afterRank;
- (void) retrieveTournamentRanking:(int)eventId afterRank:(int)afterRank;

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg;
- (void) purchaseGroupChats;

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly delegate:(id)delegate;
- (void) leaveClanWithDelegate:(id)delegate;
- (void) requestJoinClan:(int)clanId delegate:(id)delegate;
- (void) retractRequestToJoinClan:(int)clanId delegate:(id)delegate;
- (void) approveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept delegate:(id)delegate;
- (void) transferClanOwnership:(int)newClanOwnerId delegate:(id)delegate;
- (void) changeClanDescription:(NSString *)description delegate:(id)delegate;
- (void) changeClanJoinType:(BOOL)requestRequired delegate:(id)delegate;
- (void) bootPlayerFromClan:(int)playerId delegate:(id)delegate;
- (void) retrieveClanInfo:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId delegate:(id)delegate;
- (ClanBulletinPostProto *) postOnClanBulletin:(NSString *)content;
- (void) retrieveClanBulletinPosts:(int)beforeThisPostId;
- (void) upgradeClanTierLevel;

- (void) beginGoldmineTimer;
- (void) collectFromGoldmine;

- (void) pickLockBox:(int)eventId method:(PickLockBoxRequestProto_PickLockBoxMethod)method;

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y;
- (void) expansionWaitComplete:(BOOL)speedUp atX:(int)x atY:(int)y;

- (void) retrieveThreeCardMonte;
- (void) playThreeCardMonte:(int)cardID;

- (void) bossAction:(UserBoss *)ub isSuperAttack:(BOOL)isSuperAttack;

- (int) claimTower:(int)towerId;
- (int) beginTowerWar:(int)towerId;
- (int) concedeClanTower:(int)towerId;

- (void) submitEquipEnhancement:(int)enhancingId feeders:(NSArray *)feeders;

- (void) retrieveClanTowerScores:(int)towerId;

- (void) purchaseBoosterPack:(int)boosterPackId purchaseOption:(PurchaseOption)option;
- (void) resetBoosterPack:(int)boosterPackId;

- (void) privateChatPost:(int)recipientId content:(NSString *)content;
- (void) retrievePrivateChatPosts:(int)otherUserId;

- (void) redeemLockBoxItems:(int)lockBoxEventId;
- (void) redeemUserCityGems:(int)cityId;

- (void) beginDungeon:(int)taskId;

@end
