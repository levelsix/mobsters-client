//
//  SkillBombs.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBombs.h"
#import "NewBattleLayer.h"

@implementation SkillBombs

#pragma mark - Initialization

- (void) setDefaultValues
{
  // Properties
  [super setDefaultValues];
  
  _minBombs = 1;
  _maxBombs = 1;
  _initialBombs = 1;
  _bombCounter = 1;
  _bombDamage = 1;
  _bombChance = 0.2;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_BOMBS"] )
    _minBombs = value;
  else if ( [property isEqualToString:@"MAX_BOMBS"] )
    _maxBombs = value;
  else if ( [property isEqualToString:@"INITIAL_BOMBS"] )
    _initialBombs = value;
  else if ( [property isEqualToString:@"BOMB_COUNTER"] )
    _bombCounter = value;
  else if ( [property isEqualToString:@"BOMB_DAMAGE"] )
    _bombDamage = value;
  else if ( [property isEqualToString:@"BOMB_CHANCE"] )
    _bombChance = value;
}

#pragma mark - Overrides

- (SpecialOrbType) generateSpecialOrb
{
  NSInteger bombsOnBoard = [self specialsOnBoardCount:SpecialOrbTypeBomb];
  float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
  if ((rand < _bombChance && bombsOnBoard < _maxBombs) || bombsOnBoard < _minBombs)
    return SpecialOrbTypeBomb;
  
  return SpecialOrbTypeNone;
}

- (OrbColor) specialOrbColor
{
  return self.orbColor;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Initial bomb spawn
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
      [self initialSequence];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

// Jumping, showing overlay and spawning initial set
- (void) initialSequence
{
  [self showSkillPopupOverlay:YES withCompletion:^{
    [self performAfterDelay:0.5 block:^{
      [self spawnBombs:_initialBombs withTarget:self andSelector:@selector(skillTriggerFinished)];
    }];
  }];
}

// Adding bombs
- (void) spawnBombs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < count; n++)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = nil;
    NSInteger column, row;
    NSInteger counter = 0;
    do {
      column = rand() % (layout.numColumns-2) + 1;  // So we'll never spawn at the edge of the board
      row = rand() % (layout.numRows-2) + 1;
      orb = [layout orbAtColumn:column row:row];
      counter++;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone || orb.orbColor != self.orbColor) && counter < 1000);
    
    // Nothing found (just in case)
    if (counter == 1000)
    {
      if (n == count-1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
            [target performSelector:selector withObject:nil]; );
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeBomb;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:column row:row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:((n==count-1)?target:nil) andCallback:selector];
    
    // Update orb
    [self performAfterDelay:0.5 block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
}

@end
