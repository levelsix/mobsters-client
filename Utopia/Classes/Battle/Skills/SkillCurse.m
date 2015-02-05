//
//  SkillCurse.m
//  Utopia
//  Description: Casts a status ailment on the enemy for X turns.
//  Enemy skill orb counter does not work while cursed.
//
//  Created by Rob Giusti on 2/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillCurse.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillCurse

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _curseTurns = 3;
  _curseTurnsLeft = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CURSE_TURNS"])
    _curseTurns = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return _curseTurnsLeft > 0;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (_curseTurnsLeft)
  {
    //Reset on new target
    if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
        || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
    {
      [self removeCurse];
    }
    else if (trigger == SkillTriggerPointEndOfPlayerMove)
    {
      _curseTurnsLeft--;
      if (_curseTurnsLeft == 0)
        [self removeCurse];
    }
  }
  
  if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
      (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self startCurse];
        }];
      }
      return YES;
    }
  }
  
  
  return NO;
}

#pragma mark - Skill Logic

- (void) startCurse
{
  [self resetOrbCounter];
  
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isCursed = YES;
  _curseTurnsLeft = _curseTurns;
  
  [self addCurseAnimations];
  
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

- (void) removeCurse
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isCursed = NO;
  
  _curseTurnsLeft = 0;
  [self endCurseAnimations];
}

#pragma mark - Animations

- (void) addCurseAnimations
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
}

- (void) endCurseAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent runAction:[CCActionEaseBounceIn actionWithAction:
                       [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_curseTurnsLeft) forKey:@"curseTurnsLeft"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* curseTurnsLeft = [dict objectForKey:@"curseTurnsLeft"];
  if (curseTurnsLeft) _curseTurnsLeft = [curseTurnsLeft intValue];
  
  return YES;
}
@end
