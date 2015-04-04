//
//  ChatObject.m
//  Utopia
//
//  Created by Ashwin on 10/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ChatObject.h"
#import "ChatCell.h"

#import "NibUtils.h"

#import "Globals.h"
#import "GameState.h"

#import "OutgoingEventController.h"
#import "UnreadNotifications.h"

#import "GameViewController.h"
#import "ProfileViewController.h"

@implementation ChatMessage

@synthesize sender, date, isAdmin, originalLanguage;

- (id) initWithProto:(GroupChatMessageProto *)p {
  if ((self = [super init])) {
    self.originalMessage = p.content;
    self.originalLanguage = p.contentLanguage;
    self.translatedTextProtos = [NSMutableArray arrayWithArray:p.translatedContentList];
    self.sender = p.sender.minUserProto;
    self.date = [MSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
    self.isAdmin = p.isAdmin;
    self.revertedTranslation = NO;
    self.postUuid = p.chatUuid;
    self.timeOfPost = p.timeOfChat;
  }
  return self;
}

- (PrivateChatPostProto *)makePrivateChatPostProto {
  GameState *gs = [GameState sharedGameState];
  
  PrivateChatPostProto *pcpp = [[[[[[[PrivateChatPostProto builder]
                                     setPrivateChatPostUuid:self.postUuid]
                                    setPoster:nil]
                                   setRecipient:[gs minUserWithLevel]]
                                  setTimeOfPost:self.timeOfPost]
                                 setContent:self.originalMessage]
                                build];
  return pcpp;
}

- (NSString *)message {
  return self.originalMessage;
}

- (void)setMessage:(NSString *)message {
  self.originalMessage = message;
}

- (UIColor *)bottomViewTextColor {
  return [UIColor whiteColor];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language {
  GameState *gs = [GameState sharedGameState];
  NSString *translatedMessage = self.originalMessage;
  
  //this if for determining if the revert translation should show
  TranslateLanguages translationLanguage = TranslateLanguagesNoTranslation;
  
  for(TranslatedTextProto *ttp in self.translatedTextProtos) {
    if (ttp.language == language) {
      translatedMessage = ttp.text;
      translationLanguage = language;
      break;
    }
  }
  
  if (self.revertedTranslation || self.originalLanguage == language || [self.sender.userUuid isEqualToString:[gs minUser].userUuid]) {
    translatedMessage = self.originalMessage;
    translationLanguage = TranslateLanguagesNoTranslation;
  }
  
  [chatCell updateForMessage:translatedMessage showsClanTag:showsClanTag translatedTo:translationLanguage chatMessage:self];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language{
  GameState *gs = [GameState sharedGameState];
  
  [self updateInChatCell:chatCell showsClanTag:NO language:language];
  float translationSpace = 0.f;
  
  if ((language != TranslateLanguagesNoTranslation || self.revertedTranslation) && ![self.sender.userUuid isEqualToString:gs.userUuid] && language != self.originalLanguage) {
    translationSpace = 20.f;
  }
  
  return CGRectGetMaxY(chatCell.msgLabel.frame)+14.f+translationSpace;
}

- (void) markAsRead {
  self.isRead = YES;
}

@end

@implementation RequestFromFriend (ChatObject)

- (ResidenceProto *) staticStruct {
  GameState *gs = [GameState sharedGameState];
  for (id<StaticStructure> ss in gs.staticStructs.allValues) {
    if (ss.structInfo.structType == StructureInfoProto_StructTypeResidence &&
        ss.structInfo.level == self.invite.structFbLvl) {
      ResidenceProto *rp = (ResidenceProto *)ss;
      return rp;
    }
  }
  
  return nil;
}

- (MinimumUserProto *) sender {
  return self.invite.inviter.minUserProto;
}

- (MinimumUserProto *) otherUser {
  return [self sender];
}

- (NSString *) message {
  ResidenceProto *rp = [self staticStruct];
  return [NSString stringWithFormat:@"Please help me increase my %@ size by being my %@.", rp.structInfo.name, rp.occupationName];
}

- (MSDate *) date {
  return [MSDate dateWithTimeIntervalSince1970:self.invite.timeOfInvite/1000.];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  return NO;
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language{
  NSString *nibName = @"ChatBonusSlotRequestView";
  ChatBonusSlotRequestView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForRequest:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language{
  [self updateInChatCell:chatCell showsClanTag:YES language:TranslateLanguagesEnglish];
  return CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f;
}

- (PrivateChatPostProto *) privateChat {
  ResidenceProto *rp = [self staticStruct];
  NSString *posName = [NSString stringWithFormat:@"Happy to help! I am now your %@. 😉", rp.occupationName];
  
  GameState *gs = [GameState sharedGameState];
  PrivateChatPostProto_Builder *bldr = [PrivateChatPostProto builder];
  bldr.content = posName;
  bldr.poster = [gs minUserWithLevel];
  bldr.recipient = [[[MinimumUserProtoWithLevel builder] setMinUserProto:[self sender]] build];
  bldr.timeOfPost = [[MSDate date] timeIntervalSince1970]*1000.;
  PrivateChatPostProto *pcpp = [bldr build];
  return pcpp;
}

- (IBAction)helpClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptUuids:@[self.invite.inviteUuid] rejectUuids:nil];
  
  PrivateChatPostProto *pcpp = [self privateChat];
  
  // Send a private message as if you just accepted the hire
  [[OutgoingEventController sharedOutgoingEventController] privateChatPost:self.invite.inviter.minUserProto.userUuid content:pcpp.content];
  
  NSString *key = [NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, pcpp.recipient.minUserProto.userUuid];
  [[NSNotificationCenter defaultCenter] postNotificationName:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:self userInfo:@{key : pcpp}];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
}

- (void) markAsRead {
  [[self privateChat] markAsRead];
}

@end

@implementation PrivateChatPostProto (ChatObject)

- (MinimumUserProto *) sender {
  return self.poster.minUserProto;
}

- (NSString *) message {
  return self.content;
}

- (MSDate *) date {
  return [MSDate dateWithTimeIntervalSince1970:self.timeOfPost/1000.];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor whiteColor];
}

- (BOOL) isRead {
  return !self.isUnread;
}

@end

@implementation PvpHistoryProto (ChatObject)

- (MinimumUserProto *) sender {
  if ([self userIsAttacker]) {
    GameState *gs = [GameState sharedGameState];
    return [gs minUser];
  } else {
    return [self otherUser];
  }
}

- (MinimumUserProto *) otherUser {
  FullUserProto *fup = [self userIsAttacker] ? self.defender : self.attacker;
  MinimumUserProto_Builder *bldr = [MinimumUserProto builder];
  bldr.name = fup.name;
  bldr.userUuid = fup.userUuid;
  bldr.avatarMonsterId = fup.avatarMonsterId;
  
  if (fup.hasClan) {
    bldr.clan = fup.clan;
  }
  
  return bldr.build;
}

- (BOOL) userIsAttacker {
  GameState *gs = [GameState sharedGameState];
  return [self.attacker.userUuid isEqualToString:gs.userUuid];
}

- (BOOL) userWon {
  return self.userIsAttacker ? self.attackerWon : !self.attackerWon;
}

- (NSString *) message {
  return [NSString stringWithFormat:@"Your %@ %@",self.userIsAttacker ? @"Offense" : @"Defense", self.userWon ? @"Won" : @"Lost" ];
}

- (MSDate *) date {
  return [MSDate dateWithTimeIntervalSince1970:self.battleEndTime/1000.];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  return [[self privateChat] isRead];
}

- (void) markAsRead {
  [[self privateChat] markAsRead];
}


- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language{
  NSString *nibName = @"ChatBattleHistoryView";
  ChatBattleHistoryView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:NO chatSubview:v identifier:nibName];
  [chatCell updateBubbleImagesWithPrefix:!self.userWon ? @"red" : @"green"];
  [v updateForPvpHistoryProto:self];
  
  chatCell.msgLabel.textColor = !self.userWon ? [UIColor colorWithHexString:@"BA0010"] : [UIColor colorWithHexString:@"3E7D16"];
  chatCell.timeLabel.textColor = !self.userWon ? [UIColor colorWithHexString:@"BA0010"] : [UIColor colorWithHexString:@"3E7D16"];
  chatCell.msgLabel.highlightedTextColor = chatCell.msgLabel.textColor;
}

- (BOOL) updateForTimeInChatCell:(ChatCell *)chatCell {
  ChatBattleHistoryView *v = (ChatBattleHistoryView *)chatCell.currentChatSubview;
  [v updateTimeForPvpHistoryProto:self];
  return NO;
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language{
  [self updateInChatCell:chatCell showsClanTag:YES language:TranslateLanguagesEnglish];
  return CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f;
}

- (PrivateChatPostProto *) privateChat {
  GameState *gs = [GameState sharedGameState];
  PrivateChatPostProto_Builder *bldr = [PrivateChatPostProto builder];
  bldr.poster = [[[MinimumUserProtoWithLevel builder] setMinUserProto:[self sender]] build];
  bldr.recipient = [gs minUserWithLevel];
  bldr.timeOfPost = [[self date] timeIntervalSince1970]*1000.;
  PrivateChatPostProto *pcpp = [bldr build];
  return pcpp;
}

- (IBAction)revengeClicked:(id)sender {
  if ([Globals checkEnteringDungeon]) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc beginPvpMatchForRevenge:self];
  }
}

