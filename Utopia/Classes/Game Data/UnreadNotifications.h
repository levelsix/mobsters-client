//
//  UnreadNotifications.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/23/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

#define PRIVATE_CHAT_DEFAULTS_KEY @"PrivateChat%d"
#define PVP_HISTORY_DEFAULTS_KEY @"PvpHistoryLastRead"

@interface PrivateChatPostProto (UnreadStatus)

- (MinimumUserProtoWithLevel *) otherUserWithLevel;
- (MinimumUserProto *) otherUser;
- (BOOL) isUnread;
- (void) markAsRead;

@end

@interface PvpHistoryProto (UnreadStatus)

- (BOOL) isUnread;
- (void) markAsRead;

@end