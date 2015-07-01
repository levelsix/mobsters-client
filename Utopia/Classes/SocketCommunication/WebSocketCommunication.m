//
//  WebSocketCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "WebSocketCommunication.h"

#import "Globals.h"

#define WSLog(fmt, ...) LNLog((@"%@: " fmt), NSStringFromClass(self.delegate.class), ##__VA_ARGS__)

#define RECONNECT_TIMEOUT 1.f
#define NUM_SILENT_RECONNECTS 15

@implementation WebSocketCommunication

- (id) initWithURLString:(NSString *)hostName sslCert:(NSString *)sslCert {
  if ((self = [super init])) {
    _hostName = hostName;
    _sslCertFile = sslCert;
    
  }
  return self;
}

- (void) connect {
  _shouldReconnect = YES;
  _numDisconnects = 0;
  
  _purposefulClose = NO;
  
  [self tryConnect];
}

- (void) tryConnect {
  // Close the old one just in case
  if (self.webSocket) {
    [self.webSocket close];
  }
  
  NSURL *url = [NSURL URLWithString:_hostName];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  
  if ([_hostName containsString:@"wss://"] && _sslCertFile) {
    NSString *cerPath = [[[[NSBundle mainBundle] bundleURL] absoluteString] stringByAppendingString:_sslCertFile];
    NSData *certData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:cerPath]];
    CFDataRef certDataRef = (__bridge CFDataRef)certData;
    SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certDataRef);
    id certificate = (__bridge id)certRef;
    
    if (certificate) {
      [request setSR_SSLPinnedCertificates:@[certificate]];
    }
  }
  
  self.webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
  self.webSocket.delegate = self;
  [self.webSocket open];
  
  WSLog(@"Attempting connection to \"%@\"", _hostName);
}

- (void) connectedToHost {
  WSLog(@"Connected to host \"%@\"", self.webSocket.url);
  
  [self.delegate connectedToHost];
  
  _shouldReconnect = NO;
}

- (void) unableToConnectToHost:(NSString *)error
{
  WSLog(@"Unable to connect: %@", error);
  
  if (_shouldReconnect) {
    _numDisconnects++;
    if (_numDisconnects > NUM_SILENT_RECONNECTS) {
      WSLog(@"Asking to reconnect..");
      
      _shouldReconnect = NO;
      
      [self.delegate unableToConnectToHost];
    } else {
      WSLog(@"Silently reconnecting..");
      [self performBlockAfterDelay:RECONNECT_TIMEOUT block:^{
        if (_shouldReconnect) {
          [self tryConnect];
        }
      }];
    }
  }
}

- (void) connectionDied {
  WSLog(@"Disconnected from the server. Reconnecting...");
  
  [self connect];
  [self.delegate attemptingReconnect];
}

- (void) sendMessage:(NSData *)data {
  if (self.webSocket.readyState == SR_OPEN) {
    [self.webSocket send:data];
  } else {
    WSLog(@"Unable to send data.. WebSocket is not in open state.");
  }
}

- (void) closeDownConnection {
  _purposefulClose = YES;
  
  self.webSocket.delegate = nil;
  [self.webSocket close];
  self.webSocket = nil;
}

#pragma mark - Web Socket Delegate

- (void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  NSData *data = (NSData *)message;
  [self.delegate receivedMessage:data];
}

- (void) webSocketDidOpen:(SRWebSocket *)webSocket {
  WSLog(@"websocket opened..");
  
  if (webSocket != self.webSocket) {
    WSLog(@"Somehow there are 2 websockets: %@, %@", self.webSocket, webSocket);
    webSocket.delegate = nil;
    [webSocket close];
  } else {
    [self.delegate connectedToHost];
  }
}

- (void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  WSLog(@"websocket failed.");
  if (_shouldReconnect) {
    [self unableToConnectToHost:error.localizedDescription];
  } else if (!_purposefulClose) {
    [self connectionDied];
  }
}

- (void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  WSLog(@"websocket closed. %@ code=%d clean=%d", reason, (int)code, wasClean);
  
  if (!_purposefulClose) {
    if (webSocket != self.webSocket) {
      WSLog(@"Somehow there are 2 websockets: %@, %@", self.webSocket, webSocket);
    } else {
      [self connectionDied];
    }
  }
}

@end
