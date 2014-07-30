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
  BOOL _isCreatingQueues;
  BOOL _canSendPreDbEvents;
  
  BOOL _healingQueuePotentiallyChanged;
  int _healingQueueCashChange;
  int _healingQueueGemCost;
  
  BOOL _enhancementPotentiallyChanged;
  int _enhanceQueueOilChange;
  int _enhanceQueueGemCost;
  
  NSDate *_lastFlushedTime;
}

@property (nonatomic, retain) GenericPopupController *popupController;

@property (nonatomic, retain) AMQPConnectionThread *connectionThread;

@property (nonatomic, retain) NSMutableArray *queuedMessages;

@property (nonatomic, retain) NSMutableArray *structRetrievals;
@property (nonatomic, retain) NSMutableDictionary *structRetrievalAchievements;
@property (nonatomic, assign) uint64_t lastClientTime;

@property (nonatomic, retain) NSArray *healingQueueSnapshot;
@property (nonatomic, retain) UserEnhancement *enhancementSnapshot;

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
- (void) initNetworkCommunicationWithDelegate:(id)delegate;
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
- (int) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (int) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost;
- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime;
- (int) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId gemCost:(int)gemCost time:(uint64_t)milliseconds;

- (int) sendLoadPlayerCityMessage:(int)userId;
- (int) sendLoadCityMessage:(int)cityId;

- (int) sendLevelUpMessage:(int)level;

- (int) sendQuestAcceptMessage:(int)questId;
- (int) sendQuestProgressMessage:(int)questId isComplete:(BOOL)isComplete userQuestJobs:(NSArray *)userQuestJobs userMonsterIds:(NSArray *)userMonsterIds;
- (int) sendQuestRedeemMessage:(int)questId;

- (int) sendAchievementProgressMessage:(NSArray *)userAchievements clientTime:(uint64_t)clientTime;
- (int) sendAchievementRedeemMessage:(int)achievementId clientTime:(uint64_t)clientTime;

- (int) sendRetrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam;

- (int) sendAPNSMessage:(NSString *)deviceToken;
- (int) sendSetGameCenterMessage:(NSString *)gameCenterId;
- (int) sendSetFacebookIdMessage:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSString *)otherFbInfo;

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time;

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime;

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly iconId:(int)iconId cashChange:(int)cashChange gemsSpent:(int)gemsSpent;
- (int) sendLeaveClanMessage;
- (int) sendRequestJoinClanMessage:(int)clanId;
- (int) sendRetractRequestJoinClanMessage:(int)clanId;
- (int) sendApproveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept;
- (int) sendTransferClanOwnership:(int)newClanOwnerId;
- (int) sendChangeClanDescription:(BOOL)isDescription description:(NSString *)description isRequestType:(BOOL)isRequestType requestRequired:(BOOL)requestRequired isIcon:(BOOL)isIcon iconId:(int)iconId;
- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId;
- (int) sendPromoteDemoteClanMemberMessage:(int)victimId newStatus:(UserClanStatus)status;
- (int) sendBootPlayerFromClan:(int)playerId;

- (int) sendPurchaseCityExpansionMessageAtX:(int)x atY:(int)y timeOfPurchase:(uint64_t)time;
- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp gemCost:(int)gemCost curTime:(uint64_t)time atX:(int)x atY:(int)y;

- (int) sendRetrieveTournamentRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank;

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId clientTime:(uint64_t)clientTime;

- (int) sendPrivateChatPostMessage:(int)recipientId content:(NSString *)content;
- (int) sendRetrievePrivateChatPostsMessage:(int)otherUserId;

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId gems:(int)gems enemyElement:(Element)element shouldForceElem:(BOOL)shouldForceElem alreadyCompletedMiniTutorialTask:(BOOL)alreadyCompletedMiniTutorialTask questIds:(NSArray *)questIds;
- (int) sendUpdateMonsterHealthMessage:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths isForTask:(BOOL)isForTask userTaskId:(int64_t)userTaskId taskStageId:(int)taskStageId;
- (int) sendEndDungeonMessage:(uint64_t)userTaskId userWon:(BOOL)userWon isFirstTimeCompleted:(BOOL)isFirstTimeCompleted time:(uint64_t)time;
- (int) sendReviveInDungeonMessage:(uint64_t)userTaskId clientTime:(uint64_t)clientTime userHealths:(NSArray *)healths gems:(int)gems;

