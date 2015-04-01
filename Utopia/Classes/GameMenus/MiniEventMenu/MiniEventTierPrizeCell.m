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
  GameState* gs = [GameState sharedGameState];
  
  NSString* name  = nil;
  NSString* count = nil;
  NSString* icon  = nil;
  
  switch (rewardProto.typ)
  {
    case RewardProto_RewardTypeItem:
    {
      ItemProto* item = [gs.staticItems objectForKey:@(rewardProto.staticDataId)];
      if (!item) return NO;
      name  = (useItemShortName && item.hasShortName) ? item.shortName : item.name;
      icon  = item.imgName;
      count = [NSString stringWithFormat:@"x%d", rewardProto.amt];
    }
      break;
    case RewardProto_RewardTypeGems:
      name  = [NSString stringWithFormat:@"%@ Gems", [Globals commafyNumber:rewardProto.amt]];
      icon  = @"diamond.png";
      count = @"x1";
      break;
    case RewardProto_RewardTypeCash:
      name  = [NSString stringWithFormat:@"%@ Cash", [Globals commafyNumber:rewardProto.amt]];
      icon  = @"moneystack.png";
      count = @"x1";
      break;
    case RewardProto_RewardTypeOil:
      name  = [NSString stringWithFormat:@"%@ Oil", [Globals commafyNumber:rewardProto.amt]];
      icon  = @"oilicon.png";
      count = @"x1";
      break;
    case RewardProto_RewardTypeMonster:
    {
      MonsterProto* monster = [gs.staticMonsters objectForKey:@(rewardProto.staticDataId)];
      if (!monster) return NO;
      name  = monster.displayName;
      icon  = [monster.imagePrefix stringByAppendingString:@"Card.png"];
      count = [NSString stringWithFormat:@"x%d", rewardProto.amt];
    }
      break;
      
    default:
      return NO;
  }
  
  self.prizeName.text  = name;
  self.prizeCount.text = count;
  
  [Globals imageNamed:icon withView:self.prizeIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  return YES;
}

@end
