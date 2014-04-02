//
//  AMQPConnectionThread.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMQPWrapper.h"
#import "AMQPConnectionThreadDelegate.h"

@interface AMQPConnectionThread : NSThread {
  AMQPExchange *_directExchange;
  AMQPExchange *_topicExchange;
  AMQPConnection *_connection;
  AMQPQueue *_udidQueue;
  AMQPQueue *_facebookQueue;
  AMQPQueue *_useridQueue;
  AMQPQueue *_chatQueue;
  AMQPQueue *_clanQueue;
  AMQPConsumer *_udidConsumer;
  AMQPConsumer *_facebookConsumer;
  AMQPConsumer *_useridConsumer;
  AMQPConsumer *_chatConsumer;
  AMQPConsumer *_clanConsumer;
  
  BOOL _shouldStop;
}

@property (assign) NSObject<AMQPConnectionThreadDelegate> *delegate;

@property (copy) NSString *udid;
@property (copy) NSString *facebookId;
@property (copy) NSString *lastClanKey;

- (void) reloadClanMessageQueue;
- (void) connectWithUdid:(NSString *)udid facebookId:(NSString *)facebookId;
- (void) sendData:(NSData *)data;
- (void) startUserIdQueue;
- (void) closeDownConnection;
- (void) end;

@end
