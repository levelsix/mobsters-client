//
//  SkillPopupOverlay.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPopupOverlay.h"
#import "Globals.h"
#import "CAKeyframeAnimation+AHEasing.h"

@implementation SkillPopupOverlay

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (! self)
    return nil;
  
  self.alpha = 0.0;
  
  return self;
}

- (void) animateForSkill:(SkillType)skill forPlayer:(BOOL)player withCompletion:(SkillControllerBlock)completion
{
  // Skill image
  switch (skill)
  {
    case SkillTypeQuickAttack: _skillImage.image = [Globals imageNamed:@"quickattacklogo.png"]; break;
    case SkillTypeJelly: _skillImage.image = [Globals imageNamed:@"skillgoosplashlogo.png"]; break;
    case SkillTypeCakeDrop: _skillImage.image = [Globals imageNamed:@"skillgoosplashlogo.png"]; break;
    case SkillTypeNoSkill: return;
  }
  _skillImage.alpha = 0.0;
  _skillImage.transform = CGAffineTransformMakeScale(0.1, 0.1);
  
  // Player used images (enemy pair set by default)
  if (player)
  {
    _ownerImage.image = [Globals imageNamed:@"skillyouusedused.png"];
    _usedImage.image = [Globals imageNamed:@"skillyouusedyou.png"];
  }
  _ownerImage.alpha = 0.f;
  _usedImage.alpha = 0.f;
  
  // Show view
  [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.alpha = 1.0;
  } completion:^(BOOL finished) {
    
    //////////////////////////////////
    // Ashwin's part
    CGPoint delta = ccp(-60, 11);
    CGPoint levelCenter = _ownerImage.center;
    CGPoint upCenter = _usedImage.center;
    
    float mult = 1.1;
    float animIn = 0.2f*mult;
    float animScaleDelay = 0.06f*mult;
    float animDelay = 0.1f*mult;
    float animHold = 0.8f;
    float smallScale = 0.1;
    
    _ownerImage.center = ccpAdd(levelCenter, delta);
    [UIView animateWithDuration:animIn delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      _ownerImage.center = levelCenter;
      _ownerImage.alpha = 1.f;
    } completion:nil];
    
    _ownerImage.transform = CGAffineTransformMakeScale(smallScale, smallScale);
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale" function:BackEaseOut fromValue:smallScale toValue:1.f];
    anim.duration = animIn;
    anim.beginTime = CACurrentMediaTime()+animScaleDelay;
    [_ownerImage.layer addAnimation:anim forKey:@"scale"];
    [self performAfterDelay:animScaleDelay block:^{
      _ownerImage.transform = CGAffineTransformIdentity;
    }];
    
    _usedImage.center = ccpAdd(upCenter, ccpMult(delta, -1));
    [UIView animateWithDuration:animIn delay:animDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
      _usedImage.center = upCenter;
      _usedImage.alpha = 1.f;
    } completion:nil];
    
    _usedImage.transform = CGAffineTransformMakeScale(smallScale, smallScale);
    CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale" function:BackEaseOut fromValue:smallScale toValue:1.f];
    anim2.duration = anim.duration;
    anim2.beginTime = CACurrentMediaTime()+animDelay+animScaleDelay;
    [_usedImage.layer addAnimation:anim2 forKey:@"scale"];
    [self performAfterDelay:animDelay+animScaleDelay block:^{
      _usedImage.transform = CGAffineTransformIdentity;
    }];
    // Ashwin's part ends
    //////////////////////////////////
    
    // Animate skill image
    [UIView animateWithDuration:0.3 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
      _skillImage.alpha = 1.0;
      _skillImage.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    // Hide view
    [UIView animateWithDuration:0.3 delay:animDelay+animIn+animHold options:UIViewAnimationOptionCurveLinear animations:^{
      self.alpha = 0.0;
    } completion:^(BOOL finished) {
      [self removeFromSuperview];
      completion();
    }];
  }];
}

@end
