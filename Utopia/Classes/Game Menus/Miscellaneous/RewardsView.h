//
//  RewardsView.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface RewardView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *rewardIcon;
@property (nonatomic, strong) IBOutlet UILabel *rewardLabel;

- (void) loadForReward:(Reward *)reward;

@end

@interface RewardsView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *innerView;

@property (nonatomic, strong) IBOutlet RewardView *rewardView;

- (void) updateForRewards:(NSArray *)rewards;

@end

@interface RewardsViewContainer : UIView

@property (nonatomic, strong) RewardsView *rewardsView;

@end
