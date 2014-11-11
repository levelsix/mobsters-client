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
    
    for (id<ClanHelp> ch in self.myClanHelps) {
      for (ClanHelp *ind in [ch allIndividualClanHelps]) {
        ind.isOpen = NO;
      }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) addClanHelpProtos:(NSArray *)clanHelpProtos fromUser:(MinimumUserProto *)sender {
  BOOL checkMyHelps = NO;
  NSMutableSet *forAlerts = [NSMutableSet set];
  NSMutableArray *forNotifications = [NSMutableArray array];
  for (ClanHelpProto *chp in clanHelpProtos) {
    ClanHelp *clanHelp = [[ClanHelp alloc] initWithClanHelpProto:chp];
    if (chp.mup.userUuid isEqualToString:self.userUuid]) {
      id<ClanHelp> help = [self addClanHelpProto:clanHelp toArray:self.myClanHelps];
      
      if (sender) {
        [forAlerts addObject:help];
      }
      
      checkMyHelps = YES;
      
      [forNotifications addObject:clanHelp];
    } else if (chp.clanId == self.clanId && [clanHelp isOpen]) {
      [self addClanHelpProto:clanHelp toArray:self.allClanHelps];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
    }
  }
  
  // We want to do alerts and then notifications so that free speedup timer doesn't popup before the help
  for (id<ClanHelp> help in forAlerts) {
    [Globals addOrangeAlertNotification:[help justHelpedString:sender.name]];
  }
  
  for (ClanHelp *ch in forNotifications) {
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVED_CLAN_HELP_NOTIFICATION object:@{CLAN_HELP_NOTIFICATION_KEY : ch}];
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

- (void) removeClanHelpsForUserId:(int)userId {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (id<ClanHelp> ch in self.allClanHelps) {
    if ([ch.requester.userUuid isEqualToString:userUuid]) {
      [toRemove addObject:ch];
    }
  }
  
  if (toRemove.count) {
    [self.allClanHelps removeObjectsInArray:toRemove];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  }
}

- (ClanHelp *) getMyClanHelpForType:(GameActionType)type userDataId:(uint64_t)userDataId {
  for (id<ClanHelp> help in self.myClanHelps) {
    ClanHelp *specific = [help getClanHelpForType:type userDataId:userDataId];
    
    if (specific) {
      return specific;
    }
  }
  return nil;
}

- (int) getNumClanHelpsForType:(GameActionType)type userDataId:(uint64_t)userDataId {
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
      
      if (ch.helpType == GameActionTypeUpgradeStruct) {
        UserStruct *us = [gs myStructWithId:(int)ch.userDataId];
        // If us doesn't exist, this will also return true which is good in case city hasn't loaded.
        isValid = !us.isComplete;
      } else if (ch.helpType == GameActionTypeMiniJob) {
        UserMiniJob *umj = nil;
        for (UserMiniJob *u in gs.myMiniJobs) {
          if (u.userMiniJobId == ch.userDataId) {
            umj = u;
          }
        }
        
        isValid = umj.timeStarted && !umj.timeCompleted;
      } else if (ch.helpType == GameActionTypeHeal) {
        UserMonsterHealingItem *hi = nil;
        for (UserMonsterHealingItem *u in gs.monsterHealingQueue) {
          if (u.userMonsterId == ch.userDataId) {
            hi = u;
          }
        }
        
        isValid = !!hi;
      } else if (ch.helpType == GameActionTypeEvolve) {
        UserEvolution *ue = gs.userEvolution;
        
        isValid = (ue.userMonsterId1 == ch.userDataId);
      } else if (ch.helpType == GameActionTypeEnhanceTime) {
        UserEnhancement *ue = gs.userEnhancement;
        
        isValid = ue.baseMonster.userMonsterId == ch.userDataId;
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
