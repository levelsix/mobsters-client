//
//  ChatCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebSocketCommunication.h"

@interface ChatCommunication : NSObject <WebSocketCommunicationDelegate>

@property (nonatomic, retain) WebSocketCommunication *webSocketCommunication;

- (void) connect;

@end
