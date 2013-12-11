//
//  SocketCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "SocketCommunication.h"
#import "LNSynthesizeSingleton.h"
#import "IncomingEventController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
//#import "Apsalar.h"
#import "ClientProperties.h"
#import "FullEvent.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "GameState.h"
#import <AdSupport/AdSupport.h>

// Tags for keeping state
#define READING_HEADER_TAG -1
#define HEADER_SIZE 12

#define RECONNECT_TIMEOUT 0.5f
#define NUM_SILENT_RECONNECTS 1

#define CONNECTED_TO_HOST_DELEGATE_TAG 9999

@implementation SocketCommunication

SYNTHESIZE_SINGLETON_FOR_CLASS(SocketCommunication);

static NSString *udid = nil;

- (NSString *)getIPAddress
{
  NSURL *url = [[NSURL alloc] initWithString:@"http://checkip.dyndns.com/"];
  NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSStringEncodingConversionAllowLossy error:nil];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.\\d+\\.\\d+\\.\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
  NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
  if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
    NSString *substringForFirstMatch = [contents substringWithRange:rangeOfFirstMatch];
    LNLog(@"IP Address: %@", substringForFirstMatch);
    return substringForFirstMatch;
  }
  return nil;
}

- (NSString *)getMacAddress
{
  int                 mgmtInfoBase[6];
  char                *msgBuffer = NULL;
  size_t              length;
  unsigned char       macAddress[6];
  struct if_msghdr    *interfaceMsgStruct;
  struct sockaddr_dl  *socketStruct;
  NSString            *errorFlag = NULL;
  
  // Setup the management Information Base (mib)
  mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
  mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
  mgmtInfoBase[2] = 0;
  mgmtInfoBase[3] = AF_LINK;        // Request link layer information
  mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
  
  // With all configured interfaces requested, get handle index
  if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
    errorFlag = @"if_nametoindex failure";
  else
  {
    // Get the size of the data available (store in len)
    if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
      errorFlag = @"sysctl mgmtInfoBase failure";
    else
    {
      // Alloc memory based on above call
      if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
      else
      {
        // Get system information, store in buffer
        if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
          errorFlag = @"sysctl msgBuffer failure";
      }
    }
  }
  
  // Befor going any further...
  if (errorFlag != NULL)
  {
    free(msgBuffer);
    NSLog(@"Error: %@", errorFlag);
    return errorFlag;
  }
  
  // Map msgbuffer to interface message structure
  interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
  
  // Map to link-level socket structure
  socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
  
  // Copy link layer address data in socket structure to an array
  memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
  
  // Read from char array into a string object, into traditional Mac address format
  NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                macAddress[0], macAddress[1], macAddress[2],
                                macAddress[3], macAddress[4], macAddress[5]];
  
  // Release the buffer memory
  free(msgBuffer);
  
  return macAddressString;
}

- (NSString *) getIFA {
  ASIdentifierManager *as = [ASIdentifierManager sharedManager];
  NSString *advertiserId = as.advertisingIdentifier.UUIDString;
  return advertiserId;
}

- (id) init {
  if ((self = [super init])) {
#ifdef FORCE_TUTORIAL
    udid = [[NSString stringWithFormat:@"%d%d%d", arc4random(), arc4random(), arc4random()] retain];
#else
    udid = UDID;
#endif
    
    self.connectionThread = [[AMQPConnectionThread alloc] init];
    [self.connectionThread start];
    [self.connectionThread setName:@"AMQPConnectionThread"];
    self.connectionThread.delegate = self;
  }
  return self;
}

- (void) rebuildSender {
  int oldClanId = _sender.clan.clanId;
  GameState *gs = [GameState sharedGameState];
  _sender = gs.minUser;
  
  // if clan changes, reload the queue
  if (oldClanId != _sender.clan.clanId) {
    [self reloadClanMessageQueue];
  }
}

- (void) initNetworkCommunicationWithDelegate:(id)delegate {
  [self.connectionThread connect:udid];
  
  [self rebuildSender];
  _currentTagNum = 1;
  _shouldReconnect = YES;
  _numDisconnects = 0;
  
  self.structRetrievals = [NSMutableArray array];
  
  self.tagDelegates = [NSMutableDictionary dictionary];
  [self setDelegate:delegate forTag:CONNECTED_TO_HOST_DELEGATE_TAG];
}

- (void) reloadClanMessageQueue {
  [self.connectionThread reloadClanMessageQueue];
}

