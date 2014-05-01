//
//  MiniJobsListViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniJobsListCell : UITableViewCell

@end

@interface MiniJobsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *returnsInLabel;

@property (nonatomic, retain) IBOutlet MiniJobsListCell *listCell;

@end
