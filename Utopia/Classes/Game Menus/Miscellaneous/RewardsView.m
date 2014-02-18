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

@implementation RewardView

- (void) loadForReward:(Reward *)reward {
  NSString *imgName = nil;
  NSString *labelName = nil;
  NSString *bgdName = nil;
  UIColor *color = nil;
  if (reward.type == RewardTypeMonster) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:reward.monsterId];
    imgName = [Globals imageNameForRarity:mp.quality suffix:@"piece.png"];
    bgdName = [Globals imageNameForRarity:mp.quality suffix:@"found.png"];
    labelName = [Globals shortenedStringForRarity:mp.quality];
    color = [Globals colorForRarity:mp.quality];
  } else if (reward.type == RewardTypeSilver) {
    imgName = @"moneystack.png";
    bgdName = @"cashfound.png";
    labelName = [Globals cashStringForNumber:reward.silverAmount];
    color = [Globals greenColor];
  } else if (reward.type == RewardTypeOil) {
    imgName = @"oilicon.png";
    bgdName = @"ultrafound.png";
    labelName = [Globals commafyNumber:reward.oilAmount];
    color = [Globals goldColor];
  } else if (reward.type == RewardTypeGold) {
    imgName = @"diamond.png";
    labelName = [Globals commafyNumber:reward.goldAmount];
    color = [Globals purplishPinkColor];
  } else if (reward.type == RewardTypeExperience) {
    imgName = @"levelnumber.png";
    bgdName = @"expfound.png";
    labelName = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:reward.expAmount]];
    color = [Globals orangeColor];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 10)];
    [self addSubview:l];
    l.textColor = [UIColor whiteColor];
    l.backgroundColor = [UIColor clearColor];
    l.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
    l.font = [UIFont fontWithName:[Globals font] size:11.f];
    l.center = self.rewardIcon.center;
    l.textAlignment = NSTextAlignmentCenter;
    l.shadowOffset = CGSizeMake(0, 1);
    l.text = @"EXP";
  }
  
  self.rewardIcon.image = [Globals imageNamed:imgName];
  self.rewardBgd.image = [Globals imageNamed:bgdName];
  CGPoint center = self.rewardIcon.center;
  self.rewardIcon.frame = CGRectMake(0, 0, self.rewardIcon.image.size.width, self.rewardIcon.image.size.height);
  self.rewardIcon.center = center;
  self.rewardLabel.text = labelName;
  self.rewardLabel.textColor = color;
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
