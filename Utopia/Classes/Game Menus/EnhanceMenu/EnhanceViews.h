//
//  EnhanceViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonsterCardView.h"
#import "NibUtils.h"
#import "EasyTableView.h"

@class EnhanceCardCell;

@protocol EnhanceCardDelegate <NSObject>

- (void) infoClicked:(EnhanceCardCell *)cell;
- (void) cardClicked:(EnhanceCardCell *)cell;

@end

@interface EnhanceCardCell : UIView <MonsterCardViewDelegate>

@property (nonatomic, strong) IBOutlet MonsterCardContainerView *cardContainer;
@property (nonatomic, strong) IBOutlet UIImageView *onTeamIcon;

@property (nonatomic, strong) IBOutlet UIView *feederLabelView;
@property (nonatomic, strong) IBOutlet UILabel *feederLabel;

@property (nonatomic, strong) IBOutlet UIView *enhanceBarView;
@property (nonatomic, strong) IBOutlet UILabel *percentageLabel;
@property (nonatomic, strong) IBOutlet ProgressBar *orangeBar;

@property (nonatomic, strong) UserMonster *monster;

@property (nonatomic, weak) IBOutlet id<EnhanceCardDelegate> delegate;

- (void) updateForUserMonster:(UserMonster *)monster withUserEnhancement:(UserEnhancement *)ue;

@end

@interface EnhanceQueueCell : UIView

@property (nonatomic, strong) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, strong) IBOutlet UIView *timerView;
@property (nonatomic, strong) IBOutlet ProgressBar *progressBar;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) EnhancementItem *enhanceItem;

- (void) updateForEnhanceItem:(EnhancementItem *)item;
- (void) updateForTime;

@end

@protocol EnhanceQueueDelegate <NSObject>

- (void) cellRequestsRemovalFromQueue:(EnhanceQueueCell *)cell;
- (void) speedupButtonClicked;

@end

@interface EnhanceQueueView : UIView <EasyTableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UILabel *speedupCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *instructionLabel;

@property (nonatomic, strong) IBOutlet EnhanceQueueCell *queueCell;

@property (nonatomic, strong) EasyTableView *queueTable;
@property (nonatomic, strong) NSArray *enhancingQueue;

@property (nonatomic, weak) IBOutlet id<EnhanceQueueDelegate> delegate;

- (void) updateTimes;
- (void) reloadTable;

- (IBAction)speedupClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;

@end

@interface EnhanceBaseView : EnhanceCardCell

@property (nonatomic, strong) IBOutlet ProgressBar *yellowBar;

- (void) updateForUserEnhancement:(UserEnhancement *)ue;

@end
