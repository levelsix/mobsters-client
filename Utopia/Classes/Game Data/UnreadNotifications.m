//
//  UnreadNotifications.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/23/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "UnreadNotifications.h"
#import "GameState.h"

@implementation PrivateChatPostProto (UnreadStatus)

- (MinimumUserProtoWithLevel *) otherUserWithLevel {
  GameState *gs = [GameState sharedGameState];
  return [self.recipient.minUserProto.userUuid isEqualToString:gs.userUuid] ? self.poster : self.recipient;
}

- (MinimumUserProto *) otherUser {
  return [self otherUserWithLevel].minUserProto;
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
  GameState *gs = [GameState sharedGameState];
  // Only need to do this if you are not the poster
  if (![self.poster.minUserProto.userUuid isEqualToString:gs.userUuid]) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.poster.minUserProto.userUuid];
    uint64_t curTime = [[ud objectForKey:key] longLongValue];
    
    if (curTime < self.timeOfPost) {
      [ud setObject:@(self.timeOfPost) forKey:key];
    }
  }
}

@end

@implementation PvpHistoryProto (UnreadStatus)

- (BOOL) isUnread {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  int64_t lastReadTime = [[ud objectForKey:PVP_HISTORY_DEFAULTS_KEY] longLongValue];
  int64_t thisTime = self.battleEndTime;
  return lastReadTime < thisTime;
}

- (void) markAsRead {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  int64_t lastReadTime = [[ud objectForKey:PVP_HISTORY_DEFAULTS_KEY] longLongValue];
  int64_t thisTime = self.battleEndTime;
  
  if (lastReadTime < thisTime) {
    [ud setObject:[NSNumber numberWithLongLong:thisTime] forKey:PVP_HISTORY_DEFAULTS_KEY];
  }
}

@end