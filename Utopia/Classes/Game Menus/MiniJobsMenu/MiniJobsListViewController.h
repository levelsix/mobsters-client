//
//  MiniJobsListViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "RewardsView.h"
#import "PopupSubViewController.h"
#import "MiniJobsDetailsViewController.h"
#import "MiniJobsCompleteViewController.h"
#import "SpeedupItemsFiller.h"

@interface MiniJobsListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *jobQualityTag;
@property (nonatomic, retain) IBOutlet UIView *rewardsView;

@property (nonatomic, retain) IBOutlet UIView *rewardsBgd;
@property (nonatomic, strong) IBOutlet RewardView *rewardView;

@property (nonatomic, retain) IBOutlet UIView *finishView;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *finishSpinner;
@property (nonatomic, retain) IBOutlet UIView *finishLabelsView;

@property (nonatomic, retain) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, retain) IBOutlet UIView *getHelpView;

@property (nonatomic, retain) IBOutlet UIView *completeView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *completeSpinner;
@property (nonatomic, retain) IBOutlet UIView *completeLabelsView;

@property (nonatomic, retain) IBOutlet UIImageView *arrowIcon;

@property (nonatomic, retain) UserMiniJob *userMiniJob;

- (void) spinCollect;
- (void) spinFinish;
- (void) stopSpinners;

- (void) updateForMiniJob:(UserMiniJob *)umj;

@end

@interface MiniJobsListViewController : PopupSubViewController <UITableViewDelegate, UITableViewDataSource, MiniJobsDetailsDelegate, MiniJobsCompleteDelegate, SpeedupItemsFillerDelegate> {
  MiniJobsListCell *_selectedCell;
  BOOL _itemSelectClosedProgrammatically;
  BOOL _isBeginningJob;
  
  BOOL _beganSomeJob;
}

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *returnsInLabel;
@property (nonatomic, retain) IBOutlet UITableView *listTable;
@property (nonatomic, retain) IBOutlet UILabel *spawnTimeLabel;

@property (nonatomic, retain) IBOutlet UILabel *noMoreJobsLabel;

@property (nonatomic, retain) IBOutlet MiniJobsListCell *listCell;

@property (nonatomic, retain) NSMutableArray *miniJobsList;

@property (nonatomic, retain) NSTimer *updateTimer;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;

@property (nonatomic, retain) MiniJobsDetailsViewController *detailsViewController;
@property (nonatomic, retain) MiniJobsCompleteViewController *completeViewController;

- (void) reloadTableAnimated:(BOOL)animated;

- (void) miniJobsListCellClicked:(MiniJobsListCell *)listCell;
- (void) miniJobsListCollectClicked:(MiniJobsListCell *)listCell;
- (void) miniJobsListFinishClicked:(MiniJobsListCell *)listCell invokingView:(UIView*)sender popupDirection:(ViewAnchoringDirection)direction;
- (void) miniJobsListHelpClicked:(MiniJobsListCell *)listCell;

@end