- (IBAction) avengeClicked:(UIButton *)sender{
  // Check gamestate if there are any avengings by me
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan) {
    [Globals addAlertNotification:@"You must be in a clan to request avenging. Join one now!"];
  } else {
    BOOL found = NO;
    for (PvpClanAvenging *ca in gs.clanAvengings) {
      if ([ca isValid] && [ca.defender.userUuid isEqualToString:gs.userUuid]) {
        found = YES;
      }
    }
    
    if (!found) {
      [[OutgoingEventController sharedOutgoingEventController] beginClanAvenge:self];
      clanAvenged_ = YES;
      
      [sender.superview setHidden:YES];
      ChatBattleHistoryView *historyView = [sender getAncestorInViewHierarchyOfType:[ChatBattleHistoryView class]];
      historyView.avengedLabel.superview.hidden = NO;
      historyView.avengeCheck.hidden = NO;
      
      historyView.avengeCheck.transform = CGAffineTransformScale(CGAffineTransformIdentity, 10, 10);
      historyView.avengeCheck.alpha = 0;
      [UIView animateWithDuration:.3f animations:^{
        historyView.avengeCheck.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        historyView.avengeCheck.alpha = 1;
      }];
    } else {
      [Globals addAlertNotification:@"You already have a valid clan avenge request. Try again later."];
    }
  }
}

