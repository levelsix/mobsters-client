//
//  ClanHelp.m
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanHelp.h"

#import "GameState.h"
#import "Globals.h"

@implementation ClanHelp

- (id) initWithClanHelpProto:(ClanHelpProto *)chp {
  if ((self = [super init])) {
    self.clanHelpId = chp.clanHelpId;
    self.requester = chp.mup;
    self.clanId = chp.clanId;
    self.requestedTime = [MSDate dateWithTimeIntervalSince1970:chp.timeRequested/1000.];
    self.maxHelpers = chp.maxHelpers;
    self.helperUserIds = [NSMutableSet setWithArray:[chp.helperIdsList toNSArray]];
    self.helpType = chp.helpType;
    self.userDataId = chp.userDataId;
    self.staticDataId = chp.staticDataId;
    self.isOpen = chp.open;
  }
  return self;
}

- (int) numHelpers {
  return MIN(self.maxHelpers, (int)self.helperUserIds.count);
}

- (NSString *) statusStingWithPossessive:(NSString *)possessive {
  GameState *gs = [GameState sharedGameState];
  if (self.helpType == ClanHelpTypeUpgradeStruct) {
    StructureInfoProto *sip = [[gs structWithId:self.staticDataId] structInfo];
    return [NSString stringWithFormat:@" build a Level %d %@", sip.level, sip.name];
  } else if (self.helpType == ClanHelpTypeMiniJob) {
    return [NSString stringWithFormat:@" complete %@ %@ Job", possessive, [Globals stringForRarity:self.staticDataId]];
  } else if (self.helpType == ClanHelpTypeHeal) {
    MonsterProto *mp = [gs monsterWithId:self.staticDataId];
    return [NSString stringWithFormat:@" heal %@", mp.displayName];
  } else if (self.helpType == ClanHelpTypeEvolve) {
    MonsterProto *mp = [gs monsterWithId:self.staticDataId];
    return [NSString stringWithFormat:@" evolve %@", mp.displayName];
  }
  return @"!";
}

- (NSString *) helpString {
  return [NSString stringWithFormat:@"Help me%@", [self statusStingWithPossessive:@"my"]];
}

- (NSString *) justHelpedString:(NSString *)name {
  return [NSString stringWithFormat:@"%@ just helped you%@.", name, [self statusStingWithPossessive:@"your"]];
}

- (void) consumeClanHelp:(ClanHelp *)chp {
  if (!self.clanHelpId) {
    // This means we just asked for help and got back the response
    self.clanHelpId = chp.clanHelpId;
    self.requester = chp.requester;
    self.clanId = chp.clanId;
    self.requestedTime = chp.requestedTime;
    self.maxHelpers = chp.maxHelpers;
    self.helperUserIds = chp.helperUserIds;
    self.helpType = chp.helpType;
    self.userDataId = chp.userDataId;
    self.staticDataId = chp.staticDataId;
    self.isOpen = chp.isOpen;
  } else {
    [self.helperUserIds unionSet:chp.helperUserIds];
  }
}

- (ClanHelp *) getClanHelpForType:(ClanHelpType)type userDataId:(uint64_t)userDataId {
  if (self.helpType == type && self.userDataId == userDataId) {
    return self;
  }
  return nil;
}

- (NSArray *) helpableClanHelpIdsForUserId:(int)userId {
  if (self.isOpen && self.requester.userId != userId && ![self.helperUserIds containsObject:@(userId)] && self.numHelpers < self.maxHelpers) {
    return @[@(self.clanHelpId)];
  }
  return nil;
}

- (BOOL) canHelpForUserId:(int)userId {
  return [self helpableClanHelpIdsForUserId:userId].count > 0;
}

- (BOOL) hasHelpedForUserId:(int)userId {
  return [self.helperUserIds containsObject:@(userId)];
}

- (void) incrementHelpForUserId:(int)userId {
  if ([self canHelpForUserId:userId]) {
    [self.helperUserIds addObject:@(userId)];
  }
}

- (NSArray *)allIndividualClanHelps {
  return @[self];
}

- (BOOL) removeClanHelps:(NSArray *)clanHelps {
  if ([clanHelps containsObject:self]) {
    return YES;
  }
  return NO;
}

- (BOOL) isEqual:(ClanHelp *)object {
  return (self.requester.userId == object.requester.userId &&
           self.clanId == object.clanId && self.helpType == object.helpType &&
           self.userDataId == object.userDataId);
}

- (NSUInteger) hash {
  return (NSUInteger)(self.requester.userId*31 + self.clanId*29 + self.helpType*11 + self.userDataId*7);
}

@end
