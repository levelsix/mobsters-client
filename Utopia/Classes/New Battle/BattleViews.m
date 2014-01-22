//
//  BattleContinueView.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleViews.h"
#import "Globals.h"
#import "GameState.h"

@implementation BattleEndView

- (void) displayWinWithDungeon:(BeginDungeonResponseProto *)dungeon {
  self.rewardsViewContainer.hidden = NO;
  self.lostStickerHead.hidden = YES;
  
  self.splashImage.image = [Globals imageNamed:@"wonsplash.png"];
  self.splashTextImage.image = [Globals imageNamed:@"youwon.png"];
  
  NSArray *rewards = [Reward createRewardsForDungeon:dungeon];
  [self.rewardsViewContainer.rewardsView updateForRewards:rewards];
  
  [Globals displayUIView:self];
}

- (void) displayLossWithDungeon:(BeginDungeonResponseProto *)dungeon {
  self.rewardsViewContainer.hidden = YES;
  self.lostStickerHead.hidden = NO;
  
  self.splashImage.image = [Globals imageNamed:@"lostsplash.png"];
  self.splashTextImage.image = [Globals imageNamed:@"youlost.png"];
  
  [Globals displayUIView:self];
}

@end

@implementation BattleDeployCardView

- (void) updateForBattlePlayer:(BattlePlayer *)bp {
  if (!bp) {
    self.emptyView.hidden = NO;
    self.mainView.hidden = YES;
  } else {
    self.healthbar.percentage = bp.curHealth/(float)bp.maxHealth;
    self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    BOOL grayscale = bp.curHealth == 0;
    NSString *mini = [Globals imageNameForElement:bp.element suffix:@"team.png"];
    [Globals imageNamed:mini withView:self.bgdIcon greyscale:grayscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    NSString *monster = [bp.spritePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:monster withView:self.monsterIcon greyscale:grayscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.emptyView.hidden = YES;
    self.mainView.hidden = NO;
  }
}

@end

@implementation BattleDeployView

- (void) updateWithBattlePlayers:(NSArray *)players {
  for (BattleDeployCardView *card in self.cardViews) {
    [card updateForBattlePlayer:nil];
    for (BattlePlayer *bp in players) {
      if (bp.slotNum == card.tag) {
        [card updateForBattlePlayer:bp];
      }
    }
  }
}

@end
