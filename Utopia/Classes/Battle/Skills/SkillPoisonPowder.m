//
//  SkillPoisonPowder.m
//  Utopia
//  Description: Once activated, opponent takes [X] damage each turn
//
//  Created by Rob Giusti on 1/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonPowder.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillPoisonPowder

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damage = 10;
  _percent = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_DAMAGE"])
    _damage = value;
  else if ( [property isEqualToString:@"MIN_PERCENT"])
    _percent = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist {
  return [self isActive];
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfPoison), nil];
}

- (void) restoreVisualsIfNeeded {
  if ([self isActive]) {
    [self addPoisonAnimations];
  }
}

- (int) poisonDamage
{
  return MAX(_damage, _percent * (self.belongsToPlayer ? self.enemy.maxHealth : self.player.maxHealth));
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if ((!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn)
        || (self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn))
    {
      [self dealPoisonDamage];
      [self tickDuration];
      return YES;
    }
    //Reset on new target
    else if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
             || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
    {
      [self endDurationNow];
    }
  }
  
  return NO;
}

- (BOOL) onDurationStart
{
  [self poisonOpponent];
  return YES;
}

- (BOOL) onDurationReset
{
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnOpponent:SideEffectTypeNerfPoison];
  return NO;
}

- (BOOL) onDurationEnd
{
  [self removePoison];
  return [super onDurationEnd];
}

- (void) poisonOpponent
{
  [self addPoisonAnimations];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
    [self skillTriggerFinished:YES];
  }];
}

- (void) addPoisonAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink purple
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor purpleColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
  
  [self addSkillSideEffectToOpponent:SideEffectTypeNerfPoison turnsAffected:self.turnsLeft];
}

- (void) removePoison
{
  [self resetOrbCounter];
  [self endPoisonAnimations];
}

- (void) endPoisonAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
  
  [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfPoison];
}

//- (void) dealPoisonDamage
//{
//  BattleSprite *poisonedSprite = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
//  
//  
//  if (self.belongsToPlayer)
//  {
//    [poisonedSprite performNearFlinchAnimationWithStrength:0 delay:0.4];
//  }
//  else
//  {
//    // Flinch
//    [poisonedSprite performFarFlinchAnimationWithDelay:0.4];
//  }
//  
//  // Flash red
//  [poisonedSprite.sprite runAction:[CCActionSequence actions:
//                                       [CCActionDelay actionWithDuration:0.3],
//                                       [RecursiveTintTo actionWithDuration:0.2 color:[CCColor purpleColor]],
//                                       [RecursiveTintTo actionWithDuration:0.2 color:[CCColor whiteColor]],
//                                       nil]];
//  
//  // Skull and bones
//  CCSprite* skull = [CCSprite spriteWithImageNamed:@"poisonplayer.png"];
//  skull.position = ccp(20, poisonedSprite.contentSize.height/2);
//  skull.scale = 0.01;
//  skull.opacity = 0.0;
//  [poisonedSprite addChild:skull z:10];
//  [skull runAction:[CCActionSequence actions:
//                    [CCActionSpawn actions:
//                     [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:0.3f scale:1]],
//                     [CCActionFadeIn actionWithDuration:0.3f],
//                     nil],
//                    [CCActionCallFunc actionWithTarget:self selector:@selector(dealPoisonDamage2)],
//                    [CCActionDelay actionWithDuration:0.5],
//                    [CCActionEaseElasticIn actionWithAction:[CCActionScaleTo actionWithDuration:0.7f scale:0]],
//                    [CCActionRemove action],
//                    nil]];
//}
//
//- (void) dealPoisonDamage2
//{
//  int damage = MAX(_damage, _percent * (self.belongsToPlayer ? self.enemy.maxHealth : self.player.maxHealth));
//  
//  // Deal damage
//  [self.battleLayer dealDamage:(int)damage enemyIsAttacker:!self.belongsToPlayer usingAbility:YES withTarget:self withSelector:@selector(dealPoisonDamage3)];
//}
//
//- (void) dealPoisonDamage3
//{
//  // Turn on the lights for the board and finish skill execution
////  [self performAfterDelay:1.3 block:^{
////    [self.battleLayer.orbLayer allowInput];
////    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
////  }];
//  [self skillTriggerFinished];
//}

@end