- (void) connectedToHost {
  LNLog(@"Connected to host");
  
  NSObject *delegate = [self.tagDelegates objectForKey:[NSNumber numberWithInt:CONNECTED_TO_HOST_DELEGATE_TAG]];
  if (delegate) {
    SEL selector = @selector(handleConnectedToHost);
    if ([delegate respondsToSelector:selector]) {
      [delegate performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
    }
  }
  
  _flushTimer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(flush) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:_flushTimer forMode:NSRunLoopCommonModes];
  
  _numDisconnects = 0;
}

- (void) initUserIdMessageQueue {
  [self.connectionThread startUserIdQueue];
  
  LNLog(@"Created user id queue");
}

- (void) tryReconnect {
  [self.connectionThread connect:udid];
}

- (void) unableToConnectToHost:(NSString *)error
{
	LNLog(@"Unable to connect: %@", error);
  
  if (_shouldReconnect) {
    _numDisconnects++;
    if (_numDisconnects > NUM_SILENT_RECONNECTS) {
      LNLog(@"Asking to reconnect..");
      [GenericPopupController displayNotificationViewWithText:@"Sorry, we are unable to connect to the server. Please try again." title:@"Disconnected!" okayButton:@"Reconnect" target:self selector:@selector(tryReconnect)];
      _numDisconnects = 0;
    } else {
      LNLog(@"Silently reconnecting..");
      [self tryReconnect];
    }
  }
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type flush:(BOOL)flush {
  if (flush) {
    [self flush];
  }
  
  NSMutableData *messageWithHeader = [NSMutableData data];
  NSData *data = [msg data];
  
  GameState *gs = [GameState sharedGameState];
  if (_sender.userId == 0 || !gs.connected) {
    if (type != EventProtocolRequestCStartupEvent&& type != EventProtocolRequestCUserCreateEvent) {
      LNLog(@"User id is 0 or GameState is not connected!!!");
      LNLog(@"Did not send event of type %@.", NSStringFromClass(msg.class));
      return 0;
    }
  }
  
  // Need to reverse bytes for size and type(to account for endianness??)
  uint8_t header[HEADER_SIZE];
  header[3] = type & 0xFF;
  header[2] = (type & 0xFF00) >> 8;
  header[1] = (type & 0xFF0000) >> 16;
  header[0] = (type & 0xFF000000) >> 24;
  
  header[7] = _currentTagNum & 0xFF;
  header[6] = (_currentTagNum & 0xFF00) >> 8;
  header[5] = (_currentTagNum & 0xFF0000) >> 16;
  header[4] = (_currentTagNum & 0xFF000000) >> 24;
  
  int size = [data length];
  header[11] = size & 0xFF;
  header[10] = (size & 0xFF00) >> 8;
  header[9] = (size & 0xFF0000) >> 16;
  header[8] = (size & 0xFF000000) >> 24;
  
  [messageWithHeader appendBytes:header length:sizeof(header)];
  [messageWithHeader appendData:data];
  
  [self.connectionThread sendData:messageWithHeader];
  
  int tag = _currentTagNum;
  _currentTagNum++;
  return tag;
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type {
  return [self sendData:msg withMessageType:type flush:YES];
}

- (void) amqpConsumerThreadReceivedNewMessage:(AMQPMessage *)theMessage {
  NSData *data = theMessage.body;
  uint8_t *header = (uint8_t *)[data bytes];
  // Get the next 4 bytes for the payload size
  int nextMsgType = *(int *)(header);
  int tag = *(int *)(header+4);
  //  int size = *(int *)(header+8); // No longer used
  NSData *payload = [data subdataWithRange:NSMakeRange(HEADER_SIZE, data.length-HEADER_SIZE)];
  
  [self messageReceived:payload withType:nextMsgType tag:tag];
}

-(void) messageReceived:(NSData *)data withType:(EventProtocolResponse)eventType tag:(int)tag {
  IncomingEventController *iec = [IncomingEventController sharedIncomingEventController];
  
  // Get the proto class for this event type
  Class typeClass = [iec getClassForType:eventType];
  if (!typeClass) {
    LNLog(@"Unable to find controller for event type: %d", eventType);
    return;
  }
  
  // Call handle<Proto Class> method in event controller
  NSString *selectorStr = [NSString stringWithFormat:@"handle%@:", [typeClass description]];
  SEL handleMethod = NSSelectorFromString(selectorStr);
  if ([iec respondsToSelector:handleMethod]) {
    FullEvent *fe = [FullEvent createWithEvent:(PBGeneratedMessage *)[typeClass parseFromData:data] tag:tag];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [iec performSelector:handleMethod withObject:fe];
    
    NSNumber *num = [NSNumber numberWithInt:tag];
    NSObject *delegate = [self.tagDelegates objectForKey:num];
    if (delegate) {
      if ([delegate respondsToSelector:handleMethod]) {
        [delegate performSelector:handleMethod withObject:fe];
#pragma clang diagnostic pop
      } else {
        LNLog(@"Unable to find %@ in %@", selectorStr, NSStringFromClass(delegate.class));
      }
      [self.tagDelegates removeObjectForKey:num];
    }
  } else {
    LNLog(@"Unable to find %@ in IncomingEventController", selectorStr);
  }
}

- (void) setDelegate:(id)delegate forTag:(int)tag {
  if (delegate && tag) {
    [self.tagDelegates setObject:delegate forKey:@(tag)];
  }
}

- (int) sendUserCreateMessageWithName:(NSString *)name lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense energy:(int)energy stamina:(int)stamina structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild {
  UserCreateRequestProto_Builder *bldr = [UserCreateRequestProto builder];
  
  bldr.udid = udid;
  bldr.name = name;
  
  if (refCode) {
    bldr.referrerCode = refCode;
  }
  
  if (deviceToken) {
    bldr.deviceToken = deviceToken;
  }
  bldr.structCoords = [[[[CoordinateProto builder] setX:structX] setY:structY] build];
  bldr.usedDiamondsToBuilt = usedDiamondsToBuild;
  
  UserCreateRequestProto *req = [bldr build];
  return [self sendData:req withMessageType:EventProtocolRequestCUserCreateEvent];
}

- (int) sendStartupMessage:(uint64_t)clientTime {
  NSString *advertiserId = [self getIFA];
  NSString *mac = [self getMacAddress];
  StartupRequestProto_Builder *bldr = [[[[StartupRequestProto builder]
                                         setUdid:udid]
                                        setVersionNum:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]]
                                       setMacAddress:mac];
  
  if (advertiserId) {
    [bldr setAdvertiserId:advertiserId];
  }
  
  StartupRequestProto *req = [bldr build];
  
  LNLog(@"Sent over udid: %@", udid);
  LNLog(@"Mac Address: %@", mac);
  LNLog(@"Advertiser ID: %@", advertiserId);
  return [self sendData:req withMessageType:EventProtocolRequestCStartupEvent];
}

- (int) sendLogoutMessage {
  LogoutRequestProto *req = [[[LogoutRequestProto builder]
                              setSender:_sender]
                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLogoutEvent];
}

- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product {
  InAppPurchaseRequestProto *req = [[[[[[[[InAppPurchaseRequestProto builder]
                                          setReceipt:receipt]
                                         setLocalcents:[NSString stringWithFormat:@"%d", (int)(product.price.doubleValue*100.)]]
                                        setLocalcurrency:[product.priceLocale objectForKey:NSLocaleCurrencyCode]]
                                       setLocale:[product.priceLocale objectForKey:NSLocaleCountryCode]]
                                      setSender:_sender]
                                     setIpaddr:[self getIPAddress]]
                                    build];
  return [self sendData:req withMessageType:EventProtocolRequestCInAppPurchaseEvent];
}

- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost {
  PurchaseNormStructureRequestProto *req = [[[[[[[[[PurchaseNormStructureRequestProto builder]
                                                   setSender:_sender]
                                                  setStructId:structId]
                                                 setStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
                                                setTimeOfPurchase:time]
                                               setResourceType:type]
                                              setResourceChange:resourceChange]
                                             setGemsSpent:gemCost]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseNormStructureEvent];
}

- (int) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y {
  MoveOrRotateNormStructureRequestProto *req =
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeMove]
    setCurStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent];
}

