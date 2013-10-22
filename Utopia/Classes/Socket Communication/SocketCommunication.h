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

#define CONNECTED_TO_HOST_DELEGATE_TAG 9999

@interface SocketCommunication : NSObject <UIAlertViewDelegate, AMQPConnectionThreadDelegate> {
  BOOL _shouldReconnect;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
  
  AMQPConnectionThread *_connectionThread;
  
  NSTimer *_flushTimer;
  
  int _numDisconnects;
  
  BOOL _healingQueuePotentiallyChanged;
  BOOL _enhancementPotentiallyChanged;
}

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
- (void) initNetworkCommunication;
- (void) initUserIdMessageQueue;
- (void) closeDownConnection;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse)eventType tag:(int)tag;
- (void) setDelegate:(id)delegate forTag:(int)tag;

// Send different event messages
- (int) sendUserCreateMessageWithName:(NSString *)name lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense energy:(int)energy stamina:(int)stamina structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild;

- (int) sendStartupMessage:(uint64_t)clientTime;
- (int) sendLogoutMessage;
- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product;

// Norm Struct messages
- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time;
- (int) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (int) sendRotateNormStructureMessage:(int)userStructId orientation:(StructOrientation)orientation;
- (int) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime;
- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime;
- (int) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds;
- (int) sendSellNormStructureMessage:(int)userStructId;

- (int) sendLoadPlayerCityMessage:(int)userId;
- (int) sendLoadCityMessage:(int)cityId;

- (int) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds events:(BOOL)events bossIds:(NSArray *)bossIds;

- (int) sendLevelUpMessage;

- (int) sendQuestAcceptMessage:(int)questId;
- (int) sendQuestRedeemMessage:(int)questId;
- (int) sendUserQuestDetailsMessage:(int)questId;

- (int) sendRetrieveUsersForUserIds:(NSArray *)userIds;

- (int) sendAPNSMessage:(NSString *)deviceToken;

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time;

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime;

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly;
- (int) sendLeaveClanMessage;
- (int) sendRequestJoinClanMessage:(int)clanId;
- (int) sendRetractRequestJoinClanMessage:(int)clanId;
- (int) sendApproveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept;
- (int) sendTransferClanOwnership:(int)newClanOwnerId;
- (int) sendChangeClanDescription:(NSString *)description;
- (int) sendChangeClanJoinType:(BOOL)requestToJoinRequired;
- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId;
- (int) sendBootPlayerFromClan:(int)playerId;

- (int) sendPurchaseCityExpansionMessageAtX:(int)x atY:(int)y timeOfPurchase:(uint64_t)time;
- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp curTime:(uint64_t)time atX:(int)x atY:(int)y;

- (int) sendRetrieveTournamentRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank;

- (int) sendRetrieveBoosterPackMessage;
- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId clientTime:(uint64_t)clientTime;

- (int) sendPrivateChatPostMessage:(int)recipientId content:(NSString *)content;
- (int) sendRetrievePrivateChatPostsMessage:(int)otherUserId;

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId;

- (int) retrieveCurrencyFromStruct:(int)userStructId time:(uint64_t)time;

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths;
- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost;
- (void) reloadHealQueueSnapshot;
- (int) setHealQueueDirty;

- (int) sendEnhanceQueueWaitTimeComplete:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds;
- (int) sendEnhanceQueueSpeedup:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds goldCost:(int)goldCost;
- (int) setEnhanceQueueDirty;
- (void) reloadEnhancementSnapshot;

- (void) flush;
- (void) flushWithInt:(int)val;
- (void) flush:(NSNumber *)type;

@end