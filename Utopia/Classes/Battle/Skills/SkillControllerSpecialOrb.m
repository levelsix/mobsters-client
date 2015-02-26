//
//  SkillControllerSpecialOrb.m
//  Utopia
//
//  Created by Rob Giusti on 2/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"
#import "NewBattleLayer.h"

#define MAX_SEARCH_ITERATIONS 256

@implementation SkillControllerSpecialOrb

- (SpecialOrbType) specialType
{
  return SpecialOrbTypeNone;
}

- (SpecialOrbSpawnZone) spawnZone
{
  return SpecialOrbSpawnColor;
}

- (BOOL) keepColor
{
  return YES;
}

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _orbsPerSpawn = 1;
  _orbSpawnCounter = 0;
  _maxOrbs = 10;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  if ([property isEqualToString:@"NUM_ORBS_TO_SPAWN"])
    _orbsPerSpawn = value;
  else if ([property isEqualToString:@"ORBS_SPAWN_COUNTER"])
    _orbSpawnCounter = value;
  else if ([property isEqualToString:@"MAX_ORBS"])
    _maxOrbs = value;
}

- (BOOL) skillDefCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillDefCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEnemyDefeated && ![self shouldPersist])
  {
    if (execute)
    {
      [self removeSpecialOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && _orbSpawnCounter > 0)
  {
    if (execute)
    {
      return [self checkSpecialOrbs];
    }
  }
  
  return NO;
}

- (BOOL) onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  return NO;
}

- (BOOL) checkSpecialOrbs
{
  NSInteger _orbsFinished = [self updateSpecialOrbs];
  if (_orbsFinished)
  {
    return [self onSpecialOrbCounterFinish:_orbsFinished];
  }
  return NO;
}

- (BOOL) activate
{
  if (!self.belongsToPlayer)
  {
    _orbsSpawned = [self specialsOnBoardCount:[self specialType]];
    
    NSInteger orbsToSpawn = MIN(_orbsPerSpawn, _maxOrbs - _orbsSpawned);
    
    if ([self checkSpecialOrbs])
      [self spawnSpecialOrbs:orbsToSpawn withTarget:nil andSelector:nil];
    else
      [self spawnSpecialOrbs:orbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
    
    if ([self doesRefresh])
      [self resetOrbCounter];
    
    return YES;
  }
  return [super activate];
}

- (void) spawnSpecialOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleOrb* orb;
  
  if (count == 0)
  {
    if (target && selector)
      SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
  }
  
  for (NSInteger n = 0; n < count; ++n)
  {
    orb = [self pickOrb:layout];
    
    // Nothing found (just in case), continue and perform selector if the last special orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = [self specialType];
    orb.orbColor = [self keepColor] ? self.orbColor : OrbColorNone;
    orb.turnCounter = _orbSpawnCounter;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:orb.column row:orb.row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:(n == count - 1) ? target : nil andCallback:selector];
    
    // Update orb
    [self performAfterDelay:.5f block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
}

- (void) removeSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == [self specialType])
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        
        if (orb.orbColor == OrbColorNone)
        {
          do {
            orb.orbColor = [layout generateRandomOrbColor];
          } while ([layout hasChainAtColumn:column row:row]);
        }
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

- (BattleOrb*) pickOrb:(BattleOrbLayout*)layout
{
  switch ([self spawnZone]) {
    case SpecialOrbSpawnColor: {
      return [layout findOrbWithColorPreference:self.orbColor isInitialSkill:NO];
      break;
    }
      
    case SpecialOrbSpawnTop: {
      BattleOrb* orb;
      NSInteger column, row;
      NSInteger counter = 0;
      do {
        column = rand() % layout.numColumns;
        row = (layout.numRows - 1) - rand() % 2; // Top two rows
        orb = [layout orbAtColumn:column row:row];
        ++counter;
      }
      while ((!orb || orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone || orb.isLocked) &&
             counter < MAX_SEARCH_ITERATIONS);
      
      return orb;
    }
      
    default:
      return nil;
  }
}

- (NSInteger) updateSpecialOrbs
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
      if (orb.specialOrbType == [self specialType] && orb.turnCounter > 0)
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
          
          // Change orb color, if necessary
          if (orb.orbColor == OrbColorNone)
          {
            do {
              orb.orbColor = [layout generateRandomOrbColor];
            } while ([layout hasChainAtColumn:column row:row]);
          }
          
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

@end
