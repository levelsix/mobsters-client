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

@implementation ChatCell

static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  buttonInitialWidth = self.nameLabel.frame.size.width;
  
  self.chatSubviews = [NSMutableDictionary dictionary];
  
  self.backgroundView = [[UIView alloc] init];
  self.backgroundView.backgroundColor = [UIColor clearColor];
  
  _initLabelColor = self.msgLabel.textColor;
  _initLabelHighlightedColor = self.msgLabel.highlightedTextColor;
  
  _initialMsgLabelWidth = self.msgLabel.width;
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag {
  [self updateForMessage:message sender:sender date:date showsClanTag:showsClanTag allowHighlight:YES chatSubview:nil identifier:nil];
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag allowHighlight:(BOOL)allowHighlight chatSubview:(UIView *)view identifier:(NSString *)identifier {
  GameState *gs = [GameState sharedGameState];
  
  self.msgLabel.text = message;
  self.msgLabel.textColor = _initLabelColor;
  self.msgLabel.highlightedTextColor = _initLabelHighlightedColor;
  
  self.timeLabel.text = [Globals stringForTimeSinceNow:date shortened:NO];
  
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
  
  CGSize size = [message getSizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(_initialMsgLabelWidth, 999)];
  
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

- (void) updateForPrivateChat:(id<ChatObject>)pcpp {
  self.privateChat = pcpp;
  
  self.msgLabel.text = [pcpp message];
  self.timeLabel.text = [Globals stringForTimeSinceNow:[pcpp date] shortened:NO];
  self.nameLabel.text = pcpp.otherUser.name;
  self.unreadIcon.hidden = [pcpp isRead];
  [self.monsterView updateForMonsterId:pcpp.otherUser.avatarMonsterId];
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
  
  NSArray *monsters;
  
  if ([pvp userIsAttacker]) {
    NSMutableArray *arr = [NSMutableArray array];
    GameState *gs = [GameState sharedGameState];
    for (UserMonster *um in gs.allMonstersOnMyTeam) {
      MinimumUserMonsterProto *mup = [[[[MinimumUserMonsterProto builder]
                                       setMonsterId:um.monsterId]
                                      setMonsterLvl:um.level]
                                      build];
      PvpMonsterProto *mon = [[[PvpMonsterProto builder] setDefenderMonster:mup] build];
      
      [arr addObject:mon];
    }
    monsters = arr;
  } else {
    monsters = pvp.attackersMonstersList;
  }
  
  for (int i = 0; i < self.monsterViews.count; i++) {
    PvpMonsterProto *pm = i < monsters.count ? monsters[i] : nil;
    MinimumUserMonsterProto *um = pm.defenderMonster;
    ChatMonsterView *cmv = self.monsterViews[i];
    
    [cmv updateForMinMonster:um];
  }
  
  self.avengeButton.superview.hidden = [pvp userIsAttacker] || pvp.clanAvenged;
  self.revengeButton.superview.hidden = [pvp userIsAttacker] || pvp.exactedRevenge;
  
  if (!self.avengeButton.superview.hidden && self.revengeButton.superview.hidden) {
    self.avengeButton.superview.frame = self.revengeButton.superview.frame;
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
  } else {
    self.avengeTimeLabel.superview.hidden = YES;
  }
}

@end

@implementation ChatClanAvengeView

- (void) updateForClanAvenging:(PvpClanAvenging *)ca {
  [self.monsterView updateForMonsterId:ca.attacker.minUserProto.avatarMonsterId];
  self.nameLabel.text = [Globals fullNameWithName:ca.attacker.minUserProto.name clanTag:ca.attacker.minUserProto.clan.tag];
  self.levelLabel.text = [NSString stringWithFormat:@"Level %d", ca.attacker.level];
  
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
    UserMonster *um = donation.donatedMonster;
    MonsterProto *mp = um.staticMonster;
    
    [self.monsterView updateForMonsterId:um.monsterId];
    
    NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
    NSString *p2 = [NSString stringWithFormat:@"L%d", um.level];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
    self.monsterLabel.attributedText = attr;
    
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
}

@end
