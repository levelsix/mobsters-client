//
//  SkillHellFire.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/30/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillHellFire.h"
#import "NewBattleLayer.h"

static const NSInteger kBulletOrbsMaxSearchIterations = 256;

@implementation SkillHellFire

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _fixedDamageReceived = 0.f;
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
}

#pragma mark - Overrides

- (void) restoreVisualsIfNeeded
{
  if (!self.belongsToPlayer)
    _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeBullet];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  BOOL didAttack = NO;
  BOOL didSpawn = NO;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeBullet];
      _orbsConsumed = [self updateBulletOrbs];
      // Update counters on bullet orbs
      if (_orbsConsumed > 0)
      {
        // If any orbs have reached zero turns left, perform out of turn attack
        [self beginOutOfTurnAttack];
        return YES;
      }
    }
  }
  
  // Initial bullet orb spawn
  if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
      (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self spawnOrbs];
      }
      return YES;
    }
  }

  if (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Remove all bullet orbs added by this enemy
      [self removeAllBulletOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return didAttack || didSpawn;
}

#pragma mark - Skill logic

- (int) updateBulletOrbs
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
      if (orb.specialOrbType == SpecialOrbTypeBullet && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the bullet orb
        {
          // Clone the orb sprite to be used in the visual effect
          CCSprite* clonedSprite = [CCSprite spriteWithTexture:sprite.orbSprite.texture rect:sprite.orbSprite.textureRect];
          clonedSprite.position = [bgdLayer convertToNodeSpace:[sprite.orbSprite convertToWorldSpaceAR:sprite.orbSprite.position]];
          clonedSprite.zOrder = sprite.orbSprite.zOrder + 100;
          [clonedOrbs addObject:clonedSprite];
          
          // Change sprite type
          orb.specialOrbType = SpecialOrbTypeNone;
          do {
            orb.orbColor = [layout generateRandomOrbColor];
          } while ([layout hasChainAtColumn:column row:row]);
          
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

- (int)quickAttackDamage
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];

  if ([self skillIsReady])
    [self spawnOrbs];
  else
    [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
      [self skillTriggerFinished:YES];
    }];
}

- (void) showLogo
{
  [self dealQuickAttack];
  [self endDurationNow];
  [self resetOrbCounter];
  [self removeSpecialOrbs];
  return YES;
}

- (void)onAllSpecialsDestroyed
{
  [self resetOrbCounter];
}

@end
