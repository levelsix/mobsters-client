//
//  MiniEventCollectRewardView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MiniEventCollectRewardCallbackDelegate <NSObject>

- (void) rewardCollectedForTier:(int)tier;

@end

@interface MiniEventCollectRewardView : UIView <UITableViewDataSource>
{
  int _rewardTier;
  NSMutableArray* _prizeList;
}

@property (nonatomic, retain) IBOutlet UIImageView* rewardReadyBackground;
@property (nonatomic, retain) IBOutlet UILabel* rewardReadyLabel;
@property (nonatomic, retain) IBOutlet UITableView* tierPrizeList;
@property (nonatomic, retain) IBOutlet UIButton* collectRewardButton;
@property (nonatomic, retain) IBOutlet UILabel* collectRewardLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* collectRewardSpinner;

@property (nonatomic, weak) id<MiniEventCollectRewardCallbackDelegate> delegate;

- (void) updateForTier:(int)tier prizeList:(NSArray*)prizeList;

- (IBAction) collectButtonTapped:(id)sender;

@end
