//
//  MonsterTeamSlotView.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MonsterTeamSlotView.h"
#import "GameState.h"
#import "Globals.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "CAKeyFrameAnimation+Jumping.h"

@implementation MonsterTeamSlotView

- (void) updateLeftViewForUserMonster:(UserMonster *)um {
  if (!um) {
    self.emptyIcon.hidden = NO;
    self.monsterView.hidden = YES;
  } else {
    self.monsterView.hidden = NO;
    self.monsterView.alpha = 1.f;
    
    [self.monsterView updateForMonsterId:um.monsterId];
    
    if (![um isAvailable]) {
      self.emptyIcon.hidden = NO;
      self.healthView.hidden = YES;
      [self sendSubviewToBack:self.monsterView];
    } else {
      self.emptyIcon.hidden = YES;
      self.healthView.hidden = NO;
    }
  }
}

- (void) updateRightViewForMyCronies:(UserMonster *)um {
  while (self.subtitleLabel.subviews.count > 0) {
    [self.subtitleLabel.subviews[0] removeFromSuperview];
  }
  while (self.titleLabel.subviews.count > 0) {
    [self.titleLabel.subviews[0] removeFromSuperview];
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (!um) {
    self.subtitleLabel.hidden = NO;
    self.healthView.hidden = YES;
    
    self.titleLabel.text = @"Team Slot Open";
    self.titleLabel.textColor = [UIColor colorWithWhite:0.23 alpha:0.75f];
    
    self.subtitleLabel.text = @"Tap      to Add";
    
    // Create green +
    UIImageView *plus = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"addteam.png"]];
    plus.contentMode = UIViewContentModeScaleAspectFit;
    [self.subtitleLabel addSubview:plus];
    
    CGRect r = plus.frame;
    r.origin.x = [@"Tap " sizeWithFont:self.subtitleLabel.font].width-1;
    r.origin.y = self.subtitleLabel.frame.size.height/2-plus.frame.size.height/2;
    r.size.width *= 0.6;
    plus.frame = r;
  } else {
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    self.titleLabel.text = mp.monsterName;
    if (self.titleLabel.subviews.count > 0) {
      [self.titleLabel.subviews[0] removeFromSuperview];
    }
    if (![um isAvailable]) {
      self.titleLabel.textColor = [UIColor colorWithWhite:0.23 alpha:0.75f];
      
      UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:um.statusImageName]];
      [self.titleLabel addSubview:img];
      CGSize s = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:self.titleLabel.frame.size];
      img.center = ccp(s.width+img.frame.size.width/2+3, self.titleLabel.frame.size.height/2);
      
      [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        img.alpha = 0.6;
      } completion:nil];
      
      self.subtitleLabel.text = @"Slot Open";
      
      self.subtitleLabel.hidden = NO;
      
      self.monsterView.alpha = 0.6f;
    } else {
      self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
      
      self.titleLabel.textColor = [UIColor colorWithWhite:0.23 alpha:1.f];
      
      self.subtitleLabel.hidden = YES;
      
      self.monsterView.alpha = 1.f;
    }
  }
}

- (void) updateForMyCroniesConfiguration:(UserMonster *)um {
  // Remove green label from subtitle
  [self updateLeftViewForUserMonster:um];
  [self updateRightViewForMyCronies:um];
  
  if (!um) {
    self.minusButton.hidden = YES;
  } else {
    self.minusButton.hidden = NO;
  }
  
  self.monster = um;
}

- (void) updateForEnhanceConfiguration:(UserMonster *)um {
  [self updateLeftViewForUserMonster:um];
  [self updateRightViewForMyCronies:um];
  self.minusButton.hidden = YES;
  self.subtitleLabel.hidden = YES;
  
  if (!um) {
    self.titleLabel.textColor = [UIColor colorWithWhite:0.23f alpha:0.75f];
  }
}

- (void) animateNewMonster:(UserMonster *)um {
  [self.monsterView.layer removeAllAnimations];
  [self.rightView.layer removeAllAnimations];
  [self.layer removeAllAnimations];
  
  if ([self.monster isEqual:um]) {
    // Monster just started/stopped healing
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"fade"];
    [self updateForMyCroniesConfiguration:um];
    return;
  }
  
  [self sendSubviewToBack:self.emptyIcon];
  if (um) {
    CGPoint center = self.emptyIcon.center;
    
    [self updateLeftViewForUserMonster:um];
    
    self.emptyIcon.hidden = NO;
    self.minusButton.hidden = YES;
    self.monsterView.alpha = 1.f;
    
    CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:ccpAdd(center, ccp(0, -35)) toPoint:center keyframeCount:150];
    kf.duration = 0.5f;
    kf.delegate = self;
    [self.monsterView.layer addAnimation:kf forKey:@"bounce"];
    self.monsterView.center = center;
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5f;
    [self.rightView.layer addAnimation:animation forKey:@"fade"];
    [self updateRightViewForMyCronies:um];
    self.monster = um;
  } else {
    if (self.monster) {
      CGPoint center = self.monsterView.center;
      self.minusButton.hidden = YES;
      self.emptyIcon.hidden = NO;
      [UIView animateWithDuration:0.3f animations:^{
        self.monsterView.center = ccpAdd(center, ccp(0, 30));
        self.monsterView.alpha = 0.f;
      } completion:^(BOOL finished) {
        if (finished) {
          [self updateForMyCroniesConfiguration:um];
        }
      }];
      
      CATransition *animation = [CATransition animation];
      animation.duration = 0.3f;
      animation.type = kCATransitionFade;
      animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      [self.rightView.layer addAnimation:animation forKey:@"fade"];
      [self updateRightViewForMyCronies:um];
    } else {
      [self updateForMyCroniesConfiguration:um];
    }
  }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (flag) {
    [self updateForMyCroniesConfiguration:self.monster];
  }
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate minusClickedForTeamSlotView:self];
}

- (IBAction)healAreaClicked:(id)sender {
  if ([self.delegate respondsToSelector:@selector(healAreaClicked:)]) {
    [self.delegate healAreaClicked:self];
  }
}

@end

@implementation MonsterTeamSlotContainerView

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"MonsterTeamSlotView" owner:self options:nil];
  [self addSubview:self.teamSlotView];
  self.teamSlotView.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  self.backgroundColor = [UIColor clearColor];
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.teamSlotView.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
}

@end
