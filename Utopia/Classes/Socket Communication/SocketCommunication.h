//
//  SocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

//#import "GCDAsyncSocket.h"

#import "MobstersEventProtocol.pb.h"
#import "StoreKit/StoreKit.h"
#import "UserData.h"

#import "AMQPWrapper.h"
#import "AMQPConnectionThread.h"
#import "AMQPConnectionThreadDelegate.h"

@interface SocketCommunication : NSObject <UIAlertViewDelegate, AMQPConnectionThreadDelegate> {
  BOOL _shouldReconnect;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
  
  NSTimer *_flushTimer;
  
  int _numDisconnects;
  
  int _numBuyInventorySlots;
  
  BOOL _healingQueuePotentiallyChanged;
  int _healingQueueCashChange;
  int _healingQueueGemCost;
  
  BOOL _enhancementPotentiallyChanged;
  int _enhanceQueueCashChange;
  int _enhanceQueueGemCost;
}

@property (nonatomic, retain) AMQPConnectionThread *connectionThread;

@property (nonatomic, retain) NSMutableArray *structRetrievals;

@property (nonatomic, retain) NSArray *healingQueueSnapshot;
@property (nonatomic, retain) UserEnhancement *enhancementSnapshot;

@property (nonatomic, retain) NSMutableDictionary *tagDelegates;

- (NSString *) getIFA;
- (NSString *) getIPAddress;
- (NSString *) getMacAddress;

- (void) reloadClanMessageQueue;
- (void) rebuildSender;

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunicationWithDelegate:(id)delegate;
- (void) initUserIdMessageQueue;
- (void) closeDownConnection;
- (void) messageReceived:(NSData *)buffer withType:(MobstersEventProtocolResponse)eventType tag:(int)tag;
- (void) setDelegate:(id)delegate forTag:(int)tag;

// Send different event messages
- (int) sendUserCreateMessageWithName:(NSString *)name lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense energy:(int)energy stamina:(int)stamina structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild;

- (int) sendStartupMessage:(uint64_t)clientTime;
- (int) sendLogoutMessage;
- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product;

// Norm Struct messages
- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time;
- (int) sendMoveNormStructureMessage:(NSString *)userStructUuid x:(int)x y:(int)y;
- (int) sendRotateNormStructureMessage:(NSString *)userStructUuid orientation:(StructOrientation)orientation;
- (int) sendUpgradeNormStructureMessage:(NSString *)userStructUuid time:(uint64_t)curTime;
- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructUuids time:(uint64_t)curTime;
- (int) sendFinishNormStructBuildWithDiamondsMessage:(NSString *)userStructUuid gemCost:(int)gemCost time:(uint64_t)milliseconds;
- (int) sendSellNormStructureMessage:(NSString *)userStructUuid;

- (int) sendLoadPlayerCityMessage:(NSString *)userUuid;
- (int) sendLoadCityMessage:(int)cityId;

- (int) sendLevelUpMessage;

- (int) sendQuestAcceptMessage:(int)questId;
- (int) sendQuestProgressMessage:(int)questId progress:(int)progress isComplete:(BOOL)isComplete userMonsterUuids:(NSArray *)userMonsterUuids;
- (int) sendQuestRedeemMessage:(int)questId;

- (int) sendRetrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam;

- (int) sendAPNSMessage:(NSString *)deviceToken;

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time;

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime;

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly;
- (int) sendLeaveClanMessage;
- (int) sendRequestJoinClanMessage:(NSString *)clanUuid;
- (int) sendRetractRequestJoinClanMessage:(NSString *)clanUuid;
- (int) sendApproveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept;
- (int) sendTransferClanOwnership:(NSString *)ownerUuid;
- (int) sendChangeClanDescription:(NSString *)description;
- (int) sendChangeClanJoinType:(BOOL)requestToJoinRequired;
- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList;
- (int) sendBootPlayerFromClan:(NSString *)playerUuid;

- (int) sendPurchaseCityExpansionMessageAtX:(int)x atY:(int)y timeOfPurchase:(uint64_t)time;
- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp gemCost:(int)gemCost curTime:(uint64_t)time atX:(int)x atY:(int)y;

- (int) sendRetrieveTournamentRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank;

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId clientTime:(uint64_t)clientTime;

- (int) sendPrivateChatPostMessage:(NSString *)recipientUuid content:(NSString *)content;
- (int) sendRetrievePrivateChatPostsMessage:(NSString *)otherUserUuid;

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId;
- (int) sendUpdateMonsterHealthMessage:(uint64_t)clientTime monsterHealth:(UserMonsterCurrentHealthProto *)monsterHealth;
- (int) sendEndDungeonMessage:(NSString *)userTaskUuid userWon:(BOOL)userWon isFirstTimeCompleted:(BOOL)isFirstTimeCompleted time:(uint64_t)time;

- (int) retrieveCurrencyFromStruct:(NSString *)userStructUuid time:(uint64_t)time;

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths;
- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost;
- (int) sendAddMonsterToTeam:(NSString *)userMonsterUuid teamSlot:(int)teamSlot;
- (int) sendRemoveMonsterFromTeam:(NSString *)userMonsterUuid;
- (int) buyInventorySlots;
- (int) sendCombineUserMonsterPiecesMessage:(NSArray *)userMonsterUuids gemCost:(int)gemCost;
- (int) sendInviteFbFriendsForSlotsMessage:(NSArray *)fbFriendIds;
- (int) sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids;
- (void) reloadHealQueueSnapshot;
- (int) setHealQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost;

- (int) sendEnhanceQueueWaitTimeComplete:(UserMonsterCurrentExpProto *)monsterExp userMonsterUuids:(NSArray *)userMonsterUuids;
- (int) sendEnhanceQueueSpeedup:(UserMonsterCurrentExpProto *)monsterExp userMonsterUuids:(NSArray *)userMonsterUuids goldCost:(int)goldCost;
- (int) setEnhanceQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost;
- (void) reloadEnhancementSnapshot;

- (void) flush;
- (void) flushAllExceptEventType:(int)val;
- (void) flushAllExcept:(NSNumber *)type;

@end