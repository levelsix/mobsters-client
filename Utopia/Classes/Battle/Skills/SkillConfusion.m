//
//  SkillConfusion.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/22/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillConfusion.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillConfusion

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];

  _chanceToHitSelf = 0.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CHANCE_TO_HIT_SELF"])
    _chanceToHitSelf = value;
}

#pragma mark - Overrides

- (BOOL) affectsOwner
{
  return NO;
}

- (TickTrigger) tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfConfusion), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player && !self.belongsToPlayer)
  {
    if ([self isActive])
    {
      // Chance of player hitting self
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _chanceToHitSelf)
      {
        SkillLogStart(@"Confusion -- Skill caused player to hit himself");
        
        // Tell NewBattleLayer that player will be confused on his next turn
        self.player.isConfused = YES;
      }
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointStartOfEnemyTurn && self.belongsToPlayer)
    {
      if (execute)
      {
        // Chance of enemy hitting self
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chanceToHitSelf)
        {
          SkillLogStart(@"Confusion -- Skill caused enemy to hit himself");
          
          // Tell NewBattleLayer that enemy will be confused on his next turn
          self.enemy.isConfused = YES;
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) showLogo
{
  [self showSkillPopupMiniOverlay:NO
                       bottomText:@"CONFUSED"
                   withCompletion:^{}];
}
@end
