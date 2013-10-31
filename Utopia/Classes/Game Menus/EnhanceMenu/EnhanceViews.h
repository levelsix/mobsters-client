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

- (void) enhanceClicked:(EnhanceCardCell *)cell;
- (void) cardClicked:(EnhanceCardCell *)cell;

@end

@interface EnhanceCardCell : UIView <MonsterCardViewDelegate> {
  int _overlayMaskStatus;
}

@property (nonatomic, strong) IBOutlet MonsterCardContainerView *cardContainer;
@property (nonatomic, strong) IBOutlet UIView *cashButtonView;
@property (nonatomic, strong) IBOutlet UILabel *cashButtonLabel;

@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UILabel *overlayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *overlayMask;

@property (nonatomic, strong) UserMonster *monster;

@property (nonatomic, weak) IBOutlet id<EnhanceCardDelegate> delegate;

- (void) updateForUserMonster:(UserMonster *)monster withBaseMonster:(EnhancementItem *)base;

@end

@interface EnhanceQueueCell : UIView

@property (nonatomic, strong) IBOutlet UIImageView *monsterIcon;
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

@property (nonatomic, strong) IBOutlet EnhanceQueueCell *queueCell;

@property (nonatomic, strong) EasyTableView *queueTable;

@property (nonatomic, weak) IBOutlet id<EnhanceQueueDelegate> delegate;

- (void) updateTimes;
- (void) reloadTable;

- (IBAction)speedupClicked:(id)sender;

@end

@interface EnhanceBaseView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, strong) IBOutlet UIView *starView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet ProgressBar *orangeBar;
@property (nonatomic, strong) IBOutlet ProgressBar *yellowBar;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *noMonsterView;

- (void) updateForUserEnhancement:(UserEnhancement *)ue;

@end
