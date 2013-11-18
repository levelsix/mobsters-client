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

- (int) otherUserId {
  GameState *gs = [GameState sharedGameState];
  return self.recipient.minUserProto.userId == gs.userId ? self.poster.minUserProto.userId : self.recipient.minUserProto.userId;
}

- (BOOL) isUnread {
  GameState *gs = [GameState sharedGameState];
  if (self.poster.minUserProto.userId != gs.userId) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, self.poster.minUserProto.userId];
    int curId = [ud integerForKey:key];
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
    int curId = [ud integerForKey:key];
    
    if (curId < self.privateChatPostId) {
      [ud setInteger:self.privateChatPostId forKey:key];
    }
  }
}

@end
