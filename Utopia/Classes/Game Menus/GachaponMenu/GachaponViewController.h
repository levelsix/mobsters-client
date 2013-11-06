//
//  GachaponViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/31/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "TimingFunctionTableView.h"

@interface GachaponItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end

@interface GachaponViewController : GenViewController <UITableViewDataSource, UITableViewDelegate> {
  BOOL _isSpinning;
}

@property (nonatomic, retain) NSArray *items;

@property (nonatomic, retain) IBOutlet TimingFunctionTableView *gachaTable;
@property (nonatomic, retain) IBOutlet UIImageView *machineIcon;
@property (nonatomic, retain) IBOutlet UIImageView *spinner;

@property (nonatomic, retain) IBOutlet GachaponItemCell *itemCell;

@end