- (int) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost {
  UpgradeNormStructureRequestProto *req = [[[[[[[[UpgradeNormStructureRequestProto builder]
                                                 setSender:_sender]
                                                setUserStructId:userStructId]
                                               setTimeOfUpgrade:curTime]
                                              setResourceChange:resourceChange]
                                             setResourceType:type]
                                            setGemsSpent:gemCost]
                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpgradeNormStructureEvent];
}

- (int) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId gemCost:(int)gemCost time:(uint64_t)milliseconds {
  FinishNormStructWaittimeWithDiamondsRequestProto *req = [[[[[[FinishNormStructWaittimeWithDiamondsRequestProto builder]
                                                               setSender:_sender]
                                                              setGemCostToSpeedup:gemCost]
                                                             setUserStructId:userStructId]
                                                            setTimeOfSpeedup:milliseconds]
                                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent];
}

- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime {
  NormStructWaitCompleteRequestProto *req = [[[[[NormStructWaitCompleteRequestProto builder]
                                                setSender:_sender]
                                               addAllUserStructId:userStructIds]
                                              setCurTime:curTime]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCNormStructWaitCompleteEvent];
}

- (int) sendLoadPlayerCityMessage:(int)userId {
  LoadPlayerCityRequestProto *req = [[[[LoadPlayerCityRequestProto builder]
                                       setSender:_sender]
                                      setCityOwnerId:userId]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLoadPlayerCityEvent];
}

