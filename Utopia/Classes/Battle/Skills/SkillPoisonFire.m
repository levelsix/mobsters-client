//
//  SkillPoisonFire.m
//  Utopia
//
//  Created by Rob Giusti on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonFire.h"
#import "NewBattleLayer.h"

static const NSInteger maxSearchIterations = 256;

@implementation SkillPoisonFire

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _numOrbsSpawned = 1;
  _orbSpawnTurnCounter = 5;
  
  _poisonStacks = 0;
  _quickAttackStacks = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"NUM_ORBS"])
    _numOrbsSpawned = value;
  if ( [property isEqualToString:@"TURN_COUNTER"])
    _orbSpawnTurnCounter = value;
}

- (int) poisonDamage
{
  if (self.belongsToPlayer) return [super poisonDamage];
  return [super poisonDamage] * _poisonStacks;
}

- (int) quickAttackDamage
{
  if (self.belongsToPlayer) return [super quickAttackDamage];
  return [super quickAttackDamage] * _quickAttackStacks;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      return [self checkOrbs];
    }
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

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    _poisonStacks++;
    return [self resetDuration];
  }
  else
  {
    if ([self checkOrbs])
      [self spawnPoisonFireOrbs:_numOrbsSpawned withTarget:nil andSelector:nil];
    else
      [self spawnPoisonFireOrbs:_numOrbsSpawned withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
  }
  return YES;
}

- (BOOL) checkOrbs
{
  int orbsComplete = [self updatePoisonFireOrbs];
  if (orbsComplete)
  {
    _poisonStacks += orbsComplete;
    _quickAttackStacks = orbsComplete;
    
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
    [self.battleLayer.orbLayer disallowInput];
    
    [self performAfterDelay:.5 block:^{
      [self resetDuration];
    }];
    
    return YES;
  }
  return NO;
}

- (void) spawnPoisonFireOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleOrb* orb;
  for (NSInteger n = 0; n < count; ++n) {
    NSInteger column, row;
    NSInteger counter = 0;
    do {
      column = rand() % layout.numColumns;
      row = (layout.numRows - 1) - rand() % 2; // Top two rows
      orb = [layout orbAtColumn:column row:row];
      ++counter;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone || orb.isLocked) &&
           counter < maxSearchIterations);
    
    // Update data
    orb.specialOrbType = SpecialOrbTypePoisonFire;
    orb.orbColor = OrbColorNone;
    orb.turnCounter = _orbSpawnTurnCounter;
    
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

- (int) updatePoisonFireOrbs
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
      if (orb.specialOrbType == SpecialOrbTypePoisonFire && orb.turnCounter > 0)
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
          do {
            orb.orbColor = [layout generateRandomOrbColor];
          } while ([layout hasChainAtColumn:column row:row]);
          
          // Reload sprite
          [sprite reloadSprite:YES];
          
          ++usedUpOrbCount;
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

- (void) removeAllSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypePoisonFire)
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

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_poisonStacks) forKey:@"poisonStacks"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* poisonStacks = [dict objectForKey:@"poisonStacks"];
  if (poisonStacks) _poisonStacks = [poisonStacks intValue];
  
  return YES;
}



@end
