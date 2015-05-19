//
//  MiniEventTierPrizeCell.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventTierPrizeCell.h"
#import "GameState.h"

@implementation MiniEventTierPrizeCell

- (BOOL) updateForReward:(RewardProto*)rewardProto useItemShortName:(BOOL)useItemShortName
{
  Reward *reward = [[Reward alloc] initWithReward:rewardProto];
  
  NSString* name  = useItemShortName ? [reward shortName] : [reward name];
  NSString* count = [NSString stringWithFormat:@"x%d", [reward quantity]];
  NSString* icon  = [reward imgName];
  
  self.prizeName.text  = name;
  self.prizeCount.text = count;
  
  [Globals imageNamed:icon withView:self.prizeIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  return YES;
}

@end
