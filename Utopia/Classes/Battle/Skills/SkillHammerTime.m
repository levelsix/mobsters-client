//
//  SkillHammerTime.m
//  Utopia
//  Description: [chance] to stun enemy for [turns].
//
//  Created by Rob Giusti on 1/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillHammerTime.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillHammerTime

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _chance = .25;
  _stunTurns = 1;
  _turnsLeft = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"CHANCE"])
    _chance = value;
  else if ( [property isEqualToString:@"STUN_TURNS"])
    _stunTurns = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return _turnsLeft > 0;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  //If the character dies before the stun runs up, make sure the stun doesn't persist
  if (_turnsLeft>0 && ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
           || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized)))
  {
    [self endStun];
  }
  
  //At the end of the turn, diminish stun stacks
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn) ||
      (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn))
  {
    if (_turnsLeft>0)
    {
      _turnsLeft--;
      if (_turnsLeft == 0)
        [self endStun];
    }
  }
  
  //Note: You can refresh a stun!
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn) ||
           (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn))
  {
    if (execute)
    {
      if (((double)arc4random()/0x100000000) < _chance){
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self stunOpponent];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

- (void) stunOpponent
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  
  opponent.isStunned = YES;
  
  _turnsLeft = _stunTurns;
  [self addStunAnimations];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

- (void) addStunAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink yellow
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor yellowColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
}

- (void) endStun
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  
  opponent.isStunned = NO;
  
  _turnsLeft = 0;
  [self endStunAnimations];
}

- (void) endStunAnimations
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
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft)
    _turnsLeft = [turnsLeft intValue];
  
  return YES;
}

@end