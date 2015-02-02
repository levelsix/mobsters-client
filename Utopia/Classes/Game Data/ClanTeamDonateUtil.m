//
//  ClanTeamDonateUtil.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ClanTeamDonateUtil.h"

#import "GameState.h"
#import "Globals.h"

@implementation ClanMemberTeamDonationProto (ChatObject)


#pragma mark - ChatObject protocol

- (MinimumUserProto *) sender {
  return self.userUuid;
}

- (MSDate *) date {
  return [MSDate dateWithTimeIntervalSince1970:self.timeOfSolicitation/1000.];
}

- (NSString *) message {
  return self.msg;
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (BOOL) isRead {
  GameState *gs = [GameState sharedGameState];
  return ![self canHelpForUserUuid:gs.userUuid];
}

- (void) markAsRead {
  // Do nothing
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  
  NSString *nibName = @"ChatClanHelpView";
  ChatClanHelpView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForClanHelp:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
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

@implementation ClanTeamDonateUtil

- (void) addClanTeamDonations:(NSArray *)teamDonations {
  if (!self.teamDonations) {
    self.teamDonations = [NSMutableArray array];
  }
  
  GameState *gs = [GameState sharedGameState];
  for (ClanMemberTeamDonationProto *td in teamDonations) {
    // Remove from current list
    ClanMemberTeamDonationProto *old;
    for (ClanMemberTeamDonationProto *t in self.teamDonations) {
      if ([t.userUuid isEqualToString:td.userUuid]) {
        old = t;
      }
    }
    [self.teamDonations removeObject:old];
    
    [self.teamDonations addObject:td];
    
    if ([td.userUuid isEqualToString:gs.userUuid]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_CLAN_TEAM_DONATION_CHANGED_NOTIFICATION object:nil];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION object:nil];
}

- (ClanMemberTeamDonationProto *) myTeamDonation {
  GameState *gs = [GameState sharedGameState];
  for (ClanMemberTeamDonationProto *td in self.teamDonations) {
    if ([td.userUuid isEqualToString:gs.userUuid]) {
      return td;
    }
  }
  return nil;
}

@end
