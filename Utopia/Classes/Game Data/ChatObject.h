//
//  ChatObject.h
//  Utopia
//
//  Created by Ashwin on 10/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Protocols.pb.h"
#import "MSDate.h"
#import "ChatCell.h"

@protocol ChatObject <NSObject>

- (MinimumUserProto *)sender;
- (NSString *)message;
- (MSDate *)date;
- (UIColor *)textColor;

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag;
- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell;

@end

@interface ChatMessage : NSObject <ChatObject>

@property (nonatomic, retain) MinimumUserProto *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) MSDate *date;
@property (nonatomic, assign) BOOL isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p;

@end