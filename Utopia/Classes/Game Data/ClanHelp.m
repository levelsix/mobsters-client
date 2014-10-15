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
    self.requestedTime = [MSDate dateWithTimeIntervalSince1970:chp.timeRequested/1000.0];
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
  if (self.clanHelpId != chp.clanHelpId) {
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
    
    self.isOpen = self.isOpen & chp.isOpen;
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
    // Set to NO so that if anything is holding this object, it won't try to add helps
    self.isOpen = NO;
    return YES;
  }
  return NO;
}

- (BOOL) isEqual:(ClanHelp *)object {
  // Types that are gonna be bundled need to match with this (2nd statement).
  // Otherwise, actually compare values.
  return ([self class] == [object class] && self.requester.userId == object.requester.userId &&
          self.clanId == object.clanId && self.helpType == object.helpType &&
          self.userDataId == object.userDataId) ||
  // Bundle will match with this object but make sure its not also this object
  ([self class] != [object class] && [object conformsToProtocol:@protocol(ClanHelp)] &&  self.requester.userId == object.requester.userId &&
   self.clanId == object.clanId && self.helpType == object.helpType);
}

- (NSUInteger) hash {
  // Types that are gonna be bundled need to match with this
  uint64_t val = self.helpType == ClanHelpTypeHeal ? 1 : self.userDataId;
  return (NSUInteger)(self.requester.userId*31 + self.clanId*29 + self.helpType*11 + val*7);
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

- (UIColor *) textColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  GameState *gs = [GameState sharedGameState];
  return ![self canHelpForUserId:gs.userId];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  
  NSString *nibName = @"ChatClanHelpView";
  ChatClanHelpView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanHelp:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell {
  UIFont *font = chatCell.msgLabel.font;
  CGRect frame = chatCell.msgLabel.frame;
  
  [self updateInChatCell:chatCell showsClanTag:YES];
  
  NSString *msg = [self message];
  CGSize size = [msg getSizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+frame.origin.y+14.f;
  height = MAX(height, CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f);
  
  return height;
}

- (IBAction)helpClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:@[self]];
}

@end

@implementation BundleClanHelp

+ (id<ClanHelp>) getPossibleBundleFromClanHelp:(ClanHelp *)clanHelp {
  if (clanHelp.helpType == ClanHelpTypeHeal) {
    return [[BundleClanHelp alloc] initWithClanHelp:clanHelp];
  }
  return clanHelp;
}

- (id) initWithClanHelp:(ClanHelp *)clanHelp {
  if ((self = [super init])) {
    self.requester = clanHelp.requester;
    self.clanId = clanHelp.clanId;
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
    if (self.helpType == ClanHelpTypeHeal) {
      return [NSString stringWithFormat:@"Help me heal %d %@s.", (int)self.clanHelps.count, MONSTER_NAME];
    }
  }
  return @"Help Me!";
}

- (NSString *) justHelpedString:(NSString *)name {
  if (self.clanHelps.count == 1) {
    return [self.clanHelps[0] justHelpedString:name];
  } else {
    if (self.helpType == ClanHelpTypeHeal) {
      return [NSString stringWithFormat:@"%@ just helped you heal your %@s!", name, MONSTER_NAME];
    }
  }
  return @"Help Me!";
}

- (NSString *) justSolicitedString {
  if (self.clanHelps.count == 1) {
    return [self.clanHelps[0] justSolicitedString];
  } else {
    if (self.helpType == ClanHelpTypeHeal) {
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

- (ClanHelp *) getClanHelpForType:(ClanHelpType)type userDataId:(uint64_t)userDataId {
  for (ClanHelp *ch in self.clanHelps) {
    if (ch.helpType == type && ch.userDataId == userDataId) {
      return ch;
    }
  }
  return nil;
}

- (NSArray *) helpableClanHelpIdsForUserId:(int)userId {
  NSMutableArray *clanHelpIds = [NSMutableArray array];
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch canHelpForUserId:userId]) {
      [clanHelpIds addObject:@(ch.clanHelpId)];
    }
  }
  return clanHelpIds;
}

- (BOOL) canHelpForUserId:(int)userId {
  return [self helpableClanHelpIdsForUserId:userId].count > 0;
}

- (BOOL) hasHelpedForUserId:(int)userId {
  // Only return YES if we have helped at least once and we can't help anymore.
  BOOL hasHelped = NO;
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch hasHelpedForUserId:userId]) {
      hasHelped = YES;
    }
  }
  
  return hasHelped && ![self canHelpForUserId:userId];
}

- (NSArray *) allIndividualClanHelps {
  return [self.clanHelps copy];
}

- (BOOL) removeClanHelps:(NSArray *)clanHelps {
  [self.clanHelps removeObjectsInArray:clanHelps];
  
  // If clanHelps is empty, say YES so this object gets deleted.
  return self.clanHelps.count == 0;
}

- (void) incrementHelpForUserId:(int)userId {
  for (ClanHelp *ch in self.clanHelps) {
    if ([ch canHelpForUserId:userId]) {
      [ch incrementHelpForUserId:userId];
    }
  }
}

- (BOOL) isEqual:(ClanHelp *)object {
  return ([object conformsToProtocol:@protocol(ClanHelp)] &&  self.requester.userId == object.requester.userId &&
          self.clanId == object.clanId && self.helpType == object.helpType);
}

- (NSUInteger) hash {
  uint64_t val = 1;
  return (NSUInteger)(self.requester.userId*31 + self.clanId*29 + self.helpType*11 + val*7);
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
  return ![self canHelpForUserId:gs.userId];
}

- (UIColor *) textColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  NSString *nibName = @"ChatClanHelpView";
  ChatClanHelpView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanHelp:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell {
  UIFont *font = chatCell.msgLabel.font;
  CGRect frame = chatCell.msgLabel.frame;
  
  [self updateInChatCell:chatCell showsClanTag:YES];
  
  NSString *msg = [self message];
  CGSize size = [msg getSizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+frame.origin.y+14.f;
  height = MAX(height, CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f);
  
  return height;
}

- (IBAction)helpClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:@[self]];
}

@end
