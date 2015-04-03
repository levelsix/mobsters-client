//
//  TeamViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "NibUtils.h"
#import "ListCollectionView.h"

#import "DonateMsgViewController.h"

#import "SpeedupItemsFiller.h"

@protocol TeamSlotDelegate <NSObject>

- (void) teamSlotMinusClicked:(id)sender;
- (void) teamSlotMonsterClicked:(id)sender;
- (void) teamSlotRightSideClicked:(id)sender;

@end

@interface TeamSlotView : EmbeddedNibView {
  CGSize _initSize;
}

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;
@property (nonatomic, retain) IBOutlet UIButton *toonDetailsView;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet UILabel *tapToAddLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unavailableBorder;

@property (nonatomic, retain) IBOutlet UIButton *minusButton;

@property (nonatomic, retain) IBOutlet UIView *emptyView;
@property (nonatomic, retain) IBOutlet UIView *notEmptyView;

@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIView *rightView;

@property (nonatomic, assign) IBOutlet id<TeamSlotDelegate> delegate;

@end

@interface TeamViewController : PopupSubViewController <ListCollectionDelegate, TeamSlotDelegate, SpeedupItemsFillerDelegate, UIScrollViewDelegate, DonateMsgDelegate> {
  UserMonster *_combineMonster;
  UIImageView* _combineMonsterImageView;
  
  int _clickedSlot;
  int _openedSlot;
  BOOL _showsClanDonateToonView;
  BOOL _showRequestToonArrow;
  
  BOOL _useGemsForDonate;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet TeamSlotView *teamCell;

@property (nonatomic, strong) IBOutlet UILabel *unavailableLabel;

@property (nonatomic, retain) IBOutlet UIView *clanRequestView;
@property (nonatomic, retain) IBOutlet UIView *requestButtonView;
@property (nonatomic, retain) IBOutlet UIView *speedupButtonView;
@property (nonatomic, retain) IBOutlet TeamSlotView *clanRequestSlotView;
@property (nonatomic, retain) IBOutlet UILabel *donateTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *donateCostLabel;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *teamSlotViews;

@property (nonatomic, retain) NSArray *userMonsters;

@property (nonatomic, retain) DonateMsgViewController *donateMsgViewController;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;
- (id) initShowArrowOnRequestToon:(BOOL) showArrow;
- (UserMonster *) monsterForSlot:(NSInteger)slot;

- (void) speedupClicked:(UserMonster *)um invokingView:(UIView*)sender indexPath:(NSIndexPath*)indexPath;

@end
