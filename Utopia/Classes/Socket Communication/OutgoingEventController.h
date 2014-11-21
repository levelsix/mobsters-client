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

- (void) registerClanEventDelegate:(id)delegate;
- (void) unregisterClanEventDelegate:(id)delegate;

- (void) createUserWithName:(NSString *)name facebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSDictionary *)otherFbInfo structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems delegate:(id)delegate;

- (void) startupWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart delegate:(id)delegate;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product delegate:(id)delegate;
- (void) exchangeGemsForResources:(int)gems resources:(int)resources percFill:(int)percFill resType:(ResourceType)resType delegate:(id)delegate;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y allowGems:(BOOL)allowGems delegate:(id)delegate;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (int) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct delegate:(id)delegate queueUp:(BOOL)queueUp;
- (void) normStructWaitComplete:(UserStruct *)userStruct delegate:(id)delegate;
- (void) upgradeNormStruct:(UserStruct *)userStruct allowGems:(BOOL)allowGems delegate:(id)delegate;

- (void) loadPlayerCity:(NSString *)userUuid withDelegate:(id)delegate;
- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate;

- (void) levelUp;

- (UserQuest *) acceptQuest:(int)questId;
- (void) redeemQuest:(int)questId delegate:(id)delegate;
- (void) questProgress:(int)questId jobIds:(NSArray *)jobIds;
- (UserQuest *) donateForQuest:(int)questId jobId:(int)jobId monsterUuids:(NSArray *)monsterUuids;
- (void) achievementProgress:(NSArray *)userAchievements;
- (void) redeemAchievement:(int)achievementId delegate:(id)delegate;

- (void) retrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate;

- (void) enableApns:(NSString *)deviceToken;
- (void) setGameCenterId:(NSString *)gameCenterId;
- (void) setFacebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSDictionary *)otherFbInfo delegate:(id)delegate;

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg;

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly iconId:(int)iconId useGems:(BOOL)useGems delegate:(id)delegate;
- (void) leaveClanWithDelegate:(id)delegate;
- (void) requestJoinClan:(NSString *)clanUuid delegate:(id)delegate;
- (void) retractRequestToJoinClan:(NSString *)clanUuid delegate:(id)delegate;
- (void) approveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept delegate:(id)delegate;
- (void) transferClanOwnership:(NSString *)newClanOwnerUuid delegate:(id)delegate;
- (void) changeClanSettingsIsDescription:(BOOL)isDescription description:(NSString *)description isRequestType:(BOOL)isRequestType requestRequired:(BOOL)requestRequired isIcon:(BOOL)isIcon iconId:(int)iconId delegate:(id)delegate;
- (void) promoteOrDemoteMember:(NSString *)memberUuid newStatus:(UserClanStatus)status delegate:(id)delegate;
- (void) bootPlayerFromClan:(NSString *)playerUuid delegate:(id)delegate;
- (void) retrieveClanInfo:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList delegate:(id)delegate;

- (void) solicitBuildingHelp:(UserStruct *)us;
- (void) solicitMiniJobHelp:(UserMiniJob *)mj;
- (void) solicitEvolveHelp:(UserEvolution *)ue;
- (void) solicitEnhanceHelp:(UserEnhancement *)ue;
- (void) solicitHealHelp;
- (void) giveClanHelp:(NSArray *)clanHelpUuids;
- (void) endClanHelp:(NSArray *)clanHelpUuids;

- (void) beginClanRaid:(PersistentClanEventProto *)event delegate:(id)delegate;
- (void) setClanRaidTeam:(NSArray *)userMonsterUuids delegate:(id)delegate;
- (void) dealDamageToClanRaidMonster:(int)dmg attacker:(BattlePlayer *)userMonsterId curTeam:(NSArray *)curTeam;

- (void) purchaseBoosterPack:(int)boosterPackId isFree:(BOOL)free delegate:(id)delegate;
- (void) tradeItemForFreeBoosterPack:(int)boosterPackId delegate:(id)delegate;

- (void) privateChatPost:(NSString *)recipientUuid content:(NSString *)content;
- (void) retrievePrivateChatPosts:(NSString *)otherUserUuid delegate:(id)delegate;

