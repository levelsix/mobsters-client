//
//  SkillRightHook.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/3/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillRightHook.h"
#import "NewBattleLayer.h"

@implementation SkillRightHook

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _fixedDamageDone = 0.f;
  _targetChanceToHitSelf = 0.f;
  _skillActive = NO;
  _confusionTurns = 0;
  _logoShown = NO;
  
  _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeGlove];
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  if ([property isEqualToString:@"ORBS_SPAWN_COUNTER"])
    _orbsSpawnCounter = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  if ([property isEqualToString:@"TARGET_CHANCE_TO_HIT_SELF"])
    _targetChanceToHitSelf = value;
}

#pragma mark - Overrides

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player && !self.belongsToPlayer)
  {
    if (_skillActive)
    {
      // Chance of player hitting self
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _targetChanceToHitSelf)
      {
        [self showLogo];
        
        // Tell NewBattleLayer that enemy will be confused on his next turn
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
  
  if ((trigger == SkillTriggerPointEnemyAppeared      && !_logoShown) ||
      (trigger == SkillTriggerPointStartOfPlayerTurn  && !_logoShown) ||
      (trigger == SkillTriggerPointStartOfEnemyTurn   && !_logoShown))
  {
    if (execute)
    {
      _logoShown = YES;
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
      
      // Will restore visuals if coming back to a battle after leaving midway
      if (!self.belongsToPlayer && _skillActive)
      {
        // Display confused symbol on player's turn indicator(s)
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                          onUpcomingTurns:(int)_confusionTurns
                                                               forMonster:self.player.monsterId];
      }
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (!_skillActive && _orbsSpawned == 0)
    {
      if (execute)
      {
        if ([self skillIsReady])
        {
          // Spawn glove orbs when skill is activated
          [self showSkillPopupOverlay:YES withCompletion:^(){
            [self performAfterDelay:.5f block:^{
              [self spawnGloveOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinished)];
            }];
          }];
        }
        else
          [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Update counters on glove orbs
      if (_orbsSpawned > 0 && [self updateGloveOrbs])
      {
        _skillActive = YES;
        
        // Display confused symbol on player's turn indicator(s)
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                          onUpcomingTurns:(int)_confusionTurns
                                                               forMonster:self.player.monsterId];
        
        // If any orbs have reached zero turns left, perform out of turn attack
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginOutOfTurnAttack)];
      }
      else
        [self skillTriggerFinished];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer)
  {
    if (_skillActive)
    {
      if (execute)
      {
        if (--_confusionTurns == 0)
        {
          _skillActive = NO;
          [self resetOrbCounter];
          
          // Tell NewBattleLayer that player is no longer confused,
          // remove confused symbol from player's turn indicator(s)
          self.player.isConfused = NO;
          [self.battleLayer.hudView.battleScheduleView updateConfusionState:NO
                                               onAllUpcomingTurnsForMonster:self.player.monsterId];
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer)
  {
    if (execute)
    {
      if (_skillActive)
      {
        _skillActive = NO;
        [self resetOrbCounter];
        
        // Tell NewBattleLayer that player is no longer confused,
        // remove confused symbol from player's turn indicator(s)
        self.player.isConfused = NO;
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:NO
                                             onAllUpcomingTurnsForMonster:self.player.monsterId];
      }
      
      // Remove all glove orbs added by this enemy
      [self removeAllGloveOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) updateGloveOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
  
  NSInteger usedUpOrbCount = 0;
  NSMutableSet* clonedOrbs = [NSMutableSet set];
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeGlove && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the glove orb
        {
          // Clone the orb sprite to be used in the visual effect
          CCSprite* clonedSprite = [CCSprite spriteWithTexture:sprite.orbSprite.texture rect:sprite.orbSprite.textureRect];
          clonedSprite.position = [bgdLayer convertToNodeSpace:[sprite.orbSprite convertToWorldSpaceAR:sprite.orbSprite.position]];
          clonedSprite.zOrder = sprite.orbSprite.zOrder + 100;
          [clonedOrbs addObject:clonedSprite];
          
          // Change sprite type
          orb.specialOrbType = SpecialOrbTypeNone;
          
          // Reload sprite
          [sprite reloadSprite:YES];
          
          ++usedUpOrbCount;
          --_orbsSpawned;
        }
        else
          [sprite updateTurnCounter:YES];
      }
    }
  }
  
  for (CCSprite* clonedSprite in clonedOrbs)
  {
    [self.battleLayer.orbLayer.bgdLayer addChild:clonedSprite];
    [clonedSprite runAction:[CCActionSequence actions:
                             [CCActionEaseOut actionWithAction:
                              [CCActionMoveTo actionWithDuration:.25f position:ccp(bgdLayer.contentSize.width * .5f, bgdLayer.contentSize.height * .5f)]],
                             [CCActionDelay actionWithDuration:.25f],
                             [CCActionSpawn actions:
                              [CCActionEaseIn actionWithAction:
                               [CCActionScaleBy actionWithDuration:.35f scale:10.f]],
                              [CCActionEaseIn actionWithAction:
                               [CCActionFadeOut actionWithDuration:.35f]],
                              nil],
                             [CCActionRemove action],
                             nil]];
  }
  
  if (!_skillActive)
  {
    // However many glove orbs are left on the board when their
    // timer reaches zero is what dictates for how many turns the
    // player will be confused (with a chance of hitting self)
    _confusionTurns = usedUpOrbCount;
  }
  
  return (usedUpOrbCount > 0);
}

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showLogo];
  
  // Perform attack animation
  [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite
                                           shouldReturn:YES
                                            shouldEvade:NO
                                           shouldFlinch:YES
                                                 target:self
                                               selector:@selector(dealDamage)
                                         animCompletion:nil];
}

- (void) dealDamage
{
  [self.battleLayer dealDamage:_fixedDamageDone
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];

  [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageDone];
  [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
}

- (void) endOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self skillTriggerFinished];
}

- (void) showLogo
{
  /*
   * 2/4/15 - BN - Disabling skills displaying logos
   *
   
  const CGFloat yOffset = self.belongsToPlayer ? 40.f : -20.f;
  
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f + yOffset);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Animate
  [logoSprite runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:.3f],
                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
                         [CCActionDelay actionWithDuration:.5f],
                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
                         [CCActionRemove action],
                         nil]];
   */
}

- (void) spawnGloveOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; ++n)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor];
    
    // Nothing found (just in case), continue and perform selector if the last glove orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeGlove;
    orb.orbColor = self.orbColor;
    orb.turnCounter = _orbsSpawnCounter;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:orb.column row:orb.row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:(n == count - 1) ? target : nil andCallback:selector];
    
    // Update orb
    [self performAfterDelay:.5f block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
    
    ++_orbsSpawned;
  }
}

- (void) removeAllGloveOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeGlove)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_skillActive) forKey:@"skillActive"];
  [result setObject:@(_confusionTurns) forKey:@"confusionTurns"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* skillActive = [dict objectForKey:@"skillActive"];
  if (skillActive) _skillActive = [skillActive boolValue];
  NSNumber* confusionTurns = [dict objectForKey:@"confusionTurns"];
  if (confusionTurns) _confusionTurns = [confusionTurns integerValue];
  
  return YES;
}

@end
