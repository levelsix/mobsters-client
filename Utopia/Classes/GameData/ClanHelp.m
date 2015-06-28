//
//  ClanHelp.m
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanHelp.h"
#import "ChatCell.h"

#import "GameState.h"
#import "Globals.h"

@implementation ClanHelp

- (id) initWithClanHelpProto:(ClanHelpProto *)chp {
  if ((self = [super init])) {
    self.clanHelpUuid = chp.clanHelpUuid;
    self.requester = chp.mup;
    self.clanUuid = chp.clanUuid;
    self.requestedTime = [MSDate dateWithTimeIntervalSince1970:chp.timeRequested/1000.0];
    self.maxHelpers = chp.maxHelpers;
    self.helperUserUuids = [NSMutableSet setWithArray:chp.helperUuidsList];
    self.helpType = chp.helpType;
    self.userDataUuid = chp.userDataUuid;
    self.staticDataId = chp.staticDataId;
    self.isOpen = chp.open;
  }
  return self;
}

- (int) numHelpers {
  return MIN(self.maxHelpers, (int)self.helperUserUuids.count);
}

- (NSString *) statusStingWithPossessive:(NSString *)possessive {
  GameState *gs = [GameState sharedGameState];
  if (self.helpType == GameActionTypeUpgradeStruct) {
    StructureInfoProto *sip = [[gs structWithId:self.staticDataId] structInfo];
    return [NSString stringWithFormat:@" build a Level %d %@", sip.level, sip.name];
  } else if (self.helpType == GameActionTypeMiniJob) {
    return [NSString stringWithFormat:@" speed up %@ %@ Job", possessive, [Globals stringForRarity:self.staticDataId]];
  } else if (self.helpType == GameActionTypeHeal) {
    MonsterProto *mp = [gs monsterWithId:self.staticDataId];
    return [NSString stringWithFormat:@" heal %@", mp.displayName];
  } else if (self.helpType == GameActionTypeEvolve) {
    MonsterProto *mp = [gs monsterWithId:self.staticDataId];
    return [NSString stringWithFormat:@" evolve %@", mp.displayName];
  } else if (self.helpType == GameActionTypeEnhanceTime) {
    MonsterProto *mp = [gs monsterWithId:self.staticDataId];
    return [NSString stringWithFormat:@" enhance %@", mp.displayName];
  } else if (self.helpType == GameActionTypeCreateBattleItem) {
    BattleItemProto *bip = [gs battleItemWithId:self.staticDataId];
    return [NSString stringWithFormat:@" create a %@", bip.name];
  } else if (self.helpType == GameActionTypePerformingResearch) {
    ResearchProto *rp = [gs researchWithId:self.staticDataId];
    return [NSString stringWithFormat:@" research %@ R%d",rp.name, rp.rank];
  }
  return @"!";
}

- (NSString *) helpString {
  return [NSString stringWithFormat:@"Help me%@.", [self statusStingWithPossessive:@"my"]];
}

- (NSString *) justHelpedString:(NSString *)name {
  return [NSString stringWithFormat:@"%@ just helped you%@!", name, [self statusStingWithPossessive:@"your"]];
}

- (NSString *) justSolicitedString {
  // Take out space and capitalize
  NSString *str = [[self statusStingWithPossessive:@"my"] substringFromIndex:1];
  str = [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[str substringToIndex:1] uppercaseString]];
  return str;
}

- (void) consumeClanHelp:(ClanHelp *)chp {
  if (![self.clanHelpUuid isEqualToString:chp.clanHelpUuid]) {
    // This means we just asked for help and got back the response
    self.clanHelpUuid = chp.clanHelpUuid;
    self.requester = chp.requester;
    self.clanUuid = chp.clanUuid;
    self.requestedTime = chp.requestedTime;
    self.maxHelpers = chp.maxHelpers;
    self.helperUserUuids = chp.helperUserUuids;
    self.helpType = chp.helpType;
    self.userDataUuid = chp.userDataUuid;
    self.staticDataId = chp.staticDataId;
    self.isOpen = chp.isOpen;
  } else {
    [self.helperUserUuids unionSet:chp.helperUserUuids];
    
    self.isOpen = self.isOpen & chp.isOpen;
  }
}

- (ClanHelp *) getClanHelpForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid {
  if (self.helpType == type && [self.userDataUuid isEqualToString:userDataUuid]) {
    return self;
  }
  return nil;
}