- (int) sendQueueUpMessage:(NSArray *)seenUserIds clientTime:(uint64_t)clientTime;
- (int) sendUpdateUserCurrencyMessageWithCashSpent:(int)cashSpent oilSpent:(int)oilSpent gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime reason:(NSString *)reason;
- (int) sendBeginPvpBattleMessage:(PvpProto *)enemy senderElo:(int)elo isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime clientTime:(uint64_t)clientTime;
- (int) sendEndPvpBattleMessage:(int)defenderId userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon oilChange:(int)oilChange cashChange:(int)cashChange clientTime:(uint64_t)clientTime;

- (int) sendBeginClanRaidMessage:(int)raidId eventId:(int)eventId isFirstStage:(BOOL)isFirstStage curTime:(uint64_t)curTime userMonsters:(NSArray *)userMonsters;
- (int) sendAttackClanRaidMonsterMessage:(PersistentClanEventClanInfoProto *)eventDetails clientTime:(uint64_t)clientTime damageDealt:(int)damageDealt curTeam:(UserCurrentMonsterTeamProto *)curTeam monsterHealths:(NSArray *)monsterHealths attacker:(FullUserMonsterProto *)attacker;

- (int) retrieveCurrencyFromStruct:(int)userStructId time:(uint64_t)time amountCollected:(int)amountCollected;

- (int) sendSpawnObstacleMessage:(NSArray *)obstacles clientTime:(uint64_t)clientTime;
- (int) sendBeginObstacleRemovalMessage:(int)userObstacleId resType:(ResourceType)resType resChange:(int)resChange gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime;
- (int) sendObstacleRemovalCompleteMessage:(int)userObstacleId speedup:(BOOL)speedUp gemsSpent:(int)gemsSpent maxObstacles:(BOOL)maxObstacles clientTime:(uint64_t)clientTime;

- (int) sendEvolveMonsterMessageWithEvolution:(UserMonsterEvolutionProto *)evo gemCost:(int)gemCost oilChange:(int)oilChange;
- (int) sendEvolutionFinishedMessageWithGems:(int)gems;

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths;
- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost;
- (int) sendAddMonsterToTeam:(uint64_t)userMonsterId teamSlot:(int)teamSlot;
- (int) sendRemoveMonsterFromTeam:(uint64_t)userMonsterId;
- (int) sendBuyInventorySlotsWithGems:(int)userStructId;
- (int) sendBuyInventorySlots:(int)userStructId withFriendInvites:(NSArray *)inviteIds;
- (int) sendCombineUserMonsterPiecesMessage:(NSArray *)userMonsterIds gemCost:(int)gemCost;
- (int) sendSellUserMonstersMessage:(NSArray *)sellProtos;
- (int) sendInviteFbFriendsForSlotsMessage:(NSArray *)fbFriendIds;
- (int) sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds;
- (void) reloadHealQueueSnapshot;
- (int) setHealQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost;

- (int) sendEnhanceQueueWaitTimeComplete:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds;
- (int) sendEnhanceQueueSpeedup:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds goldCost:(int)goldCost;
- (int) setEnhanceQueueDirtyWithOilChange:(int)coinChange gemCost:(int)gemCost;
- (void) reloadEnhancementSnapshot;

- (int) sendSpawnMiniJobMessage:(int)numToSpawn clientTime:(uint64_t)clientTime structId:(int)structId;
- (int) sendBeginMiniJobMessage:(uint64_t)userMiniJobId userMonsterIds:(NSArray *)userMonsterIds clientTime:(uint64_t)clientTime;
- (int) sendCompleteMiniJobMessage:(uint64_t)userMiniJobId isSpeedUp:(BOOL)isSpeedUp gemCost:(int)gemCost clientTime:(uint64_t)clientTime;
- (int) sendRedeemMiniJobMessage:(uint64_t)userMiniJobId clientTime:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths ;
- (int) sendSetAvatarMonsterMessage:(int)avatarMonsterId;

- (int) sendDevRequestProto:(DevRequest)request num:(int)num;

- (BOOL) flush;
- (BOOL) flushAllExceptEventType:(int)val;
- (BOOL) flushAllExcept:(NSNumber *)type;

@end