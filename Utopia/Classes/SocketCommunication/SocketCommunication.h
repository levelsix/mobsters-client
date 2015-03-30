//
//  SocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

//#import "GCDAsyncSocket.h"

#import "Protocols.pb.h"
#import "StoreKit/StoreKit.h"
#import "UserData.h"

#import "AMQPWrapper.h"
#import "AMQPConnectionThread.h"
#import "AMQPConnectionThreadDelegate.h"

#import "GenericPopupController.h"

@interface SocketCommunication : NSObject <UIAlertViewDelegate, AMQPConnectionThreadDelegate> {
  BOOL _shouldReconnect;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
  
  NSTimer *_flushTimer;
  
  int _numDisconnects;
  BOOL _canSendRegularEvents;
  BOOL _canSendPreDbEvents;
  
  BOOL _healingQueuePotentiallyChanged;
  int _healingQueueCashChange;
  int _healingQueueGemCost;
  
  BOOL _battleItemQueuePotentiallyChanged;
  int _battleItemQueueCashChange;
  int _battleItemQueueOilChange;
  int _battleItemQueueGemCost;
  
  NSMutableArray *_speedupItemUsages;
  NSMutableArray *_speedupUpdatedUserItems;
  
  NSMutableArray *_resourceItemIdsUsed;
  NSMutableArray *_resourceUpdatedUserItems;
  
  NSDate *_lastFlushedTime;
  BOOL _pauseFlushTimer;
  
  NSData *_latestTaskClientState;
}

@property (nonatomic, retain) GenericPopupController *popupController;

@property (nonatomic, retain) AMQPConnectionThread *connectionThread;

@property (nonatomic, retain) NSMutableArray *queuedMessages;

@property (nonatomic, retain) NSMutableArray *structRetrievals;
@property (nonatomic, retain) NSMutableDictionary *structRetrievalAchievements;
@property (nonatomic, assign) uint64_t lastClientTime;

@property (nonatomic, retain) NSArray *healingQueueSnapshot;
@property (nonatomic, retain) NSArray *battleItemQueueSnapshot;

@property (nonatomic, retain) NSMutableDictionary *tagDelegates;
@property (nonatomic, retain) NSMutableArray *clanEventDelegates;

+ (BOOL) isForcedTutorial;
+ (NSString *) getUdid;

//- (NSString *) getIFA;
- (NSString *) getIPAddress;
- (NSString *) getMacAddress;

- (void) reloadClanMessageQueue;
- (void) rebuildSender;

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunicationWithDelegate:(id)delegate clearMessages:(BOOL)clearMessages;
- (void) initUserIdMessageQueue;
- (void) closeDownConnection;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse)eventType tag:(int)tag;
- (void) setDelegate:(id)delegate forTag:(int)tag;

- (void) addClanEventObserver:(id)object;
- (void) removeClanEventObserver:(id)object;

// Send different event messages
- (int) sendUserCreateMessageWithName:(NSString *)name facebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSString *)otherFbInfo structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems;

- (int) sendStartupMessageWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart clientTime:(uint64_t)clientTime;
- (int) sendLogoutMessage;

- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product;
- (int) sendExchangeGemsForResourcesMessage:(int)gems resources:(int)resources resType:(ResourceType)resType clientTime:(uint64_t)clientTime;

// Norm Struct messages
- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost;
- (int) sendMoveNormStructureMessage:(NSString *)userStructUuid x:(int)x y:(int)y;
- (int) sendUpgradeNormStructureMessage:(NSString *)userStructUuid time:(uint64_t)curTime resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost queueUp:(BOOL)queueUp;
- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructUuids time:(uint64_t)curTime;
- (int) sendFinishNormStructBuildWithDiamondsMessage:(NSString *)userStructUuid gemCost:(int)gemCost time:(uint64_t)milliseconds queueUp:(BOOL)queueUp;
- (int) retrieveCurrencyFromStruct:(NSString *)userStructUuid time:(uint64_t)time amountCollected:(int)amountCollected;

- (int) sendLoadPlayerCityMessage:(NSString *)userUuid;
- (int) sendLoadCityMessage:(int)cityId;

- (int) sendLevelUpMessage:(int)level;

- (int) sendQuestAcceptMessage:(int)questId;
- (int) sendQuestProgressMessage:(int)questId isComplete:(BOOL)isComplete userQuestJobs:(NSArray *)userQuestJobs userMonsterUuids:(NSArray *)userMonsterUuids;
- (int) sendQuestRedeemMessage:(int)questId;

- (int) sendAchievementProgressMessage:(NSArray *)userAchievements clientTime:(uint64_t)clientTime;
- (int) sendAchievementRedeemMessage:(int)achievementId clientTime:(uint64_t)clientTime;

- (int) sendBeginResearchMessage:(int)researchId uuid:(NSString*)uuid clientTime:(uint64_t)clientTime gems:(int)gems resourceType:(ResourceType)resourceType resourceCost:(int)resourceCost;
- (int) sendFinishPerformingResearchRequestProto:(NSString *)uuid gemsSpent:(int)gemsSpent;

- (int) sendRetrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam;