- (void) setAvatarMonster:(int)avatarMonsterId;
- (void) protectUserMonster:(NSString *)userMonsterUuid;
- (void) unprotectUserMonster:(NSString *)userMonsterUuid;

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId enemyElement:(Element)element withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems withDelegate:(id)delegate;
- (void) updateMonsterHealth:(NSString *)userMonsterUuid curHealth:(int)curHealth;
- (void) progressDungeon:(NSArray *)curHealths dungeonInfo:(BeginDungeonResponseProto *)dungeonInfo newStageNum:(int)newStageNum dropless:(BOOL)dropless;
- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon droplessStageNums:(NSArray *)droplessStageNums delegate:(id)delegate;
- (void) reviveInDungeon:(NSString *)userTaskUuid taskId:(int)taskId myTeam:(NSArray *)team;

- (void) queueUpEvent:(NSArray *)seenUserUuids withDelegate:(id)delegate;
- (BOOL) viewNextPvpGuy:(BOOL)useGems;
- (void) beginPvpBattle:(PvpProto *)proto isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime;
- (void) endPvpBattleMessage:(PvpProto *)proto userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon delegate:(id)delegate;

- (BOOL) removeMonsterFromTeam:(NSString *)userMonsterUuid;
- (BOOL) addMonsterToTeam:(NSString *)userMonsterUuid;
- (void) increaseInventorySlots:(UserStruct *)us withGems:(BOOL)gems delegate:(id)delegate;
- (void) combineMonsters:(NSArray *)userMonsterUuids;
- (BOOL) combineMonsterWithSpeedup:(NSString *)userMonsterUuid;
- (BOOL) addMonsterToHealingQueue:(NSString *)userMonsterUuid useGems:(BOOL)useGems;
- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item;
- (BOOL) speedupHealingQueue:(id)delegate;
- (void) healQueueWaitTimeComplete:(NSArray *)healingItems;
- (void) sellUserMonsters:(NSArray *)userMonsterUuids;

- (BOOL) submitEnhancement:(UserEnhancement *)enhancement useGems:(BOOL)useGems delegate:(id)delegate;
- (BOOL) enhanceWaitComplete:(BOOL)useGems delegate:(id)delegate;
- (void) collectEnhancementWithDelegate:(id)delegate;

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends forStruct:(UserStruct *)us;
- (void) acceptAndRejectInvitesWithAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids;

- (BOOL) evolveMonster:(EvoItem *)evoItem useGems:(BOOL)gems delegate:(id)delegate;
- (void) finishEvolutionWithGems:(BOOL)gems withDelegate:(id)delegate;

- (void) updateUserCurrencyWithCashChange:(int)cashChange oilChange:(int)oilChange gemChange:(int)gemChange reason:(NSString *)reason;

- (void) spawnObstacles:(NSArray *)obstacles delegate:(id)delegate;
- (void) beginObstacleRemoval:(UserObstacle *)obstacle spendGems:(BOOL)spendGems;
- (BOOL) obstacleRemovalComplete:(UserObstacle *)obstacle speedup:(BOOL)speedup;

- (void) spawnMiniJob:(int)numToSpawn structId:(int)structId;
- (void) beginMiniJob:(UserMiniJob *)userMiniJob userMonsterUuids:(NSArray *)userMonsterUuids delegate:(id)delegate;
- (void) completeMiniJob:(UserMiniJob *)userMiniJob isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost delegate:(id)delegate;
- (void) redeemMiniJob:(UserMiniJob *)userMiniJob delegate:(id)delegate;

- (void) tradeItemForSpeedup:(int)itemId userStruct:(UserStruct *)us;
- (void) tradeItemForSpeedup:(int)itemId userObstacle:(UserObstacle *)uo;
- (void) tradeItemForSpeedup:(int)itemId userMiniJob:(UserMiniJob *)umj;
- (void) tradeItemForSpeedup:(int)itemId userEnhancement:(UserEnhancement *)ue;
- (void) tradeItemForSpeedup:(int)itemId userEvolution:(UserEvolution *)ue;
- (void) tradeItemForHealSpeedup:(int)itemId;
- (void) removeUserItemUsed:(NSArray *)usageUuids;

- (void) tradeItemForResources:(NSDictionary *)itemIdsToQuantity;

@end
