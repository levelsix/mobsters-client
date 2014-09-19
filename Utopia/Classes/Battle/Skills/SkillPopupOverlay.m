//
//  SkillPopupOverlay.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPopupOverlay.h"
#import "CAKeyframeAnimation+AHEasing.h"
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

- (void) animateForSkill:(SkillType)skill forPlayer:(BOOL)player withImage:(UIImageView*)imageView withCompletion:(SkillPopupBlock)completion
{
  UIView* mainView = player ? _avatarPlayer : _avatarEnemy;
  UIImageView* skillImage = player ? _skillImagePlayer : _skillImageEnemy;
  UIImageView* playerImage = player ? _imagePlayer : _imageEnemy;
  mainView.hidden = NO;
  
  // Skill image
  switch (skill)
  {
    case SkillTypeQuickAttack: skillImage.image = [Globals imageNamed:@"cheapshotlogo.png"]; break;
    case SkillTypeJelly: skillImage.image = [Globals imageNamed:@"goosplashlogo.png"]; break;
    case SkillTypeCakeDrop: skillImage.image = [Globals imageNamed:@"cakedroplogo.png"]; break;
    case SkillTypeBombs: skillImage.image = [Globals imageNamed:@"bombsawaylogo.png"]; break;
    case SkillTypeShield: skillImage.image = [Globals imageNamed:@"forcefieldlogo.png"]; break;
    case SkillTypePoison: skillImage.image = [Globals imageNamed:@"poisonlogo.png"]; break;
    default: CustomAssert(NO, @"Trying to create a skill popup and the skill logo definition is missing."); completion(NO); return;
  }
  skillImage.alpha = 0.0;
  skillImage.transform = CGAffineTransformMakeScale(10.0, 10.0);
  
  // Mobster image
  imageView.frame = playerImage.frame;
  [mainView addSubview:imageView];
  playerImage.hidden = YES;
  imageView.originY += 200;
  
  // Flip enemy avatar and his gradient
  if (! player)
  {
    //imageView.transform = CGAffineTransformMakeScale(-1, 1); // Don't flip the cake kid
    _enemyGradient.transform = CGAffineTransformMakeScale(-1, 1);
  }
  
  // Show view
  [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.alpha = 1.0;
    
  } completion:^(BOOL finished) {
    
    // Animate skill image
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      skillImage.alpha = 1.0;
      skillImage.transform = CGAffineTransformIdentity;
      imageView.originY -= 200;
    } completion:^(BOOL finished) {
      completion();
    }];
  }];
}

- (void) hideWithCompletion:(SkillPopupBlock)completion
{
  // Hide view
  [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
    self.alpha = 0.0;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    completion();
  }];
}

@end
