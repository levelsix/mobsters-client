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
#import "ChatObject.h"
#import "BattleItemUtil.h"

@interface OutgoingEventController : NSObject

+ (OutgoingEventController *) sharedOutgoingEventController;

- (void) registerClanEventDelegate:(id)delegate;
- (void) unregisterClanEventDelegate:(id)delegate;

- (void) createUserWithName:(NSString *)name facebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSDictionary *)otherFbInfo structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems tokens:(int)tokens delegate:(id)delegate;

- (void) startupWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart delegate:(id)delegate;
- (void) logout;

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product saleUuid:(NSString *)saleUuid delegate:(id)delegate;
- (void) exchangeGemsForResources:(int)gems resources:(int)resources percFill:(int)percFill resType:(ResourceType)resType delegate:(id)delegate;

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y allowGems:(BOOL)allowGems delegate:(id)delegate;
- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y;
- (int) retrieveFromNormStructure:(UserStruct *)userStruct;
- (void) instaUpgrade:(UserStruct *)userStruct delegate:(id)delegate queueUp:(BOOL)queueUp;
- (void) normStructWaitComplete:(UserStruct *)userStruct delegate:(id)delegate;
- (void) upgradeAndCompleteFreeBuilding:(UserStruct *)us;
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

- (void) sendGroupChat:(ChatScope)scope message:(NSString *)msg;

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
- (void) solicitBattleItemHelp:(BattleItemQueue *)biq;
- (void) solicitResearchHelp:(UserResearch *)userResearch;
- (void) solicitHealHelp:(HospitalQueue *)hq;
- (void) giveClanHelp:(NSArray *)clanHelpUuids;
- (void) endClanHelp:(NSArray *)clanHelpUuids;

- (void) beginClanRaid:(PersistentClanEventProto *)event delegate:(id)delegate;
- (void) setClanRaidTeam:(NSArray *)userMonsterUuids delegate:(id)delegate;
- (void) dealDamageToClanRaidMonster:(int)dmg attacker:(BattlePlayer *)userMonsterId curTeam:(NSArray *)curTeam;

- (void) solicitClanTeamDonation:(NSString *)message useGems:(BOOL)useGems;
- (void) fulfillClanTeamDonation:(UserMonster *)um solicitation:(ClanMemberTeamDonationProto *)solicitation;
- (void) invalidateSolicitation:(ClanMemberTeamDonationProto *)solicitation;

- (void) purchaseBoosterPack:(int)boosterPackId isFree:(BOOL)free isMultiSpin:(BOOL)multiSpin gemsSpent:(int)gemsSpent tokensChange:(int)tokensChange delegate:(id)delegate;
- (void) tradeItemForFreeBoosterPack:(int)boosterPackId delegate:(id)delegate;

- (void) privateChatPost:(NSString *)recipientUuid content:(NSString *)content originalLanguage:(TranslateLanguages)originalLanguage;
- (void) retrievePrivateChatPosts:(NSString *)otherUserUuid delegate:(id)delegate;

- (void) translateSelectMessages:(NSArray *)messages language:(TranslateLanguages)language otherUserUuid:(NSString *)otherUserUuid chatType:(ChatScope)chatType translateOn:(BOOL)translateOn delegate:(id)delegate;

- (void) setAvatarMonster:(int)avatarMonsterId;
- (void) setDefendingMessage:(NSString *)defendingMessage;
- (void) protectUserMonster:(NSString *)userMonsterUuid;
- (void) unprotectUserMonster:(NSString *)userMonsterUuid;
- (void) updateUserStrength:(uint64_t)newStrength;

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId enemyElement:(Element)element withDelegate:(id)delegate;
- (void) beginDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems withDelegate:(id)delegate;
- (void) updateMonsterHealth:(NSString *)userMonsterUuid curHealth:(int)curHealth;
- (void) progressDungeon:(NSArray *)curHealths dungeonInfo:(BeginDungeonResponseProto *)dungeonInfo newStageNum:(int)newStageNum dropless:(BOOL)dropless;
- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon droplessStageNums:(NSArray *)droplessStageNums delegate:(id)delegate;
- (void) reviveInDungeon:(NSString *)userTaskUuid taskId:(int)taskId myTeam:(NSArray *)team;
- (void) updateClientState:(NSData *)data shouldFlush:(BOOL)shouldFlush;

- (void) queueUpEvent:(NSArray *)seenUserUuids withDelegate:(id)delegate;
- (BOOL) viewNextPvpGuy:(BOOL)useGems;
- (void) beginPvpBattle:(PvpProto *)proto isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime;
- (void) endPvpBattleMessage:(PvpProto *)proto userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon droplessStageNums:(NSArray *)droplessStageNums delegate:(id)delegate;
- (void) retrieveUserTeam:(NSString *)userUuid delegate:(id)delegate;
- (void) saveUserPvpBoard:(NSArray *)obstacleList;

- (void) beginClanAvenge:(PvpHistoryProto *)pvp;
- (void) queueUpForClanAvenge:(PvpClanAvenging *)ca delegate:(id)delegate;
- (void) endClanAvengings:(NSArray *)clanAvengings;

- (BOOL) removeMonsterFromTeam:(NSString *)userMonsterUuid;
- (BOOL) addMonsterToTeam:(NSString *)userMonsterUuid preferableSlot:(int)preferableSlot;
- (void) increaseInventorySlots:(UserStruct *)us withGems:(BOOL)gems delegate:(id)delegate;
- (void) combineMonsters:(NSArray *)userMonsterUuids;
- (BOOL) combineMonsterWithSpeedup:(NSString *)userMonsterUuid;

