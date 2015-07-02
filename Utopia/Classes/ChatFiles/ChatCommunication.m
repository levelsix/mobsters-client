//
//  ChatCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ChatCommunication.h"

#import "ClientProperties.h"
#import "Chat_event.pb.h"
#import "GameState.h"

@implementation ChatCommunication

- (id) init {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    
    NSDictionary *headers = @{@"useruuid" : gs.userUuid};
    
    self.webSocketCommunication = [[WebSocketCommunication alloc] initWithURLString:CHAT_HOST_NAME sslCert:nil customHeaders:headers];
    self.webSocketCommunication.delegate = self;
  }
  return self;
}

- (void) connect {
  [self.webSocketCommunication connect];
}

- (void) connectedToHost {
  GameState *gs = [GameState sharedGameState];
  
  ChatUserDetailsProto_Builder *details = [ChatUserDetailsProto builder];
  details.name = gs.name;
  details.useruuid = gs.userUuid;
  //details.clantag = gs.clan.tag;
  details.avatarmonsterid = gs.avatarMonsterId;
  details.admin = gs.isAdmin;
  
  CreateUserRequestProto_Builder *req = [CreateUserRequestProto builder];
  req.useruuid = gs.userUuid;
  req.userdetails = [details build];
  
  ChatEventProto_Builder *cepb = [ChatEventProto builder];
  cepb.uuid = [[NSUUID UUID] UUIDString];
  cepb.eventname = ChatEventTypeCreateUserRequest;
  cepb.eventdata = [[req build] data];
  
  NSData *data = [[cepb build] data];
  [self.webSocketCommunication sendMessage:data];
}

- (void) receivedMessage:(NSData *)data {
  ChatEventProto *cep = [ChatEventProto parseFromData:data];
  
  NSLog(@"%@", cep);
}


- (void) attemptingReconnect {
  NSLog(@"meep1");
}

- (void) unableToConnectToHost {
  NSLog(@"meep2");
}

@end
