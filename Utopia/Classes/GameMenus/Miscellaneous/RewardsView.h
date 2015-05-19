//
//  RewardsView.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@class THLabel;

@interface RewardView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *rewardIcon;
@property (nonatomic, strong) IBOutlet UILabel *rewardLabel;

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet THLabel *iconLabel;
@property (nonatomic, strong) IBOutlet UILabel *itemQuantityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *itemGameActionTypeIcon;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *itemView;

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
