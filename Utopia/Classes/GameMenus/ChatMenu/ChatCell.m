//
//  ChatCell.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ChatCell.h"
#import "GameState.h"
#import "Globals.h"
#import "UnreadNotifications.h"
#import "ClanHelp.h"
#import "GameViewController.h"

#define GREY_CHECK @"greycheck.png"
#define GREEN_CHECK @"greencheck.png"

#define RED_BG_COLOR @"FFDCD9"
#define GREEN_BG_COLOR @"E6F5C7"

#define RED_DIVIDE @"messagereddivider.png"
#define GREEN_DIVIDE @"messagegreendivider.png"

#define RED_CHAT_DIVIDER @"redchatdivider.png"
#define GREEN_CHAT_DIVIDER @"greenchatdivider.png"

#define GREEN @"3E7D16"
#define RED @"BA0010"
#define GREY @"929292"
#define DARK_GREY @"434343"

@implementation ChatCell

static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  buttonInitialWidth = self.nameLabel.frame.size.width;
  
  self.chatSubviews = [NSMutableDictionary dictionary];
  
  self.backgroundView = [[UIView alloc] init];
  self.backgroundView.backgroundColor = [UIColor clearColor];
  
  _initMsgLabelColor = self.msgLabel.textColor;
  _initMsgLabelHighlightedColor = self.msgLabel.highlightedTextColor;
  _initTimeLabelColor = self.timeLabel.textColor;
  
  _initialMsgLabelWidth = self.msgLabel.width;
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag translatedTo:(TranslateLanguages)translatedTo untranslate:(BOOL)untranslate showTranslateButton:(BOOL)showTranslateButton {
  [self updateForMessage:message sender:sender date:date showsClanTag:showsClanTag allowHighlight:YES chatSubview:nil identifier:nil translatedTo:translatedTo untranslate:untranslate showTranslateButton:showTranslateButton];
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier {
  [self updateForMessage:message sender:sender date:date showsClanTag:showsClanTag allowHighlight:allowHighlight chatSubview:view identifier:identifier translatedTo:TranslateLanguagesNoTranslation untranslate:NO showTranslateButton:NO];
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier translatedTo:(TranslateLanguages)translatedTo untranslate:(BOOL)untranslate showTranslateButton:(BOOL)showTranslateButton {
  GameState *gs = [GameState sharedGameState];
  
  self.msgLabel.text = message;
  self.msgLabel.textColor = _initMsgLabelColor;
  self.msgLabel.highlightedTextColor = _initMsgLabelHighlightedColor;
  
  self.timeLabel.text = [Globals stringForTimeSinceNow:date shortened:NO];
  self.timeLabel.textColor = _initTimeLabelColor;
  
  NSString *buttonText = [Globals fullNameWithName:sender.name clanTag:sender.clan.tag];
  if (!showsClanTag) {
    buttonText = sender.name;
  }
  
//  if (isAdmin) {
//    [self.nameButton setTitleColor:[Globals redColor] forState:UIControlStateNormal];
//  } else {
//    [self.nameButton setTitleColor:[Globals goldColor] forState:UIControlStateNormal];
//  }
  
  self.nameLabel.text = buttonText;
  CGSize buttonSize = [buttonText getSizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(buttonInitialWidth, 999) lineBreakMode:self.nameLabel.lineBreakMode];
  
  [self.monsterView updateForMonsterId:sender.avatarMonsterId];
  
  CGRect r = self.nameLabel.frame;
  r.size.width = buttonSize.width+7.f;
  self.nameLabel.frame = r;
  
  CGSize size = [message getSizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(_initialMsgLabelWidth, 999) lineBreakMode:self.msgLabel.lineBreakMode];
  
  // Do width after we use the current chat subview
  self.msgLabel.height = size.height+3.f;
  
  self.mainView.width = MAX(size.width+66.f, buttonSize.width+self.timeLabel.frame.size.width+50.f);
  
  // Chat subview stuff
  for (UIView *sub in self.chatSubviews.allValues) {
    [sub removeFromSuperview];
  }
  self.currentChatSubview = nil;
  
  if (view) {
    self.chatSubviews[identifier] = view;
    
    [self.mainView addSubview:view];
    
    view.originX = self.msgLabel.originX;
    view.originY = CGRectGetMaxY(self.msgLabel.frame);
    
    self.mainView.width = MAX(self.mainView.width, CGRectGetMaxX(view.frame)+14.f);
    view.width = self.mainView.width-14.f-view.originX;
    
    self.currentChatSubview = view;
  }
  
  self.msgLabel.width = self.mainView.width-66.f;
  
  // Translation tag and button
  self.translationDescription.superview.hidden = !showTranslateButton;
  
  if (untranslate) {
    self.translationDescription.text = @"Untranslated";
  } else {
    self.translationDescription.text = [Globals translationDescriptionWith:translatedTo];
  }
  
  if (!self.translationDescription.superview.hidden) {
    CGSize size = [self.translationDescription.text getSizeWithFont:self.translationDescription.font];
    self.mainView.width = MAX(self.mainView.width, size.width + 77.f + 14.f); //77 is the spacing on the left // 14 is right padding
  }

  BOOL shouldHighlight;
  if ([sender.userUuid isEqualToString:gs.userUuid]) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.msgLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.timeLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    shouldHighlight = YES;
    
    if ([self.currentChatSubview respondsToSelector:@selector(flip)]) {
      [self.currentChatSubview performSelector:@selector(flip)];
    } else {
      self.currentChatSubview.transform = CGAffineTransformMakeScale(-1, 1);
    }
  } else {
    self.transform = CGAffineTransformIdentity;
    self.nameLabel.transform = CGAffineTransformIdentity;
    self.msgLabel.transform = CGAffineTransformIdentity;
    self.timeLabel.transform = CGAffineTransformIdentity;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    shouldHighlight = NO;
    
    if ([self.currentChatSubview respondsToSelector:@selector(unflip)]) {
      [self.currentChatSubview performSelector:@selector(unflip)];
    } else {
      self.currentChatSubview.transform = CGAffineTransformIdentity;
    }
  }
  
  if (allowHighlight && _bubbleColorChanged) {
    [self updateBubbleImagesWithPrefix:@"grey"];
    _bubbleColorChanged = NO;
  }
  
  shouldHighlight = allowHighlight ? shouldHighlight : NO;
  [self highlightSubviews:self.mainView shouldHighlight:shouldHighlight];
}

- (void) updateBubbleImagesWithPrefix:(NSString *)prefix {
  for (UIImageView *iv in self.bubbleAlignView.superview.subviews) {
    if ([iv isKindOfClass:[UIImageView class]]) {
      NSString *suffix = nil;
      
      if (iv.tag == 1) {
        suffix = @"chattail.png";
      } else if (iv.tag == 2) {
        suffix = @"chatcorner.png";
      } else if (iv.tag == 3) {
        suffix = @"chatmiddle.png";
      }
      
      if (suffix) {
        iv.image = [Globals imageNamed:[prefix stringByAppendingString:suffix]];
      }
    }
  }
  
  _bubbleColorChanged = YES;
}

- (void) highlightSubviews:(UIView *)v shouldHighlight:(BOOL)h {
  if ([v isKindOfClass:[UILabel class]]) {
    [(UILabel *)v setHighlighted:h];
  } else if ([v isKindOfClass:[UIImageView class]]) {
    [(UIImageView *)v setHighlighted:h];
  }
  
  for (UIView *sv in v.subviews) {
    [self highlightSubviews:sv shouldHighlight:h];
  }
}

- (UIView *) dequeueChatSubview:(NSString *)identifier {
  return self.chatSubviews[identifier];
}

@end

@implementation PrivateChatListCell

- (void) updateForPrivateChat:(id<ChatObject>)pcpp language:(TranslateLanguages)language {
  PrivateChatPostProto *postProto = (PrivateChatPostProto *)pcpp;
  if (language != TranslateLanguagesNoTranslation && [postProto isKindOfClass:[PrivateChatPostProto class]]) {
    self.msgLabel.text = [[postProto makeChatMessage] getContentInLanguage:language isTranslated:NULL translationExists:NULL];
  } else {
    self.msgLabel.text = [pcpp message];
  }
  
  self.timeLabel.text = [Globals stringForTimeSinceNow:[pcpp date] shortened:NO];
  self.nameLabel.text = pcpp.otherUser.name;
  self.unreadIcon.hidden = [pcpp isRead];
  [self.monsterView updateForMonsterId:pcpp.otherUser.avatarMonsterId];
}

@end

@implementation PrivateChatAttackLogCell : PrivateChatListCell

- (void) updateForPrivateChat:(id<ChatObject>)privateChat language:(TranslateLanguages)language{
  [super updateForPrivateChat:privateChat language:language];
  
  PvpHistoryProto *php = (PvpHistoryProto*)privateChat;
  self.msgLabel.text = [NSString stringWithFormat:@"Your %@ %@",php.userIsAttacker ? @"Offense" : @"Defense", php.userWon ? @"Won" : @"Lost" ];
  self.msgLabel.textColor = php.userWon ? [UIColor colorWithHexString:GREEN] : [UIColor colorWithHexString:RED];
  self.timeLabel.textColor = php.userWon ? [UIColor colorWithHexString:GREEN] : [UIColor colorWithHexString:RED];
  int oilChange = php.userIsAttacker ? php.attackerOilChange : php.defenderOilChange;
  int cashChange = php.userIsAttacker ? php.attackerCashChange : php.defenderCashChange;
  if (oilChange == 0 && cashChange == 0) {
    self.oilLabel.superview.hidden = YES;
    self.cashLabel.superview.hidden = YES;
  } else {
    self.oilLabel.superview.hidden = NO;
    self.cashLabel.superview.hidden = NO;
  }
  
  self.oilLabel.text = [NSString stringWithFormat:@"%d", oilChange];
  self.cashLabel.text = [NSString stringWithFormat:@"%d", cashChange];
  
  self.revengeCheck.hidden = !php.exactedRevenge;
  self.avengedCheck.hidden = !php.clanAvenged;
  
  Globals *gl = [Globals sharedGlobals];
  int mins = gl.requestClanToAvengeTimeLimitMins;
  float secs = php.battleEndTime/1000.+mins*60;
  secs = [MSDate dateWithTimeIntervalSince1970:secs].timeIntervalSinceNow;
  
  if(php.userIsAttacker) {
    self.revengedLabel.textColor = [UIColor colorWithHexString:DARK_GREY];
    self.revengeCheck.image = [Globals imageNamed:GREY_CHECK];
    if (secs <= 0) {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
      self.avengedCheck.image = [Globals imageNamed:GREY_CHECK];
    } else {
      self.avengedLabel.textColor = [UIColor colorWithHexString:DARK_GREY];
      self.avengedCheck.image = [Globals imageNamed:GREY_CHECK];
    }
  } else {
    self.revengedLabel.textColor = [UIColor colorWithHexString:RED];
    self.revengeCheck.image = [Globals imageNamed:GREEN_CHECK];
    self.avengedCheck.image = [Globals imageNamed:GREEN_CHECK];
    if (secs <= 0) {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
    } else {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREEN];
    }
  }
  
  if(php.userWon) {
    UIColor *BGColor = [UIColor colorWithHexString:GREEN_BG_COLOR];
    self.selectedSubViewBackGround.backgroundColor = BGColor;
    self.avengedCheck.superview.backgroundColor = [BGColor colorWithAlphaComponent:0.6f];
    self.chatDivider.image = [Globals imageNamed:GREEN_DIVIDE];
  } else {
    UIColor *BGColor = [UIColor colorWithHexString:RED_BG_COLOR];
    self.selectedSubViewBackGround.backgroundColor = BGColor;
    self.avengedCheck.superview.backgroundColor = [BGColor colorWithAlphaComponent:0.6f];
    self.chatDivider.image = [Globals imageNamed:RED_DIVIDE];
  }
  
}

