//
//  MiniJobsCompleteViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NibUtils.h"
#import "RewardsView.h"

@interface MiniJobsCompleteMonsterView : UIView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;

@end

@protocol MiniJobsCompleteDelegate <NSObject>

- (void) activeMiniJobCompleted:(UserMiniJob *)miniJob;

@end

@interface MiniJobsCompleteViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *rewardsBox;
@property (nonatomic, strong) IBOutletCollection(MiniJobsCompleteMonsterView) NSArray *monsterViews;

@property (nonatomic, strong) IBOutlet RewardView *rewardView;

@property (nonatomic, weak) id<MiniJobsCompleteDelegate> delegate;

@property (nonatomic, retain) UserMiniJob *miniJob;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *collectLabel;

- (void) loadForMiniJob:(UserMiniJob *)miniJob;
- (void) beginSpinning;
- (void) stopSpinning;

@end
