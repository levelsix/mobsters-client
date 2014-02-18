//
//  ClanRaidViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"

@interface ClanRaidViewController : GenViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *nibCell;

- (IBAction)raidSelected:(id)sender;

@end