- (NSArray *) helpableClanHelpIdsForUserUuid:(NSString *)userUuid {
  if (self.isOpen && ![self.requester.userUuid isEqualToString:userUuid] && ![self.helperUserUuids containsObject:userUuid] && self.numHelpers < self.maxHelpers) {
    return @[self.clanHelpUuid];
  }
  return nil;
}

- (BOOL) canHelpForUserUuid:(NSString *)userUuid {
  return [self helpableClanHelpIdsForUserUuid:userUuid].count > 0;
}

- (BOOL) hasHelpedForUserUuid:(NSString *)userUuid {
  return [self.helperUserUuids containsObject:userUuid];
}

- (void) incrementHelpForUserUuid:(NSString *)userUuid {
  if ([self canHelpForUserUuid:userUuid]) {
    [self.helperUserUuids addObject:userUuid];
  }
}

- (NSArray *)allIndividualClanHelps {
  return @[self];
}

- (BOOL) removeClanHelps:(NSArray *)clanHelps {
  if ([clanHelps containsObject:self]) {
    // Set to NO so that if anything is holding this object, it won't try to add helps
    self.isOpen = NO;
    return YES;
  }
  return NO;
}

- (BOOL) isEqual:(ClanHelp *)object {
  // Types that are gonna be bundled need to match with this (2nd statement).
  // Otherwise, actually compare values.
  return ([self class] == [object class] && [self.requester.userUuid isEqualToString:object.requester.userUuid] &&
          [self.clanUuid isEqualToString:object.clanUuid] && self.helpType == object.helpType &&
          [self.userDataUuid isEqualToString:object.userDataUuid]) ||
  // Bundle will match with this object but make sure its not also this object
  ([self class] != [object class] && [object conformsToProtocol:@protocol(ClanHelp)] &&  [self.requester.userUuid isEqualToString:object.requester.userUuid] &&
   [self.clanUuid isEqualToString:object.clanUuid] && self.helpType == object.helpType);
}

- (NSUInteger) hash {
  // Types that are gonna be bundled need to match with this
  NSUInteger val = self.helpType == GameActionTypeHeal ? 1 : self.userDataUuid.hash;
  return (NSUInteger)(self.requester.userUuid.hash*31 + self.clanUuid.hash*29 + self.helpType*11 + val*7);
}

#pragma mark - ChatObject protocol

- (MinimumUserProto *) sender {
  return self.requester;
}

- (MSDate *) date {
  return self.requestedTime;
}

- (NSString *) message {
  return [self helpString];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  GameState *gs = [GameState sharedGameState];
  return ![self canHelpForUserUuid:gs.userUuid];
}

- (void) markAsRead {
  // Do nothing
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language {
  NSString *nibName = @"ChatClanHelpView";
  ChatClanHelpView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanHelp:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language {
  [self updateInChatCell:chatCell showsClanTag:YES language:language];
  return CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f;
}

- (IBAction)helpClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:@[self]];
}

@end

@implementation BundleClanHelp

+ (id<ClanHelp>) getPossibleBundleFromClanHelp:(ClanHelp *)clanHelp {
  if (clanHelp.helpType == GameActionTypeHeal) {
    return [[BundleClanHelp alloc] initWithClanHelp:clanHelp];
  }
  return clanHelp;
}

- (id) initWithClanHelp:(ClanHelp *)clanHelp {
  if ((self = [super init])) {
    self.requester = clanHelp.requester;
    self.clanUuid = clanHelp.clanUuid;
    self.helpType = clanHelp.helpType;
    self.clanHelps = [NSMutableArray arrayWithObject:clanHelp];
  }
  return self;
}

- (ClanHelp *) mainHelp {
  // Find the help that requires the most num of helps
  ClanHelp *needsMostHelp = nil;
  for (ClanHelp *ch in self.clanHelps) {
    if (ch.isOpen) {
      int chHelps = ch.maxHelpers-ch.numHelpers;
      int needsHelps = needsMostHelp.maxHelpers-needsMostHelp.numHelpers;
      if (!needsMostHelp || chHelps > needsHelps ||
          (chHelps == needsHelps && [ch.requestedTime compare:needsMostHelp.requestedTime] == NSOrderedDescending)) {
        needsMostHelp = ch;
      }
    }
  }
  return needsMostHelp;
}

- (int) maxHelpers {
  return self.mainHelp.maxHelpers;
}

- (int) numHelpers {
  return self.mainHelp.numHelpers;
}