- (int) sendAPNSMessage:(NSString *)deviceToken;
- (int) sendSetGameCenterMessage:(NSString *)gameCenterId;
- (int) sendSetFacebookIdMessage:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSString *)otherFbInfo;

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time;

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime;

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly iconId:(int)iconId cashChange:(int)cashChange gemsSpent:(int)gemsSpent;
- (int) sendLeaveClanMessage;
- (int) sendRequestJoinClanMessage:(NSString *)clanUuid;
- (int) sendRetractRequestJoinClanMessage:(NSString *)clanUuid;
- (int) sendApproveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept;
- (int) sendTransferClanOwnership:(NSString *)newClanOwnerUuid;
- (int) sendChangeClanDescription:(BOOL)isDescription description:(NSString *)description isRequestType:(BOOL)isRequestType requestRequired:(BOOL)requestRequired isIcon:(BOOL)isIcon iconId:(int)iconId;
- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList;
- (int) sendPromoteDemoteClanMemberMessage:(NSString *)victimUuid newStatus:(UserClanStatus)status;
- (int) sendBootPlayerFromClan:(NSString *)playerUuid;

- (int) sendSolicitClanHelpMessage:(NSArray *)clanHelpNotices maxHelpers:(int)maxHelpers clientTime:(uint64_t)clientTime;
- (int) sendGiveClanHelpMessage:(NSArray *)clanHelpUuids;
- (int) sendEndClanHelpMessage:(NSArray *)clanHelpUuids;

- (int) sendRemoveUserItemUsedMessage:(NSArray *)usageUuids;

- (int) sendPurchaseCityExpansionMessageAtX:(int)x atY:(int)y timeOfPurchase:(uint64_t)time;
- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp gemCost:(int)gemCost curTime:(uint64_t)time atX:(int)x atY:(int)y;

- (int) sendRetrieveTournamentRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank;

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId isFree:(BOOL)free clientTime:(uint64_t)clientTime;
- (int) sendTradeItemForBoosterMessage:(int)itemId clientTime:(uint64_t)clientTime;

- (int) sendPrivateChatPostMessage:(NSString *)recipientUuid content:(NSString *)content;
- (int) sendRetrievePrivateChatPostsMessage:(NSString *)otherUserUuid;

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId gems:(int)gems enemyElement:(Element)element shouldForceElem:(BOOL)shouldForceElem alreadyCompletedMiniTutorialTask:(BOOL)alreadyCompletedMiniTutorialTask questIds:(NSArray *)questIds;
- (int) sendUpdateMonsterHealthMessage:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths isForTask:(BOOL)isForTask userTaskUuid:(NSString *)userTaskUuid taskStageId:(int)taskStageId droplessTsfuUuid:(NSString *)droplessTsfuUuid;
- (int) sendEndDungeonMessage:(NSString *)userTaskUuid userWon:(BOOL)userWon isFirstTimeCompleted:(BOOL)isFirstTimeCompleted droplessTsfuUuids:(NSArray *)droplessTsfuUuids time:(uint64_t)time;
- (int) sendReviveInDungeonMessage:(NSString *)userTaskUuid clientTime:(uint64_t)clientTime userHealths:(NSArray *)healths gems:(int)gems;
- (int) updateClientTaskStateMessage:(NSData *)data;

- (int) sendQueueUpMessage:(NSArray *)seenUserUuids clientTime:(uint64_t)clientTime;
- (int) sendUpdateUserCurrencyMessageWithCashSpent:(int)cashSpent oilSpent:(int)oilSpent gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime reason:(NSString *)reason;
- (int) sendBeginPvpBattleMessage:(PvpProto *)enemy senderElo:(int)elo isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime clientTime:(uint64_t)clientTime;
- (int) sendEndPvpBattleMessage:(NSString *)defenderUuid userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon oilChange:(int)oilChange cashChange:(int)cashChange clientTime:(uint64_t)clientTime monsterDropIds:(NSArray *)monsterDropIds;

- (int) sendBeginClanRaidMessage:(int)raidId eventId:(int)eventId isFirstStage:(BOOL)isFirstStage curTime:(uint64_t)curTime userMonsters:(NSArray *)userMonsters;
- (int) sendAttackClanRaidMonsterMessage:(PersistentClanEventClanInfoProto *)eventDetails clientTime:(uint64_t)clientTime damageDealt:(int)damageDealt curTeam:(UserCurrentMonsterTeamProto *)curTeam monsterHealths:(NSArray *)monsterHealths attacker:(FullUserMonsterProto *)attacker;

- (int) sendSpawnObstacleMessage:(NSArray *)obstacles clientTime:(uint64_t)clientTime;
- (int) sendBeginObstacleRemovalMessage:(NSString *)userObstacleUuid resType:(ResourceType)resType resChange:(int)resChange gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime;
- (int) sendObstacleRemovalCompleteMessage:(NSString *)userObstacleUuid speedup:(BOOL)speedUp gemsSpent:(int)gemsSpent maxObstacles:(BOOL)maxObstacles clientTime:(uint64_t)clientTime;

