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
- (void) cardClicked:(MyCroniesCardCell *)cell;
- (void) infoClicked:(MyCroniesCardCell *)cell;
- (void) speedupCombineClicked:(MyCroniesCardCell *)cell;
- (void) buySlotsClicked:(MyCroniesCardCell *)cell;

@end

@interface MyCroniesCardCell : UIView <MonsterCardViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UIImageView *onTeamIcon;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *cardContainer;

@property (nonatomic, strong) IBOutlet UIView *genLabelView;
@property (nonatomic, strong) IBOutlet UILabel *genLabel;

@property (nonatomic, strong) IBOutlet UIView *healthBarView;
@property (nonatomic, strong) IBOutlet UILabel *healCostLabel;
@property (nonatomic, strong) IBOutlet ProgressBar *healthBar;

@property (nonatomic, strong) IBOutlet UIView *combineView;
@property (nonatomic, strong) IBOutlet UILabel *combineCostLabel;

@property (nonatomic, strong) IBOutlet UIView *buySlotsView;
@property (nonatomic, strong) IBOutlet UILabel *buySlotsNumLabel;
@property (nonatomic, strong) IBOutlet UILabel *buySlotsCostLabel;

@property (nonatomic, strong) IBOutlet UIView *mainView;

@property (nonatomic, strong) UserMonster *monster;

@property (nonatomic, weak) IBOutlet id<MyCroniesCardDelegate> delegate;

- (void) updateForUserMonster:(UserMonster *)monster;
- (void) updateForEmptySlots:(int)numSlots;
- (void) updateForBuySlots;

- (void) updateForTime;

- (IBAction) speedupCombineClicked:(id)sender;

@end

@interface MyCroniesQueueCell : UIView

@property (nonatomic, strong) IBOutlet UIImageView *bgdIcon;
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
@property (nonatomic, strong) IBOutlet UILabel *instructionLabel;

@property (nonatomic, strong) IBOutlet MyCroniesQueueCell *queueCell;

@property (nonatomic, strong) EasyTableView *queueTable;
@property (nonatomic, strong) NSArray *healingQueue;

@property (nonatomic, weak) IBOutlet id<MyCroniesQueueDelegate> delegate;

- (void) updateTimes;
- (void) reloadTable;

- (IBAction)speedupClicked:(id)sender;

@end
