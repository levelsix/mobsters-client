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
  _fixedDamageReceived = 0.f;
  _targetChanceToHitSelf = 0.f;
  _skillActive = NO;
  _confusionTurns = 0;
  _logoShown = NO;
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
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
  if ([property isEqualToString:@"TARGET_CHANCE_TO_HIT_SELF"])
    _targetChanceToHitSelf = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfConfusion), nil];
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  [super orbDestroyed:color special:type];
  
  if (type == SpecialOrbTypeGlove)
  {
    _orbsSpawned--;
    if (_orbsSpawned == 0)
    {
      [self resetOrbCounter];
    }
  }
}

- (void) restoreVisualsIfNeeded
{
  if (!self.belongsToPlayer)
    _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeGlove];
  
  if (_skillActive)
  {
    [self addSkillSideEffectToOpponent:SideEffectTypeNerfConfusion turnsAffected:_confusionTurns];
  }
}

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
      else
        self.player.isConfused = NO;
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  /**********************
   * Offensive Triggers *
   **********************/
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (!_skillActive && [self skillIsReady])
    {
      if (execute)
      {
        _skillActive = YES;
        
        [self showSkillPopupOverlay:YES withCompletion:^{
          [self performAfterDelay:.5f block:^{
            [self beginOutOfTurnAttack];
          }];
        }];
        
        [self addSkillSideEffectToOpponent:SideEffectTypeNerfConfusion turnsAffected:1];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn && self.belongsToPlayer)
  {
    if (_skillActive)
    {
      if (execute)
      {
        // Chance of enemy hitting self
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _targetChanceToHitSelf)
        {
          [self showLogo];
          
          // Tell NewBattleLayer that enemy will be confused on his next turn
          self.enemy.isConfused = YES;
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyDefeated && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerMobDefeated && self.belongsToPlayer))
  {
    if (_skillActive)
    {
      if (execute)
      {
        _skillActive = NO;
        [self resetOrbCounter];
        
        // Tell NewBattleLayer that enemy is no longer confused
        self.enemy.isConfused = NO;

        [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfConfusion];
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  /**********************
   * Defensive Triggers *
   **********************/
  
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
              [self spawnGloveOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
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
      const BOOL alreadyConfused = _confusionTurns > 0;
      // Update counters on glove orbs
      if ([self updateGloveOrbs])
      {
        _skillActive = YES;
        
        if (alreadyConfused)
          [self resetAfftectedTurnsCount:_confusionTurns forSkillSideEffectOnOpponent:SideEffectTypeNerfConfusion];
        else
          [self addSkillSideEffectToOpponent:SideEffectTypeNerfConfusion turnsAffected:_confusionTurns];
        
        // If any orbs have reached zero turns left, perform out of turn attack
        [self beginOutOfTurnAttack];
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
          
          // Tell NewBattleLayer that player is no longer confused
          self.player.isConfused = NO;

          [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfConfusion];
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if ((trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerMobDefeated && !self.belongsToPlayer))
  {
    if (execute)
    {
      if (_skillActive)
      {
        _skillActive = NO;
        [self resetOrbCounter];
        
        // Tell NewBattleLayer that player is no longer confused
        self.player.isConfused = NO;

        [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfConfusion];
      }
      
      if (trigger == SkillTriggerPointEnemyDefeated)
      {
        // Remove all glove orbs added by this enemy
        [self removeAllGloveOrbs];
        [self performAfterDelay:.3f block:^{
          [self skillTriggerFinished];
        }];
      }
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
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f
                                                 shouldEvade:NO
                                                       enemy:self.enemySprite
                                                      target:self
                                                    selector:@selector(dealDamage)
                                              animCompletion:nil];
  else
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
  [self.battleLayer dealDamage:self.belongsToPlayer ? _fixedDamageDone : _fixedDamageReceived
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageReceived];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
    [self skillTriggerFinished:YES];
  }];
}

- (void) showLogo
{
  /*
   * 2/4/15 - BN - Disabling skills displaying logos
   *
   
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
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
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor isInitialSkill:NO];
    
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
