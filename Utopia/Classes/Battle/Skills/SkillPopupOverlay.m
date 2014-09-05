//
//  SkillPopupOverlay.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPopupOverlay.h"
#import "Globals.h"

@implementation SkillPopupOverlay

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (! self)
    return nil;
  
  self.alpha = 0.0;
  
  return self;
}

- (void) animateForSkill:(SkillType)skill forPlayer:(BOOL)player withBlock:(SkillControllerBlock)block
{
  // Skill image
  switch (skill)
  {
    case SkillTypeQuickAttack: _skillImage.image = [Globals imageNamed:@"quickattacklogo.png"]; break;
    case SkillTypeJelly: _skillImage.image = [Globals imageNamed:@"skillgoosplashlogo.png"]; break;
    case SkillTypeCakeDrop: _skillImage.image = [Globals imageNamed:@"skillgoosplashlogo.png"]; break;
    case SkillTypeNoSkill: return;
  }
  
  // Player used images (enemy pair set by default)
  if (player)
  {
    _ownerImage.image = [Globals imageNamed:@"skillyouusedused.png"];
    _usedImage.image = [Globals imageNamed:@"skillyouusedyou.png"];
  }
  
  [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.alpha = 1.0;
  } completion:^(BOOL finished) {
    
    [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
      self.alpha = 0.0;
    } completion:^(BOOL finished) {
      [self removeFromSuperview];
      block();
    }];
  }];
}

@end
