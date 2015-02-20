//
//  SkillKnockout.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillKnockout.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillKnockout

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];

  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _fixedDamageDone = 0;
  _fixedDamageReceived = 0;
  _enemyHealthThreshold = 0;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  if ([property isEqualToString:@"ORBS_SPAWN_COUNTER"])
    _orbsSpawnCounter = value;
  if ([property isEqualToString:@"ENEMY_HP_THRESHOLD"])
    _enemyHealthThreshold = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
}

#pragma mark - Overrides

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  [super orbDestroyed:color special:type];
  
  if (type == SpecialOrbTypeFryingPan)
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
    _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeFryingPan];
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
    if ([self skillIsReady])
    {
      if (execute)
      {
        SkillLogStart(@"Knockout -- Skill activated");
        
        // Perform out of turn attack and either instantly kill the target or deal fixed damage
        [self showSkillPopupOverlay:YES withCompletion:^{
          [self performAfterDelay:.5f block:^{
            [self beginOutOfTurnAttack];
          }];
        }];
      }
      return YES;
    }
  }
  
  /**********************
   * Defensive Triggers *
   **********************/
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (_orbsSpawned == 0 && [self skillIsReady])
    {
      if (execute)
      {
        // Spawn special orbs when skill is activated
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self performAfterDelay:.5f block:^{
            [self spawnSpecialOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
          }];
        }];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Update counters on special orbs
      _orbsConsumed = [self updateSpecialOrbs];
      if (_orbsConsumed > 0)
      {
        // If any orbs have reached zero turns left, Perform out of turn attack
        // and either instantly kill the target or deal fixed damage
        [self beginOutOfTurnAttack];
      }
      else
        [self skillTriggerFinished];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Remove all special orbs added by this enemy
      [self removeAllSpecialOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (int) updateSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
  
  int usedUpOrbCount = 0;
  NSMutableSet* clonedOrbs = [NSMutableSet set];
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeFryingPan && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the special orb
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
  
  return usedUpOrbCount;
}

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  const SEL selector = ((self.belongsToPlayer ? self.enemy : self.player).curHealth < _enemyHealthThreshold)
    ? @selector(instantlyKillEnemy)
    : @selector(dealDamageToEnemy);

  // Perform attack animation
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f
                                                 shouldEvade:NO
                                                       enemy:self.enemySprite
                                                      target:self
                                                    selector:selector
                                              animCompletion:nil];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite
                                             shouldReturn:YES
                                              shouldEvade:NO
                                             shouldFlinch:YES
                                                   target:self
                                                 selector:selector
                                           animCompletion:nil];
}

- (void) dealDamageToEnemy
{
  [self.battleLayer dealDamage:self.belongsToPlayer ? _fixedDamageDone : _fixedDamageReceived * _orbsConsumed
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageReceived * _orbsConsumed];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self resetOrbCounter];
  [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
    [self skillTriggerFinished:YES];
  }];
}

- (void) instantlyKillEnemy
{
  [self.battleLayer instantSetHealthForEnemy:self.belongsToPlayer
                                          to:0
                                  withTarget:self
                                 andSelector:@selector(endOutOfTurnAttack)];
}

- (void) spawnSpecialOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; ++n)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor isInitialSkill:NO];
    
    // Nothing found (just in case), continue and perform selector if the last special orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeFryingPan;
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

- (void) removeAllSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeFryingPan)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

@end
