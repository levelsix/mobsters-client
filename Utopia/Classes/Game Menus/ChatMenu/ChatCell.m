//
//  ChatCell.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ChatCell.h"
#import "Globals.h"
#import "PrivateChatPostProto+UnreadStatus.h"

@implementation ChatCell

static float buttonInitialWidth = 159.f;

- (void) awakeFromNib {
  buttonInitialWidth = self.nameButton.frame.size.width;
}

- (void) updateForChat:(ChatMessage *)msg {
  self.chatMessage = msg;
  
  self.msgLabel.text = msg.message;
  CGSize size = [msg.message sizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(self.msgLabel.frame.size.width, 999)];
  
  self.levelLabel.text = [Globals commafyNumber:msg.sender.level];
  self.timeLabel.text = [Globals stringForTimeSinceNow:msg.date shortened:NO];
  
  if (msg.sender.minUserProto.clan.hasClanUuid) {
    [self.clanButton setTitle:msg.sender.minUserProto.clan.name forState:UIControlStateNormal];
    [Globals adjustView:self.clanButton.superview withLabel:self.clanButton.titleLabel forXAnchor:1.f];
    self.clanButton.superview.hidden = NO;
  } else {
    self.clanButton.superview.hidden = YES;
  }
  
  NSString *buttonText = msg.sender.minUserProto.name;
  
  if (msg.isAdmin) {
    [self.nameButton setTitleColor:[Globals redColor] forState:UIControlStateNormal];
  } else {
    [self.nameButton setTitleColor:[Globals goldColor] forState:UIControlStateNormal];
  }
  
  [self.nameButton setTitle:buttonText forState:UIControlStateNormal];
  CGSize buttonSize = [buttonText sizeWithFont:self.nameButton.titleLabel.font constrainedToSize:CGSizeMake(buttonInitialWidth, 999) lineBreakMode:self.nameButton.titleLabel.lineBreakMode];
  
  CGRect r = self.nameButton.frame;
  r.size.width = buttonSize.width+5.f;
  self.nameButton.frame = r;
  
  CGRect frame = self.msgLabel.frame;
  frame.size.height = size.height+1.f;
  self.msgLabel.frame = frame;
}

@end

@implementation PrivateChatListCell

- (void) updateForPrivateChat:(PrivateChatPostProto *)pcpp {
  self.privateChat = pcpp;
  
  self.msgLabel.text = pcpp.content;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[NSDate dateWithTimeIntervalSince1970:pcpp.timeOfPost/1000.] shortened:NO];
  self.nameLabel.text = pcpp.poster.minUserProto.name;
  self.unreadIcon.hidden = ![pcpp isUnread];
}

@end