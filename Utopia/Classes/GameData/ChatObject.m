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

#import "MiniEventManager.h"

static char const * clanGiftRedeemedKey = "clanGiftRedeemedKey";

@implementation ChatMessage

- (id) initWithProto:(GroupChatMessageProto *)p {
  if ((self = [super init])) {
    self.originalMessage = p.content;
    self.originalLanguage = p.contentLanguage;
    self.translatedTextProtos = [NSMutableArray arrayWithArray:p.translatedContentList];
    self.originalSender = p.sender;
    self.date = [MSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
    self.isAdmin = p.isAdmin;
    self.revertedTranslation = NO;
    self.postUuid = p.chatUuid;
  }
  return self;
}

- (id) initWithPrivateChatPostProto:(PrivateChatPostProto *)p {
  if ((self = [super init])) {
    self.originalMessage = p.content;
    self.originalLanguage = p.originalContentLanguage;
    self.translatedTextProtos = [NSMutableArray arrayWithArray:p.translatedContentList];
    self.originalSender = p.poster;
    self.date = [MSDate dateWithTimeIntervalSince1970:p.timeOfPost/1000.];
    self.revertedTranslation = NO;
    self.postUuid = p.privateChatPostUuid;
  }
  return self;
}

- (PrivateChatPostProto *) makePrivateChatPostProto {
  PrivateChatPostProto *pcpp = [[[[[[[PrivateChatPostProto builder]
                                     setPrivateChatPostUuid:self.postUuid]
                                    setPoster:self.originalSender]
                                   setTimeOfPost:self.date.timeIntervalSince1970*1000.]
                                  setContent:self.originalMessage]
                                 addAllTranslatedContent:self.translatedTextProtos]
                                build];
  return pcpp;
}

- (MinimumUserProto *) sender {
  return self.originalSender.minUserProto;
}

- (NSString *) message {
  return self.originalMessage;
}

- (UIColor *)bottomViewTextColor {
  return [UIColor whiteColor];
}

- (NSString *) getContentInLanguage:(TranslateLanguages)language isTranslated:(BOOL *)isTranslatedPtr translationExists:(BOOL *)translationExistsPtr {
  BOOL isTranslated = NO;
  BOOL translationExists = NO;
  NSString *content = self.originalMessage;
  
  // Pretend no translation exists if it is the same as original language or if user is the sender
  GameState *gs = [GameState sharedGameState];
  if (self.originalLanguage != language && ![self.sender.userUuid isEqualToString:gs.userUuid]) {
    
    // Go through list to see if translation exists. Only translate if it wasn't reverted
    for (TranslatedTextProto *ttp in self.translatedTextProtos) {
      if (ttp.language == language) {
        if (!self.revertedTranslation) {
          content = ttp.text;
          isTranslated = YES;
        }
        
        translationExists = YES;
        break;
      }
    }
  }
  
  // Make sure the pointers actually exist
  if (isTranslatedPtr) {
    *isTranslatedPtr = isTranslated;
  }
  
  if (translationExistsPtr) {
    *translationExistsPtr = translationExists;
  }
  
  return content;
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag language:(TranslateLanguages)language {
  BOOL isTranslated = NO, translationExists = NO;
  NSString *message = [self getContentInLanguage:language isTranslated:&isTranslated translationExists:&translationExists];
  [chatCell updateForMessage:message sender:self.sender date:self.date showsClanTag:showsClanTag translatedTo:language untranslate:self.revertedTranslation showTranslateButton:translationExists];

- (UIColor *) bottomViewTextColor {
  return [UIColor whiteColor];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell language:(TranslateLanguages)language {
  [self updateInChatCell:chatCell showsClanTag:NO language:language];
  float translationSpace = 0.f;
  
  if (!chatCell.translationDescription.superview.hidden) {
    translationSpace = 14.f;
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
  bldr.originalContentLanguage = [gs languageForUser:bldr.recipient.minUserProto.userUuid];
  PrivateChatPostProto *pcpp = [bldr build];
  return pcpp;
}

- (IBAction) helpClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptUuids:@[self.invite.inviteUuid] rejectUuids:nil];
  
  PrivateChatPostProto *pcpp = [self privateChat];
  
  // Send a private message as if you just accepted the hire
  [[OutgoingEventController sharedOutgoingEventController] privateChatPost:self.invite.inviter.minUserProto.userUuid content:pcpp.content originalLanguage:pcpp.originalContentLanguage];
  
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

- (ChatMessage *) makeChatMessage {
  ChatMessage *cm = [[ChatMessage alloc] initWithPrivateChatPostProto:self];
  return cm;
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

- (IBAction) revengeClicked:(id)sender {
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
      
      [[MiniEventManager sharedInstance] checkAvengeRequest];
      
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

- (IBAction) attackClicked:(id)sender {
  if ([Globals checkEnteringDungeon]) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc beginPvpMatchForAvenge:self];
  }
}

- (IBAction) profileClicked:(id)sender {
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

@implementation UserClanGiftProto (ChatObject)

- (MinimumUserProto *) sender {
  return self.sender;
}

- (NSString *) message {
  return @"Sent you a gift.";
}

- (MSDate *) date {
  return [MSDate date];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ff2400"];
}

- (PrivateChatPostProto *) clanChatPrivateChat {
  // This is an easy way to do read msgs for all clan chats (use an id that is shared amongst everything)
  MinimumUserProto *mup = [[[MinimumUserProto builder] setUserUuid:CLAN_CHAT_PRIVATE_CHAT_USER_ID] build];
  MinimumUserProtoWithLevel *mupl = [[[MinimumUserProtoWithLevel builder] setMinUserProto:mup] build];
  PrivateChatPostProto *pcpp = [[[[PrivateChatPostProto builder]
                                  setRecipient:mupl]
                                 setTimeOfPost:self.timeReceived]
                                build];
  return pcpp;
}

- (BOOL) isRead {
  return self.isValid || [[self clanChatPrivateChat] isRead];
}

- (void) markAsRead {
  // Do nothing
  return [[self clanChatPrivateChat] markAsRead];
}

- (BOOL) isValid {
  return [self.exprieDate timeIntervalSinceNow] > 0;
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  NSString *nibName = @"ChatClanGiftView";
  ChatClanGiftView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanGift:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (long) expireTime {
  return self.timeReceived + (self.clanGift.hoursUntilExpiration * 60 * 60 * 1000);
}

- (MSDate *) exprieDate {
  return [MSDate dateWithTimeIntervalSince1970:[self expireTime]];
}

- (IBAction)collectClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] collectClanGift:[NSArray arrayWithObject:self] delegate:nil];
  
  [self setIsRedeemed:YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_VIEWED_NOTIFICATION object:nil];
}

- (void) setIsRedeemed:(BOOL)isRedeemed {
  objc_setAssociatedObject(self, clanGiftRedeemedKey, @(isRedeemed), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL) isRedeemed {
  return (BOOL)objc_getAssociatedObject(self, clanGiftRedeemedKey);
}

- (BOOL) updateForTimeInChatCell:(ChatCell *)chatCell {
  ChatClanGiftView *v = (ChatClanGiftView *)chatCell;
  
  MSDate *expirationDate = [self exprieDate];
  if (expirationDate.timeIntervalSinceNow > 0) {
    //send message to expire gifts
    return YES;
  } else {
    [v updateForExpireDate:expirationDate];
    return NO;
  }
  
}

@end

