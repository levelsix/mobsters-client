//
//  MiniJobsDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "TopBarViewController.h"

@interface MiniJobsDetailsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *hpProgressBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *attackProgressBar;

@property (nonatomic, assign) UserMonster *userMonster;

- (void) updateForUserMonster:(UserMonster *)um requiredHp:(int)reqHp requiredAttack:(int)reqAtk;

@end

@interface MiniJobsMonsterView : UIView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UIButton *minusButton;

@end

@interface MiniJobsInProgressView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *inProgressLabel;

@property (nonatomic, retain) IBOutlet UIView *finishView;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *finishSpinner;
@property (nonatomic, retain) IBOutlet UIView *finishLabelsView;

@property (nonatomic, retain) IBOutlet UIView *completeView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *completeSpinner;
@property (nonatomic, retain) IBOutlet UIView *completeLabelsView;

@end

@protocol MiniJobsDetailsDelegate <NSObject>

- (void) beginMiniJob:(UserMiniJob *)miniJob withUserMonsters:(NSArray *)userMonsters;
- (void) activeMiniJobSpedUp:(UserMiniJob *)miniJob;
- (void) activeMiniJobCompleted:(UserMiniJob *)miniJob;

@end

typedef enum {
  MiniJobsSortOrderHpAsc = 1,
  MiniJobsSortOrderHpDesc,
  MiniJobsSortOrderAtkAsc,
  MiniJobsSortOrderAtkDesc,
} MiniJobsSortOrder;

@interface MiniJobsDetailsViewController : PopupSubViewController <UITableViewDataSource, UITableViewDelegate> {
  UIButton *_clickedButton;
}

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIImageView *headerArrow;
@property (nonatomic, retain) IBOutlet UITableView *monstersTable;
@property (nonatomic, retain) IBOutlet UIView *tapCharView;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *engageSpinner;
@property (nonatomic, retain) IBOutlet UIView *engageLabelsView;
@property (nonatomic, retain) IBOutlet UILabel *engageLabel;
@property (nonatomic, retain) IBOutlet UIButton *engageButton;
@property (nonatomic, retain) IBOutlet UIImageView *engageArrow;

@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *hpProgressBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *attackProgressBar;

@property (nonatomic, retain) IBOutletCollection(MiniJobsMonsterView) NSMutableArray *monsterViews;
@property (nonatomic, retain) IBOutlet MiniMonsterView *animMonsterView;

@property (nonatomic, retain) IBOutlet MiniJobsInProgressView *inProgressView;

@property (nonatomic, retain) IBOutlet MiniJobsDetailsCell *detailsCell;

@property (nonatomic, retain) IBOutlet UILabel *availableMonstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *tapMobsterLabel;

@property (nonatomic, retain) NSMutableArray *monsterArray;
@property (nonatomic, retain) NSMutableArray *pickedMonsters;
@property (nonatomic, assign) MiniJobsSortOrder sortOrder;

@property (nonatomic, assign) id<MiniJobsDetailsDelegate> delegate;

@property (nonatomic, retain) UserMiniJob *userMiniJob;
@property (nonatomic, retain) UserMiniJob *activeMiniJob;

@property (nonatomic, retain) NSTimer *updateTimer;

- (id) initWithMiniJob:(UserMiniJob *)miniJob;

- (void) beginEngageSpinning;
- (void) beginFinishSpinning;
- (void) beginCollectSpinning;
- (void) stopSpinning;

@end
