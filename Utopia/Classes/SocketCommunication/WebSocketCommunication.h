//
//  WebSocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SRWebSocket.h>

@protocol WebSocketCommunicationDelegate <NSObject>

- (void) receivedData:(NSData *)data;

@end

@interface WebSocketCommunication : NSObject {
  BOOL _shouldReconnect;
  
  int _numDisconnects;
  BOOL _purposefulClose;
}

@property (nonatomic, retain) SRWebSocket *webSocket;

@property (nonatomic, retain) NSMutableArray *queuedMessages;
@property (nonatomic, retain) NSMutableArray *unrespondedMessages;

- (void) sendData:(NSData *)data;

@end
