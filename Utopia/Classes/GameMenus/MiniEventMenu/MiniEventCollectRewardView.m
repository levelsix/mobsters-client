//
//  MiniEventCollectRewardView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventCollectRewardView.h"
#import "MiniEventTierPrizeCell.h"
#import "GameState.h"
#import "NibUtils.h"

@implementation MiniEventCollectRewardView

- (void) awakeFromNib
{
  [super awakeFromNib];
  
  UIImageView* backgroundLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rewardreadybgcap.png"]];
  {
    backgroundLeftCap.frame = CGRectMake(self.rewardReadyBackground.originX - 10, self.rewardReadyBackground.originY, 10, self.rewardReadyBackground.height);
    [self insertSubview:backgroundLeftCap belowSubview:self.rewardReadyBackground];
  }
  UIImageView* backgroundRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rewardreadybgcap.png"]];
  {
    backgroundRightCap.frame = CGRectMake(self.rewardReadyBackground.originX + self.rewardReadyBackground.width, self.rewardReadyBackground.originY, 10, self.rewardReadyBackground.height);
    backgroundRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self insertSubview:backgroundRightCap belowSubview:self.rewardReadyBackground];
  }
  
  [self.tierPrizeList registerNib:[UINib nibWithNibName:@"MiniEventTierPrizeCell" bundle:nil] forCellReuseIdentifier:@"ReusableTierPrizeCell"];
}

- (void) updateForTier:(int)tier prizeList:(NSArray*)prizeList
{
  self.rewardReadyLabel.text = [NSString stringWithFormat:@"Your Tier %d Reward is Ready!", tier];
  
  _prizeList = [NSMutableArray array];
  
  GameState* gs = [GameState sharedGameState];
  for (MiniEventTierRewardProto* prize in prizeList)
  {
    RewardProto* reward = [gs.staticRewards objectForKey:@(prize.rewardId)];
    if (reward) [_prizeList addObject:reward];
  }
  
  [self.tierPrizeList reloadData];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
  return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  return _prizeList.count;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  MiniEventTierPrizeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ReusableTierPrizeCell" forIndexPath:indexPath];
  if (![cell updateForReward:(RewardProto*)[_prizeList objectAtIndex:indexPath.row] useItemShortName:NO])
    return [[UITableViewCell alloc] init];
  
  cell.containerView.width = tableView.width;
  
  return cell;
}

@end
