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
  
  _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeBullet];
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

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Initial bullet orb spawn
  if (trigger == SkillTriggerPointEnemyAppeared && !_logoShown)
  {
    if (execute)
    {
      _logoShown = YES;
      // Jumping, showing overlay and spawning initial set
      [self showSkillPopupOverlay:YES withCompletion:^{
        if (_orbsSpawned == 0)
        {
          [self performAfterDelay:.5f block:^{
            [self spawnBulletOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinished)];
          }];
        }
        else
          [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Update counters on bullet orbs
      if (_orbsSpawned > 0 && [self updateBulletOrbs])
      {
        // If any orbs have reached zero turns left, perform out of turn attack
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginOutOfTurnAttack)];
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
      // Remove all bullet orbs added by this enemy
      [self removeAllBulletOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) updateBulletOrbs
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
  
  return (usedUpOrbCount > 0);
}

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showLogo];
  
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
  [self.battleLayer dealDamage:_fixedDamageReceived
               enemyIsAttacker:YES
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];
  
  [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageReceived];
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
}

- (void) spawnBulletOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleOrb* orb = nil;
  
  for (NSInteger n = 0; n < count; ++n)
  {
    NSInteger column, row;
    NSInteger counter = 0;
    do {
      column = rand() % layout.numColumns;
      row = (layout.numRows - 1) - rand() % 2; // Top two rows
      orb = [layout orbAtColumn:column row:row];
      ++counter;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone || orb.isLocked) &&
           counter < kBulletOrbsMaxSearchIterations);
    
    // Nothing found (just in case), continue and perform selector if the last bullet orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeBullet;
    orb.orbColor = OrbColorNone;
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

- (void) removeAllBulletOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeBullet)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        do {
          orb.orbColor = [layout generateRandomOrbColor];
        } while ([layout hasChainAtColumn:column row:row]);
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

@end