@end

@implementation ChatClanHelpView

- (void) updateForClanHelp:(id<ClanHelp>)help {
  int numHelps = [help numHelpers];
  int maxHelps = [help maxHelpers];
  
  NSString *str1 = @"Help: ";
  NSString *str2 = [NSString stringWithFormat:@"%d/%d", numHelps, maxHelps];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
  [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Gotham-Ultra" size:10] range:NSMakeRange(str1.length, str2.length)];
  
  self.numHelpsLabel.attributedText = attr;
  self.progressBar.percentage = numHelps/(float)maxHelps;
  
  GameState *gs = [GameState sharedGameState];
  self.helpButtonView.hidden = ![help canHelpForUserUuid:gs.userUuid];
  self.helpedView.hidden = ![help hasHelpedForUserUuid:gs.userUuid];
  
  [self.helpButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.helpButton addTarget:help action:@selector(helpClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) flip {
  self.progressBar.superview.transform = CGAffineTransformMakeScale(-1, 1);
}

- (void) unflip {
  self.progressBar.superview.transform = CGAffineTransformIdentity;
}

@end

@implementation ChatBonusSlotRequestView

- (void) updateForRequest:(RequestFromFriend *)req {
  [self.helpButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.helpButton addTarget:req action:@selector(helpClicked:) forControlEvents:UIControlEventTouchUpInside];
}

@end

@implementation ChatMonsterView

- (void) updateForMinMonster:(MinimumUserMonsterProto *)um {
  GameState *gs = [GameState sharedGameState];
  if (um.monsterId) {
    [self.monsterView updateForMonsterId:um.monsterId];
    
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
    NSString *p2 = [NSString stringWithFormat:@"L%d", um.monsterLvl];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
    self.nameLabel.attributedText = attr;
    
    self.rarityTag.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"tag.png"]]];
    
    self.hidden = NO;
  } else {
    self.hidden = YES;
  }
}

