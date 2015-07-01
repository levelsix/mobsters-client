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
#import "FacebookDelegate.h"

// Tags for keeping state
#define READING_HEADER_TAG -1
#define HEADER_SIZE 4

#define CONNECTED_TO_HOST_DELEGATE_TAG 999998
#define CLAN_EVENT_DELEGATE_TAG 999999

@implementation SocketCommunication

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(SocketCommunication);

static NSString *udid = nil;

- (NSString *)getIPAddress
{
  NSURL *url = [[NSURL alloc] initWithString:@"http://checkip.dyndns.com/"];
  NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSStringEncodingConversionAllowLossy error:nil];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.\\d+\\.\\d+\\.\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
  
  if (contents) {
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
      NSString *substringForFirstMatch = [contents substringWithRange:rangeOfFirstMatch];
      LNLog(@"IP Address: %@", substringForFirstMatch);
      return substringForFirstMatch;
    }
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
    LNLog(@"Error: %@", errorFlag);
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

+ (BOOL) isForcedTutorial {
#ifdef FORCE_TUTORIAL
  return YES;
#else
  return NO;
#endif
}

+ (NSString *) getUdid {
  return udid;
}

- (id) init {
  if ((self = [super init])) {
    if ([SocketCommunication isForcedTutorial]) {
      udid = [NSString stringWithFormat:@"%d%d%d", arc4random(), arc4random(), arc4random()];
    } else {
      udid = UDID;
    }
    
    self.queuedMessages = [NSMutableArray array];
    self.unrespondedMessages = [NSMutableArray array];
    
    self.clanEventDelegates = [NSMutableArray array];
    
    _updatedUserMiniEventGoals = [NSMutableDictionary dictionary];
    
    
    // Web Socket Communication
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    // Convert version to use a '-' instead of a '.'
    version = [version stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    NSString *hostName = HOST_NAME;
    hostName = [NSString stringWithFormat:hostName, version];
    
    self.webSocketCommunication = [[WebSocketCommunication alloc] initWithURLString:hostName sslCert:@"lvl6_crt.der"];
    self.webSocketCommunication.delegate = self;
  }
  return self;
}

- (void) rebuildSender {
  GameState *gs = [GameState sharedGameState];
  _sender = gs.minUser;
  
  LNLog (@"Rebuilt sender: %@", _sender);
}

- (MinimumUserProtoWithMaxResources *) senderWithMaxResources {
  GameState *gs = [GameState sharedGameState];
  MinimumUserProtoWithMaxResources_Builder *res = [MinimumUserProtoWithMaxResources builder];
  res.minUserProto = _sender;
  res.maxCash = [gs maxCash];
  res.maxOil = [gs maxOil];
  return res.build;
}

- (void) initNetworkCommunicationWithDelegate:(id)delegate clearMessages:(BOOL)clearMessages {
  
  [self.webSocketCommunication connect];
  
  LNLog(@"Initializing network connection..");
  
  // In case we just came from inactive state
  _currentTagNum = ABS(arc4random());
  
  _canSendRegularEvents = NO;
  _canSendPreDbEvents = NO;
  
  _pauseFlushTimer = NO;
  
  self.structRetrievals = [NSMutableArray array];
  self.structRetrievalAchievements = [NSMutableDictionary dictionary];
  _healingQueuePotentiallyChanged = NO;
  _speedupItemUsages = [NSMutableArray array];
  _speedupUpdatedUserItems = [NSMutableArray array];
  _resourceItemIdsUsed = [NSMutableArray array];
  _resourceUpdatedUserItems = [NSMutableArray array];
  
  if (clearMessages) {
    self.tagDelegates = [NSMutableDictionary dictionary];
    
    // Need to do this so clan queue gets recreated on clicking home button
    _sender = nil;
    LNLog (@"Nulled out sender..");
  }
  [self setDelegate:delegate forTag:CONNECTED_TO_HOST_DELEGATE_TAG];
  
  if (clearMessages) {
    if (self.queuedMessages.count || self.unrespondedMessages.count) {
      LNLog(@"Removing %d queued messages, %d unresponded messages.", (int)self.queuedMessages.count, (int)self.unrespondedMessages.count);
      [self.queuedMessages removeAllObjects];
      [self.unrespondedMessages removeAllObjects];
    }
  } else {
    GameState *gs = [GameState sharedGameState];
    if (!gs.isTutorial && gs.connected) {
      // Check if first event is already a reconnect
      FullEvent *fe1 = [self.queuedMessages firstObject];
      FullEvent *fe2 = [self.unrespondedMessages firstObject];
      if (![fe1.event isKindOfClass:[ReconnectRequestProto class]] &&
          ![fe2.event isKindOfClass:[ReconnectRequestProto class]]) {
        // Send reconnect msg at front
        NSMutableArray *oldQueuedMsgs = self.queuedMessages;
        self.queuedMessages = [NSMutableArray array];
        [self sendReconnectMessage];
        [self.queuedMessages addObjectsFromArray:oldQueuedMsgs];
      }
    }
    
    [self.queuedMessages addObjectsFromArray:self.unrespondedMessages];
    [self.unrespondedMessages removeAllObjects];
  }
}

- (void) callSelectorOnHostDelegate:(SEL)sel {
  
  NSObject *delegate = [self.tagDelegates objectForKey:[NSNumber numberWithInt:CONNECTED_TO_HOST_DELEGATE_TAG]];
  if (delegate) {
    if ([delegate respondsToSelector:sel]) {
      SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING
      (
       [delegate performSelector:sel withObject:nil];
       );
    }
  } else {
    LNLog(@"Unable to find delegate for %@", NSStringFromSelector(sel));
  }
}

- (void) connectedToHost {
  _canSendRegularEvents = NO;
  _canSendPreDbEvents = YES;
  
  [self callSelectorOnHostDelegate:@selector(handleConnectedToHost)];
  
  _flushTimer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(timerFlush) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:_flushTimer forMode:NSRunLoopCommonModes];
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (FullEvent *fe in self.queuedMessages) {
    if ([self isPreDbEventType:fe.requestType]) {
      LNLog(@"1: Sending queued event of type %@.", NSStringFromClass(fe.event.class));
      [toRemove addObject:fe];
    }
  }
  [self.queuedMessages removeObjectsInArray:toRemove];
  [self sendFullEvents:toRemove];
}

- (void) initUserIdMessageQueue {
  _canSendRegularEvents = NO;
  _canSendPreDbEvents = YES;
  
  [self connectedToUserIdQueue];
  //[self.connectionThread startUserIdQueue];
}

- (void) connectedToUserIdQueue {
  _canSendRegularEvents = YES;
  
  [self callSelectorOnHostDelegate:@selector(connectedToUserIdQueue)];
  
  if (_canSendPreDbEvents) {
    for (FullEvent *fe in self.queuedMessages) {
      LNLog(@"2: Sending queued event of type %@.", NSStringFromClass(fe.event.class));
    }
    NSArray *msgs = [self.queuedMessages copy];
    [self.queuedMessages removeAllObjects];
    [self sendFullEvents:msgs];
  }
}

- (void) attemptingReconnect {
  [self callSelectorOnHostDelegate:@selector(reconnectingToServer)];
}

- (void) unableToConnectToHost {
  [self callSelectorOnHostDelegate:@selector(unableToConnectToHost)];
}

- (BOOL) isPreDbEventType:(EventProtocolRequest)type {
  return type == EventProtocolRequestCStartupEvent || type == EventProtocolRequestCUserCreateEvent;
}

- (NSData *) serializeEvent:(PBGeneratedMessage *)msg withMessageType:(int)type tagNum:(int)tagNum eventUuid:(NSString *)eventUuid {
  NSMutableData *messageWithHeader = [NSMutableData data];
  NSData *eventData = [msg data];
  
  EventProto_Builder *ep = [EventProto builder];
  ep.eventType = type;
  ep.tagNum = tagNum;
  ep.eventBytes = eventData;
  ep.eventUuid = eventUuid;
  NSData *data = [ep build].data;
  
  // Need to reverse bytes for size and type(to account for endianness??)
  uint8_t header[HEADER_SIZE];
  
  NSInteger size = [data length];
  header[3] = size & 0xFF;
  header[2] = (size & 0xFF00) >> 8;
  header[1] = (size & 0xFF0000) >> 16;
  header[0] = (size & 0xFF000000) >> 24;
  
  [messageWithHeader appendBytes:header length:sizeof(header)];
  [messageWithHeader appendData:data];
  
  return messageWithHeader;
}

