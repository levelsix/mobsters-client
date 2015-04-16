//
//  MiniEventTierPrizeCell.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RewardProto;

@interface MiniEventTierPrizeCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView* containerView;
@property (nonatomic, retain) IBOutlet UIImageView* prizeIcon;
@property (nonatomic, retain) IBOutlet UILabel* prizeName;
@property (nonatomic, retain) IBOutlet UILabel* prizeCount;

- (BOOL) updateForReward:(RewardProto*)rewardProto useItemShortName:(BOOL)useItemShortName;

@end