- (int) sendLoadCityMessage:(int)cityId {
  LoadCityRequestProto *req = [[[[LoadCityRequestProto builder]
                                 setSender:_sender]
                                setCityId:cityId]
                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLoadCityEvent];
}

- (int) sendLevelUpMessage {
  LevelUpRequestProto *req = [[[LevelUpRequestProto builder]
                               setSender:_sender]
                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLevelUpEvent];
}

- (int) sendQuestAcceptMessage:(int)questId {
  QuestAcceptRequestProto *req = [[[[QuestAcceptRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestAcceptEvent];
}

- (int) sendQuestProgressMessage:(int)questId progress:(int)progress isComplete:(BOOL)isComplete userMonsterIds:(NSArray *)userMonsterIds {
  QuestProgressRequestProto *req = [[[[[[[QuestProgressRequestProto builder]
                                         setSender:_sender]
                                        setQuestId:questId]
                                       setCurrentProgress:progress]
                                      setIsComplete:isComplete]
                                     addAllDeleteUserMonsterIds:userMonsterIds]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestProgressEvent];
}

- (int) sendQuestRedeemMessage:(int)questId {
  QuestRedeemRequestProto *req = [[[[QuestRedeemRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestRedeemEvent];
}

- (int) sendRetrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam {
  RetrieveUsersForUserIdsRequestProto *req = [[[[[RetrieveUsersForUserIdsRequestProto builder]
                                                 setSender:_sender]
                                                addAllRequestedUserIds:userIds]
                                               setIncludeCurMonsterTeam:includeCurMonsterTeam]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveUsersForUserIdsEvent];
}

- (int) sendAPNSMessage:(NSString *)deviceToken {
  EnableAPNSRequestProto *req = [[[[EnableAPNSRequestProto builder]
                                   setSender:_sender]
                                  setDeviceToken:deviceToken]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEnableApnsEvent];
}

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time {
  EarnFreeDiamondsRequestProto *req = [[[[[EarnFreeDiamondsRequestProto builder]
                                          setSender:_sender]
                                         setFreeDiamondsType:EarnFreeDiamondsTypeFbConnect]
                                        setClientTime:time]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEarnFreeDiamondsEvent];
}

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime {
  SendGroupChatRequestProto *req = [[[[[[SendGroupChatRequestProto builder]
                                        setScope:scope]
                                       setChatMessage:msg]
                                      setSender:_sender]
                                     setClientTime:clientTime]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSendGroupChatEvent];
}

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly {
  CreateClanRequestProto *req = [[[[[[[CreateClanRequestProto builder]
                                      setSender:_sender]
                                     setName:clanName]
                                    setTag:tag]
                                   setDescription:description]
                                  setRequestToJoinClanRequired:requestOnly]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCreateClanEvent];
}

- (int) sendLeaveClanMessage {
  LeaveClanRequestProto *req = [[[LeaveClanRequestProto builder]
                                 setSender:_sender]
                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLeaveClanEvent];
}

- (int) sendRequestJoinClanMessage:(int)clanId {
  RequestJoinClanRequestProto *req = [[[[RequestJoinClanRequestProto builder]
                                        setSender:_sender]
                                       setClanId:clanId]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRequestJoinClanEvent];
}

- (int) sendRetractRequestJoinClanMessage:(int)clanId {
  RetractRequestJoinClanRequestProto *req = [[[[RetractRequestJoinClanRequestProto builder]
                                               setSender:_sender]
                                              setClanId:clanId]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetractRequestJoinClanEvent];
}

- (int) sendApproveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept {
  ApproveOrRejectRequestToJoinClanRequestProto *req = [[[[[ApproveOrRejectRequestToJoinClanRequestProto builder]
                                                          setSender:_sender]
                                                         setRequesterId:requesterId]
                                                        setAccept:accept]
                                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCApproveOrRejectRequestToJoinClanEvent];
}

- (int) sendTransferClanOwnership:(int)newClanOwnerId {
  TransferClanOwnershipRequestProto *req = [[[[TransferClanOwnershipRequestProto builder]
                                              setSender:_sender]
                                             setNewClanOwnerId:newClanOwnerId]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTransferClanOwnership];
}

- (int) sendChangeClanDescription:(NSString *)description {
  ChangeClanDescriptionRequestProto *req = [[[[ChangeClanDescriptionRequestProto builder]
                                              setSender:_sender]
                                             setDescription:description]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCChangeClanDescriptionEvent];
}

- (int) sendChangeClanJoinType:(BOOL)requestToJoinRequired {
  ChangeClanJoinTypeRequestProto *req = [[[[ChangeClanJoinTypeRequestProto builder]
                                           setSender:_sender]
                                          setRequestToJoinRequired:requestToJoinRequired]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCChangeClanJoinTypeEvent];
}

- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId {
  RetrieveClanInfoRequestProto_Builder *bldr = [[[[RetrieveClanInfoRequestProto builder]
                                                  setSender:_sender]
                                                 setGrabType:grabType]
                                                setIsForBrowsingList:isForBrowsingList];
  
  if (clanName) bldr.clanName = clanName;
  if (clanId) bldr.clanId = clanId;
  if (beforeClanId) bldr.beforeThisClanId = beforeClanId;
  
  RetrieveClanInfoRequestProto *req = [bldr build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveClanInfoEvent];
}

- (int) sendBootPlayerFromClan:(int)playerId {
  BootPlayerFromClanRequestProto *req = [[[[BootPlayerFromClanRequestProto builder]
                                           setSender:_sender]
                                          setPlayerToBoot:playerId]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBootPlayerFromClanEvent];
}

- (int) sendPurchaseCityExpansionMessageAtX:(int)x atY:(int)y timeOfPurchase:(uint64_t)time {
  PurchaseCityExpansionRequestProto *req = [[[[[[PurchaseCityExpansionRequestProto builder]
                                                setSender:_sender]
                                               setXPosition:x]
                                              setYPosition:y]
                                             setTimeOfPurchase:time]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseCityExpansionEvent];
}

- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp gemCost:(int)gemCost curTime:(uint64_t)time atX:(int)x atY:(int)y {
  ExpansionWaitCompleteRequestProto *req = [[[[[[[[ExpansionWaitCompleteRequestProto builder]
                                                  setSender:_sender]
                                                 setXPosition:x]
                                                setYPosition:y]
                                               setSpeedUp:speedUp]
                                              setGemCostToSpeedup:gemCost]
                                             setCurTime:time]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCExpansionWaitCompleteEvent];
}

- (int) sendRetrieveTournamentRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank {
  RetrieveTournamentRankingsRequestProto *req = [[[[[RetrieveTournamentRankingsRequestProto builder]
                                                    setSender:_sender]
                                                   setEventId:eventId]
                                                  setAfterThisRank:afterThisRank]
                                                 build];
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveTournamentRankingsEvent];
}

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId clientTime:(uint64_t)clientTime {
  PurchaseBoosterPackRequestProto *req = [[[[[PurchaseBoosterPackRequestProto builder]
                                             setSender:_sender]
                                            setBoosterPackId:boosterPackId]
                                           setClientTime:clientTime]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseBoosterPackEvent];
}

- (int) sendPrivateChatPostMessage:(int)recipientId content:(NSString *)content {
  PrivateChatPostRequestProto *req = [[[[[PrivateChatPostRequestProto builder]
                                         setSender:_sender]
                                        setRecipientId:recipientId]
                                       setContent:content]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPrivateChatPostEvent];
}

- (int) sendRetrievePrivateChatPostsMessage:(int)otherUserId {
  RetrievePrivateChatPostsRequestProto *req = [[[[RetrievePrivateChatPostsRequestProto builder]
                                                 setOtherUserId:otherUserId]
                                                setSender:_sender]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrievePrivateChatPostEvent];
}

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId {
  BeginDungeonRequestProto *req = [[[[[BeginDungeonRequestProto builder]
                                      setSender:_sender]
                                     setClientTime:clientTime]
                                    setTaskId:taskId]
                                   build];
  return [self sendData:req withMessageType:EventProtocolRequestCBeginDungeonEvent];
}

- (int) sendUpdateMonsterHealthMessage:(uint64_t)clientTime monsterHealth:(UserMonsterCurrentHealthProto *)monsterHealth {
  UpdateMonsterHealthRequestProto *req = [[[[[UpdateMonsterHealthRequestProto builder]
                                             setSender:_sender]
                                            setClientTime:clientTime]
                                           addUmchp:monsterHealth]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpdateMonsterHealthEvent];
}

- (int) sendEndDungeonMessage:(uint64_t)userTaskId userWon:(BOOL)userWon isFirstTimeCompleted:(BOOL)isFirstTimeCompleted time:(uint64_t)time {
  EndDungeonRequestProto *req = [[[[[[[EndDungeonRequestProto builder]
                                      setSender:_sender]
                                     setUserTaskId:userTaskId]
                                    setUserWon:userWon]
                                   setFirstTimeUserWonTask:isFirstTimeCompleted]
                                  setClientTime:time]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEndDungeonEvent];
}

- (int) sendCombineUserMonsterPiecesMessage:(NSArray *)userMonsterIds gemCost:(int)gemCost {
  CombineUserMonsterPiecesRequestProto *req = [[[[[CombineUserMonsterPiecesRequestProto builder]
                                                  setSender:_sender]
                                                 addAllUserMonsterIds:userMonsterIds]
                                                setGemCost:gemCost]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCombineUserMonsterPiecesEvent];
}

- (int) sendInviteFbFriendsForSlotsMessage:(NSArray *)fbFriendInvites {
  GameState *gs = [GameState sharedGameState];
  MinimumUserProtoWithFacebookId *mup = [[[[MinimumUserProtoWithFacebookId builder]
                                           setMinUserProto:_sender]
                                          setFacebookId:gs.facebookId]
                                         build];
  
  InviteFbFriendsForSlotsRequestProto *req = [[[[InviteFbFriendsForSlotsRequestProto builder]
                                                setSender:mup]
                                               addAllInvites:fbFriendInvites]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCInviteFbFriendsForSlotsEvent];
}

- (int) sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds {
  GameState *gs = [GameState sharedGameState];
  MinimumUserProtoWithFacebookId *mup = [[[[MinimumUserProtoWithFacebookId builder]
                                           setMinUserProto:_sender]
                                          setFacebookId:gs.facebookId]
                                         build];
  
  AcceptAndRejectFbInviteForSlotsRequestProto *req = [[[[[AcceptAndRejectFbInviteForSlotsRequestProto builder]
                                                         setSender:mup]
                                                        addAllAcceptedInviteIds:acceptIds]
                                                       addAllRejectedInviteIds:rejectIds]
                                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAcceptAndRejectFbInviteForSlotsEvent];
}

#pragma mark - Batch/Flush events

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths {
  HealMonsterWaitTimeCompleteRequestProto *req = [[[[HealMonsterWaitTimeCompleteRequestProto builder]
                                                    setSender:_sender]
                                                   addAllUmchp:monsterHealths]
                                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCHealMonsterWaitTimeCompleteEvent];
  
  [self reloadHealQueueSnapshot];
  
  return tag;
}

- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost {
  HealMonsterWaitTimeCompleteRequestProto *req = [[[[[[HealMonsterWaitTimeCompleteRequestProto builder]
                                                      setSender:_sender]
                                                     setIsSpeedup:YES]
                                                    setGemsForSpeedup:goldCost]
                                                   addAllUmchp:monsterHealths]
                                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCHealMonsterWaitTimeCompleteEvent];
  
  [self reloadHealQueueSnapshot];
  
  return tag;
}

- (int) sendAddMonsterToTeam:(int)userMonsterId teamSlot:(int)teamSlot {
  AddMonsterToBattleTeamRequestProto *req = [[[[[AddMonsterToBattleTeamRequestProto builder]
                                                setSender:_sender]
                                               setUserMonsterId:userMonsterId]
                                              setTeamSlotNum:teamSlot]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAddMonsterToBattleTeamEvent];
}

- (int) sendRemoveMonsterFromTeam:(int)userMonsterId {
  RemoveMonsterFromBattleTeamRequestProto *req = [[[[RemoveMonsterFromBattleTeamRequestProto builder]
                                                    setSender:_sender]
                                                   setUserMonsterId:userMonsterId]
                                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRemoveMonsterFromBattleTeamEvent];
}

- (int) sendBuyInventorySlotsWithGems:(int)userStructId {
  IncreaseMonsterInventorySlotRequestProto *req = [[[[[IncreaseMonsterInventorySlotRequestProto builder]
                                                      setSender:_sender]
                                                     setIncreaseSlotType:IncreaseMonsterInventorySlotRequestProto_IncreaseSlotTypePurchase]
                                                    setUserStructId:userStructId]
                                                   build];
  
  return [self sendData:req withMessageType:EventProtocolResponseSIncreaseMonsterInventorySlotEvent];
}

- (int) sendBuyInventorySlots:(int)userStructId withFriendInvites:(NSArray *)inviteIds {
  IncreaseMonsterInventorySlotRequestProto *req = [[[[[[IncreaseMonsterInventorySlotRequestProto builder]
                                                       setSender:_sender]
                                                      setIncreaseSlotType:IncreaseMonsterInventorySlotRequestProto_IncreaseSlotTypeRedeemFacebookInvites]
                                                     setUserStructId:userStructId]
                                                    addAllUserFbInviteForSlotIds:inviteIds]
                                                   build];
  
  return [self sendData:req withMessageType:EventProtocolResponseSIncreaseMonsterInventorySlotEvent];
}

- (int) sendEnhanceQueueWaitTimeComplete:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds {
  EnhancementWaitTimeCompleteRequestProto *req = [[[[[EnhancementWaitTimeCompleteRequestProto builder]
                                                     setSender:_sender]
                                                    setUmcep:monsterExp]
                                                   addAllUserMonsterIds:userMonsterIds]
                                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCEnhancementWaitTimeCompleteEvent];
  
  [self reloadEnhancementSnapshot];
  
  return tag;
}

- (int) sendEnhanceQueueSpeedup:(UserMonsterCurrentExpProto *)monsterExp userMonsterIds:(NSArray *)userMonsterIds goldCost:(int)goldCost {
  EnhancementWaitTimeCompleteRequestProto *req = [[[[[[[EnhancementWaitTimeCompleteRequestProto builder]
                                                       setSender:_sender]
                                                      setUmcep:monsterExp]
                                                     setIsSpeedup:YES]
                                                    setGemsForSpeedup:goldCost]
                                                   addAllUserMonsterIds:userMonsterIds]
                                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCEnhancementWaitTimeCompleteEvent];
  
  [self reloadEnhancementSnapshot];
  
  return tag;
}

- (int) retrieveCurrencyFromStruct:(int)userStructId time:(uint64_t)time {
  [self flushAllExceptEventType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent];
  RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval *sr = [[[[RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval builder]
                                                                         setUserStructId:userStructId]
                                                                        setTimeOfRetrieval:time]
                                                                       build];
  [self.structRetrievals addObject:sr];
  return _currentTagNum;
}

- (int) sendRetrieveCurrencyFromNormStructureMessage {
  RetrieveCurrencyFromNormStructureRequestProto *req = [[[[RetrieveCurrencyFromNormStructureRequestProto builder]
                                                          setSender:_sender]
                                                         addAllStructRetrievals:self.structRetrievals]
                                                        build];
  
  LNLog(@"Sending retrieve currency message with %d structs.", self.structRetrievals.count);
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent flush:NO];
}

- (int) setHealQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost {
  [self flushAllExceptEventType:EventProtocolRequestCHealMonsterEvent];
  _healingQueueCashChange += coinChange;
  _healingQueueGemCost += gemCost;
  _healingQueuePotentiallyChanged = YES;
  return _currentTagNum;
}

- (void) reloadHealQueueSnapshot {
  GameState *gs = [GameState sharedGameState];
  self.healingQueueSnapshot = [gs.monsterHealingQueue clone];
}

- (int) sendHealMonsterMessage {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *old = [NSMutableSet setWithArray:self.healingQueueSnapshot];
  NSMutableSet *cur = [NSMutableSet setWithArray:gs.monsterHealingQueue];
  
  NSMutableSet *added = cur.mutableCopy;
  [added minusSet:old];
  
  NSMutableSet *removed = old.mutableCopy;
  [removed minusSet:cur];
  
  NSMutableSet *modifiedOld = old.mutableCopy;
  [modifiedOld intersectSet:cur];
  
  NSMutableSet *modifiedCur = cur.mutableCopy;
  [modifiedCur intersectSet:old];
  
  NSMutableSet *changed = [NSMutableSet set];
  for (UserMonsterHealingItem *itemOld in modifiedOld) {
    UserMonsterHealingItem *itemNew = [modifiedCur member:itemOld];
    if ([itemOld.expectedStartTime compare:itemNew.expectedStartTime] != NSOrderedSame) {
      [changed addObject:itemNew];
    }
  }
  
  if (added.count || removed.count || changed.count || _healingQueueCashChange || _healingQueueGemCost) {
    HealMonsterRequestProto_Builder *bldr = [[HealMonsterRequestProto builder] setSender:_sender];
    
    for (UserMonsterHealingItem *item in added) {
      [bldr addUmhNew:[item convertToProto]];
    }
    
    for (UserMonsterHealingItem *item in removed) {
      [bldr addUmhDelete:[item convertToProto]];
    }
    
    for (UserMonsterHealingItem *item in changed) {
      [bldr addUmhUpdate:[item convertToProto]];
    }
    
    [bldr setCashChange:_healingQueueCashChange];
    [bldr setGemCost:_healingQueueGemCost];
    
    NSLog(@"Sending healing queue update with %d adds, %d removals, and %d updates.", added.count, removed.count, changed.count);
    NSLog(@"Cash change: %@, gemCost: %d", [Globals commafyNumber:_healingQueueCashChange], _healingQueueGemCost);
    
    return [self sendData:bldr.build withMessageType:EventProtocolRequestCHealMonsterEvent flush:NO];
  } else {
    return 0;
  }
}

- (int) setEnhanceQueueDirtyWithCoinChange:(int)coinChange gemCost:(int)gemCost {
  [self flushAllExceptEventType:EventProtocolRequestCSubmitMonsterEnhancementEvent];
  _enhanceQueueCashChange += coinChange;
  _enhanceQueueGemCost += gemCost;
  _enhancementPotentiallyChanged = YES;
  return _currentTagNum;
}

- (void) reloadEnhancementSnapshot {
  GameState *gs = [GameState sharedGameState];
  self.enhancementSnapshot = [gs.userEnhancement clone];
}

- (int) sendEnhanceMonsterMessage {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *old = [NSMutableSet setWithArray:self.enhancementSnapshot.feeders];
  if (self.enhancementSnapshot.baseMonster) [old addObject:self.enhancementSnapshot.baseMonster];
  NSMutableSet *cur = [NSMutableSet setWithArray:gs.userEnhancement.feeders];
  if (gs.userEnhancement.baseMonster) [cur addObject:gs.userEnhancement.baseMonster];
  
  NSMutableSet *added = cur.mutableCopy;
  [added minusSet:old];
  
  NSMutableSet *removed = old.mutableCopy;
  [removed minusSet:cur];
  
  NSMutableSet *modifiedOld = old.mutableCopy;
  [modifiedOld intersectSet:cur];
  
  NSMutableSet *modifiedCur = cur.mutableCopy;
  [modifiedCur intersectSet:old];
  
  NSMutableSet *changed = [NSMutableSet set];
  for (UserMonsterHealingItem *itemOld in modifiedOld) {
    UserMonsterHealingItem *itemNew = [modifiedCur member:itemOld];
    if ([itemOld.expectedStartTime compare:itemNew.expectedStartTime] != NSOrderedSame) {
      [changed addObject:itemNew];
    }
  }
  
  if (added.count || removed.count || changed.count) {
    SubmitMonsterEnhancementRequestProto_Builder *bldr = [[SubmitMonsterEnhancementRequestProto builder] setSender:_sender];
    
    for (EnhancementItem *item in added) {
      [bldr addUeipNew:[item convertToProto]];
    }
    
    for (EnhancementItem *item in removed) {
      [bldr addUeipDelete:[item convertToProto]];
    }
    
    for (EnhancementItem *item in changed) {
      [bldr addUeipUpdate:[item convertToProto]];
    }
    
    [bldr setCashChange:_enhanceQueueCashChange];
    //    [bldr setGemCost:_enhanceQueueGemCost];
    
    NSLog(@"Sending enhancement update with %d adds, %d removals, and %d updates.", added.count, removed.count, changed.count);
    
    return [self sendData:bldr.build withMessageType:EventProtocolRequestCSubmitMonsterEnhancementEvent flush:NO];
  } else {
    return 0;
  }
}

- (void) flush {
  [self flushAllExceptEventType:-1];
}

- (void) flushAllExceptEventType:(int)val {
  [self flushAllExcept:[NSNumber numberWithInt:val]];
}

- (void) flushAllExcept:(NSNumber *)num {
  int type = num.intValue;
  if (type != EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent) {
    if (self.structRetrievals.count > 0) {
      [self sendRetrieveCurrencyFromNormStructureMessage];
      [self.structRetrievals removeAllObjects];
    }
  }
  
  if (type != EventProtocolRequestCHealMonsterEvent) {
    if (_healingQueuePotentiallyChanged) {
      [self sendHealMonsterMessage];
      [self reloadHealQueueSnapshot];
      _healingQueuePotentiallyChanged = NO;
      _healingQueueGemCost = 0;
      _healingQueueCashChange = 0;
    }
  }
  
  if (type != EventProtocolRequestCSubmitMonsterEnhancementEvent) {
    if (_enhancementPotentiallyChanged) {
      [self sendEnhanceMonsterMessage];
      [self reloadEnhancementSnapshot];
      _enhancementPotentiallyChanged = NO;
      _enhanceQueueGemCost = 0;
      _enhanceQueueCashChange = 0;
    }
  }
}

- (void) closeDownConnection {
  [_flushTimer invalidate];
  _flushTimer = nil;
  [self flush];
  [self.connectionThread end];
}

@end
