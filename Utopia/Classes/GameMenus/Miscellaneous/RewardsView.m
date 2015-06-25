//
//  RewardsView.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "RewardsView.h"
#import "Globals.h"
#import "GameState.h"

#import "NibUtils.h"

@implementation RewardView

- (void) awakeFromNib {
  self.iconLabel.strokeSize = 1.5f;
  self.iconLabel.strokeColor = [UIColor colorWithHexString:@"ebebeb"];
  
  self.itemView.frame = self.mainView.frame;
  [self.mainView.superview addSubview:self.itemView];
}

- (void) loadForReward:(Reward *)reward {
  
  //Reward *actualReward = reward.type == RewardTypeReward ? reward.innerReward : reward;
  BOOL useItemView = YES;//actualReward.type == RewardTypeMonster || actualReward.type == RewardTypeItem ;
  
  NSString *imgName = [reward imgName];
  NSString *labelName = [reward shorterName];
  int quantity = [reward quantity];
  
  UIColor *color = nil;
  if (reward.type == RewardTypeCash) {
    color = [UIColor colorWithRed:105/255. green:141/255. blue:7/255.f alpha:1.f];
  } else if (reward.type == RewardTypeOil) {
    color = [UIColor colorWithRed:225/255. green:137/255. blue:11/255.f alpha:1.f];
  } else if (reward.type == RewardTypeGems) {
    color = [UIColor colorWithRed:186/255. green:47/255. blue:255/255.f alpha:1.f];
  } else {// else if (reward.type == RewardTypeGachaToken) {
    color = [UIColor colorWithHexString:@"EA5F25"];
  }
  
  if (useItemView) {
    [Globals imageNamed:imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.iconLabel.text = labelName;
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"%dx", quantity];
    self.itemQuantityLabel.superview.hidden = quantity <= 1;
    
    if (color) {
      self.iconLabel.textColor = color;
    }
    
    self.itemView.hidden = NO;
    self.mainView.hidden = YES;
  } else {
    [Globals imageNamed:imgName withView:self.rewardIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.rewardLabel.text = labelName;
    self.rewardLabel.textColor = color;
    
    self.itemView.hidden = YES;
    self.mainView.hidden = NO;
  }
  
  if (reward.type == RewardTypeItem) {
    GameState *gs = [GameState sharedGameState];
    ItemProto *ip = [gs itemForId:reward.itemId];
    
    self.itemGameActionTypeIcon.hidden = NO;
    switch (ip.gameActionType) {
      case GameActionTypeCreateBattleItem:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timercreateitems.png"];
        break;
      case GameActionTypeEnhanceTime:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerenhance.png"];
        break;
      case GameActionTypeEvolve:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerevolve.png"];
        break;
      case GameActionTypeHeal:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerheal.png"];
        break;
      case GameActionTypeMiniJob:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerminijobs.png"];
        break;
      case GameActionTypeRemoveObstacle:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerremove.png"];
        break;
      case GameActionTypePerformingResearch:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerresearch.png"];
        break;
      case GameActionTypeUpgradeStruct:
        self.itemGameActionTypeIcon.image = [Globals imageNamed:@"timerupgrade.png"];
        break;
        
      case GameActionTypeNoHelp:
      case GameActionTypeCombineMonster:
      case GameActionTypeEnterPersistentEvent:
        self.itemGameActionTypeIcon.hidden = YES;
        break;
    }
  } else {
    self.itemGameActionTypeIcon.hidden = YES;
  }
}


@end

@implementation RewardsView

#define REWARD_VIEW_SPACE 6

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  self.scrollView.frame = self.bounds;
  float width = self.innerView.frame.size.width;
  if (self.scrollView.frame.size.width > width) {
    self.innerView.center = ccp(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
  } else {
    CGRect r = CGRectZero;
    r.size = CGSizeMake(width, self.scrollView.frame.size.height);
    self.innerView.frame = r;
  }
  
  self.scrollView.contentSize = CGSizeMake(width, self.scrollView.frame.size.height);
}

- (void) updateForRewards:(NSArray *)rewards {
  [self.scrollView removeFromSuperview];
  self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  self.scrollView.showsHorizontalScrollIndicator = NO;
  [self addSubview:self.scrollView];
  
  self.innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.scrollView.frame.size.height)];
  [self.scrollView addSubview:self.innerView];
  
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  for (int i = 0; i < rewards.count; i++) {
    Reward *reward = [rewards objectAtIndex:i];
    
    [[NSBundle mainBundle] loadNibNamed:@"RewardView" owner:self options:nil];
    [self.rewardView loadForReward:reward];
    
    [self.innerView addSubview:self.rewardView];
    self.rewardView.center = ccp(self.rewardView.frame.size.width*(0.5+i)+REWARD_VIEW_SPACE*(i+1), self.innerView.frame.size.height/2);
  }
  
  float width = CGRectGetMaxX(self.rewardView.frame)+REWARD_VIEW_SPACE;
  CGRect r = CGRectZero;
  r.size = CGSizeMake(width, self.scrollView.frame.size.height);
  self.innerView.frame = r;
  if (self.scrollView.frame.size.width > width) {
    self.innerView.center = ccp(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
  }
  
  self.scrollView.contentSize = CGSizeMake(width, self.scrollView.frame.size.height);
}

@end

@implementation RewardsViewContainer

- (void) awakeFromNib {
  self.rewardsView = [[RewardsView alloc] initWithFrame:self.bounds];
  self.rewardsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.rewardsView];
  self.backgroundColor = [UIColor clearColor];
}

@end
