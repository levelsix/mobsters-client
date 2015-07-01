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

- (void) receivedMessage:(NSData *)data;
- (void) connectedToHost;
- (void) unableToConnectToHost;
- (void) attemptingReconnect;


@end

@interface WebSocketCommunication : NSObject <SRWebSocketDelegate> {
  BOOL _shouldReconnect;
  
  int _numDisconnects;
  BOOL _purposefulClose;
  
  NSString *_hostName;
  NSString *_sslCertFile;
}

@property (nonatomic, retain) SRWebSocket *webSocket;

@property (nonatomic, assign) id<WebSocketCommunicationDelegate> delegate;


- (id) initWithURLString:(NSString *)hostName sslCert:(NSString *)sslCert;

- (void) connect;

- (void) sendMessage:(NSData *)data;

- (void) closeDownConnection;

@end
