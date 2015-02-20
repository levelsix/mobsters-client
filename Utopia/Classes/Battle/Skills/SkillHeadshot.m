//
//  SkillHeadshot.m
//  Utopia
//
//  Created by Behrouz N. on 12/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillHeadshot.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"

@implementation SkillHeadshot

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _fixedDamageReceived = 0.f;
  _fixedDamageDone = 0.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  if ([property isEqualToString:@"ORBS_SPAWN_COUNTER"])
    _orbsSpawnCounter = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
}

#pragma mark - Overrides

- (void) restoreVisualsIfNeeded
{
  _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeHeadshot];
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  [super orbDestroyed:color special:type];
  
  if (!self.belongsToPlayer && type == SpecialOrbTypeHeadshot)
  {
    _orbsSpawned--;
    if (_orbsSpawned == 0)
    {
      [self resetOrbCounter];
    }
  }
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  //If skill is charged, generate orbs
  if (_orbsSpawned == 0)
  {
    if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
        (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
    {
      if ([self skillIsReady])
      {
        if (execute)
        {
          // Jumping, showing overlay and spawning
          [self showSkillPopupOverlay:YES withCompletion:^{
            [self performAfterDelay:.5f block:^{
              [self spawnHeadshotOrbs:_numOrbsToSpawn isInitialSkill:NO withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
            }];
          }];
        }
        return YES;
      }
    }
  }
  
  // Update counters on headshot orbs
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeHeadshot];
      if ([self updateHeadshotOrbs])
      {
        // If any orbs have reached zero turns left, perform headshot
        [self beginHeadshot];
      }
      else
      {
        [self skillTriggerFinished];
      }
    }
    return YES;
  }
  
  // Player matched and removed all headshot orbs; time for a quick attack
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (execute)
    {
      if (_orbsSpawned > 0)
      {
        _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeHeadshot];
        if (_orbsSpawned == 0)
        {
          [self beginHeadshot];
        }
        else
          [self skillTriggerFinished];
        return YES;
      }
    }
  }
  
  // Remove all headshot orbs added when the user dies
  if ((trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerMobDefeated && self.belongsToPlayer))
  {
    if (execute)
    {
      [self removeAllHeadshotOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) updateHeadshotOrbs
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
      if (orb.specialOrbType == SpecialOrbTypeHeadshot && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the headshot orb
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
  
  return (usedUpOrbCount > 0);
}

- (void) beginHeadshot
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self resetOrbCounter];
  
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
                  withSelector:@selector(endHeadshot)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageReceived];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endHeadshot
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
//  if (self.belongsToPlayer && self.enemy.curHealth != 0.f)
//  {
//    [self performAfterDelay:.5f block:^{
//      [self spawnHeadshotOrbs:_numOrbsToSpawn isInitialSkill:NO withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
//    }];
//  }
//  else
  [self skillTriggerFinished];
}

- (void) showLogo
{
//  // Display logo
//  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
//  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
//                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
//  logoSprite.scale = 0.f;
//  [self.playerSprite.parent addChild:logoSprite z:50];
//  
//  // Animate
//  [logoSprite runAction:[CCActionSequence actions:
//                         [CCActionDelay actionWithDuration:.3f],
//                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
//                         [CCActionDelay actionWithDuration:.5f],
//                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
//                         [CCActionRemove action],
//                         nil]];
}

- (void) spawnHeadshotOrbs:(NSInteger)count isInitialSkill:(BOOL)isInitialSkill withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; ++n)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor isInitialSkill:isInitialSkill];
    
    // Nothing found (just in case), continue and perform selector if the last headshot orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeHeadshot;
    orb.orbColor = self.orbColor;
    if (self.belongsToPlayer) // Offensive skill
      orb.turnCounter = 0;
    else // Defensive skill
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

- (void) removeAllHeadshotOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeHeadshot)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

@end
