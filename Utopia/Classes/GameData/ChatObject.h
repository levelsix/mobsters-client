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

#import "UserData.h"

@class ChatCell;

@protocol ChatObject <NSObject>

- (MinimumUserProto *)sender;
- (NSString *)message;
- (MSDate *)date;


- (UIColor *)bottomViewTextColor;

- (BOOL) isRead;
- (void) markAsRead;

@optional
- (MinimumUserProto *)otherUser;

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag;

// If true, requests reload of entire view.. for when it runs out of time
- (BOOL) updateForTimeInChatCell:(ChatCell *)chatCell;
- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell;

@end

@interface ChatMessage : NSObject <ChatObject>

@property (nonatomic, retain) MinimumUserProto *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) MSDate *date;
@property (nonatomic, assign) BOOL isAdmin;

@property (nonatomic, assign) BOOL isRead;

- (id) initWithProto:(GroupChatMessageProto *)p;

@end

@interface RequestFromFriend (ChatObject) <ChatObject>

@end

@interface PrivateChatPostProto (ChatObject) <ChatObject>

@end

@interface PvpHistoryProto (ChatObject) <ChatObject>

- (BOOL) userIsAttacker;
- (BOOL) userWon;
- (IBAction)revengeClicked:(id)sender;
- (IBAction)avengeClicked:(id)sender;

@end

@interface PvpClanAvenging : NSObject  <ChatObject>

@property (nonatomic, retain) NSString *clanAvengeUuid;
@property (nonatomic, retain) NSString *clanUuid;
@property (nonatomic, retain) MinimumUserProtoWithLevel *attacker;
@property (nonatomic, retain) MinimumUserProto *defender;
@property (nonatomic, retain) MSDate *battleEndTime;
@property (nonatomic, retain) MSDate *avengeRequestTime;
@property (nonatomic, retain) NSMutableArray *avengedUserUuids;

@property (nonatomic, assign) BOOL isRead;

- (id) initWithClanAvengeProto:(PvpClanAvengeProto *)proto;

- (PvpClanAvengeProto *) convertToProto;

- (IBAction)attackClicked:(id)sender;
- (IBAction)profileClicked:(id)sender;

- (BOOL) isValid;
- (BOOL) canAttack;

@end
