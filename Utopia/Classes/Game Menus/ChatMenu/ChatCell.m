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

@implementation ChatCell

static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  buttonInitialWidth = self.nameLabel.frame.size.width;
}

- (void) updateForChat:(ChatMessage *)msg showsClanTag:(BOOL)showsClanTag {
  GameState *gs = [GameState sharedGameState];
  self.chatMessage = msg;
  
  self.msgLabel.text = msg.message;
  
  self.levelLabel.text = [Globals commafyNumber:msg.sender.level];
  self.timeLabel.text = [Globals stringForTimeSinceNow:msg.date shortened:NO];
  
  NSString *buttonText = [Globals fullNameWithName:msg.sender.minUserProto.name clanTag:msg.sender.minUserProto.clan.tag];
  if (!showsClanTag) {
    buttonText = msg.sender.minUserProto.name;
  }
  
//  if (msg.isAdmin) {
//    [self.nameButton setTitleColor:[Globals redColor] forState:UIControlStateNormal];
//  } else {
//    [self.nameButton setTitleColor:[Globals goldColor] forState:UIControlStateNormal];
//  }
  
  self.nameLabel.text = buttonText;
  CGSize buttonSize = [buttonText sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(buttonInitialWidth, 999) lineBreakMode:self.nameLabel.lineBreakMode];
  
  [self.monsterView updateForMonsterId:msg.sender.minUserProto.avatarMonsterId];
  
  CGRect r = self.nameLabel.frame;
  r.size.width = buttonSize.width+7.f;
  self.nameLabel.frame = r;
  
  CGSize size = [msg.message sizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(self.msgLabel.frame.size.width, 999)];
  CGRect frame = self.msgLabel.frame;
  frame.size.height = size.height+1.f;
  self.msgLabel.frame = frame;
  
  size.width = MAX(size.width+66.f, buttonSize.width+self.timeLabel.frame.size.width+50.f);
  frame = self.mainView.frame;
  frame.size.width = size.width;
  self.mainView.frame = frame;

  BOOL shouldHighlight;
  if (msg.sender.minUserProto.userId == gs.userId) {
    self.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.msgLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.timeLabel.transform = CGAffineTransformMakeScale(-1, 1);
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    self.msgLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    shouldHighlight = NO;
  } else {
    self.transform = CGAffineTransformIdentity;
    self.nameLabel.transform = CGAffineTransformIdentity;
    self.msgLabel.transform = CGAffineTransformIdentity;
    self.timeLabel.transform = CGAffineTransformIdentity;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.msgLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    shouldHighlight = YES;
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