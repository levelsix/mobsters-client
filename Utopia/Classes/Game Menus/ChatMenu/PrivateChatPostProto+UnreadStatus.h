//
//  PrivateChatPostProto+UnreadStatus.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Chat.pb.h"

#define PRIVATE_CHAT_DEFAULTS_KEY @"PrivateChat%@"

@interface PrivateChatPostProto (UnreadStatus)

- (NSString *) otherUserUuid;
- (BOOL) isUnread;
- (void) markAsRead;

@end
