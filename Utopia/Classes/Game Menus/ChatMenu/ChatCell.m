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
  buttonInitialWidth = self.nameButton.frame.size.width;
}

- (void) updateForChat:(ChatMessage *)msg {
  GameState *gs = [GameState sharedGameState];
  self.chatMessage = msg;
  
  self.msgLabel.text = msg.message;
  
  self.levelLabel.text = [Globals commafyNumber:msg.sender.level];
  self.timeLabel.text = [Globals stringForTimeSinceNow:msg.date shortened:NO];
  
  if (msg.sender.minUserProto.clan.clanId) {
    [self.clanButton setTitle:msg.sender.minUserProto.clan.name forState:UIControlStateNormal];
    [Globals adjustViewForCentering:self.clanButton.superview withLabel:self.clanButton.titleLabel];
    
    ClanIconProto *icon = [gs clanIconWithId:msg.sender.minUserProto.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.shieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.clanButton.superview.hidden = NO;
  } else {
    self.clanButton.superview.hidden = YES;
  }
  
  NSString *buttonText = msg.sender.minUserProto.name;
  
//  if (msg.isAdmin) {
//    [self.nameButton setTitleColor:[Globals redColor] forState:UIControlStateNormal];
//  } else {
//    [self.nameButton setTitleColor:[Globals goldColor] forState:UIControlStateNormal];
//  }
  
  [self.nameButton setTitle:buttonText forState:UIControlStateNormal];
  CGSize buttonSize = [buttonText sizeWithFont:self.nameButton.titleLabel.font constrainedToSize:CGSizeMake(buttonInitialWidth, 999) lineBreakMode:self.nameButton.titleLabel.lineBreakMode];
  
  CGRect r = self.nameButton.frame;
  r.size.width = buttonSize.width+7.f;
  self.nameButton.frame = r;
  
  r = self.clanButton.superview.frame;
  r.origin.x = CGRectGetMaxX(self.nameButton.frame);
  self.clanButton.superview.frame = r;
  
  CGSize size = [msg.message sizeWithFont:self.msgLabel.font constrainedToSize:CGSizeMake(self.msgLabel.frame.size.width, 999)];
  CGRect frame = self.msgLabel.frame;
  frame.size.height = size.height+1.f;
  self.msgLabel.frame = frame;
  
//  int clanWidth = msg.sender.minUserProto.clan.clanId ? self.clanButton.superview.frame.size.width : 0;
//  size.width = MAX(size.width+33.f, buttonSize.width+clanWidth+self.timeLabel.frame.size.width+14.f);
//  frame = self.mainView.frame;
//  frame.size.width = size.width;
//  self.mainView.frame = frame;
//  
//  if (msg.sender.minUserProto.userId == gs.userId) {
//    self.transform = CGAffineTransformMakeScale(-1, 1);
//    self.nameButton.transform = CGAffineTransformMakeScale(-1, 1);
//    self.msgLabel.transform = CGAffineTransformMakeScale(-1, 1);
//    self.timeLabel.transform = CGAffineTransformMakeScale(-1, 1);
//    self.clanButton.superview.transform = CGAffineTransformMakeScale(-1, 1);
//    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    self.msgLabel.textAlignment = NSTextAlignmentRight;
//    self.timeLabel.textAlignment = NSTextAlignmentLeft;
//  } else {
//    self.transform = CGAffineTransformIdentity;
//    self.nameButton.transform = CGAffineTransformIdentity;
//    self.msgLabel.transform = CGAffineTransformIdentity;
//    self.timeLabel.transform = CGAffineTransformIdentity;
//    self.clanButton.superview.transform = CGAffineTransformIdentity;
//    self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    self.msgLabel.textAlignment = NSTextAlignmentLeft;
//    self.timeLabel.textAlignment = NSTextAlignmentRight;
//  }
}

@end

@implementation PrivateChatListCell

- (void) updateForPrivateChat:(PrivateChatPostProto *)pcpp {
  self.privateChat = pcpp;
  
  self.msgLabel.text = pcpp.content;
  self.timeLabel.text = [Globals stringForTimeSinceNow:[MSDate dateWithTimeIntervalSince1970:pcpp.timeOfPost/1000.] shortened:NO];
  self.nameLabel.text = pcpp.otherUserName;
  self.unreadIcon.hidden = ![pcpp isUnread];
}

@end