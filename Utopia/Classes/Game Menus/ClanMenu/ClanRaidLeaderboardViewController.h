//
//  ClanRaidLeaderboardViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanInfoViewController.h"

@interface ClanRaidLeaderboardViewController : ClanInfoViewController

- (id) initWithMembersList:(NSArray *)members;

- (void) createMembersListFromClanMembers:(NSArray *)originalClanMembers;

@end
