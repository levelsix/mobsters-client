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
#import "BattlePlayer.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) createUserWithName:(NSString *)name facebookId:(NSString *)facebookId structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems delegate:(id)delegate;

- (void) startupWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart delegate:(id)delegate;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product delegate:(id)delegate;
- (void) exchangeGemsForResources:(int)gems resources:(int)resources resType:(ResourceType)resType delegate:(id)delegate;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y allowGems:(BOOL)allowGems;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (void) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct;
- (void) normStructWaitComplete:(UserStruct *)userStruct;
- (void) upgradeNormStruct:(UserStruct *)userStruct allowGems:(BOOL)allowGems;

- (void) loadPlayerCity:(int)userId withDelegate:(id)delegate;
- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate;

- (void) levelUp;

- (UserQuest *) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId delegate:(id)delegate;
- (void) questProgress:(int)questId;
- (UserQuest *) donateForQuest:(int)questId monsterIds:(NSArray *)monsterIds;

- (void) retrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate;

- (void) enableApns:(NSString *)deviceToken;
- (void) setGameCenterId:(NSString *)gameCenterId;
- (void) setFacebookId:(NSString *)facebookId delegate:(id)delegate;

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg;

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

- (void) beginClanRaid:(PersistentClanEventProto *)event delegate:(id)delegate;
- (void) setClanRaidTeam:(NSArray *)userMonsterIds delegate:(id)delegate;
- (void) dealDamageToClanRaidMonster:(int)dmg attacker:(BattlePlayer *)userMonsterId curTeam:(NSArray *)curTeam;

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y;
- (void) expansionWaitComplete:(BOOL)speedUp atX:(int)x atY:(int)y;

- (void) purchaseBoosterPack:(int)boosterPackId delegate:(id)delegate;

- (void) privateChatPost:(int)recipientId content:(NSString *)content;
- (void) retrievePrivateChatPosts:(int)otherUserId delegate:(id)delegate;

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId enemyElement:(MonsterProto_MonsterElement)element withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems withDelegate:(id)delegate;
- (void) updateMonsterHealth:(uint64_t)userMonsterId curHealth:(int)curHealth;
- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate;
- (void) reviveInDungeon:(uint64_t)userTaskId myTeam:(NSArray *)team;

- (void) queueUpEvent:(NSArray *)seenUserIds withDelegate:(id)delegate;
- (BOOL) viewNextPvpGuy:(BOOL)useGems;
- (void) beginPvpBattle:(PvpProto *)proto;

- (BOOL) removeMonsterFromTeam:(uint64_t)userMonsterId;
- (BOOL) addMonsterToTeam:(uint64_t)userMonsterId;
- (void) increaseInventorySlots:(UserStruct *)us withGems:(BOOL)gems;
- (void) combineMonsters:(NSArray *)userMonsterIds;
- (BOOL) combineMonsterWithSpeedup:(uint64_t)userMonsterId;
- (BOOL) addMonsterToHealingQueue:(uint64_t)userMonsterId useGems:(BOOL)useGems;
- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item;
- (BOOL) speedupHealingQueue;
- (void) healQueueWaitTimeComplete:(NSArray *)healingItems;
- (void) sellUserMonster:(uint64_t)userMonsterId;

- (BOOL) setBaseEnhanceMonster:(uint64_t)userMonsterId;
- (BOOL) removeBaseEnhanceMonster;
- (BOOL) addMonsterToEnhancingQueue:(uint64_t)userMonsterId useGems:(BOOL)useGems;
- (BOOL) removeMonsterFromEnhancingQueue:(EnhancementItem *)item;
- (BOOL) speedupEnhancingQueue;
- (void) enhanceQueueWaitTimeComplete:(NSArray *)enhancingItems;

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends forStruct:(UserStruct *)us;
- (void) acceptAndRejectInvitesWithAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds;

- (BOOL) evolveMonster:(EvoItem *)evoItem useGems:(BOOL)gems;
- (void) finishEvolutionWithGems:(BOOL)gems withDelegate:(id)delegate;

- (void) updateUserCurrencyWithCashChange:(int)cashChange oilChange:(int)oilChange gemChange:(int)gemChange reason:(NSString *)reason;

@end