@end

@implementation PvpClanAvenging

- (id) initWithClanAvengeProto:(PvpClanAvengeProto *)proto {
  if ((self = [super init])) {
    self.clanAvengeUuid = proto.clanAvengeUuid;
    self.attacker = proto.attacker;
    self.defender = proto.defender;
    self.clanUuid = proto.defenderClanUuid;
    self.battleEndTime = [MSDate dateWithTimeIntervalSince1970:proto.battleEndTime/1000.];
    self.avengeRequestTime = [MSDate dateWithTimeIntervalSince1970:proto.avengeRequestTime/1000.];
    
    self.avengedUserUuids = [NSMutableArray array];
    for (PvpUserClanAvengeProto *p in proto.usersAvengingList) {
      [self.avengedUserUuids addObject:p.userUuid];
    }
  }
  return self;
}

- (PvpClanAvengeProto *) convertToProto {
  PvpClanAvengeProto_Builder *bldr = [PvpClanAvengeProto builder];
  bldr.clanAvengeUuid = self.clanAvengeUuid;
  bldr.attacker = self.attacker;
  bldr.defender = self.defender;
  bldr.defenderClanUuid = self.clanUuid;
  bldr.battleEndTime = self.battleEndTime.timeIntervalSince1970*1000.;
  bldr.avengeRequestTime = self.avengeRequestTime.timeIntervalSince1970*1000.;
  
  return bldr.build;
}

- (BOOL) isValid {
  Globals *gl = [Globals sharedGlobals];
  
  int mins = gl.beginAvengingTimeLimitMins;
  return [self.avengeRequestTime dateByAddingTimeInterval:mins*60].timeIntervalSinceNow > 0;
}

- (BOOL) canAttack {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *invalidIds = [self.avengedUserUuids mutableCopy];
  [invalidIds addObject:self.attacker.minUserProto.userUuid];
  [invalidIds addObject:self.defender.userUuid];
  
  return ![invalidIds containsObject:gs.userUuid];
}

- (MinimumUserProto *) sender {
  return self.defender;
}

- (NSString *) message {
  return [NSString stringWithFormat:@"I have been attacked by %@. Please avenge me!", self.attacker.minUserProto.name];
}

- (MSDate *) date {
  return self.avengeRequestTime;
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  return _isRead || ![self canAttack];
}

- (void) markAsRead {
  self.isRead = YES;
}


- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language{
  NSString *nibName = @"ChatClanAvengeView";
  ChatClanAvengeView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanAvenging:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (BOOL) updateForTimeInChatCell:(ChatCell *)chatCell {
  ChatClanAvengeView *v = (ChatClanAvengeView *)chatCell.currentChatSubview;
  [v updateTimeForClanAvenging:self];
  return ![self isValid];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language{
  [self updateInChatCell:chatCell showsClanTag:YES language:TranslateLanguagesEnglish];
  return CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f;
}

- (IBAction)attackClicked:(id)sender {
  if ([Globals checkEnteringDungeon]) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc beginPvpMatchForAvenge:self];
  }
}

- (IBAction)profileClicked:(id)sender {
  UIViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserUuid:self.attacker.minUserProto.userUuid];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (BOOL) isEqual:(PvpClanAvenging *)object {
  return [self class] == [object class] &&
  ( (self.clanAvengeUuid && [object clanAvengeUuid] && [self.clanAvengeUuid isEqualToString:[object clanAvengeUuid]]) ||
   ( (!self.clanAvengeUuid || ![object clanAvengeUuid]) &&
    [self.attacker.minUserProto.userUuid isEqualToString:[object attacker].minUserProto.userUuid] &&
    [self.defender.userUuid isEqualToString:[object defender].userUuid]));
}

@end
