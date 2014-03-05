//
//  ClanRaidViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClanRaidDetailsViewController.h"
#import "ClanRaidLeaderboardViewController.h"
#import "Protocols.pb.h"
#import "GenViewController.h"

@interface ClanRaidViewController : GenViewController

@property (nonatomic, retain) ClanRaidDetailsViewController *detailsViewController;
@property (nonatomic, retain) ClanRaidLeaderboardViewController *leaderboardViewController;

@property (nonatomic, retain) IBOutlet FlipTabBar *menuTopBar;

@property (nonatomic, retain) PersistentClanEventProto *clanEvent;

@property (nonatomic, retain) NSArray *clanMembers;

- (id) initWithClanEvent:(PersistentClanEventProto *)clanEvent membersList:(NSArray *)membersList canStartRaidStage:(BOOL)canStartRaidStage;

@end