- (void) sendFullEvents:(NSArray *)events {
  if (events.count > 1) {
    LNLog(@"Sending %d events at once.. %@", (int)events.count, events);
  }
  
  NSMutableData *mutableData = [NSMutableData data];
  for (FullEvent *fe in events) {
    PBGeneratedMessage *msg = fe.event;
    int tagNum = fe.tag;
    EventProtocolRequest type = fe.requestType;
    
    if (!_canSendPreDbEvents) {
      LNLog(@"3: Queueing up event of type %@.", NSStringFromClass(msg.class));
      
      [self.queuedMessages addObject:fe];
      continue;
    } else {
      if (!_canSendRegularEvents) {
        if (![self isPreDbEventType:type]) {
          LNLog(@"4: Queueing up event of type %@.", NSStringFromClass(msg.class));
          
          [self.queuedMessages addObject:fe];
          continue;
        }
      }
    }
    
    NSData *messageWithHeader = [self serializeEvent:msg withMessageType:type tagNum:tagNum eventUuid:fe.eventUuid];
    [mutableData appendData:messageWithHeader];
    
    [self.unrespondedMessages addObject:fe];
  }
  
  if (mutableData.length) {
    [self.webSocketCommunication sendMessage:mutableData];
    //[self.webSocket performSelector:@selector(send:) withObject:mutableData afterDelay:2.5f];
  }
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type flush:(BOOL)flush queueUp:(BOOL)queueUp incrementTagNum:(int)inc {
  if (flush) {
    if ([self flushAndQueueUp]) {
      _lastFlushedTime = [NSDate date];
    }
  }
  
  int tag = 0;
  if (inc) {
    tag = _currentTagNum;
    _currentTagNum++;
    _currentTagNum %= RAND_MAX;
  }
  
  NSString *eventUuid = [[NSUUID UUID] UUIDString];
  FullEvent *fe = [FullEvent createWithEvent:msg tag:tag requestType:type eventUuid:eventUuid];
  if (!queueUp) {
    if (flush && self.queuedMessages.count > 0) {
      NSArray *msgs = [self.queuedMessages arrayByAddingObject:fe];
      [self.queuedMessages removeAllObjects];
      [self sendFullEvents:msgs];
    } else {
      [self sendFullEvents:@[fe]];
    }
  } else {
    [self.queuedMessages addObject:fe];
  }
  
  return tag;
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type queueUp:(BOOL)queueUp incrementTagNum:(int)inc  {
  return [self sendData:msg withMessageType:type flush:YES queueUp:queueUp incrementTagNum:inc];
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type {
  return [self sendData:msg withMessageType:type flush:YES queueUp:NO incrementTagNum:YES];
}

- (void) receivedMessage:(NSData *)data {
  int cursor = 0;
  
  while (cursor < data.length) {
    uint8_t header[HEADER_SIZE];
    [data getBytes:header range:NSMakeRange(cursor, HEADER_SIZE)];
    // Get the next 4 bytes for the payload size
    int size = *(int *)(header);
    NSData *payload = [data subdataWithRange:NSMakeRange(cursor+HEADER_SIZE, size)];
    
    EventProto *ep = [EventProto parseFromData:payload];
    
    [self messageReceived:ep.eventBytes withType:ep.eventType tag:ep.tagNum eventUuid:ep.eventUuid];
    
    cursor += HEADER_SIZE + size;
  }
}

- (void) messageReceived:(NSData *)data withType:(EventProtocolResponse)eventType tag:(int)tag eventUuid:(NSString *)eventUuid {
  IncomingEventController *iec = [IncomingEventController sharedIncomingEventController];
  
  // Delete this eventUuid from unresponded messages
  for (FullEvent *fe in self.unrespondedMessages.copy) {
    if ([fe.eventUuid isEqualToString:eventUuid] && ![fe.event isKindOfClass:[ForceLogoutResponseProto class]]) {
      [self.unrespondedMessages removeObject:fe];
    }
  }
  
  // Get the proto class for this event type
  Class typeClass = [iec getClassForType:eventType];
  if (!typeClass) {
    LNLog(@"Unable to find controller for event type: %d", (int)eventType);
    return;
  }
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  // Call handle<Proto Class> method in event controller
  NSString *selectorStr = [NSString stringWithFormat:@"handle%@:", [typeClass description]];
  SEL handleMethod = NSSelectorFromString(selectorStr);
  if ([iec respondsToSelector:handleMethod]) {
    FullEvent *fe = [FullEvent createWithEvent:(PBGeneratedMessage *)[typeClass parseFromData:data] tag:tag eventUuid:eventUuid];
    
    [iec performSelector:handleMethod withObject:fe];
    
    NSNumber *num = [NSNumber numberWithInt:tag];
    NSObject *delegate = [self.tagDelegates objectForKey:num];
    if (delegate) {
      if ([delegate respondsToSelector:handleMethod]) {
        [delegate performSelector:handleMethod withObject:fe];
      } else {
        LNLog(@"Unable to find %@ in %@", selectorStr, NSStringFromClass(delegate.class));
      }
      [self.tagDelegates removeObjectForKey:num];
    }
    
    BOOL isClanEvent = [self isEventTypeClanEvent:eventType];
    if (isClanEvent) {
      NSString *selectorStr = [NSString stringWithFormat:@"handleClanEvent%@:", [typeClass description]];
      SEL handleMethod = NSSelectorFromString(selectorStr);
      
      // Copy the delegates array in case it is mutated
      NSArray *curDelegates = [self.clanEventDelegates copy];
      for (id delegate in curDelegates) {
        if ([delegate respondsToSelector:handleMethod]) {
          [delegate performSelector:handleMethod withObject:fe.event];
        }
      }
    }
  } else {
    LNLog(@"Unable to find %@ in IncomingEventController", selectorStr);
  }
#pragma clang diagnostic pop
}

- (void) setDelegate:(id)delegate forTag:(int)tag {
  if (delegate && tag) {
    [self.tagDelegates setObject:delegate forKey:@(tag)];
  }
}

- (void) addClanEventObserver:(id)object {
  [self.clanEventDelegates addObject:object];
}

- (void) removeClanEventObserver:(id)object {
  [self.clanEventDelegates removeObject:object];
}

- (BOOL) isEventTypeClanEvent:(EventProtocolResponse)eventType {
  switch (eventType) {
    case EventProtocolResponseSApproveOrRejectRequestToJoinClanEvent:
    case EventProtocolResponseSPromoteDemoteClanMemberEvent:
    case EventProtocolResponseSCreateClanEvent:
    case EventProtocolResponseSChangeClanSettingsEvent:
    case EventProtocolResponseSLeaveClanEvent:
    case EventProtocolResponseSRequestJoinClanEvent:
    case EventProtocolResponseSRetractRequestJoinClanEvent:
    case EventProtocolResponseSBootPlayerFromClanEvent:
    case EventProtocolResponseSTransferClanOwnership:
      return YES;
      break;
      
    default:
      return NO;
      break;
  }
}

#pragma mark - Events

- (int) sendUserCreateMessageWithName:(NSString *)name facebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSString *)otherFbInfo structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems {
  UserCreateRequestProto_Builder *bldr = [UserCreateRequestProto builder];
  
  bldr.udid = udid;
  bldr.name = name;
  bldr.facebookId = facebookId;
  [bldr addAllStructsJustBuilt:structs];
  bldr.cash = cash;
  bldr.oil = oil;
  bldr.cash = cash;
  bldr.gems = gems;
  bldr.email = email;
  bldr.fbData = otherFbInfo;
  
  UserCreateRequestProto *req = [bldr build];
  return [self sendData:req withMessageType:EventProtocolRequestCUserCreateEvent];
}

- (int) sendStartupMessageWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart clientTime:(uint64_t)clientTime {
  NSString *advertiserId = [self getIFA];
  NSString *mac = [self getMacAddress];
  
  NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
  NSScanner *scan = [NSScanner scannerWithString:build];
  scan.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"."];
  
  int supermajor, major, minor;
  
  [scan scanInt:&supermajor];
  [scan scanInt:&major];
  [scan scanInt:&minor];
  
  StartupRequestProto_VersionNumberProto *version = [[[[[StartupRequestProto_VersionNumberProto builder] setSuperNum:supermajor] setMajorNum:major] setMinorNum:minor] build];
  
  StartupRequestProto_Builder *bldr = [[[[[[[StartupRequestProto builder]
                                            setUdid:udid]
                                           setFbId:facebookId]
                                          setIsForceTutorial:[SocketCommunication isForcedTutorial]]
                                         setIsFreshRestart:isFreshRestart]
                                        setVersionNumberProto:version]
                                       setMacAddress:mac];
  
  if (advertiserId) {
    [bldr setAdvertiserId:advertiserId];
  }
  if (facebookId) {
    [bldr setFbId:facebookId];
  }
  
  StartupRequestProto *req = [bldr build];
  
  LNLog(@"Sent over udid: %@", udid);
  LNLog(@"Facebook Id: %@", facebookId);
  LNLog(@"Mac Address: %@", mac);
  LNLog(@"Advertiser ID: %@", advertiserId);
  return [self sendData:req withMessageType:EventProtocolRequestCStartupEvent];
}

- (int) sendReconnectMessage {
  ReconnectRequestProto *req = [[[[ReconnectRequestProto builder]
                                  setSender:_sender]
                                 setUdid:udid]
                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCReconnectEvent];
}

- (int) sendLogoutMessage {
  LogoutRequestProto *req = [[[LogoutRequestProto builder]
                              setSender:_sender]
                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLogoutEvent];
}

- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product saleUuid:(NSString *)saleUuid {
  InAppPurchaseRequestProto *req = [[[[[[[[InAppPurchaseRequestProto builder]
                                          setReceipt:receipt]
                                         setLocalcents:[NSString stringWithFormat:@"%d", (int)(product.price.doubleValue*100.)]]
                                        setLocalcurrency:[product.priceLocale objectForKey:NSLocaleCurrencyCode]]
                                       setLocale:[product.priceLocale objectForKey:NSLocaleCountryCode]]
                                      setSender:_sender]
                                     //setIpaddr:[self getIPAddress]]
                                     setUuid:saleUuid]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCInAppPurchaseEvent];
}

- (int) sendExchangeGemsForResourcesMessage:(int)gems resources:(int)resources resType:(ResourceType)resType clientTime:(uint64_t)clientTime {
  ExchangeGemsForResourcesRequestProto *req = [[[[[[[ExchangeGemsForResourcesRequestProto builder]
                                                    setSender:[self senderWithMaxResources]]
                                                   setNumGems:gems]
                                                  setResourceType:resType]
                                                 setNumResources:resources]
                                                setClientTime:clientTime]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCExchangeGemsForResourcesEvent];
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

- (int) sendMoveNormStructureMessage:(NSString *)userStructUuid x:(int)x y:(int)y {
  MoveOrRotateNormStructureRequestProto *req =
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructUuid:userStructUuid]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeMove]
    setCurStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent queueUp:YES incrementTagNum:NO];
}

- (int) sendUpgradeNormStructureMessage:(NSString *)userStructUuid time:(uint64_t)curTime resourceType:(ResourceType)type resourceChange:(int)resourceChange gemCost:(int)gemCost queueUp:(BOOL)queueUp {
  UpgradeNormStructureRequestProto *req = [[[[[[[[UpgradeNormStructureRequestProto builder]
                                                 setSender:_sender]
                                                setUserStructUuid:userStructUuid]
                                               setTimeOfUpgrade:curTime]
                                              setResourceChange:resourceChange]
                                             setResourceType:type]
                                            setGemsSpent:gemCost]
                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpgradeNormStructureEvent queueUp:queueUp incrementTagNum:YES];
}

