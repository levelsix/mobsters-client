//
//  MiniJobsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MiniJobsListViewController.h"
#import "MiniJobsDetailsViewController.h"
#import "MiniJobsCompleteViewController.h"
#import "NibUtils.h"

@interface MiniJobsViewController : UIViewController <MiniJobsDetailsDelegate, MiniJobsCompleteDelegate>  {
  MiniJobsListCell *_selectedCell;
  BOOL _isBeginningJob;
  
  BOOL _beganSomeJob;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) MiniJobsListViewController *listViewController;
@property (nonatomic, retain) MiniJobsDetailsViewController *detailsViewController;
@property (nonatomic, retain) MiniJobsCompleteViewController *completeViewController;

- (IBAction)backClicked:(id)sender;

@end
