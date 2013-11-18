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

- (void) awakeFromNib {
  self.darkOverlay = [[UIImageView alloc] initWithFrame:self.bgdIcon.frame];
  self.darkOverlay.image = [Globals maskImage:self.bgdIcon.image withColor:[UIColor colorWithWhite:0.f alpha:0.4f]];
  [self.bgdIcon.superview addSubview:self.darkOverlay];
}

- (void) updateLeftViewForUserMonster:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  if (!um) {
    self.emptyIcon.hidden = NO;
    self.bgdIcon.hidden = YES;
    self.darkOverlay.hidden = YES;
    self.monsterIcon.hidden = YES;
  } else {
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    self.monsterIcon.hidden = NO;
    self.bgdIcon.hidden = NO;
    
    NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    fileName = [Globals imageNameForElement:mp.element suffix:@"team.png"];
    [Globals imageNamed:fileName withView:self.bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if ([um isHealing] || [um isEnhancing] || [um isSacrificing]) {
      self.emptyIcon.hidden = NO;
      self.healthView.hidden = YES;
      [self sendSubviewToBack:self.cardView];
    } else {
      self.emptyIcon.hidden = YES;
      self.healthView.hidden = NO;
    }
  }
}

- (void) updateRightViewForMyCronies:(UserMonster *)um {
  if (self.subtitleLabel.subviews.count > 0) {
    [self.subtitleLabel.subviews[0] removeFromSuperview];
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (!um) {
    self.subtitleLabel.hidden = NO;
    self.healthView.hidden = YES;
    
    self.titleLabel.text = @"Team Slot Open";
    self.titleLabel.textColor = [UIColor whiteColor];
    
    self.subtitleLabel.text = @"Tap     to Add";
    
    // Create green +
    UIFont *font = self.subtitleLabel.font;
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:176/255.f green:223/255.f blue:33/255.f alpha:1.f];
    label.text = @"+";
    [self.subtitleLabel addSubview:label];
    
    CGRect r = CGRectZero;
    r.origin.x = [@"Tap " sizeWithFont:font].width-1;
    r.size.width = [@"+" sizeWithFont:font].width;
    r.size.height = self.subtitleLabel.frame.size.height;
    label.frame = r;
  } else {
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    if ([um isHealing] || [um isEnhancing] || [um isSacrificing]) {
      self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", mp.displayName, [um isHealing] ? @"Healing" : @"Enhancing"];
      self.titleLabel.textColor = [UIColor colorWithWhite:1.f alpha:0.5f];
      self.subtitleLabel.text = @"Slot Open";
      
      self.subtitleLabel.hidden = NO;
      self.darkOverlay.hidden = NO;
    } else {
      NSString *fileName = [Globals imageNameForElement:mp.element suffix:@"teamhealthbar.png"];
      [Globals imageNamed:fileName withView:self.healthBar maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
      self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
      
      self.titleLabel.text = mp.displayName;
      self.titleLabel.textColor = [UIColor whiteColor];
      
      self.subtitleLabel.hidden = YES;
      self.darkOverlay.hidden = YES;
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
    self.titleLabel.textColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  }
}

- (void) animateNewMonster:(UserMonster *)um {
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
    CGPoint center = self.cardView.center;
    
    [self updateLeftViewForUserMonster:um];
    
    self.emptyIcon.hidden = NO;
    self.minusButton.hidden = YES;
    
    CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:ccpAdd(center, ccp(0, -35)) toPoint:center keyframeCount:150];
    kf.duration = 0.5f;
//    CAKeyframeAnimation *kf = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:40.f];
    kf.delegate = self;
    [self.cardView.layer addAnimation:kf forKey:@"bounce"];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5f;
    [self.rightView.layer addAnimation:animation forKey:@"fade"];
    [self updateRightViewForMyCronies:um];
    self.monster = um;
  } else {
    if (self.monster) {
      CGPoint center = self.cardView.center;
      self.minusButton.hidden = YES;
      self.emptyIcon.hidden = NO;
      [UIView animateWithDuration:0.3f animations:^{
        self.cardView.center = ccpAdd(center, ccp(0, 30));
        self.cardView.alpha = 0.f;
      } completion:^(BOOL finished) {
        self.cardView.center = center;
        self.cardView.alpha = 1.f;
        [self updateForMyCroniesConfiguration:um];
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
  [self updateForMyCroniesConfiguration:self.monster];
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate minusClickedForTeamSlotView:self];
}

@end

@implementation MonsterTeamSlotContainerView

- (void) awakeFromNib {
  [[NSBundle mainBundle] loadNibNamed:@"MonsterTeamSlotView" owner:self options:nil];
  [self addSubview:self.teamSlotView];
  self.teamSlotView.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  self.backgroundColor = [UIColor clearColor];
}

@end