- (NSString *)helpString {
  if (self.clanHelps.count == 1) {
    return [self.clanHelps[0] helpString];
  } else {
    if (self.helpType == GameActionTypeHeal) {
      return [NSString stringWithFormat:@"Help me heal %d %@s.", (int)self.clanHelps.count, MONSTER_NAME];
    }
  }
  return @"Help Me!";
}

- (NSString *) justHelpedString:(NSString *)name {
  if (self.clanHelps.count == 1) {
    return [self.clanHelps[0] justHelpedString:name];
  } else {
    if (self.helpType == GameActionTypeHeal) {
      return [NSString stringWithFormat:@"%@ just helped you heal your %@s!", name, MONSTER_NAME];
    }
  }
  return @"Help Me!";
}

- (NSString *) justSolicitedString {
  if (self.clanHelps.count == 1) {
    return [self.clanHelps[0] justSolicitedString];
  } else {
    if (self.helpType == GameActionTypeHeal) {
      return [NSString stringWithFormat:@"Heal %d %@s", (int)self.clanHelps.count, MONSTER_NAME];
    }
  }
  return @"Help";
}

- (MSDate *) requestedTime {
  return self.mainHelp.requestedTime;
}

- (BOOL) isOpen {
  for (ClanHelp *ch in self.clanHelps) {
    if (ch.isOpen) {
      return YES;
    }
  }
  return NO;
}

- (void) consumeClanHelp:(ClanHelp *)clanHelp {
  NSInteger idx = [self.clanHelps indexOfObject:clanHelp];
  if (idx != NSNotFound) {
    ClanHelp *preexisting = [self.clanHelps objectAtIndex:idx];
    [preexisting consumeClanHelp:clanHelp];
  } else {
    [self.clanHelps addObject:clanHelp];
  }
}

- (ClanHelp *) getClanHelpForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid {
  for (ClanHelp *ch in self.clanHelps) {
    if (ch.helpType == type && [ch.userDataUuid isEqualToString:userDataUuid]) {
      return ch;
    }
  }
  return nil;
}

- (NSArray *) helpableClanHelpIdsForUserUuid:(NSString *)userUuid {
  NSMutableArray *clanHelpUuids = [NSMutableArray array];
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch canHelpForUserUuid:userUuid]) {
      [clanHelpUuids addObject:ch.clanHelpUuid];
    }
  }
  return clanHelpUuids;
}

- (BOOL) canHelpForUserUuid:(NSString *)userUuid {
  return [self helpableClanHelpIdsForUserUuid:userUuid].count > 0;
}

- (BOOL) hasHelpedForUserUuid:(NSString *)userUuid {
  // Only return YES if we have helped at least once and we can't help anymore.
  BOOL hasHelped = NO;
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch hasHelpedForUserUuid:userUuid]) {
      hasHelped = YES;
    }
  }
  
  return hasHelped && ![self canHelpForUserUuid:userUuid];
}

- (NSArray *) allIndividualClanHelps {
  return [self.clanHelps copy];
}

- (BOOL) removeClanHelps:(NSArray *)clanHelps {
  [self.clanHelps removeObjectsInArray:clanHelps];
  
  // If clanHelps is empty, say YES so this object gets deleted.
  return self.clanHelps.count == 0;
}

- (void) incrementHelpForUserUuid:(NSString *)userUuid {
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch canHelpForUserUuid:userUuid]) {
      [ch incrementHelpForUserUuid:userUuid];
    }
  }
}

- (BOOL) isEqual:(ClanHelp *)object {
  return ([object conformsToProtocol:@protocol(ClanHelp)] &&  [self.requester.userUuid isEqualToString:object.requester.userUuid] &&
          [self.clanUuid isEqualToString:object.clanUuid] && self.helpType == object.helpType);
}

- (NSUInteger) hash {
  uint64_t val = 1;
  return (NSUInteger)(self.requester.userUuid.hash*31 + self.clanUuid.hash*29 + self.helpType*11 + val*7);
}

#pragma mark - ChatObject protocol

- (MinimumUserProto *) sender {
  return self.requester;
}

- (MSDate *) date {
  return self.requestedTime;
}

- (NSString *) message {
  return [self helpString];
}

- (BOOL) isRead {
  GameState *gs = [GameState sharedGameState];
  return ![self canHelpForUserUuid:gs.userUuid];
}

- (void) markAsRead {
  // Do nothing
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language{
  NSString *nibName = @"ChatClanHelpView";
  ChatClanHelpView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanHelp:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language{
  [self updateInChatCell:chatCell showsClanTag:YES language:language];
  return CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f;
}

- (IBAction)helpClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:@[self]];
}

@end