- (int) sendEvolveMonsterMessageWithEvolution:(UserMonsterEvolutionProto *)evo gemCost:(int)gemCost oilChange:(int)oilChange;
- (int) sendEvolutionFinishedMessageWithGems:(int)gems;

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths;
- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost;
- (int) sendAddMonsterToTeam:(NSString *)userMonsterUuid teamSlot:(int)teamSlot;
- (int) sendRemoveMonsterFromTeam:(NSString *)userMonsterUuid;
- (int) sendBuyInventorySlotsWithGems:(NSString *)userStructUuid;
- (int) sendBuyInventorySlots:(NSString *)userStructUuid withFriendInvites:(NSArray *)inviteIds;
- (int) sendCombineUserMonsterPiecesMessage:(NSArray *)userMonsterUuids gemCost:(int)gemCost;
- (int) sendSellUserMonstersMessage:(NSArray *)sellProtos;
- (int) sendInviteFbFriendsForSlotsMessage:(NSArray *)fbFriendIds;
- (int) sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids;
- (void) reloadHealQueueSnapshot;
- (int) setHealQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost;

- (int) sendEnhanceMessage:(UserEnhancementProto *)enhancement monsterExp:(UserMonsterCurrentExpProto *)monsterExp gemCost:(int)gemCost oilChange:(int)oilChange;
- (int) sendSubmitEnhancementMessage:(NSArray *)items gemCost:(int)gemCost oilChange:(int)oilChange;
- (int) sendEnhanceWaitCompleteMessage:(NSString *)userMonsterUuid isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost;
- (int) sendCollectMonsterEnhancementMessage:(UserMonsterCurrentExpProto *)exp userMonsterUuids:(NSArray *)userMonsterUuids;

- (int) sendSpawnMiniJobMessage:(int)numToSpawn clientTime:(uint64_t)clientTime structId:(int)structId;
- (int) sendBeginMiniJobMessage:(NSString *)userMiniJobUuid userMonsterUuids:(NSArray *)userMonsterUuids clientTime:(uint64_t)clientTime;
- (int) sendCompleteMiniJobMessage:(NSString *)userMiniJobUuid isSpeedUp:(BOOL)isSpeedUp gemCost:(int)gemCost clientTime:(uint64_t)clientTime;
- (int) sendRedeemMiniJobMessage:(NSString *)userMiniJobUuid clientTime:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths;

- (int) sendSetAvatarMonsterMessage:(int)avatarMonsterId;
- (int) sendSetDefendingMsgMessage:(NSString *)newMsg;
- (int) sendRestrictUserMonsterMessage:(NSArray *)userMonsterUuids;
- (int) sendUnrestrictUserMonsterMessage:(NSArray *)userMonsterUuids;
- (int) sendUpdateUserStrengthMessage:(uint64_t)newStrength;

- (int) sendDevRequestProto:(DevRequest)request staticDataId:(int)staticDataId quantity:(int)quantity;

- (int) sendRedeemSecretGiftMessage:(NSArray *)uisgIds clientTime:(uint64_t)clientTime;
- (int) tradeItemForSpeedups:(NSArray *)uiups updatedUserItem:(UserItemProto *)uip;

// First one is the non-batched one, second one batches
- (int) sendTradeItemForResourcesMessage:(NSArray *)itemIdsUsed updatedUserItems:(NSArray *)updatedUserItems clientTime:(uint64_t)clientTime;
- (int) tradeItemForResources:(int)itemId updatedUserItem:(UserItemProto *)uip clientTime:(uint64_t)clientTime;

- (int) sendBeginClanAvengingMessage:(NSArray *)pvpHistories clientTime:(uint64_t)clientTime;
- (int) sendEndClanAvengingMessage:(NSArray *)avengeUuids;
- (int) sendAvengeClanMateMessage:(PvpClanAvengeProto *)ca clientTime:(uint64_t)clientTime;

- (int) sendSolicitTeamDonationMessage:(NSString *)msg powerLimit:(int)powerLimit clientTime:(uint64_t)clientTime gemsSpent:(int)gemsSpent;
- (int) sendFulfillTeamDonationSolicitationMessage:(FullUserMonsterProto *)fump solicitation:(ClanMemberTeamDonationProto *)solicitation clientTime:(uint64_t)clientTime;
- (int) sendVoidTeamDonationSolicitationMessage:(NSArray *)solicitations;

- (int) sendRetrieveUserMonsterTeamMessage:(NSArray *)userUuids;

- (int) sendCustomizePvpBoardObstacleMessage:(NSArray *)removeUpboIds nuOrUpdatedObstacles:(NSArray *)nuOrUpdatedObstacles;

- (int) setBattleItemQueueDirtyWithCoinChange:(int)coinChange oilChange:(int)oilChange gemCost:(int)gemCost;
- (void) reloadBattleItemQueueSnapshot;
- (int) sendBattleItemQueueMessage;
- (int) sendCompleteBattleItemMessage:(NSArray *)completedBiqfus isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost;
- (int) sendDiscardBattleItemMessage:(NSArray *)battleItemIds;

- (int) sendRetrieveMiniEventRequestProtoMessage;

- (void) flush;
- (void) pauseFlushTimer;
- (void) resumeFlushTimer;

@end