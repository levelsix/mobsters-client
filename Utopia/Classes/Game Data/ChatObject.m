//
//  ChatObject.m
//  Utopia
//
//  Created by Ashwin on 10/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ChatObject.h"

#import "NibUtils.h"

@implementation ChatMessage

@synthesize message, sender, date, isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p {
  if ((self = [super init])) {
    self.message = p.content;
    self.sender = p.sender.minUserProto;
    self.date = [MSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
    self.isAdmin = p.isAdmin;
  }
  return self;
}

- (UIColor *)textColor {
  return [UIColor whiteColor];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell {
  UIFont *font = chatCell.msgLabel.font;
  CGRect frame = chatCell.msgLabel.frame;
  
  NSString *msg = [self message];
  CGSize size = [msg getSizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+frame.origin.y+14.f;
  return height;
}

@end