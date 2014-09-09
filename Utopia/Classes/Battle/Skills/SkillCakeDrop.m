//
//  SkillCakeDrop.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillCakeDrop.h"
#import "NewBattleLayer.h"

@implementation SkillCakeDrop

#pragma mark - Initialization

- (void) setDefaultValues
{
  // Properties
  [super setDefaultValues];
  
  _minCakes = 1;
  _maxCakes = 1;
  _initialSpeed = 0.1;
  _speedMultiplier = 1.1;
  _cakeChance = 0.1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_CAKES"] )
    _minCakes = value;
  else if ( [property isEqualToString:@"MAX_CAKES"] )
    _maxCakes = value;
  else if ( [property isEqualToString:@"INITIAL_SPEED"] )
    _initialSpeed = value;
  else if ( [property isEqualToString:@"SPEED_MULTIPLIER"] )
    _speedMultiplier = value;
  else if ( [property isEqualToString:@"CAKE_CHANCE"] )
    _cakeChance = value;
}

#pragma mark - Overrides

- (SpecialOrbType) generateSpecialOrb
{
  NSInteger cakesOnBoard = [self cakesOnBoardCount];
  float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
  if ((rand < _cakeChance && cakesOnBoard < _maxCakes) || cakesOnBoard < _minCakes)
    return SpecialOrbTypeCake;
  
  return SpecialOrbTypeNone;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger
{
  // Initial cake spawn
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    [self showSkillPopupOverlayWithCompletion:^{
      [self spawnCakeOnTop];
    }];
    return YES;
  }
  
  // Cakes cleanup
  if (trigger == SkillTriggerPointEnemyDefeated)
  {
    [self destroyAllCakes];
    return YES;
  }
  
  /*if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    [self spawnNewJelly];
    return YES;
  }*/
  
  return NO;
}

#pragma mark - Skill logic

- (void) spawnCakeOnTop
{
  // Do nothing if there are some cakes already
  if ([self cakesOnBoardCount] > 0)
  {
    [self skillTriggerFinished];
    return;
  }
  
  // Calculate position
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  NSInteger column = arc4random_uniform(layout.numColumns);
  NSInteger row = layout.numRows - 1;
  
  // Replace one of the top orbs with a cake
  BattleOrb* orb = [layout orbAtColumn:column row:row];
  orb.specialOrbType = SpecialOrbTypeCake;
  orb.orbColor = OrbColorNone;
  
  // Update visuals
  OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
  BattleTile* tile = [layout tileAtColumn:column row:row];
  [bgdLayer updateTile:tile withTarget:self andCallback:@selector(skillTriggerFinished)]; // returning from the skill
  
  [self performAfterDelay:0.5 block:^{
    OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
    [orbSprite reloadSprite:YES];
  }];
}

- (void) destroyAllCakes
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeCake)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        do {
          orb.orbColor = arc4random_uniform(layout.numColors) + OrbColorFire;
        } while ([layout hasChainAtColumn:column row:row]);
        
        OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
        
        [self performAfterDelay:0.3 block:^{
          [self skillTriggerFinished];
        }];
      }
    }
}

#pragma mark - Helpers

- (NSInteger) cakesOnBoardCount
{
  NSInteger result = 0;
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeCake)
        result++;
    }
  return result;
}

@end
