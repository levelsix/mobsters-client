//
//  SkillCounterStrike.m
//  Utopia
//
//  Created by Robert Giusti on 1/21/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillCounterStrike.h"
#import "NewBattleLayer.h"

@implementation SkillCounterStrike

# pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _damage = 0;
  _chance = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"DAMAGE"])
    _damage = value;
  else if ([property isEqualToString:@"CHANCE"])
    _chance = value;
}

# pragma mark - Overrides

- (int) quickAttackDamage
{
  return _damage;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffCounterStrike), nil];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute {
  
  if ([self isActive])
  {
    if ((trigger == SkillTriggerPointEndOfEnemyTurn && self.belongsToPlayer)
        || (trigger == SkillTriggerPointEndOfPlayerTurn && !self.belongsToPlayer)){
      if (execute){
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chance){
          [self performAfterDelay:self.opponentSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
            [self dealQuickAttack];
            [self tickDuration];
          }];
        }
        else{
          BOOL holdSkillTrigger = [self tickDuration];
          if (!holdSkillTrigger)
            [self skillTriggerFinished];
        }
      }
      return YES;
    }
  }
  
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  return NO;
}

@end