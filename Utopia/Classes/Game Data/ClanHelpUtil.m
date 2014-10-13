//
//  ClanHelpUtil.m
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanHelpUtil.h"

#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

@implementation ClanHelpUtil

- (id) initWithUserId:(int)userId clanId:(int)clanId clanHelpProtos:(NSArray *)clanHelps {
  if ((self = [super init])) {
    _userId = userId;
    _clanId = clanId;
    
    self.myClanHelps = [NSMutableArray array];
    self.allClanHelps = [NSMutableArray array];
    
    [self addClanHelpProtos:clanHelps fromUser:nil];
    
    [self cleanupRogueClanHelps];
  }
  return self;
}

- (void) setClanId:(int)clanId {
  if (clanId != _clanId) {
    _clanId = clanId;
    
    [self.allClanHelps removeAllObjects];
  }
}

- (void) addClanHelpProtos:(NSArray *)clanHelpProtos fromUser:(MinimumUserProto *)sender {
  BOOL checkMyHelps = NO;
  NSMutableSet *forNotifications = [NSMutableSet set];
  for (ClanHelpProto *chp in clanHelpProtos) {
    ClanHelp *clanHelp = [[ClanHelp alloc] initWithClanHelpProto:chp];
    if (chp.mup.userId == self.userId) {
      id<ClanHelp> help = [self addClanHelpProto:clanHelp toArray:self.myClanHelps];
      
      if (sender) {
        [forNotifications addObject:help];
      }
      
      checkMyHelps = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVED_CLAN_HELP_NOTIFICATION object:@{CLAN_HELP_NOTIFICATION_KEY : clanHelp}];
    } else if (chp.clanId == self.clanId) {
      [self addClanHelpProto:clanHelp toArray:self.allClanHelps];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
    }
  }
  
  for (id<ClanHelp> help in forNotifications) {
    [Globals addOrangeAlertNotification:[help justHelpedString:sender.name]];
  }
  
  if (checkMyHelps) {
    [self cleanupRogueClanHelps];
  }
}

- (id<ClanHelp>) addClanHelpProto:(ClanHelp *)help toArray:(NSMutableArray *)array {
  NSInteger idx = [array indexOfObject:help];
  if (idx != NSNotFound) {
    id<ClanHelp> curHelp = [array objectAtIndex:idx];
    [curHelp consumeClanHelp:help];
    return curHelp;
  } else {
    id<ClanHelp> newHelp = [BundleClanHelp getPossibleBundleFromClanHelp:help];
    [array addObject:newHelp];
    return newHelp;
  }
}

- (void) removeClanHelpIds:(NSArray *)helps {
  for (NSNumber *chId in helps) {
    for (NSMutableArray *arr in @[self.myClanHelps, self.allClanHelps]) {
      NSMutableArray *toRemove = [NSMutableArray array];
      for (id<ClanHelp> help in arr) {
        
        NSMutableArray *doneHelps = [NSMutableArray array];
        for (ClanHelp *ch in [help allIndividualClanHelps]) {
          if (ch.clanHelpId == [chId intValue]) {
            [doneHelps addObject:ch];
          }
        }
        
        BOOL shouldRemove = [help removeClanHelps:doneHelps];
        
        if (shouldRemove) {
          [toRemove addObject:help];
        }
      }
      [arr removeObjectsInArray:toRemove];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
}

- (ClanHelp *) getMyClanHelpForType:(ClanHelpType)type userDataId:(uint64_t)userDataId {
  for (id<ClanHelp> help in self.myClanHelps) {
    ClanHelp *specific = [help getClanHelpForType:type userDataId:userDataId];
    
    if (specific) {
      return specific;
    }
  }
  return nil;
}

- (int) getNumClanHelpsForType:(ClanHelpType)type userDataId:(uint64_t)userDataId {
  id<ClanHelp> help = [self getMyClanHelpForType:type userDataId:userDataId];
  return help ? help.numHelpers : -1;
}

- (NSArray *) getAllHelpableClanHelps {
  NSMutableArray *arr = [NSMutableArray array];
  for (id<ClanHelp> help in self.allClanHelps) {
    if ([help canHelpForUserId:self.userId]) {
      [arr addObject:help];
    }
  }
  return arr;
}

- (void) giveClanHelps:(NSArray *)clanHelps {
  NSMutableArray *clanHelpIds = [NSMutableArray array];
  for (id<ClanHelp> help in clanHelps) {
    if ([help canHelpForUserId:self.userId]) {
      [clanHelpIds addObjectsFromArray:[help helpableClanHelpIdsForUserId:self.userId]];
      [help incrementHelpForUserId:self.userId];
    }
  }
  
  if (clanHelpIds.count) {
    [[OutgoingEventController sharedOutgoingEventController] giveClanHelp:clanHelpIds];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) cleanupRogueClanHelps {
  GameState *gs = [GameState sharedGameState];
  
  // Grab all individual clan helps
  NSMutableArray *toRemove = [NSMutableArray array];
  NSMutableArray *removeClanHelpIds = [NSMutableArray array];
  for (id<ClanHelp> help in self.myClanHelps) {
    NSMutableArray *doneHelps = [NSMutableArray array];
    for (ClanHelp *ch in [help allIndividualClanHelps]) {
      BOOL isValid = NO;
      
      if (ch.helpType == ClanHelpTypeUpgradeStruct) {
        UserStruct *us = [gs myStructWithId:(int)ch.userDataId];
        // If us doesn't exist, this will also return true which is good in case city hasn't loaded.
        isValid = !us.isComplete;
      } else if (ch.helpType == ClanHelpTypeMiniJob) {
        UserMiniJob *umj = nil;
        for (UserMiniJob *u in gs.myMiniJobs) {
          if (u.userMiniJobId == ch.userDataId) {
            umj = u;
          }
        }
        
        isValid = umj.timeStarted && !umj.timeCompleted;
      } else if (ch.helpType == ClanHelpTypeHeal) {
        UserMonsterHealingItem *hi = nil;
        for (UserMonsterHealingItem *u in gs.monsterHealingQueue) {
          if (u.userMonsterId == ch.userDataId) {
            hi = u;
          }
        }
        
        isValid = !!hi;
      } else if (ch.helpType == ClanHelpTypeEvolve) {
        UserEvolution *ue = gs.userEvolution;
        
        isValid = (ue.userMonsterId1 == ch.userDataId);
      }
      
      if (!isValid) {
        [doneHelps addObject:ch];
        [removeClanHelpIds addObject:@(ch.clanHelpId)];
      }
    }
    
    BOOL shouldRemove = [help removeClanHelps:doneHelps];
    
    if (shouldRemove) {
      [toRemove addObject:help];
    }
  }
  
  if (removeClanHelpIds.count) {
    [self.myClanHelps removeObjectsInArray:toRemove];
    
    LNLog(@"Removing %d clan helps.", (int)removeClanHelpIds.count);
    
    [[OutgoingEventController sharedOutgoingEventController] endClanHelp:removeClanHelpIds];
  }
}

@end
