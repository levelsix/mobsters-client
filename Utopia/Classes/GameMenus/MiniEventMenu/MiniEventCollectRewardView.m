//
//  MiniEventCollectRewardView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 4/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventCollectRewardView.h"
#import "MiniEventTierPrizeCell.h"
#import "MiniEventManager.h"
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
  
  _rewardTier = tier;
  _prizeList = [NSMutableArray array];
  
  for (MiniEventTierRewardProto* prize in prizeList)
  {
    if (prize.hasRewardProto) [_prizeList addObject:prize.rewardProto];
  }
  
  [self.tierPrizeList reloadData];
}

- (void) collectButtonTapped:(id)sender
{
  [self.collectRewardButton setEnabled:NO];
  [self.collectRewardLabel setHidden:YES];
  [self.collectRewardSpinner setHidden:NO];
  [self.collectRewardSpinner startAnimating];
  
  [[MiniEventManager sharedInstance] handleRedeemMiniEventRewardInitiatedByUserWithDelegate:self tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)_rewardTier];
}

- (void) handleRedeemMiniEventRewardResponseProto:(FullEvent*)fe
{
  RedeemMiniEventRewardResponseProto *proto = (RedeemMiniEventRewardResponseProto *)fe.event;
  
  if (proto.status == ResponseStatusSuccess)
  {
    [[MiniEventManager sharedInstance] handleRedeemMiniEventRewards:proto.rewards tierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier)_rewardTier];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardCollectedForTier:)])
    {
      [self.delegate rewardCollectedForTier:_rewardTier];
    }
  }
  
  [self.collectRewardSpinner stopAnimating];
  [self.collectRewardSpinner setHidden:YES];
  [self.collectRewardLabel setHidden:NO];
  [self.collectRewardButton setEnabled:YES];
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
