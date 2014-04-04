//
//  ClanRaidLeaderboardViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidLeaderboardViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "PersistentEventProto+Time.h"

@implementation ClanRaidLeaderboardViewController

- (id) initWithMembersList:(NSArray *)members {
  if ((self = [super initWithNibName:@"ClanInfoViewController" bundle:nil])) {
    if (members) {
      [self createMembersListFromClanMembers:members];
    }
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.infoTable.tableHeaderView = self.headerButtonsView;
  self.loadingMembersView.center = ccp(self.infoTable.frame.size.width/2, self.infoTable.frame.size.height/2+self.headerButtonsView.frame.size.height/2);
  
  [self.headerButtons[2] setTitle:@"Raid Team" forState:UIControlStateNormal];
  [self.headerButtons[3] setTitle:@"Current Raid" forState:UIControlStateNormal];
}

- (void) createMembersListFromClanMembers:(NSArray *)originalClanMembers {
  GameState *gs = [GameState sharedGameState];
  PersistentClanEventClanInfoProto *clanInfo = gs.curClanRaidInfo;
  NSArray *userInfos = gs.curClanRaidUserInfos;
  
  NSMutableArray *newMembersList = [NSMutableArray array];
  NSMutableArray *curTeamsList = [NSMutableArray array];
  for (PersistentClanEventUserInfoProto *userInfo in userInfos) {
    // Grab the original member
    MinimumUserProtoForClans *mupc = nil;
    for (MinimumUserProtoForClans *m in originalClanMembers) {
      if (m.minUserProtoWithLevel.minUserProto.userId == userInfo.userId) {
        mupc = m;
        break;
      }
    }
    
    // Only add to the list if we find a clan guy
    if (mupc) {
      MinimumUserProtoForClans_Builder *bldr = [MinimumUserProtoForClans builderWithPrototype:mupc];
      bldr.raidContribution = [clanInfo raidContributionForUserInfo:userInfo];
      [newMembersList addObject:bldr.build];
      
      [curTeamsList addObject:userInfo.userMonsters];
    }
  }
  
  RetrieveClanInfoResponseProto_Builder *info = [RetrieveClanInfoResponseProto builder];
  [info addAllMembers:newMembersList];
  [info addAllMonsterTeams:curTeamsList];
  
  FullEvent *fe = [[FullEvent alloc] init];
  fe.event = [info build];
  [self handleRetrieveClanInfoResponseProto:fe];
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e {
  [super handleRetrieveClanInfoResponseProto:e];
  self.myUser = nil;
}

@end
