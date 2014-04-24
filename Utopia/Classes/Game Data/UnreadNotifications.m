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

- (int) otherUserId {
  GameState *gs = [GameState sharedGameState];
  return self.recipient.minUserProto.userId == gs.userId ? self.poster.minUserProto.userId : self.recipient.minUserProto.userId;
}

- (NSString *) otherUserName {
  GameState *gs = [GameState sharedGameState];
  return self.recipient.minUserProto.userId == gs.userId ? self.poster.minUserProto.name : self.recipient.minUserProto.name;
}

- (BOOL) isUnread {
  GameState *gs = [GameState sharedGameState];
  if (self.poster.minUserProto.userId != gs.userId) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.poster.minUserProto.userId];
    NSInteger curId = [ud integerForKey:key];
    int thisId = self.privateChatPostId;
    return curId < thisId;
  } else {
    // This means you are the poster
    return NO;
  }
}

- (void) markAsRead {
  GameState *gs = [GameState sharedGameState];
  // Only need to do this if you are not the poster
  if (self.poster.minUserProto.userId != gs.userId) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.poster.minUserProto.userId];
    NSInteger curId = [ud integerForKey:key];
    
    if (curId < self.privateChatPostId) {
      [ud setInteger:self.privateChatPostId forKey:key];
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