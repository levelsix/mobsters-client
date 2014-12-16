//
//  AMQPConnectionThread.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AMQPConnectionThread.h"

#import "amqp.h"
#import "amqp_framing.h"
#import "Gamestate.h"
#import "ClientProperties.h"

#define UDID_KEY [NSString stringWithFormat:@"client_udid_%@", _udid]
#define FACEBOOK_KEY [NSString stringWithFormat:@"client_facebookid_%@", self.facebookId]
#define USER_ID_KEY [NSString stringWithFormat:@"client_userid_%@", gs.userUuid]
#define CHAT_KEY @"chat_global"
#define CLAN_KEY [NSString stringWithFormat:@"clan_%@", gs.clan.clanUuid]

@implementation AMQPConnectionThread

static int sessionId;

- (void) connectWithUdid:(NSString *)udid facebookId:(NSString *)facebookId {
  self.udid = udid;
  self.facebookId = facebookId;
  [self performSelector:@selector(initConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initConnection {
  LNLog(@"Initializing connection..");
  @try {
    sessionId = arc4random();
    [self endConnection];
    
    if (_writeStream) {
      CFWriteStreamClose(_writeStream);
      CFRelease(_writeStream);
    }
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)HOST_NAME, HOST_PORT, NULL, &_writeStream);
    CFWriteStreamOpen(_writeStream);
    
    _connection = [[AMQPConnection alloc] init];
    [_connection connectToHost:HOST_NAME onPort:HOST_PORT useSSL:USE_SSL];
    [_connection loginAsUser:MQ_USERNAME withPassword:MQ_PASSWORD onVHost:MQ_VHOST];
    AMQPChannel *channel = [_connection openChannel];
    _directExchange = [[AMQPExchange alloc] initDirectExchangeWithName:@"gamemessages" onChannel:channel isPassive:NO isDurable:YES];
    
    _topicExchange = [[AMQPExchange alloc] initTopicExchangeWithName:@"chatmessages" onChannel:channel isPassive:NO isDurable:YES];
    
    NSString *udidKey = UDID_KEY;
    _udidQueue = [[AMQPQueue alloc] initWithName:[udidKey stringByAppendingFormat:@"_%d_queue", sessionId] onChannel:channel isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
    [_udidQueue bindToExchange:_directExchange withKey:udidKey];
    _udidConsumer = [_udidQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES];
    
    if (self.facebookId) {
      NSString *facebookKey = FACEBOOK_KEY;
      _facebookQueue = [[AMQPQueue alloc] initWithName:[facebookKey stringByAppendingFormat:@"_%d_queue", sessionId] onChannel:channel isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
      [_facebookQueue bindToExchange:_directExchange withKey:facebookKey];
      _facebookConsumer = [_facebookQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(connectedToHost)]) {
      [_delegate performSelectorOnMainThread:@selector(connectedToHost) withObject:nil waitUntilDone:NO];
    }
  } @catch (NSException *exception) {
    @try {
      _connection = nil;
    } @catch (NSException *exception) {
    }
    if ([_delegate respondsToSelector:@selector(unableToConnectToHost:)]) {
      [_delegate performSelectorOnMainThread:@selector(unableToConnectToHost:) withObject:exception.reason waitUntilDone:NO];
    }
  }
}

- (void) startUserIdQueue {
  [self performSelector:@selector(initUserIdMessageQueue) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initUserIdMessageQueue {
  GameState *gs = [GameState sharedGameState];
  NSString *useridKey = USER_ID_KEY;
  _useridQueue = [[AMQPQueue alloc] initWithName:[useridKey stringByAppendingFormat:@"_%d_queue", sessionId]  onChannel:_udidConsumer.channel  isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
  [_useridQueue bindToExchange:_directExchange withKey:useridKey];
  _useridConsumer = [_useridQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES];
  
  NSString *udidKey = USER_ID_KEY;
  _chatQueue = [[AMQPQueue alloc] initWithName:[udidKey stringByAppendingFormat:@"_%d_chat_queue", sessionId] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
  [_chatQueue bindToExchange:_topicExchange withKey:CHAT_KEY];
  _chatConsumer = [_chatQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES];
  
  LNLog(@"Created queues");
  
  if ([_delegate respondsToSelector:@selector(connectedToUserIdQueue)]) {
    [_delegate performSelectorOnMainThread:@selector(connectedToUserIdQueue) withObject:nil waitUntilDone:NO];
  }
}

- (void) reloadClanMessageQueue {
  // Changed waitUntilDone to YES because we want 
  [self performSelector:@selector(initClanMessageQueue) onThread:self withObject:nil waitUntilDone:YES];
}

- (void) initClanMessageQueue {
  GameState *gs = [GameState sharedGameState];
  [self destroyClanMessageQueue];
  if (gs.clan.clanUuid) {
    NSString *useridKey = USER_ID_KEY;
    self.lastClanKey = CLAN_KEY;
    _clanQueue = [[AMQPQueue alloc] initWithName:[useridKey stringByAppendingFormat:@"_%d_clan_queue", sessionId] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
    [_clanQueue bindToExchange:_topicExchange withKey:self.lastClanKey];
    _clanConsumer = [_clanQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES];
  }
}

- (void) destroyClanMessageQueue {
  _clanConsumer = nil;
  _clanConsumer = nil;
  _clanQueue = nil;
}

- (void) sendData:(NSData *)data withDelay:(float)delay {
  //[self performSelector:@selector(postDataToExchange:) onThread:self withObject:data waitUntilDone:NO];
  NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(timerPostData:) userInfo:data repeats:NO];
  [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void) timerPostData:(NSTimer *)timer {
  [self postDataToExchange:timer.userInfo];
}

- (void) postDataToExchange:(NSData *)data {
  @try {
    [_directExchange publishMessageWithData:data usingRoutingKey:@"messagesFromPlayers"];
  } @catch (NSException *exception) {
    NSLog(@"Failed to publish data");
  }
}

- (void) endConnection {
  @try {
    [self destroyClanMessageQueue];
    _chatConsumer = nil;
    _chatQueue = nil;
    _useridConsumer = nil;
    _udidConsumer = nil;
    _useridQueue = nil;
    _udidQueue = nil;
    _facebookConsumer = nil;
    _facebookQueue = nil;
    _directExchange = nil;
    _topicExchange = nil;
    _connection = nil;
  } @catch (NSException *e) {
    LNLog(@"%@", e);
  }
}

- (void) endAndDestroyThread {
  [self endConnection];
  //  _shouldStop = YES;
}

- (void) closeDownConnection {
  [self performSelector:@selector(endAndDestroyThread) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) end {
  [self closeDownConnection];
}

- (void) readData {
  if (_connection) {
    if (amqp_data_available(_connection.internalConnection) || amqp_data_in_buffer(_connection.internalConnection)) {
      AMQPMessage *message = [_udidConsumer pop];
      if(message)
      {
        [_delegate performSelectorOnMainThread:@selector(amqpConsumerThreadReceivedNewMessage:) withObject:message waitUntilDone:NO];
      }
    }
  }
}

- (void)main
{
  [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(readData) userInfo:nil repeats:YES];
	
  int i = 0;
  while(!_shouldStop)
  {
    i++;
    @try {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
      
      if (i % 10 == 0 && _writeStream) {
        UInt8 t = 0;
        Boolean canWrite = CFWriteStreamCanAcceptBytes(_writeStream);
        if (canWrite) {
          CFIndex x = CFWriteStreamWrite(_writeStream, &t, 1);
          if (x < 0) {
            CFStreamError err = CFWriteStreamGetError(_writeStream);
            LNLog(@"Error: %ld:%d", err.domain, (int)err.error);
          }
        }
      }
    } @catch (NSException *exception) {
      NSLog(@"Exception in AMQP thread: %@", exception);
    }
	}
}

@end
