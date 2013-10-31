//
//  MyCroniesMonsterViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonsterCardView.h"
#import "NibUtils.h"
#import "EasyTableView.h"

@class MyCroniesCardCell;

@protocol MyCroniesCardDelegate <NSObject>

- (void) plusClicked:(MyCroniesCardCell *)cell;
- (void) minusClicked:(MyCroniesCardCell *)cell;
- (void) healClicked:(MyCroniesCardCell *)cell;
- (void) cardClicked:(MyCroniesCardCell *)cell;
- (void) buySlotsClicked:(MyCroniesCardCell *)cell;

@end

@interface MyCroniesCardCell : UIView <MonsterCardViewDelegate> {
  int _overlayMaskStatus;
}

@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *cardContainer;
@property (nonatomic, strong) IBOutlet UIView *healButtonView;
@property (nonatomic, strong) IBOutlet UILabel *healButtonLabel;

@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UILabel *overlayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *overlayMask;

@property (nonatomic, strong) IBOutlet UIView *buySlotsView;
@property (nonatomic, strong) IBOutlet UILabel *buySlotsNumLabel;
@property (nonatomic, strong) IBOutlet UILabel *buySlotsCostLabel;

@property (nonatomic, strong) IBOutlet UIView *mainView;

@property (nonatomic, strong) UserMonster *monster;

@property (nonatomic, weak) id<MyCroniesCardDelegate> delegate;

- (void) updateForUserMonster:(UserMonster *)monster isOnMyTeam:(BOOL)isOnMyTeam;
- (void) updateForNoMonsterIsOnMyTeam:(BOOL)isOnMyTeam;
- (void) updateForBuySlots;

@end

@interface MyCroniesQueueCell : UIView

@property (nonatomic, strong) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, strong) IBOutlet UIView *timerView;
@property (nonatomic, strong) IBOutlet ProgressBar *healthBar;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) UserMonsterHealingItem *healingItem;

- (void) updateForHealingItem:(UserMonsterHealingItem *)item;
- (void) updateForTime;

@end

@protocol MyCroniesQueueDelegate <NSObject>

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell;
- (void) speedupButtonClicked;

@end

@interface MyCroniesQueueView : UIView <EasyTableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, strong) IBOutlet MyCroniesQueueCell *queueCell;

@property (nonatomic, strong) EasyTableView *queueTable;

@property (nonatomic, weak) IBOutlet id<MyCroniesQueueDelegate> delegate;

- (void) updateTimes;
- (void) reloadTable;

- (IBAction)speedupClicked:(id)sender;

@end

@interface MyCroniesHeaderView : UIView

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIView *leftView1;
@property (nonatomic, strong) IBOutlet UIView *leftView2;
@property (nonatomic, strong) IBOutlet UIView *rightView1;
@property (nonatomic, strong) IBOutlet UIView *rightView2;

- (void) moveLabelToXPosition:(float)x;

@end
