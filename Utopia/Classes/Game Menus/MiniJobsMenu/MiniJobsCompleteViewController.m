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

#define SPACING_PER_NODE 38.f

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
    self.nameLabel.text = mp.hasShorterName ? mp.shorterName : mp.displayName;
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
  for (int i = 0; i < self.monsterViews.count; i++) {
    MiniJobsCompleteMonsterView *mv = self.monsterViews[i];
    if (i < self.miniJob.userMonsterIds.count) {
      uint64_t umId = [self.miniJob.userMonsterIds[i] longLongValue];
      UserMonster *um = [gs myMonsterWithUserMonsterId:umId];
      [mv updateForMonsterId:um.monsterId hpLost:0];
    } else {
      [mv updateForMonsterId:0 hpLost:0];
    }
  }
  
  NSArray *rewards = [Reward createRewardsForMiniJob:miniJob.miniJob];
  if (rewards.count > 2) rewards = [rewards subarrayWithRange:NSMakeRange(0, 2)];
  
  for (int i = 0; i < rewards.count; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestRewardView" owner:self options:nil];
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
