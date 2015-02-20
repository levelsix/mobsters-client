//
//  SkillDamage.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillQuickAttack.h"
#import "NewBattleLayer.h"

@implementation SkillQuickAttack

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damage = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE"] )
    _damage = value;
}

#pragma mark - Overrides

- (int) quickAttackDamage
{
  return _damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self dealQuickAttack];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

- (void) onFinishQuickAttack
{
  [self resetOrbCounter];
  [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
    [self skillTriggerFinished:YES];
  }];
}

@end
