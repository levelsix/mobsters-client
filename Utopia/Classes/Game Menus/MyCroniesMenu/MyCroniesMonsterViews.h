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

@interface MyCroniesTabBar : ButtonTabBar

@property (nonatomic, retain) UIButton *selectedView;

@end

@class MyCroniesCardCell;

@protocol MyCroniesCardDelegate <NSObject>

- (void) plusClicked:(MyCroniesCardCell *)cell;
- (void) cardClicked:(MyCroniesCardCell *)cell;
- (void) infoClicked:(MyCroniesCardCell *)cell;
- (void) speedupCombineClicked:(MyCroniesCardCell *)cell;

@end

@interface MyCroniesCardCell : UIView <MonsterCardViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UIImageView *onTeamIcon;
@property (nonatomic, strong) IBOutlet MonsterCardContainerView *cardContainer;

@property (nonatomic, strong) IBOutlet UIView *genLabelView;
@property (nonatomic, strong) IBOutlet UILabel *genLabel;

@property (nonatomic, strong) IBOutlet UIView *healthBarView;
@property (nonatomic, strong) IBOutlet UILabel *healCostLabel;
@property (nonatomic, strong) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, strong) IBOutlet UILabel *healthLabel;

@property (nonatomic, strong) IBOutlet UIView *combineView;
@property (nonatomic, strong) IBOutlet UILabel *combineCostLabel;

@property (nonatomic, strong) IBOutlet UIView *mainView;

@property (nonatomic, strong) UserMonster *monster;

@property (nonatomic, weak) IBOutlet id<MyCroniesCardDelegate> delegate;

- (void) updateForUserMonster:(UserMonster *)monster showSellCost:(BOOL)showSellCost;
- (void) updateForEmptySlots:(NSInteger)numSlots;

- (void) updateForTime;

- (IBAction) speedupCombineClicked:(id)sender;

@end

@interface MyCroniesQueueCell : UIView

@property (nonatomic, strong) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, strong) IBOutlet UIView *timerView;
@property (nonatomic, strong) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) UserMonsterHealingItem *healingItem;
@property (nonatomic, strong) UserMonster *userMonster;

- (void) updateForHealingItem:(UserMonsterHealingItem *)item userMonster:(UserMonster *)um;
- (void) updateForSellMonster:(UserMonster *)um;
- (void) updateForTime;


@end

@protocol MyCroniesQueueDelegate <NSObject>

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell;
- (void) speedupButtonClicked;
- (void) sellButtonClicked;

@end

@interface MyCroniesQueueView : UIView <EasyTableViewDelegate> {
  int _numHospitals;
  
  BOOL _isInSellMode;
}

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;

@property (nonatomic, strong) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *instructionLabel;
@property (nonatomic, strong) IBOutlet UIButton *speedupButton;

@property (nonatomic, strong) IBOutlet UILabel *sellCostLabel;

@property (nonatomic, strong) IBOutlet UIView *healButtonView;
@property (nonatomic, strong) IBOutlet UIView *sellButtonView;

@property (nonatomic, strong) IBOutlet MyCroniesQueueCell *queueCell;

@property (nonatomic, strong) EasyTableView *queueTable;
@property (nonatomic, strong) NSArray *healingQueue;
@property (nonatomic, strong) NSArray *userMonsters;
@property (nonatomic, strong) NSArray *sellQueue;

@property (nonatomic, weak) IBOutlet id<MyCroniesQueueDelegate> delegate;

- (void) reloadTableAnimated:(BOOL)animated healingQueue:(NSArray *)healingQueue userMonster:(NSArray *)userMonsters timeLeft:(int)timeLeft hospitalCount:(int)hospitalCount;
- (void) reloadTableAnimated:(BOOL)animated sellMonsters:(NSArray *)userMonsters;
- (void) updateTimeWithTimeLeft:(int)timeLeft hospitalCount:(int)hospitalCount;

- (IBAction)speedupClicked:(id)sender;

@end
