//
//  PrivateChatPostProto+UnreadStatus.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "PrivateChatPostProto+UnreadStatus.h"
#import "GameState.h"

@implementation PrivateChatPostProto (UnreadStatus)

- (NSString *) otherUserUuid {
  GameState *gs = [GameState sharedGameState];
  return [self.recipient.minUserProto.userUuid isEqualToString:gs.userUuid] ? self.poster.minUserProto.userUuid : self.recipient.minUserProto.userUuid;
}

- (BOOL) isUnread {
  GameState *gs = [GameState sharedGameState];
  if (![self.poster.minUserProto.userUuid isEqualToString:gs.userUuid]) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.poster.minUserProto.userUuid];
    uint64_t curTime = [[ud objectForKey:key] longLongValue];
    uint64_t thisTime = self.timeOfPost;
    return curTime < thisTime;
  } else {
    // This means you are the poster
    return NO;
  }
}

- (void) markAsRead {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, [self otherUserUuid]];
  uint64_t curTime = [[ud objectForKey:key] longLongValue];
  
  if (curTime < self.timeOfPost) {
    [ud setObject:[NSNumber numberWithLongLong:self.timeOfPost] forKey:key];
  }
}

@end