- (int) sendFinishNormStructBuildWithDiamondsMessage:(NSString *)userStructUuid gemCost:(int)gemCost time:(uint64_t)milliseconds queueUp:(BOOL)queueUp {
  FinishNormStructWaittimeWithDiamondsRequestProto *req = [[[[[[FinishNormStructWaittimeWithDiamondsRequestProto builder]
                                                               setSender:_sender]
                                                              setGemCostToSpeedup:gemCost]
                                                             setUserStructUuid:userStructUuid]
                                                            setTimeOfSpeedup:milliseconds]
                                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent queueUp:queueUp incrementTagNum:YES];
}

- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructUuids timeOfCompletion:(uint64_t)timeOfCompletion clientTime:(uint64_t)clientTime {
  NormStructWaitCompleteRequestProto *req = [[[[[[NormStructWaitCompleteRequestProto builder]
                                                 setSender:_sender]
                                                addAllUserStructUuid:userStructUuids]
                                               setTimeOfCompletion:timeOfCompletion]
                                              setCurrentClientTime:clientTime]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCNormStructWaitCompleteEvent];
}

- (int) sendLoadPlayerCityMessage:(NSString *)userUuid {
  LoadPlayerCityRequestProto *req = [[[[LoadPlayerCityRequestProto builder]
                                       setSender:_sender]
                                      setCityOwnerUuid:userUuid]
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

- (int) sendLevelUpMessage:(int)level {
  LevelUpRequestProto *req = [[[[LevelUpRequestProto builder]
                                setSender:_sender]
                               setNextLevel:level]
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

- (int) sendQuestProgressMessage:(int)questId isComplete:(BOOL)isComplete userQuestJobs:(NSArray *)userQuestJobs userMonsterUuids:(NSArray *)userMonsterUuids {
  QuestProgressRequestProto *req = [[[[[[[QuestProgressRequestProto builder]
                                         setSender:_sender]
                                        setQuestId:questId]
                                       setIsComplete:isComplete]
                                      addAllUserQuestJobs:userQuestJobs]
                                     addAllDeleteUserMonsterUuids:userMonsterUuids]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestProgressEvent];
}

- (int) sendQuestRedeemMessage:(int)questId {
  QuestRedeemRequestProto *req = [[[[QuestRedeemRequestProto builder]
                                    setSender:[self senderWithMaxResources]]
                                   setQuestId:questId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestRedeemEvent];
}

- (int) sendRetrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam {
  RetrieveUsersForUserIdsRequestProto *req = [[[[[RetrieveUsersForUserIdsRequestProto builder]
                                                 setSender:_sender]
                                                addAllRequestedUserUuids:userUuids]
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

- (int) sendSetGameCenterMessage:(NSString *)gameCenterId {
  SetGameCenterIdRequestProto *req = [[[[SetGameCenterIdRequestProto builder]
                                        setSender:_sender]
                                       setGameCenterId:gameCenterId]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSetGameCenterIdEvent];
}

- (int) sendSetFacebookIdMessage:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSString *)otherFbInfo {
  SetFacebookIdRequestProto *req = [[[[[[SetFacebookIdRequestProto builder]
                                        setSender:_sender]
                                       setFbId:facebookId]
                                      setEmail:email]
                                     setFbData:otherFbInfo]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolResponseSSetFacebookIdEvent];
}

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time {
  EarnFreeDiamondsRequestProto *req = [[[[[EarnFreeDiamondsRequestProto builder]
                                          setSender:_sender]
                                         setFreeDiamondsType:EarnFreeDiamondsTypeFbConnect]
                                        setClientTime:time]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEarnFreeDiamondsEvent];
}

- (int) sendGroupChatMessage:(ChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime globalLanguage:(TranslateLanguages)globalLanguage{
  SendGroupChatRequestProto *req = [[[[[[[SendGroupChatRequestProto builder]
                                         setScope:scope]
                                        setChatMessage:msg]
                                       setSender:_sender]
                                      setClientTime:clientTime]
                                     setGlobalLanguage:globalLanguage]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSendGroupChatEvent];
}

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag description:(NSString *)description requestOnly:(BOOL)requestOnly iconId:(int)iconId cashChange:(int)cashChange gemsSpent:(int)gemsSpent {
  CreateClanRequestProto *req = [[[[[[[[[[CreateClanRequestProto builder]
                                         setSender:_sender]
                                        setName:clanName]
                                       setTag:tag]
                                      setDescription:description]
                                     setRequestToJoinClanRequired:requestOnly]
                                    setClanIconId:iconId]
                                   setCashChange:cashChange]
                                  setGemsSpent:gemsSpent]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCreateClanEvent];
}

- (int) sendLeaveClanMessage {
  LeaveClanRequestProto *req = [[[LeaveClanRequestProto builder]
                                 setSender:_sender]
                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLeaveClanEvent];
}

- (int) sendRequestJoinClanMessage:(NSString *)clanUuid clientTime:(uint64_t)clientTime {
  RequestJoinClanRequestProto *req = [[[[[RequestJoinClanRequestProto builder]
                                         setSender:_sender]
                                        setClanUuid:clanUuid]
                                       setClientTime:clientTime]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRequestJoinClanEvent];
}

- (int) sendRetractRequestJoinClanMessage:(NSString *)clanUuid {
  RetractRequestJoinClanRequestProto *req = [[[[RetractRequestJoinClanRequestProto builder]
                                               setSender:_sender]
                                              setClanUuid:clanUuid]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetractRequestJoinClanEvent];
}

- (int) sendApproveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept {
  ApproveOrRejectRequestToJoinClanRequestProto *req = [[[[[ApproveOrRejectRequestToJoinClanRequestProto builder]
                                                          setSender:_sender]
                                                         setRequesterUuid:requesterUuid]
                                                        setAccept:accept]
                                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCApproveOrRejectRequestToJoinClanEvent];
}

- (int) sendTransferClanOwnership:(NSString *)newClanOwnerUuid {
  TransferClanOwnershipRequestProto *req = [[[[TransferClanOwnershipRequestProto builder]
                                              setSender:_sender]
                                             setClanOwnerUuidNew:newClanOwnerUuid]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTransferClanOwnership];
}

- (int) sendChangeClanDescription:(BOOL)isDescription description:(NSString *)description isRequestType:(BOOL)isRequestType requestRequired:(BOOL)requestRequired isIcon:(BOOL)isIcon iconId:(int)iconId {
  ChangeClanSettingsRequestProto_Builder *bldr = [[ChangeClanSettingsRequestProto builder] setSender:_sender];
  
  if (isDescription) {
    bldr.isChangeDescription = isDescription;
    bldr.descriptionNow = description;
  }
  if (isRequestType) {
    bldr.isChangeJoinType = isRequestType;
    bldr.requestToJoinRequired = requestRequired;
  }
  if (isIcon) {
    bldr.isChangeIcon = isIcon;
    bldr.iconId = iconId;
  }
  
  return [self sendData:bldr.build withMessageType:EventProtocolRequestCChangeClanSettingsEvent];
}

- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList {
  RetrieveClanInfoRequestProto_Builder *bldr = [[[[RetrieveClanInfoRequestProto builder]
                                                  setSender:_sender]
                                                 setGrabType:grabType]
                                                setIsForBrowsingList:isForBrowsingList];
  
  if (clanName) bldr.clanName = clanName;
  if (clanUuid) bldr.clanUuid = clanUuid;
  
  RetrieveClanInfoRequestProto *req = [bldr build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveClanInfoEvent];
}

- (int) sendPromoteDemoteClanMemberMessage:(NSString *)victimUuid newStatus:(UserClanStatus)status {
  PromoteDemoteClanMemberRequestProto *req = [[[[[PromoteDemoteClanMemberRequestProto builder]
                                                 setSender:_sender]
                                                setVictimUuid:victimUuid]
                                               setUserClanStatus:status]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPromoteDemoteClanMemberEvent];
}

- (int) sendBootPlayerFromClan:(NSString *)playerUuid {
  BootPlayerFromClanRequestProto *req = [[[[BootPlayerFromClanRequestProto builder]
                                           setSender:_sender]
                                          setPlayerToBootUuid:playerUuid]
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

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId isFree:(BOOL)free isMultiSpin:(BOOL)multiSpin gemsSpent:(int)gemsSpent tokensChange:(int)tokensChange clientTime:(uint64_t)clientTime {
  PurchaseBoosterPackRequestProto *req = [[[[[[[[[PurchaseBoosterPackRequestProto builder]
                                                 setSender:_sender]
                                                setBoosterPackId:boosterPackId]
                                               setDailyFreeBoosterPack:free]
                                              setClientTime:clientTime]
                                             setBuyingInBulk:multiSpin]
                                            setGemsSpent:gemsSpent]
                                           setGachaCreditsChange:tokensChange]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseBoosterPackEvent];
}

- (int) sendTradeItemForBoosterMessage:(int)itemId clientTime:(uint64_t)clientTime {
  TradeItemForBoosterRequestProto *req = [[[[[TradeItemForBoosterRequestProto builder]
                                             setSender:_sender]
                                            setItemId:itemId]
                                           setClientTime:clientTime]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTradeItemForBoosterEvent];
}

- (int) sendPrivateChatPostMessage:(NSString *)recipientUuid content:(NSString *)content originalLanguage:(TranslateLanguages)originalLanguage{
  PrivateChatPostRequestProto *req = [[[[[[PrivateChatPostRequestProto builder]
                                          setSender:_sender]
                                         setRecipientUuid:recipientUuid]
                                        setContent:content]
                                       setContentLanguage:originalLanguage]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPrivateChatPostEvent];
}

- (int) sendRetrievePrivateChatPostsMessage:(NSString *)otherUserUuid language:(TranslateLanguages)language{
  RetrievePrivateChatPostsRequestProto *req = [[[[[RetrievePrivateChatPostsRequestProto builder]
                                                  setOtherUserUuid:otherUserUuid]
                                                 setSender:_sender]
                                                setLanguage:language]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrievePrivateChatPostEvent];
}

- (int) sendTranslateSelectMessages:(NSString *)otherUserUuid language:(TranslateLanguages)language messages:(NSArray *)messages chatType:(ChatScope)chatType translateOn:(BOOL)translateOn {
  TranslateSelectMessagesRequestProto *req = [[[[[[[[TranslateSelectMessagesRequestProto builder]
                                                    setSender:_sender]
                                                   setOtherUserUuid:otherUserUuid]
                                                  setLanguage:language]
                                                 addAllMessagesToBeTranslated:messages]
                                                setChatType:chatType]
                                               setTranslateOn:translateOn]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTranslateSelectMessagesEvent];
}

- (int) sendBeginDungeonMessage:(uint64_t)clientTime taskId:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId gems:(int)gems enemyElement:(Element)element shouldForceElem:(BOOL)shouldForceElem alreadyCompletedMiniTutorialTask:(BOOL)alreadyCompletedMiniTutorialTask questIds:(NSArray *)questIds hasBeatenTaskBefore:(BOOL)hasBeatenTaskBefore {
  BeginDungeonRequestProto *req = [[[[[[[[[[[[[BeginDungeonRequestProto builder]
                                              setSender:_sender]
                                             setClientTime:clientTime]
                                            setTaskId:taskId]
                                           setIsEvent:isEvent]
                                          setPersistentEventId:eventId]
                                         setGemsSpent:gems]
                                        setElem:element]
                                       setForceEnemyElem:shouldForceElem]
                                      setAlreadyCompletedMiniTutorialTask:alreadyCompletedMiniTutorialTask]
                                     addAllQuestIds:questIds]
                                    setHasBeatenTaskBefore:hasBeatenTaskBefore]
                                   build];
  return [self sendData:req withMessageType:EventProtocolRequestCBeginDungeonEvent];
}

- (int) sendUpdateMonsterHealthMessage:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths isForTask:(BOOL)isForTask userTaskUuid:(NSString *)userTaskUuid taskStageId:(int)taskStageId droplessTsfuUuid:(NSString *)droplessTsfuUuid {
  UpdateMonsterHealthRequestProto_Builder *bldr = [[[[UpdateMonsterHealthRequestProto builder]
                                                     setSender:_sender]
                                                    setClientTime:clientTime]
                                                   addAllUmchp:monsterHealths];
  
  if (isForTask) {
    bldr.isUpdateTaskStageForUser = isForTask;
    bldr.userTaskUuid = userTaskUuid;
    bldr.nuTaskStageId = taskStageId;
    
    if (droplessTsfuUuid) {
      bldr.droplessTsfuUuid = droplessTsfuUuid;
    }
  }
  
  return [self sendData:bldr.build withMessageType:EventProtocolRequestCUpdateMonsterHealthEvent queueUp:YES incrementTagNum:YES];
}

- (int) sendEndDungeonMessage:(NSString *)userTaskUuid userWon:(BOOL)userWon isFirstTimeCompleted:(BOOL)isFirstTimeCompleted droplessTsfuUuids:(NSArray *)droplessTsfuUuids time:(uint64_t)time {
  EndDungeonRequestProto *req = [[[[[[[[EndDungeonRequestProto builder]
                                       setSender:[self senderWithMaxResources]]
                                      setUserTaskUuid:userTaskUuid]
                                     setUserWon:userWon]
                                    setFirstTimeUserWonTask:isFirstTimeCompleted]
                                   setClientTime:time]
                                  addAllDroplessTsfuUuids:droplessTsfuUuids]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEndDungeonEvent];
}

- (int) sendCombineUserMonsterPiecesMessage:(NSArray *)userMonsterUuids gemCost:(int)gemCost clientTime:(uint64_t)clientTime {
  CombineUserMonsterPiecesRequestProto *req = [[[[[[CombineUserMonsterPiecesRequestProto builder]
                                                   setSender:_sender]
                                                  addAllUserMonsterUuids:userMonsterUuids]
                                                 setGemCost:gemCost]
                                                setClientTime:clientTime]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCombineUserMonsterPiecesEvent];
}

- (int) sendSellUserMonstersMessage:(NSArray *)sellProtos {
  SellUserMonsterRequestProto *req = [[[[SellUserMonsterRequestProto builder]
                                        setSender:[self senderWithMaxResources]]
                                       addAllSales:sellProtos]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSellUserMonsterEvent];
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

- (int) sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids {
  GameState *gs = [GameState sharedGameState];
  MinimumUserProtoWithFacebookId *mup = [[[[MinimumUserProtoWithFacebookId builder]
                                           setMinUserProto:_sender]
                                          setFacebookId:gs.facebookId]
                                         build];
  
  AcceptAndRejectFbInviteForSlotsRequestProto *req = [[[[[AcceptAndRejectFbInviteForSlotsRequestProto builder]
                                                         setSender:mup]
                                                        addAllAcceptedInviteUuids:acceptUuids]
                                                       addAllRejectedInviteUuids:rejectUuids]
                                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAcceptAndRejectFbInviteForSlotsEvent];
}

- (int) sendEvolveMonsterMessageWithEvolution:(UserMonsterEvolutionProto *)evo gemCost:(int)gemCost oilChange:(int)oilChange {
  EvolveMonsterRequestProto *req = [[[[[[EvolveMonsterRequestProto builder]
                                        setSender:_sender]
                                       setEvolution:evo]
                                      setGemsSpent:gemCost]
                                     setOilChange:oilChange]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEvolveMonsterEvent];
}

- (int) sendEvolutionFinishedMessageWithGems:(int)gems clientTime:(uint64_t)clientTime {
  EvolutionFinishedRequestProto *req = [[[[[EvolutionFinishedRequestProto builder]
                                           setSender:_sender]
                                          setGemsSpent:gems]
                                         setClientTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEvolutionFinishedEvent];
}

- (int) sendReviveInDungeonMessage:(NSString *)userTaskUuid clientTime:(uint64_t)clientTime userHealths:(NSArray *)healths gems:(int)gems {
  ReviveInDungeonRequestProto *req = [[[[[[[ReviveInDungeonRequestProto builder]
                                           setSender:_sender]
                                          setUserTaskUuid:userTaskUuid]
                                         setClientTime:clientTime]
                                        addAllReviveMe:healths]
                                       setGemsSpent:gems]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCReviveInDungeonEvent];
}

- (int) sendQueueUpMessage:(NSArray *)seenUserUuids clientTime:(uint64_t)clientTime {
  QueueUpRequestProto *req = [[[[[QueueUpRequestProto builder]
                                 addAllSeenUserUuids:seenUserUuids]
                                setAttacker:_sender]
                               setClientTime:clientTime]
                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQueueUpEvent];
}

- (int) sendUpdateUserCurrencyMessageWithCashSpent:(int)cashSpent oilSpent:(int)oilSpent gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime reason:(NSString *)reason shouldFlush:(BOOL)flush {
  UpdateUserCurrencyRequestProto *req = [[[[[[[[UpdateUserCurrencyRequestProto builder]
                                               setSender:_sender]
                                              setCashSpent:cashSpent]
                                             setOilSpent:oilSpent]
                                            setGemsSpent:gemsSpent]
                                           setClientTime:clientTime]
                                          setReason:reason]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpdateUserCurrencyEvent flush:flush queueUp:NO incrementTagNum:YES];
}

- (int) sendBeginPvpBattleMessage:(PvpProto *)enemy senderElo:(int)elo isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime clientTime:(uint64_t)clientTime {
  BeginPvpBattleRequestProto *req = [[[[[[[[BeginPvpBattleRequestProto builder]
                                           setSender:_sender]
                                          setEnemy:enemy]
                                         setSenderElo:elo]
                                        setAttackStartTime:clientTime]
                                       setPreviousBattleEndTime:previousBattleTime]
                                      setExactingRevenge:isRevenge]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginPvpBattleEvent];
}

- (int) sendEndPvpBattleMessage:(NSString *)defenderUuid userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon oilStolenFromStorage:(int)oilStolenFromStorage cashStolenFromStorage:(int)cashStolenFromStorage oilStolenFromGenerators:(int)oilStolenFromGenerators cashStolenFromGenerators:(int)cashStolenFromGenerators structStolens:(NSArray *)structStolens clientTime:(uint64_t)clientTime monsterDropIds:(NSArray *)monsterDropIds {
  EndPvpBattleRequestProto *req = [[[[[[[[[[[[[EndPvpBattleRequestProto builder]
                                              setSender:[self senderWithMaxResources]]
                                             setDefenderUuid:defenderUuid]
                                            setUserAttacked:userAttacked]
                                           setUserWon:userWon]
                                          setOilStolenFromStorage:oilStolenFromStorage]
                                         setCashStolenFromStorage:cashStolenFromStorage]
                                        setOilStolenFromGenerator:oilStolenFromGenerators]
                                       setCashStolenFromGenerator:cashStolenFromGenerators]
                                      addAllStructStolen:structStolens]
                                     setClientTime:clientTime]
                                    addAllMonsterDropIds:monsterDropIds]
                                   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEndPvpBattleEvent];
}

- (int) sendBeginClanRaidMessage:(int)raidId eventId:(int)eventId isFirstStage:(BOOL)isFirstStage curTime:(uint64_t)curTime userMonsters:(NSArray *)userMonsters {
  BeginClanRaidRequestProto_Builder *bldr = [[[[[[BeginClanRaidRequestProto builder]
                                                 setSender:_sender]
                                                setCurTime:curTime]
                                               setRaidId:raidId]
                                              setClanEventId:eventId]
                                             setIsFirstStage:isFirstStage];
  
  if (userMonsters.count > 0) {
    [bldr setSetMonsterTeamForRaid:YES];
    [bldr addAllUserMonsters:userMonsters];
  }
  
  return [self sendData:bldr.build withMessageType:EventProtocolRequestCBeginClanRaidEvent];
}

- (int) sendAttackClanRaidMonsterMessage:(PersistentClanEventClanInfoProto *)eventDetails clientTime:(uint64_t)clientTime damageDealt:(int)damageDealt curTeam:(UserCurrentMonsterTeamProto *)curTeam monsterHealths:(NSArray *)monsterHealths attacker:(FullUserMonsterProto *)attacker {
  AttackClanRaidMonsterRequestProto_Builder *bldr = [AttackClanRaidMonsterRequestProto builder];
  bldr.sender = _sender;
  bldr.eventDetails = eventDetails;
  bldr.clientTime = clientTime;
  bldr.damageDealt = damageDealt;
  [bldr addAllMonsterHealths:monsterHealths];
  bldr.userMonsterTeam = curTeam;
  bldr.userMonsterThatAttacked = attacker;
  
  return [self sendData:bldr.build withMessageType:EventProtocolRequestCAttackClanRaidMonsterEvent];
}

- (int) sendSpawnObstacleMessage:(NSArray *)obstacles clientTime:(uint64_t)clientTime {
  SpawnObstacleRequestProto *req = [[[[[SpawnObstacleRequestProto builder]
                                       setSender:_sender]
                                      addAllProspectiveObstacles:obstacles]
                                     setCurTime:clientTime]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSpawnObstacleEvent];
}

- (int) sendBeginObstacleRemovalMessage:(NSString *)userObstacleUuid resType:(ResourceType)resType resChange:(int)resChange gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime {
  BeginObstacleRemovalRequestProto *req = [[[[[[[[BeginObstacleRemovalRequestProto builder]
                                                 setSender:_sender]
                                                setUserObstacleUuid:userObstacleUuid]
                                               setResourceType:resType]
                                              setResourceChange:resChange]
                                             setGemsSpent:gemsSpent]
                                            setCurTime:clientTime]
                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginObstacleRemovalEvent];
}

- (int) sendObstacleRemovalCompleteMessage:(NSString *)userObstacleUuid speedup:(BOOL)speedUp gemsSpent:(int)gemsSpent maxObstacles:(BOOL)maxObstacles clientTime:(uint64_t)clientTime {
  ObstacleRemovalCompleteRequestProto *req = [[[[[[[[ObstacleRemovalCompleteRequestProto builder]
                                                    setUserObstacleUuid:userObstacleUuid]
                                                   setSender:_sender]
                                                  setSpeedUp:speedUp]
                                                 setGemsSpent:gemsSpent]
                                                setAtMaxObstacles:maxObstacles]
                                               setCurTime:clientTime]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCObstacleRemovalCompleteEvent];
}

- (int) sendAchievementProgressMessage:(NSArray *)userAchievements clientTime:(uint64_t)clientTime {
  // If we are currently batching struct retrievals, save all achievements till the struct retrievals completes
  if (self.structRetrievals.count == 0) {
    AchievementProgressRequestProto *req = [[[[[AchievementProgressRequestProto builder]
                                               setSender:_sender]
                                              setClientTime:clientTime]
                                             addAllUapList:userAchievements]
                                            build];
    
    return [self sendData:req withMessageType:EventProtocolRequestCAchievementProgressEvent queueUp:YES incrementTagNum:NO];
  } else {
    // Use a dictionary so that repeats will be replaced (i.e. 2 retrievals of cash)
    for (UserAchievementProto *uap in userAchievements) {
      [self.structRetrievalAchievements setObject:uap forKey:@(uap.achievementId)];
    }
    
    self.lastClientTime = clientTime;
    return 0;
  }
}

- (int) sendAchievementRedeemMessage:(int)achievementId clientTime:(uint64_t)clientTime {
  AchievementRedeemRequestProto *req = [[[[[AchievementRedeemRequestProto builder]
                                           setSender:_sender]
                                          setAchievementId:achievementId]
                                         setClientTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAchievementRedeemEvent];
}

- (int) sendBeginResearchMessage:(int)researchId uuid:(NSString*)uuid clientTime:(uint64_t)clientTime gems:(int)gems resourceType:(ResourceType)resourceType resourceCost:(int)resourceCost{
  PerformResearchRequestProto *req = [[[[[[[[[PerformResearchRequestProto builder]
                                             setSender:_sender]
                                            setResearchId:researchId]
                                           setUserResearchUuid:uuid]
                                          setClientTime:clientTime]
                                         setGemsCost:gems]
                                        setResourceCost:resourceCost]
                                       setResourceType:resourceType]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPerformResearchEvent];
}

- (int) sendFinishPerformingResearchRequestProto:(NSString *)uuid gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime {
  FinishPerformingResearchRequestProto *req = [[[[[[FinishPerformingResearchRequestProto builder]
                                                   setSender:_sender]
                                                  setUserResearchUuid:uuid]
                                                 setGemsCost:gemsSpent]
                                                setClientTime:clientTime]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCFinishPerformingResearchEvent];
}

- (int) sendSpawnMiniJobMessage:(int)numToSpawn clientTime:(uint64_t)clientTime structId:(int)structId {
  SpawnMiniJobRequestProto *req = [[[[[[SpawnMiniJobRequestProto builder]
                                       setSender:_sender]
                                      setNumToSpawn:numToSpawn]
                                     setClientTime:clientTime]
                                    setStructId:structId]
                                   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSpawnMiniJobEvent];
}

- (int) sendBeginMiniJobMessage:(NSString *)userMiniJobUuid userMonsterUuids:(NSArray *)userMonsterUuids clientTime:(uint64_t)clientTime {
  BeginMiniJobRequestProto *req = [[[[[[BeginMiniJobRequestProto builder]
                                       setSender:_sender]
                                      setUserMiniJobUuid:userMiniJobUuid]
                                     addAllUserMonsterUuids:userMonsterUuids]
                                    setClientTime:clientTime]
                                   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginMiniJobEvent];
}

- (int) sendCompleteMiniJobMessage:(NSString *)userMiniJobUuid isSpeedUp:(BOOL)isSpeedUp gemCost:(int)gemCost clientTime:(uint64_t)clientTime {
  CompleteMiniJobRequestProto *req = [[[[[[[CompleteMiniJobRequestProto builder]
                                           setSender:_sender]
                                          setUserMiniJobUuid:userMiniJobUuid]
                                         setIsSpeedUp:isSpeedUp]
                                        setGemCost:gemCost]
                                       setClientTime:clientTime]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCompleteMiniJobEvent];
}

- (int) sendRedeemMiniJobMessage:(NSString *)userMiniJobUuid clientTime:(uint64_t)clientTime monsterHealths:(NSArray *)monsterHealths {
  RedeemMiniJobRequestProto *req = [[[[[[RedeemMiniJobRequestProto builder]
                                        setSender:[self senderWithMaxResources]]
                                       setUserMiniJobUuid:userMiniJobUuid]
                                      setClientTime:clientTime]
                                     addAllUmchp:monsterHealths]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemMiniJobEvent];
}

- (int) sendRefreshMiniJobMessage:(NSArray *)replacedMiniJobs itemId:(int32_t)itemId numToSpawn:(int32_t)numToSpawn gemsSpent:(int32_t)gemsSpent quality:(Quality)quality clientTime:(uint64_t)clientTime structId:(int32_t)structId {
  RefreshMiniJobRequestProto *req = [[[[[[[[[[RefreshMiniJobRequestProto builder]
                                             setSender:_sender]
                                            addAllDeleteUserMiniJobIds:replacedMiniJobs]
                                           setItemId:itemId]
                                          setNumToSpawn:numToSpawn]
                                         setGemsSpent:gemsSpent]
                                        setMinQualitySpawned:quality]
                                       setClientTime:clientTime]
                                      setStructId:structId]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRefreshMiniJobEvent];
}

- (int) sendSetAvatarMonsterMessage:(int)avatarMonsterId {
  SetAvatarMonsterRequestProto *req = [[[[SetAvatarMonsterRequestProto builder]
                                         setSender:_sender]
                                        setMonsterId:avatarMonsterId]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSetAvatarMonsterEvent];
}

- (int) sendRestrictUserMonsterMessage:(NSArray *)userMonsterUuids {
  RestrictUserMonsterRequestProto *req = [[[[RestrictUserMonsterRequestProto builder]
                                            setSender:_sender]
                                           addAllUserMonsterUuids:userMonsterUuids]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRestrictUserMonsterEvent];
}

- (int) sendUnrestrictUserMonsterMessage:(NSArray *)userMonsterUuids {
  UnrestrictUserMonsterRequestProto *req = [[[[UnrestrictUserMonsterRequestProto builder]
                                              setSender:_sender]
                                             addAllUserMonsterUuids:userMonsterUuids]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUnrestrictUserMonsterEvent];
}

- (int) sendDevRequestProto:(DevRequest)request staticDataId:(int)staticDataId quantity:(int)quantity {
  DevRequestProto *req = [[[[[[DevRequestProto builder]
                              setDevRequest:request]
                             setStaticDataId:staticDataId]
                            setQuantity:quantity]
                           setSender:_sender]
                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCDevEvent];
}

- (int) sendAddMonsterToTeam:(NSString *)userMonsterUuid teamSlot:(int)teamSlot {
  AddMonsterToBattleTeamRequestProto *req = [[[[[AddMonsterToBattleTeamRequestProto builder]
                                                setSender:_sender]
                                               setUserMonsterUuid:userMonsterUuid]
                                              setTeamSlotNum:teamSlot]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAddMonsterToBattleTeamEvent queueUp:YES incrementTagNum:YES];
}

- (int) sendRemoveMonsterFromTeam:(NSString *)userMonsterUuid {
  RemoveMonsterFromBattleTeamRequestProto *req = [[[[RemoveMonsterFromBattleTeamRequestProto builder]
                                                    setSender:_sender]
                                                   setUserMonsterUuid:userMonsterUuid]
                                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRemoveMonsterFromBattleTeamEvent queueUp:YES incrementTagNum:YES];
}

- (int) sendBuyInventorySlotsWithGems:(NSString *)userStructUuid {
  IncreaseMonsterInventorySlotRequestProto *req = [[[[[IncreaseMonsterInventorySlotRequestProto builder]
                                                      setSender:_sender]
                                                     setIncreaseSlotType:IncreaseMonsterInventorySlotRequestProto_IncreaseSlotTypePurchase]
                                                    setUserStructUuid:userStructUuid]
                                                   build];
  
  return [self sendData:req withMessageType:EventProtocolResponseSIncreaseMonsterInventorySlotEvent];
}

- (int) sendBuyInventorySlots:(NSString *)userStructUuid withFriendInvites:(NSArray *)inviteUuids {
  IncreaseMonsterInventorySlotRequestProto *req = [[[[[[IncreaseMonsterInventorySlotRequestProto builder]
                                                       setSender:_sender]
                                                      setIncreaseSlotType:IncreaseMonsterInventorySlotRequestProto_IncreaseSlotTypeRedeemFacebookInvites]
                                                     setUserStructUuid:userStructUuid]
                                                    addAllUserFbInviteForSlotUuids:inviteUuids]
                                                   build];
  
  return [self sendData:req withMessageType:EventProtocolResponseSIncreaseMonsterInventorySlotEvent];
}

- (int) sendHealQueueWaitTimeComplete:(NSArray *)monsterHealths clientTime:(uint64_t)clientTime {
  HealMonsterRequestProto *req = [[[[[HealMonsterRequestProto builder]
                                     setSender:[self senderWithMaxResources]]
                                    addAllUmchp:monsterHealths]
                                   setClientTime:clientTime]
                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCHealMonsterEvent];
  
  return tag;
}

- (int) sendHealQueueSpeedup:(NSArray *)monsterHealths goldCost:(int)goldCost clientTime:(uint64_t)clientTime {
  HealMonsterRequestProto *req = [[[[[[[HealMonsterRequestProto builder]
                                       setSender:[self senderWithMaxResources]]
                                      setIsSpeedup:YES]
                                     setGemsForSpeedup:goldCost]
                                    addAllUmchp:monsterHealths]
                                   setClientTime:clientTime]
                                  build];
  
  int tag = [self sendData:req withMessageType:EventProtocolRequestCHealMonsterEvent];
  
  return tag;
}

- (int) sendEnhanceMessage:(UserEnhancementProto *)enhancement monsterExp:(UserMonsterCurrentExpProto *)monsterExp gemCost:(int)gemCost oilChange:(int)oilChange {
  EnhanceMonsterRequestProto *req = [[[[[[[EnhanceMonsterRequestProto builder]
                                          setSender:_sender]
                                         setUep:enhancement]
                                        setEnhancingResult:monsterExp]
                                       setGemsSpent:gemCost]
                                      setOilChange:oilChange]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEnhanceMonsterEvent];
}

- (int) sendSubmitEnhancementMessage:(NSArray *)items gemCost:(int)gemCost oilChange:(int)oilChange clientTime:(uint64_t)clientTime {
  SubmitMonsterEnhancementRequestProto *req = [[[[[[[SubmitMonsterEnhancementRequestProto builder]
                                                    setSender:[self senderWithMaxResources]]
                                                   addAllUeipNew:items]
                                                  setGemsSpent:gemCost]
                                                 setOilChange:oilChange]
                                                setClientTime:clientTime]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSubmitMonsterEnhancementEvent];
}

- (int) sendEnhanceWaitCompleteMessage:(NSString *)userMonsterUuid isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost clientTime:(uint64_t)clientTime {
  EnhancementWaitTimeCompleteRequestProto *req = [[[[[[[EnhancementWaitTimeCompleteRequestProto builder]
                                                       setSender:_sender]
                                                      setUserMonsterUuid:userMonsterUuid]
                                                     setIsSpeedup:isSpeedup]
                                                    setGemsForSpeedup:gemCost]
                                                   setClientTime:clientTime]
                                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEnhancementWaitTimeCompleteEvent];
}

- (int) sendCollectMonsterEnhancementMessage:(UserMonsterCurrentExpProto *)exp userMonsterUuids:(NSArray *)userMonsterUuids clientTime:(uint64_t)clientTime {
  CollectMonsterEnhancementRequestProto *req = [[[[[[CollectMonsterEnhancementRequestProto builder]
                                                    setSender:_sender]
                                                   setUmcep:exp]
                                                  addAllUserMonsterUuids:userMonsterUuids]
                                                 setClientTime:clientTime]
                                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCollectMonsterEnhancementEvent];
}

- (int) sendSolicitClanHelpMessage:(NSArray *)clanHelpNotices maxHelpers:(int)maxHelpers clientTime:(uint64_t)clientTime {
  SolicitClanHelpRequestProto *req = [[[[[[SolicitClanHelpRequestProto builder]
                                          setSender:_sender]
                                         setClientTime:clientTime]
                                        setMaxHelpers:maxHelpers]
                                       addAllNotice:clanHelpNotices]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSolicitClanHelpEvent flush:NO queueUp:NO incrementTagNum:NO];
}

- (int) sendGiveClanHelpMessage:(NSArray *)clanHelpUuids {
  GiveClanHelpRequestProto *req = [[[[GiveClanHelpRequestProto builder]
                                     setSender:_sender]
                                    addAllClanHelpUuids:clanHelpUuids]
                                   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCGiveClanHelpEvent];
}


- (int) sendEndClanHelpMessage:(NSArray *)clanHelpUuids {
  EndClanHelpRequestProto *req = [[[[EndClanHelpRequestProto builder]
                                    setSender:_sender]
                                   addAllClanHelpUuids:clanHelpUuids]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEndClanHelpEvent flush:NO queueUp:YES incrementTagNum:NO];
}

- (int) sendRemoveUserItemUsedMessage:(NSArray *)usageUuids {
  RemoveUserItemUsedRequestProto *req = [[[[RemoveUserItemUsedRequestProto builder]
                                           setSender:_sender]
                                          addAllUserItemUsedUuid:usageUuids]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRemoveUserItemUsedEvent queueUp:YES incrementTagNum:NO];
}

- (int) sendTradeItemForResourcesMessage:(NSArray *)itemIdsUsed updatedUserItems:(NSArray *)updatedUserItems gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime {
  TradeItemForResourcesRequestProto *req = [[[[[[[TradeItemForResourcesRequestProto builder]
                                                 setSender:[self senderWithMaxResources]]
                                                addAllItemIdsUsed:itemIdsUsed]
                                               addAllNuUserItems:updatedUserItems]
                                              setClientTime:clientTime]
                                             setGemsSpent:gemsSpent]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTradeItemForResourcesEvent queueUp:YES incrementTagNum:YES];
}

- (int) sendRedeemSecretGiftMessage:(NSArray *)uisgIds clientTime:(uint64_t)clientTime {
  RedeemSecretGiftRequestProto *req = [[[[[RedeemSecretGiftRequestProto builder]
                                          setSender:_sender]
                                         setClientTime:clientTime]
                                        addAllUisgUuid:uisgIds]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemSecretGiftEvent];
}

- (int) sendSetDefendingMsgMessage:(NSString *)newMsg {
  SetDefendingMsgRequestProto *req = [[[[SetDefendingMsgRequestProto builder]
                                        setSender:_sender]
                                       setMsg:newMsg]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSetDefendingMsgEvent];
}

- (int) sendBeginClanAvengingMessage:(NSArray *)pvpHistories clientTime:(uint64_t)clientTime {
  BeginClanAvengingRequestProto *req = [[[[[BeginClanAvengingRequestProto builder]
                                           setSender:_sender]
                                          addAllRecentNbattles:pvpHistories]
                                         setClientTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginClanAvengingEvent];
}

- (int) sendAvengeClanMateMessage:(PvpClanAvengeProto *)ca clientTime:(uint64_t)clientTime {
  AvengeClanMateRequestProto *req = [[[[[AvengeClanMateRequestProto builder]
                                        setSender:_sender]
                                       setClanAvenge:ca]
                                      setClientTime:clientTime]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCAvengeClanMateEvent];
}

- (int) sendEndClanAvengingMessage:(NSArray *)avengeUuids {
  EndClanAvengingRequestProto *req = [[[[EndClanAvengingRequestProto builder]
                                        setSender:_sender]
                                       addAllClanAvengeUuids:avengeUuids]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEndClanAvengingEvent];
}

- (int) sendSolicitTeamDonationMessage:(NSString *)msg powerLimit:(int)powerLimit clientTime:(uint64_t)clientTime gemsSpent:(int)gemsSpent {
  SolicitTeamDonationRequestProto *req = [[[[[[[SolicitTeamDonationRequestProto builder]
                                               setSender:_sender]
                                              setMsg:msg]
                                             setPowerLimit:powerLimit]
                                            setClientTime:clientTime]
                                           setGemsSpent:gemsSpent]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSolicitTeamDonationEvent];
}

- (int) sendFulfillTeamDonationSolicitationMessage:(FullUserMonsterProto *)fump solicitation:(ClanMemberTeamDonationProto *)solicitation clientTime:(uint64_t)clientTime {
  FulfillTeamDonationSolicitationRequestProto *req = [[[[[[FulfillTeamDonationSolicitationRequestProto builder]
                                                          setSender:_sender]
                                                         setClientTime:clientTime]
                                                        setSolicitation:solicitation]
                                                       setFump:fump]
                                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCFulfillTeamDonationSolicitationEvent];
}

- (int) sendVoidTeamDonationSolicitationMessage:(NSArray *)solicitations {
  VoidTeamDonationSolicitationRequestProto *req = [[[[VoidTeamDonationSolicitationRequestProto builder]
                                                     setSender:_sender]
                                                    addAllSolicitations:solicitations]
                                                   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCVoidTeamDonationSolicitationEvent queueUp:YES incrementTagNum:YES];
}

- (int) sendRetrieveUserMonsterTeamMessage:(NSArray *)userUuids {
  RetrieveUserMonsterTeamRequestProto *req = [[[[RetrieveUserMonsterTeamRequestProto builder]
                                                setSender:_sender]
                                               addAllUserUuids:userUuids]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveUserMonsterTeamEvent];
}

- (int) sendCustomizePvpBoardObstacleMessage:(NSArray *)removeUpboIds nuOrUpdatedObstacles:(NSArray *)nuOrUpdatedObstacles {
  CustomizePvpBoardObstacleRequestProto* req = [[[[[CustomizePvpBoardObstacleRequestProto builder]
                                                   setSender:_sender]
                                                  addAllRemoveUpboIds:removeUpboIds]
                                                 addAllNuOrUpdatedObstacles:nuOrUpdatedObstacles] build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCustomizePvpBoardObstacleEvent];
}

- (int) sendCompleteBattleItemMessage:(NSArray *)completedBiqfus isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost clientTime:(uint64_t)clientTime {
  CompleteBattleItemRequestProto *req = [[[[[[[CompleteBattleItemRequestProto builder]
                                              setSender:_sender]
                                             addAllBiqfuCompleted:completedBiqfus]
                                            setIsSpeedup:isSpeedup]
                                           setGemsForSpeedup:gemCost]
                                          setClientTime:clientTime]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCompleteBattleItemEvent];
}

- (int) sendDiscardBattleItemMessage:(NSArray *)battleItemIds clientTime:(uint64_t)clientTime {
  DiscardBattleItemRequestProto *req = [[[[[DiscardBattleItemRequestProto builder]
                                           setSender:_sender]
                                          addAllDiscardedBattleItemIds:battleItemIds]
                                         setClientTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCDiscardBattleItemEvent flush:NO queueUp:YES incrementTagNum:NO];
}

- (int) sendUpdateUserStrengthMessage:(uint64_t)newStrength highestToonAtk:(int)highestToonAtk highestToonHp:(int)highestToonHp {
  UpdateUserStrengthRequestProto *req = [[[[[[UpdateUserStrengthRequestProto builder]
                                             setSender:_sender]
                                            setUpdatedStrength:newStrength]
                                           setHighestToonAtk:highestToonAtk]
                                          setHighestToonHp:highestToonHp]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpdateUserStrengthEvent flush:NO queueUp:YES incrementTagNum:NO];
}

- (int) sendRetrieveMiniEventRequestProtoMessageWithClientTime:(uint64_t)clientTime {
  RetrieveMiniEventRequestProto* req = [[[[RetrieveMiniEventRequestProto builder]
                                          setSender:_sender]
                                         setClientTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveMiniEventEvent flush:YES queueUp:YES incrementTagNum:YES];
}

- (int) sendRedeemMiniEventRewardRequestProtoMessage:(RedeemMiniEventRewardRequestProto_RewardTier)tierRedeemed miniEventForPlayerLevelId:(int32_t)mefplId clientTime:(uint64_t)clientTime {
  RedeemMiniEventRewardRequestProto* req = [[[[[[RedeemMiniEventRewardRequestProto builder]
                                                setSender:[self senderWithMaxResources]]
                                               setTierRedeemed:tierRedeemed]
                                              setMefplId:mefplId]
                                             setClientTime:clientTime] build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemMiniEventRewardEvent];
}

- (int) sendTangoGiftsForTangoIds:(NSArray *)tangoIds myTangoId:(NSString *)myTangoId tangoName:(NSString *)tangoName gemReward:(int32_t)gemReward clientTime:(int64_t)clientTime {
  SendTangoGiftRequestProto *req = [[[[[[[[SendTangoGiftRequestProto builder]
                                          setSender:_sender]
                                         addAllTangoUserIds:tangoIds]
                                        setClientTime:clientTime]
                                       setSenderTangoUserId:myTangoId]
                                      setSenderTangoName:tangoName]
                                     setGemReward:gemReward]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSendTangoGiftEvent];
}

- (int) sendSetTangoId:(NSString *)tangoId {
  SetTangoIdRequestProto *req = [[[[SetTangoIdRequestProto builder]
                                   setSender:_sender]
                                  setTangoId:tangoId]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSetTangoIdEvent];
}

- (int) sendRetrieveStrengthLeaderBoarderMessage:(int)minRank maxRank:(int)maxRank {
  RetrieveStrengthLeaderBoardRequestProto *req = [[[[[RetrieveStrengthLeaderBoardRequestProto builder]
                                                     setMinRank:minRank]
                                                    setMaxRank:maxRank]
                                                   setSender:_sender]
                                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveStrengthLeaderBoardEvent];
}

- (int) sendCollectGiftMessage:(NSArray *)userClanGifts clientTime:(uint64_t)clientTime {
  CollectGiftRequestProto *req = [[[[[CollectGiftRequestProto builder]
                                     setSender:[self senderWithMaxResources]]
                                    addAllUgUuids:userClanGifts]
                                   setClientTime:clientTime]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCollectGiftEvent];
}

- (int) sendDeleteGiftsMessage:(NSArray *)userClanGifts {
  DeleteGiftRequestProto *req = [[[[DeleteGiftRequestProto builder]
                                   setSender:_sender]
                                  addAllExpiredGifts:userClanGifts]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCDeleteGiftEvent];
}

#pragma mark - Batch/Flush events

// Only for batched events.. for the redundant time check
- (uint64_t) getCurrentMilliseconds {
  return ((uint64_t)[[MSDate date] timeIntervalSince1970])*1000;
}

- (int) retrieveCurrencyFromStruct:(NSString *)userStructUuid time:(uint64_t)time amountCollected:(int)amountCollected {
  [self flushAllExceptEventType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent];
  RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval *sr = [[[[[RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval builder]
                                                                          setUserStructUuid:userStructUuid]
                                                                         setTimeOfRetrieval:time]
                                                                        setAmountCollected:amountCollected]
                                                                       build];
  [self.structRetrievals addObject:sr];
  return _currentTagNum;
}

- (int) sendRetrieveCurrencyFromNormStructureMessage {
  RetrieveCurrencyFromNormStructureRequestProto *req = [[[[RetrieveCurrencyFromNormStructureRequestProto builder]
                                                          setSender:[self senderWithMaxResources]]
                                                         addAllStructRetrievals:self.structRetrievals]
                                                        build];
  
  LNLog(@"Sending retrieve currency message with %d structs.",  (int)self.structRetrievals.count);
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent flush:NO queueUp:YES incrementTagNum:YES];
}



- (int) tradeItemForSpeedups:(NSArray *)uiups gemsSpent:(int)gemsSpent updatedUserItem:(UserItemProto *)uip {
  [self flushAllExceptEventType:EventProtocolRequestCTradeItemForSpeedUpsEvent];
  [_speedupItemUsages addObjectsFromArray:uiups];
  _speedupGems += gemsSpent;
  
  // remove the user item first if it is already in here
  for (int i = 0; i < _speedupUpdatedUserItems.count; i++) {
    UserItemProto *u = _speedupUpdatedUserItems[i];
    if (u.itemId == uip.itemId) {
      [_speedupUpdatedUserItems removeObjectAtIndex:i];
    }
  }
  [_speedupUpdatedUserItems addObject:uip];
  
  return _currentTagNum;
}

- (int) sendTradeItemForSpeedUpsMessage {
  TradeItemForSpeedUpsRequestProto *req = [[[[[[TradeItemForSpeedUpsRequestProto builder]
                                               setSender:_sender]
                                              addAllItemsUsed:_speedupItemUsages]
                                             addAllNuUserItems:_speedupUpdatedUserItems]
                                            setGemsSpent:_speedupGems]
                                           build];
  
  LNLog(@"Sending trade item for speedups message with %d item usages.", (int)_speedupItemUsages.count);
  
  return [self sendData:req withMessageType:EventProtocolRequestCTradeItemForSpeedUpsEvent flush:NO queueUp:YES incrementTagNum:NO];
}



- (int) tradeItemForResources:(int)itemId updatedUserItem:(UserItemProto *)uip gemsSpent:(int)gemsSpent clientTime:(uint64_t)clientTime {
  [self flushAllExceptEventType:EventProtocolRequestCTradeItemForResourcesEvent];
  [_resourceItemIdsUsed addObject:@(itemId)];
  _resourceGems += gemsSpent;
  
  // remove the user item first if it is already in here
  for (int i = 0; i < _resourceUpdatedUserItems.count; i++) {
    UserItemProto *u = _resourceUpdatedUserItems[i];
    if (u.itemId == uip.itemId) {
      [_resourceUpdatedUserItems removeObjectAtIndex:i];
    }
  }
  [_resourceUpdatedUserItems addObject:uip];
  
  self.lastClientTime = clientTime;
  
  return _currentTagNum;
}

- (int) sendTradeItemForResourcesMessage {
  TradeItemForResourcesRequestProto *req = [[[[[[[TradeItemForResourcesRequestProto builder]
                                                 setSender:[self senderWithMaxResources]]
                                                addAllItemIdsUsed:_resourceItemIdsUsed]
                                               addAllNuUserItems:_resourceUpdatedUserItems]
                                              setClientTime:self.lastClientTime]
                                             setGemsSpent:_resourceGems]
                                            build];
  
  LNLog(@"Sending trade item for resources message with %d items.", (int)_resourceItemIdsUsed.count);
  
  return [self sendData:req withMessageType:EventProtocolRequestCTradeItemForResourcesEvent flush:NO queueUp:YES incrementTagNum:YES];
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
  self.healingQueueSnapshot = [gs.allMonsterHealingItems clone];
}

- (int) sendHealMonsterMessage {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *old = [NSMutableSet setWithArray:self.healingQueueSnapshot];
  NSMutableSet *cur = [NSMutableSet setWithArray:gs.allMonsterHealingItems];
  
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
    if (![[itemOld convertToProto].data isEqual:[itemNew convertToProto].data]) {
      [changed addObject:itemNew];
    }
  }
  
  if (added.count || removed.count || changed.count || _healingQueueCashChange || _healingQueueGemCost) {
    HealMonsterRequestProto_Builder *bldr = [[HealMonsterRequestProto builder] setSender:[self senderWithMaxResources]];
    
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
    [bldr setGemCostForHealing:_healingQueueGemCost];
    [bldr setClientTime:[self getCurrentMilliseconds]];
    
    LNLog(@"Sending healing queue update with %d adds, %d removals, and %d updates.",  (int)added.count,  (int)removed.count,  (int)changed.count);
    LNLog(@"Cash change: %@, gemCost: %d", [Globals commafyNumber:_healingQueueCashChange], _healingQueueGemCost);
    
    return [self sendData:bldr.build withMessageType:EventProtocolRequestCHealMonsterEvent flush:NO queueUp:YES incrementTagNum:YES];
  } else {
    return 0;
  }
}



- (int) setBattleItemQueueDirtyWithCoinChange:(int)coinChange oilChange:(int)oilChange gemCost:(int)gemCost {
  [self flushAllExceptEventType:EventProtocolRequestCCreateBattleItemEvent];
  _battleItemQueueCashChange += coinChange;
  _battleItemQueueOilChange += oilChange;
  _battleItemQueueGemCost += gemCost;
  _battleItemQueuePotentiallyChanged = YES;
  return _currentTagNum;
}

- (void) reloadBattleItemQueueSnapshot {
  GameState *gs = [GameState sharedGameState];
  self.battleItemQueueSnapshot = [gs.battleItemUtil.battleItemQueue.queueObjects clone];
}

- (int) sendBattleItemQueueMessage {
  GameState *gs = [GameState sharedGameState];
  NSMutableSet *old = [NSMutableSet setWithArray:self.battleItemQueueSnapshot];
  NSMutableSet *cur = [NSMutableSet setWithArray:gs.battleItemUtil.battleItemQueue.queueObjects];
  
  NSMutableSet *added = cur.mutableCopy;
  [added minusSet:old];
  
  NSMutableSet *removed = old.mutableCopy;
  [removed minusSet:cur];
  
  NSMutableSet *modifiedOld = old.mutableCopy;
  [modifiedOld intersectSet:cur];
  
  NSMutableSet *modifiedCur = cur.mutableCopy;
  [modifiedCur intersectSet:old];
  
  NSMutableSet *changed = [NSMutableSet set];
  for (BattleItemQueueObject *itemOld in modifiedOld) {
    BattleItemQueueObject *itemNew = [modifiedCur member:itemOld];
    if (![[itemOld convertToProto].data isEqual:[itemNew convertToProto].data]) {
      [changed addObject:itemNew];
    }
  }
  
  if (added.count || removed.count || changed.count || _battleItemQueueCashChange || _battleItemQueueOilChange || _battleItemQueueGemCost) {
    CreateBattleItemRequestProto_Builder *bldr = [[CreateBattleItemRequestProto builder] setSender:[self senderWithMaxResources]];
    
    for (BattleItemQueueObject *item in added) {
      [bldr addBiqfuNew:[item convertToProto]];
    }
    
    for (BattleItemQueueObject *item in removed) {
      [bldr addBiqfuDelete:[item convertToProto]];
    }
    
    for (BattleItemQueueObject *item in changed) {
      [bldr addBiqfuUpdate:[item convertToProto]];
    }
    
    [bldr setCashChange:_battleItemQueueCashChange];
    [bldr setOilChange:_battleItemQueueOilChange];
    [bldr setGemCostForCreating:_battleItemQueueGemCost];
    [bldr setClientTime:[self getCurrentMilliseconds]];
    
    LNLog(@"Sending battle item queue update with %d adds, %d removals, and %d updates.",  (int)added.count,  (int)removed.count,  (int)changed.count);
    LNLog(@"Cash change: %@, oil change: %@, gemCost: %d", [Globals commafyNumber:_battleItemQueueCashChange], [Globals commafyNumber:_battleItemQueueOilChange], _battleItemQueueGemCost);
    
    return [self sendData:bldr.build withMessageType:EventProtocolRequestCCreateBattleItemEvent flush:NO queueUp:YES incrementTagNum:YES];
  } else {
    return 0;
  }
}



- (int) updateClientTaskStateMessage:(NSData *)data {
  [self flushAllExceptEventType:EventProtocolRequestCUpdateClientTaskStateEvent];
  
  _latestTaskClientState = data;
  
  return _currentTagNum;
}

- (int) sendUpdateClientTaskStateMessage {
  UpdateClientTaskStateRequestProto *req = [[[[UpdateClientTaskStateRequestProto builder]
                                              setSender:_sender]
                                             setTaskState:_latestTaskClientState]
                                            build];
  
  LNLog(@"Sending latest client state.");
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpdateClientTaskStateEvent flush:NO queueUp:YES incrementTagNum:YES];
}

- (int) updateUserMiniEventMessage:(UserMiniEventGoal *)updatedUserMiniEventGoal {
  [self flushAllExceptEventType:EventProtocolRequestCUpdateMiniEventEvent];
  
  [_updatedUserMiniEventGoals setObject:[updatedUserMiniEventGoal convertToProto] forKey:@(updatedUserMiniEventGoal.miniEventGoalId)];
  
  return _currentTagNum;
}

- (int) sendUpdateUserMiniEventMessage {
  UpdateMiniEventRequestProto* req = [[[[[UpdateMiniEventRequestProto builder]
                                         setSender:_sender]
                                        addAllUpdatedGoals:[_updatedUserMiniEventGoals allValues]]
                                       setClientTime:[self getCurrentMilliseconds]]
                                      build];
  
  LNLog(@"Sending updated mini event goals.");
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpdateMiniEventEvent flush:NO queueUp:YES incrementTagNum:YES];
}

#pragma mark - Flush

- (void) timerFlush {
  if (!_pauseFlushTimer) {
    [self flush];
  }
}

- (void) flush {
  [self flushAndQueueUp];
  if (self.queuedMessages.count) {
    NSArray *msgs = [self.queuedMessages copy];
    [self.queuedMessages removeAllObjects];
    [self sendFullEvents:msgs];
  }
}

- (BOOL) flushAndQueueUp {
  return [self flushAllExceptEventType:-1];
}

- (BOOL) flushAllExceptEventType:(int)val {
  return [self flushAllExcept:[NSNumber numberWithInt:val]];
}

- (BOOL) flushAllExcept:(NSNumber *)num {
  BOOL found = NO;
  
  int type = num.intValue;
  if (type != EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent) {
    if (self.structRetrievals.count > 0) {
      [self sendRetrieveCurrencyFromNormStructureMessage];
      [self.structRetrievals removeAllObjects];
      
      if (self.structRetrievalAchievements.count) {
        [self sendAchievementProgressMessage:self.structRetrievalAchievements.allValues clientTime:self.lastClientTime];
        [self.structRetrievalAchievements removeAllObjects];
        
        found = YES;
      }
    }
  }
  
  // Combining heal and speedups becuase otherwise speeding up heal queue won't batch either event
  // since it changes heal queue and adds a speedup
  if (type != EventProtocolRequestCHealMonsterEvent &&
      type != EventProtocolRequestCTradeItemForSpeedUpsEvent) {
    if (_healingQueuePotentiallyChanged) {
      int val = [self sendHealMonsterMessage];
      [self reloadHealQueueSnapshot];
      _healingQueuePotentiallyChanged = NO;
      _healingQueueGemCost = 0;
      _healingQueueCashChange = 0;
      
      if (val) {
        found = YES;
      }
    }
  }
  
  if (type != EventProtocolRequestCCreateBattleItemEvent &&
      type != EventProtocolRequestCTradeItemForSpeedUpsEvent) {
    if (_battleItemQueuePotentiallyChanged) {
      int val = [self sendBattleItemQueueMessage];
      [self reloadBattleItemQueueSnapshot];
      _battleItemQueuePotentiallyChanged = NO;
      _battleItemQueueGemCost = 0;
      _battleItemQueueCashChange = 0;
      _battleItemQueueOilChange = 0;
      
      if (val) {
        found = YES;
      }
    }
  }
  
  if (type != EventProtocolRequestCHealMonsterEvent &&
      type != EventProtocolRequestCCreateBattleItemEvent &&
      type != EventProtocolRequestCTradeItemForSpeedUpsEvent) {
    if (_speedupItemUsages.count > 0) {
      [self sendTradeItemForSpeedUpsMessage];
      
      _speedupGems = 0;
      [_speedupItemUsages removeAllObjects];
      [_speedupUpdatedUserItems removeAllObjects];
      
      found = YES;
    }
  }
  
  if (type != EventProtocolRequestCTradeItemForResourcesEvent) {
    if (_resourceItemIdsUsed.count > 0) {
      [self sendTradeItemForResourcesMessage];
      
      _resourceGems = 0;
      [_resourceItemIdsUsed removeAllObjects];
      [_resourceUpdatedUserItems removeAllObjects];
      
      found = YES;
    }
  }
  
  if (type != EventProtocolResponseSUpdateClientTaskStateEvent) {
    if (_latestTaskClientState) {
      [self sendUpdateClientTaskStateMessage];
      
      _latestTaskClientState = nil;
      found = YES;
    }
  }
  
  if (type != EventProtocolRequestCUpdateMiniEventEvent) {
    if (_updatedUserMiniEventGoals.count) {
      [self sendUpdateUserMiniEventMessage];
      
      [_updatedUserMiniEventGoals removeAllObjects];
      found = YES;
    }
  }
  
  return found;
}

- (void) pauseFlushTimer {
  _pauseFlushTimer = YES;
}

- (void) resumeFlushTimer {
  _pauseFlushTimer = NO;
}

- (void) closeDownConnection {
  [_flushTimer invalidate];
  _flushTimer = nil;
  [self flush];
  
  _canSendRegularEvents = NO;
  _canSendPreDbEvents = NO;
  
  [self.webSocketCommunication closeDownConnection];
  
  LNLog(@"Closed down connection..");
}

@end