- (BOOL) addMonster:(NSString *)userMonsterUuid toHealingQueue:(NSString *)userStructUuid useGems:(BOOL)useGems;
- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item;
- (BOOL) speedupHealingQueue:(HospitalQueue *)hq delegate:(id)delegate;
- (void) healQueueWaitTimeComplete:(NSArray *)healingItems;

- (BOOL) addBattleItem:(BattleItemProto *)bi toBattleItemQueue:(BattleItemQueue *)biq useGems:(BOOL)useGems;
- (BOOL) removeBattleQueueObject:(BattleItemQueueObject *)item fromQueue:(BattleItemQueue *)biq;
- (BOOL) speedupBattleItemQueue:(BattleItemQueue *)biq delegate:(id)delegate;
- (void) battleItemQueueWaitTimeComplete:(NSArray *)battleItemQueueObjects fromQueue:(BattleItemQueue *)biq;
- (void) removeBattleItems:(NSArray *)battleItemIds;

- (void) sellUserMonsters:(NSArray *)userMonsterUuids;

- (BOOL) submitEnhancement:(UserEnhancement *)enhancement useGems:(BOOL)useGems delegate:(id)delegate;
- (BOOL) enhanceWaitComplete:(BOOL)useGems delegate:(id)delegate;
- (BOOL) collectEnhancementWithDelegate:(id)delegate;

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends forStruct:(UserStruct *)us;
- (void) acceptAndRejectInvitesWithAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids;

- (BOOL) evolveMonster:(EvoItem *)evoItem useGems:(BOOL)gems delegate:(id)delegate;
- (void) finishEvolutionWithGems:(BOOL)gems withDelegate:(id)delegate;

- (void) updateUserCurrencyWithCashSpent:(int)cashSpent oilSpent:(int)oilSpent gemsSpent:(int)gemsSpent reason:(NSString *)reason;

- (BOOL) beginResearch:(UserResearch *)userResearch allowGems:(BOOL)allowGems delegate:(id)delegate;
- (BOOL) finishResearch:(UserResearch *)userResearch useGems:(BOOL)useGems delegate:(id)delegate;

- (void) spawnObstacles:(NSArray *)obstacles delegate:(id)delegate;
- (void) beginObstacleRemoval:(UserObstacle *)obstacle spendGems:(BOOL)spendGems;
- (BOOL) obstacleRemovalComplete:(UserObstacle *)obstacle speedup:(BOOL)speedup;

- (void) spawnMiniJob:(int)numToSpawn structId:(int)structId;
- (void) beginMiniJob:(UserMiniJob *)userMiniJob userMonsterUuids:(NSArray *)userMonsterUuids delegate:(id)delegate;
- (void) completeMiniJob:(UserMiniJob *)userMiniJob isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost delegate:(id)delegate;
- (void) redeemMiniJob:(UserMiniJob *)userMiniJob delegate:(id)delegate;
- (void) refreshMiniJobs:(NSArray *)jobsIds itemId:(int)itemId gemsSpent:(int)gemsSpent quality:(Quality)quality numToSpawn:(int)numToSpawn delegate:(id)delegate;

- (void) retrieveUserMiniEventWithDelegate:(id)delegate;
- (void) updateUserMiniEvent:(UserMiniEventGoal *)updatedUserMiniEventGoal shouldFlush:(BOOL)shouldFlush;
- (void) redeemMiniEventRewardWithDelegate:(id)delegate tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed miniEventForPlayerLevelId:(int32_t)mefplId;

- (void) tradeItemForSpeedup:(int)itemId userStruct:(UserStruct *)us;
- (void) tradeItemForSpeedup:(int)itemId userObstacle:(UserObstacle *)uo;
- (void) tradeItemForSpeedup:(int)itemId userMiniJob:(UserMiniJob *)umj;
- (void) tradeItemForSpeedup:(int)itemId userEnhancement:(UserEnhancement *)ue;
- (void) tradeItemForSpeedup:(int)itemId userEvolution:(UserEvolution *)ue;
- (void) tradeItemForSpeedup:(int)itemId userResearch:(UserResearch *)ur;
- (void) tradeItemForSpeedup:(int)itemId healingQueue:(HospitalQueue *)hq;
- (void) tradeItemForSpeedup:(int)itemId battleItemQueue:(BattleItemQueue *)biq;
- (void) tradeItemForSpeedup:(int)itemId combineUserMonster:(UserMonster *)um;
- (void) removeUserItemUsed:(NSArray *)usageUuids;

- (void) tradeItemIdsForResources:(NSDictionary *)itemIdsToQuantity;
- (void) tradeItemForResources:(int)itemId;

- (void) redeemSecretGift:(UserSecretGiftProto *)sg delegate:(id)delegate;

- (void) sendTangoGiftsToTangoUsers:(NSArray *)tangoIds gemReward:(int)gemReward delegate:(id)delegate;
- (void) collectGift:(NSArray *)userClanGifts delegate:(id)delegate;
- (void) clearGifts:(NSArray *)userClanGifts;

- (void) retrieveStrengthLeaderBoardBetweenMinRank:(int)minRank maxRank:(int)maxRank delegate:(id)delegate;

@end
