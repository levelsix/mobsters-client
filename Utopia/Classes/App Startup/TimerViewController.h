//
//  TimerViewController.h
//  Utopia
//
//  Created by Ashwin on 10/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"

@interface TimerCell : UIView

@property (weak, nonatomic) IBOutlet SplitImageProgressBar *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *gemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@interface TimerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContainer;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIImageView *bottomBgdView;
@property (weak, nonatomic) IBOutlet UIImageView *openArrow;
@property (weak, nonatomic) IBOutlet NiceFontLabel9 *openLabel;
@property (weak, nonatomic) IBOutlet UIView *openButtonView;

@property (weak, nonatomic) IBOutlet UILabel *noTimersLabel;

@property (strong, nonatomic) IBOutlet TimerCell *timerCell;

@property (strong, nonatomic) NSArray *timerActionsArray;
@property (strong, nonatomic) NSArray *timerCells;

@property (strong, nonatomic) NSTimer *updateTimer;

@property (nonatomic, assign) BOOL isOpen;

- (void) reloadData;
- (void) reloadDataAnimated;

@end
