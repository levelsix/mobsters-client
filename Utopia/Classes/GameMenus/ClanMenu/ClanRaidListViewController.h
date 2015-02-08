//
//  ClanRaidViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "ClanRaidViews.h"
#import "ClanRaidViewController.h"

@interface ClanRaidListViewController : GenViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *raidsTable;

@property (nonatomic, retain) IBOutlet ClanRaidListCell *nibCell;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSArray *activeEvents;
@property (nonatomic, retain) NSArray *inactiveEvents;

@property (nonatomic, retain) ClanRaidViewController *raidViewController;

- (IBAction)raidSelected:(id)sender;

@end
