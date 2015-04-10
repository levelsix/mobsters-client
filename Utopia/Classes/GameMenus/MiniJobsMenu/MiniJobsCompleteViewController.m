//
//  MiniJobsCompleteViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsCompleteViewController.h"
#import "GameState.h"
#import "Globals.h"

#define SPACING_PER_NODE 46.f

@implementation MiniJobsCompleteMonsterView

- (void) awakeFromNib {
  self.monsterView.transform = CGAffineTransformMakeScale(0.67, 0.67);
}

- (void) updateForMonsterId:(int)monsterId hpLost:(int)hpLost {
  self.hidden = monsterId == 0;
  if (monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monsterId];
    [self.monsterView updateForMonsterId:monsterId];
    self.nameLabel.text = mp.monsterName;
    self.hpLabel.text = [NSString stringWithFormat:@"-%@ HP", [Globals commafyNumber:hpLost]];
  }
}

@end

@implementation MiniJobsCompleteViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self stopSpinning];
  
  [self loadForMiniJob:self.miniJob];
}

- (void) loadForMiniJob:(UserMiniJob *)miniJob {
  GameState *gs = [GameState sharedGameState];
  
  NSDictionary *damages = [miniJob damageDealtPerUserMonsterUuid];
  for (int i = 0; i < self.monsterViews.count; i++) {
    MiniJobsCompleteMonsterView *mv = self.monsterViews[i];
    if (i < self.miniJob.userMonsterUuids.count) {
      NSString *umId = self.miniJob.userMonsterUuids[i];
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:umId];
      int damage = [damages[um.userMonsterUuid] intValue];
      [mv updateForMonsterId:um.monsterId hpLost:damage];
    } else {
      [mv updateForMonsterId:0 hpLost:0];
    }
  }
  
  NSArray *rewards = [Reward createRewardsForMiniJob:miniJob.miniJob];
  if (rewards.count > 3) rewards = [rewards subarrayWithRange:NSMakeRange(0, 3)];
  
  for (int i = 0; i < rewards.count; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsRewardView" owner:self options:nil];
    [self.rewardView loadForReward:rewards[i]];
    self.rewardView.center = ccp((2*i+1-(int)rewards.count)/2.f*SPACING_PER_NODE+self.rewardsBox.frame.size.width/2,
                                 self.rewardsBox.frame.size.height/2);
    [self.rewardsBox addSubview:self.rewardView];
  }
  
  self.miniJob = miniJob;
}

- (void) beginSpinning {
  self.spinner.hidden = NO;
  [self.spinner startAnimating];
  self.collectLabel.hidden = YES;
}

- (void) stopSpinning {
  self.spinner.hidden = YES;
  self.collectLabel.hidden = NO;
}

- (IBAction) collectClicked:(id)sender {
  [self.delegate activeMiniJobCompleted:self.miniJob];
}

@end
