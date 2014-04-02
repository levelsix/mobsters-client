//
//  ClanViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "Globals.h"
#import "ClanBrowseViewController.h"
#import "ClanInfoViewController.h"
#import "ClanCreateViewController.h"
#import "ClanRaidListViewController.h"

@interface ClanViewController : GenViewController {
  UIViewController *_controller1;
  UIViewController *_controller2;
  
  BOOL _shouldLoadFirstController;
}

@property (nonatomic, retain) ClanBrowseViewController *clanBrowseViewController;
@property (nonatomic, retain) ClanCreateViewController *clanCreateViewController;
@property (nonatomic, retain) ClanInfoViewController *clanInfoViewController;
@property (nonatomic, retain) ClanRaidListViewController *clanRaidViewController;

@property (nonatomic, retain) IBOutlet FlipTabBar *menuTopBar;

@property (nonatomic, retain) NSArray *myClanMembersList;
@property (nonatomic, assign) int canStartRaidStage;

@end
