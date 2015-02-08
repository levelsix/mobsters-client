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

#import "UnreadNotifications.h"

#import "ChatCell.h"
#import "GameViewController.h"

@implementation ClanMemberTeamDonationProto (ChatObject)

- (UserMonster *) donatedMonster {
  return self.donationsList.count ? [UserMonster userMonsterWithMonsterSnapshotProto:self.donationsList.firstObject] : nil;
}

- (MSDate *) fulfilledDate
{
  UserMonsterSnapshotProto *snap = [self.donationsList firstObject];
  if (snap) {
    return [MSDate dateWithTimeIntervalSince1970:snap.timeOfCreation/1000.];
  }
  return nil;
}

#pragma mark - ChatObject protocol

- (MinimumUserProto *) sender {
  return self.solicitor;
}

- (MSDate *) date {
  return [MSDate dateWithTimeIntervalSince1970:self.timeOfSolicitation/1000.];
}

- (NSString *) message {
  return [NSString stringWithFormat:@"Team Donate: %@", self.msg];
}

- (UIColor *) bottomViewTextColor {
  return [UIColor colorWithHexString:@"ffe400"];
}

- (PrivateChatPostProto *) clanChatPrivateChat {
  // This is an easy way to do read msgs for all clan chats (use an id that is shared amongst everything)
  MinimumUserProto *mup = [[[MinimumUserProto builder] setUserUuid:CLAN_CHAT_PRIVATE_CHAT_USER_ID] build];
  MinimumUserProtoWithLevel *mupl = [[[MinimumUserProtoWithLevel builder] setMinUserProto:mup] build];
  PrivateChatPostProto *pcpp = [[[[PrivateChatPostProto builder]
                                  setRecipient:mupl]
                                 setTimeOfPost:self.timeOfSolicitation]
                                build];
  return pcpp;
}

- (BOOL) isRead {
  GameState *gs = [GameState sharedGameState];
  return self.isFulfilled || [self.solicitor.userUuid isEqualToString:gs.userUuid] || [[self clanChatPrivateChat] isRead];
}

- (void) markAsRead {
  // Do nothing
  return [[self clanChatPrivateChat] markAsRead];
}

- (void) updateInChatCell:(ChatCell *)chatCell showsClanTag:(BOOL)showsClanTag {
  
  NSString *nibName = @"ChatTeamDonateView";
  ChatTeamDonateView *v = [chatCell dequeueChatSubview:nibName];
  
  if (!v) {
    v = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
  }
  
  [v updateForTeamDonation:self];
  
  [chatCell updateForMessage:self.message sender:self.sender date:self.date showsClanTag:showsClanTag allowHighlight:YES chatSubview:v identifier:nibName];
}

- (CGFloat) heightWithTestChatCell:(ChatCell *)chatCell {
  UIFont *font = chatCell.msgLabel.font;
  CGRect frame = chatCell.msgLabel.frame;
  
  [self updateInChatCell:chatCell showsClanTag:YES];
  
  NSString *message = [self message];
  CGSize size = [message getSizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+frame.origin.y+14.f;
  height = MAX(height, CGRectGetMaxY(chatCell.currentChatSubview.frame)+14.f);
  
  return height;
}

- (IBAction) donateClicked:(id)sender {
  // Kinda hacky.. Get the chat view controller since there can only be one and tell it to display monster select for self
  GameViewController *gvc = [GameViewController baseController];
  ChatViewController *cvc = gvc.chatViewController;
  
  if (cvc) {
    [cvc displayMonsterSelect:self sender:sender];
  }
}

@end

@implementation ClanTeamDonateUtil

- (void) addClanTeamDonations:(NSArray *)teamDonations {
  if (!self.teamDonations) {
    self.teamDonations = [NSMutableArray array];
  }
  
  BOOL scheduleDelayedNotification = NO;
  
  GameState *gs = [GameState sharedGameState];
  for (ClanMemberTeamDonationProto *td in teamDonations) {
    // Remove from current list
    ClanMemberTeamDonationProto *old;
    for (ClanMemberTeamDonationProto *t in self.teamDonations) {
      if ([t.solicitor.userUuid isEqualToString:td.solicitor.userUuid]) {
        old = t;
      }
    }
    [self.teamDonations removeObject:old];
    
    if (old && !old.isFulfilled && td.isFulfilled) {
      scheduleDelayedNotification = YES;
      
      if ([td.solicitor.userUuid isEqualToString:gs.userUuid]) {
        UserMonsterSnapshotProto *snap = [td.donationsList firstObject];
        MonsterProto *mp = [gs monsterWithId:snap.monsterId];
        [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ just donated a Level %d %@ to your team!", snap.user.name, snap.currentLvl, mp.displayName]];
      }
    }
    
    [self.teamDonations addObject:td];
    
    if ([td.solicitor.userUuid isEqualToString:gs.userUuid]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_CLAN_TEAM_DONATION_CHANGED_NOTIFICATION object:nil];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION object:nil];
  
  if (scheduleDelayedNotification) {
    [self performSelector:@selector(postNotification) withObject:nil afterDelay:6.f];
  }
}

- (void) removeClanTeamDonationWithUuids:(NSArray *)donationUuids {
  GameState *gs = [GameState sharedGameState];
  for (ClanMemberTeamDonationProto *d in self.teamDonations.copy) {
    if ([donationUuids containsObject:d.donationUuid]) {
      [self.teamDonations removeObject:d];
      
      if ([d.solicitor.userUuid isEqualToString:gs.userUuid]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MY_CLAN_TEAM_DONATION_CHANGED_NOTIFICATION object:nil];
      }
    }
  }
}

- (void) postNotification {
  [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION object:nil];
}

- (ClanMemberTeamDonationProto *) myTeamDonation {
  GameState *gs = [GameState sharedGameState];
  for (ClanMemberTeamDonationProto *td in self.teamDonations) {
    if ([td.solicitor.userUuid isEqualToString:gs.userUuid]) {
      return td;
    }
  }
  return nil;
}

@end
