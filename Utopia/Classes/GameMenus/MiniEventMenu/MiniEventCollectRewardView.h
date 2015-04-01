//
//  MiniEventCollectRewardView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniEventCollectRewardView : UIView <UITableViewDataSource>
{
  NSMutableArray* _prizeList;
}

@property (nonatomic, retain) IBOutlet UIImageView* rewardReadyBackground;
@property (nonatomic, retain) IBOutlet UILabel* rewardReadyLabel;
@property (nonatomic, retain) IBOutlet UITableView* tierPrizeList;

- (void) updateForTier:(int)tier prizeList:(NSArray*)prizeList;

@end