@end

@implementation ChatBattleHistoryView

- (void) awakeFromNib {
  _initAvengeFrame = self.avengeButton.superview.frame;
}

- (void) updateForPvpHistoryProto:(PvpHistoryProto *)pvp {
  self.topDivider.highlighted = !pvp.userWon;
  self.botDivider.highlighted = !pvp.userWon;
  self.dividerLine.image = pvp.userWon ? [Globals imageNamed:GREEN_CHAT_DIVIDER] : [Globals imageNamed:RED_CHAT_DIVIDER];
  
//  NSArray *monsters;
//  
//  if ([pvp userIsAttacker]) {
//    NSMutableArray *arr = [NSMutableArray array];
//    GameState *gs = [GameState sharedGameState];
//    for (UserMonster *um in [gs allMonstersOnMyTeamWithClanSlot:NO]) {
//      MinimumUserMonsterProto *mup = [[[[MinimumUserMonsterProto builder]
//                                       setMonsterId:um.monsterId]
//                                      setMonsterLvl:um.level]
//                                      build];
//      PvpMonsterProto *mon = [[[PvpMonsterProto builder] setDefenderMonster:mup] build];
//      
//      [arr addObject:mon];
//    }
//    monsters = arr;
//  } else {
//    monsters = pvp.attackersMonstersList;
//  }
//  
//  for (int i = 0; i < self.monsterViews.count; i++) {
//    PvpMonsterProto *pm = i < monsters.count ? monsters[i] : nil;
//    MinimumUserMonsterProto *um = pm.defenderMonster;
//    ChatMonsterView *cmv = self.monsterViews[i];
//    
//    [cmv updateForMinMonster:um];
//  }
  
  //setup if the button or the check mark is showing and what colors the text and checkmarks are
  
  self.avengeButton.superview.hidden = [pvp userIsAttacker] || pvp.clanAvenged;
//  self.avengeCheck.superview.hidden = !self.avengeButton.superview.hidden;
  self.avengeCheck.hidden = !pvp.clanAvenged;
  
  self.revengeButton.superview.hidden = [pvp userIsAttacker] || pvp.exactedRevenge;
  self.revengeCheck.superview.hidden = !self.revengeButton.superview.hidden;
  self.revengeCheck.hidden = !pvp.exactedRevenge;
  
  Globals *gl = [Globals sharedGlobals];
  int mins = gl.requestClanToAvengeTimeLimitMins;
  float secs = pvp.battleEndTime/1000.+mins*60;
  secs = [MSDate dateWithTimeIntervalSince1970:secs].timeIntervalSinceNow;
  
  if(pvp.userIsAttacker) {
    self.revengedLabel.textColor = [UIColor colorWithHexString:DARK_GREY];
    self.revengeCheck.image = [Globals imageNamed:GREY_CHECK];
    if (secs <= 0) {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
      self.avengeCheck.image = [Globals imageNamed:GREY_CHECK];
    } else {
      self.avengedLabel.textColor = [UIColor colorWithHexString:DARK_GREY];
      self.avengeCheck.image = [Globals imageNamed:GREY_CHECK];
    }
  } else {
    self.revengedLabel.textColor = [UIColor colorWithHexString:RED];
    self.revengeCheck.image = [Globals imageNamed:GREEN_CHECK];
    self.avengeCheck.image = [Globals imageNamed:GREEN_CHECK];
    if (secs <= 0) {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
    } else {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREEN];
    }
  }
  
  if (!self.avengeButton.superview.hidden && self.revengeButton.superview.hidden) {
//    self.avengeButton.superview.frame = self.revengeButton.superview.frame;
  } else {
    self.avengeButton.superview.frame = _initAvengeFrame;
  }
  
  [self.revengeButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.revengeButton addTarget:pvp action:@selector(revengeClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.avengeButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.avengeButton addTarget:pvp action:@selector(avengeClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  int curX = 0;
  
  if (pvp.attackerWon) {
    self.cashView.hidden = NO;
    self.oilView.hidden = NO;
    
    self.rankLabel.highlighted = YES;
    
    if ([pvp userIsAttacker]) {
      self.cashLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:ABS(pvp.attackerCashChange)]];
      self.oilLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:ABS(pvp.attackerOilChange)]];
    } else {
      self.cashLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:ABS(pvp.defenderCashChange)]];
      self.oilLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:ABS(pvp.defenderOilChange)]];
    }
    
    UILabel *label = self.cashLabel;
    CGSize size = [label.text getSizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    
    curX = label.superview.origin.x+label.originX+size.width+15.f;
    
    self.oilView.originX = curX;
    
    label = self.oilLabel;
    size = [label.text getSizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    
    curX = label.superview.origin.x+label.originX+size.width+15.f;
  } else {
    self.cashView.hidden = YES;
    self.oilView.hidden = YES;
    
    self.rankLabel.highlighted = NO;
  }
  
  self.rankView.originX = curX;
  
  GameState *gs = [GameState sharedGameState];
  UserPvpLeagueProto *pvpBefore;
  UserPvpLeagueProto *pvpAfter;
  
  if ([pvp userIsAttacker]) {
    pvpBefore = pvp.attackerBefore;
    pvpAfter = pvp.attackerAfter;
  } else {
    pvpBefore = pvp.defenderBefore;
    pvpAfter = pvp.defenderAfter;
  }
  
  self.rankLabel.hidden = NO;
  self.noChangeLabel.hidden = YES;
  if (pvpBefore.leagueId != pvpAfter.leagueId) {
    self.rankLabel.text = @"New!";
  } else {
    int change = pvpAfter.rank-pvpBefore.rank;
    if (change) {
      self.rankLabel.text = [NSString stringWithFormat:@"%+d", -change];
    } else {
      self.rankLabel.hidden = YES;
      self.noChangeLabel.hidden = NO;
    }
  }
  
  PvpLeagueProto *league = [gs leagueForId:pvpAfter.leagueId];
  NSString *icon = [league.imgPrefix stringByAppendingString:@"icon.png"];
  [Globals imageNamed:icon withView:self.rankIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  [self updateTimeForPvpHistoryProto:pvp];
}

- (void) updateTimeForPvpHistoryProto:(PvpHistoryProto *)pvp {
  Globals *gl = [Globals sharedGlobals];
  int mins = gl.requestClanToAvengeTimeLimitMins;
  float secs = pvp.battleEndTime/1000.+mins*60;
  secs = [MSDate dateWithTimeIntervalSince1970:secs].timeIntervalSinceNow;
  
  if (secs > 0) {
    self.avengeTimeLabel.text = [[Globals convertTimeToShortString:secs] uppercaseString];
    if([pvp userIsAttacker]) {
      self.avengedLabel.textColor = [UIColor colorWithHexString:DARK_GREY];
    } else {
      self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
    }
  } else {
    self.avengeTimeLabel.superview.hidden = YES;
    self.avengeCheck.superview.hidden = NO;
    self.avengedLabel.textColor = [UIColor colorWithHexString:GREY];
  }
}

@end

@implementation ChatClanAvengeView

- (void) updateForClanAvenging:(PvpClanAvenging *)ca {
  [self.monsterView updateForMonsterId:ca.attacker.avatarMonsterId];
  self.nameLabel.text = [Globals fullNameWithName:ca.attacker.name clanTag:ca.attacker.clan.tag];
  self.strengthLabel.text = [Globals commafyNumber:ca.attacker.strength];
  
  self.attackButton.superview.hidden = ![ca canAttack];
  
  if ([ca canAttack]) {
    self.width = CGRectGetMaxX(self.attackButton.superview.frame);
  } else {
    self.width = CGRectGetMaxX(self.timeLabel.superview.frame);
  }
  
  [self.attackButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.attackButton addTarget:ca action:@selector(attackClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.profileButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
  [self.profileButton addTarget:ca action:@selector(profileClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  [self updateTimeForClanAvenging:ca];
}

- (void) updateTimeForClanAvenging:(PvpClanAvenging *)ca {
  Globals *gl = [Globals sharedGlobals];
  int mins = gl.beginAvengingTimeLimitMins;
  self.timeLabel.text = [[Globals convertTimeToShortString:ca.avengeRequestTime.timeIntervalSinceNow+mins*60] uppercaseString];
}

@end

@implementation ChatTeamDonateView

- (void) awakeFromNib {
  self.filledView.frame = self.emptyView.frame;
  [self.emptyView.superview addSubview:self.filledView];
}

- (void) updateForTeamDonation:(ClanMemberTeamDonationProto *)donation {
  if (!donation.isFulfilled) {
    self.powerLimitLabel.text = [NSString stringWithFormat:@"%d", donation.powerAvailability];
    
    self.emptyView.hidden = NO;
    self.filledView.hidden = YES;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserMonsterSnapshotProto *snap = [donation.donationsList firstObject];
    
    UserMonster *um = [donation donatedMonsterWithResearchUtil:gs.researchUtil];
    MonsterProto *mp = um.staticMonster;
    
    [self.monsterView updateForMonsterId:um.monsterId];
    
    NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
    NSString *p2 = [NSString stringWithFormat:@"L%d", um.level];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
    self.monsterLabel.attributedText = attr;
    
    self.donatorNameLabel.text = [NSString stringWithFormat:@"From: %@", snap.user.name];
    
    self.emptyView.hidden = YES;
    self.filledView.hidden = NO;
  }
  
  GameState *gs = [GameState sharedGameState];
  if ([donation.solicitor.userUuid isEqualToString:gs.userUuid]) {
    self.donateButton.superview.hidden = YES;
  } else {
    [self.donateButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.donateButton addTarget:donation action:@selector(donateClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.donateButton.superview.hidden = NO;
  }
  
  
  self.donateSpinner.hidden = YES;
  self.donateLabel.hidden = NO;
  self.donateButton.userInteractionEnabled = YES;
}

@end
