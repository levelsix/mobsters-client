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

@implementation BattleContinueView

- (void) display {
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

@end

@implementation BattleEndView

- (void) displayWithDungeon:(BeginDungeonResponseProto *)dungeon {
  NSArray *rewards = [Reward createRewardsForDungeon:dungeon];
  [self.rewardsViewContainer.rewardsView updateForRewards:rewards];
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

@end

@implementation BattleDeployCardView

- (void) awakeFromNib {
  self.grayscaleView = [[UIImageView alloc] initWithFrame:self.mainView.frame];
  [self insertSubview:self.grayscaleView atIndex:0];
}

- (void) createMask {
  UIView *view = self.mainView;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.grayscaleView.image = [Globals greyScaleImageWithBaseImage:image];
}

- (void) updateForBattlePlayer:(BattlePlayer *)bp {
  if (!bp) {
    self.emptyView.hidden = NO;
    self.mainView.hidden = YES;
    self.grayscaleView.hidden = YES;
  } else {
    self.healthbar.percentage = bp.curHealth/(float)bp.maxHealth;
    
    NSString *mini = [@"mini" stringByAppendingString:[Globals imageNameForElement:bp.element suffix:@".png"]];
    [Globals imageNamed:mini withView:self.bgdView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    
    BOOL grayscale = bp.curHealth == 0;
    NSString *monster = [bp.spritePrefix stringByAppendingString:@"Card.png"];
    [Globals imageNamed:monster withView:self.monsterIcon greyscale:grayscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if (grayscale) {
      self.emptyView.hidden = YES;
      self.mainView.hidden = NO;
      [self createMask];
      self.mainView.hidden = YES;
      self.grayscaleView.hidden = NO;
    } else {
      self.emptyView.hidden = YES;
      self.mainView.hidden = NO;
      self.grayscaleView.hidden = YES;
    }
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
