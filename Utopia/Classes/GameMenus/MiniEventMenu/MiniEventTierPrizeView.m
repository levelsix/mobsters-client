//
//  MiniEventTierPrizeView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventTierPrizeView.h"
#import "MiniEventTierPrizeCell.h"
#import "GameState.h"

static NSString* kTierTitleLabelColors[3] = { @"B56C16", @"535758", @"8F6200" };

@implementation MiniEventTierPrizeView

- (void) awakeFromNib
{
  [super awakeFromNib];
  
  self.tierTitle.shadowColor  = [UIColor colorWithWhite:1.f alpha:.5f];
  self.tierTitle.shadowOffset = CGSizeMake(0, 1);
  self.tierTitle.shadowBlur   = 1.2f;
  
  [self.tierPrizeList registerNib:[UINib nibWithNibName:@"MiniEventTierPrizeCell" bundle:nil] forCellReuseIdentifier:@"ReusableTierPrizeCell"];
}

- (void) updateForTier:(int)tier completed:(BOOL)completed prizeList:(NSArray*)prizeList
{
  self.tierBackground.image = [UIImage imageNamed:[NSString stringWithFormat:@"tier%dbg.png", tier]];
  self.tierTitle.text = [NSString stringWithFormat:@"TIER %d PRIZE", tier];
  self.tierTitle.textColor = [UIColor colorWithHexString:kTierTitleLabelColors[tier - 1]];
  self.tierCheckmark.hidden = !completed;
  
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
  if (![cell updateForReward:(RewardProto*)[_prizeList objectAtIndex:indexPath.row] useItemShortName:YES])
    return [[UITableViewCell alloc] init];
  
  return cell;
}

@end
