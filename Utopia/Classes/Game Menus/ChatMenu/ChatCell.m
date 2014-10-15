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

@implementation ChatCell

static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  buttonInitialWidth = self.nameLabel.frame.size.width;
  
  self.chatSubviews = [NSMutableDictionary dictionary];
  
  self.backgroundView = [[UIView alloc] init];
  self.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag {
  [self updateForMessage:message sender:sender date:date showsClanTag:showsClanTag chatSubview:nil identifier:nil];
}

- (void) updateForMessage:(NSString *)message sender:(MinimumUserProto *)sender date:(MSDate *)date showsClanTag:(BOOL)showsClanTag chatSubview:(UIView *)view identifier:(NSString *)identifier {
  GameState *gs = [GameState sharedGameState];
  
  self.msgLabel.text = message;
  
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
  
  CGSize size = [message getSizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(self.msgLabel.frame.size.width, 999)];
  CGRect frame = self.msgLabel.frame;
  frame.size.height = size.height+1.f;
  self.msgLabel.frame = frame;
  
  size.width = MAX(size.width+66.f, buttonSize.width+self.timeLabel.frame.size.width+50.f);
  frame = self.mainView.frame;
  frame.size.width = size.width;
  self.mainView.frame = frame;
  
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

  BOOL shouldHighlight;
  if (sender.userId == gs.userId) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.msgLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.timeLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    self.msgLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    shouldHighlight = NO;
    
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
    self.msgLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    shouldHighlight = YES;
    
    if ([self.currentChatSubview respondsToSelector:@selector(unflip)]) {
      [self.currentChatSubview performSelector:@selector(unflip)];
    } else {
      self.currentChatSubview.transform = CGAffineTransformIdentity;
    }
  }
  
  [self highlightSubviews:self.mainView shouldHighlight:shouldHighlight];
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

- (void) updateForPrivateChat:(PrivateChatPostProto *)pcpp {
  self.privateChat = pcpp;
  
  self.msgLabel.text = pcpp.content;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[MSDate dateWithTimeIntervalSince1970:pcpp.timeOfPost/1000.] shortened:NO];
  self.nameLabel.text = pcpp.otherUser.name;
  self.unreadIcon.hidden = ![pcpp isUnread];
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
  self.helpButtonView.hidden = ![help canHelpForUserId:gs.userId];
  self.helpedView.hidden = ![help hasHelpedForUserId:gs.userId];
  
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
