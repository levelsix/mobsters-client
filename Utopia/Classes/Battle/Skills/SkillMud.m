//
//  SkillMud.m
//  Utopia
//
//  Created by Behrouz N. on 12/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillMud.h"
#import "NewBattleLayer.h"

static const NSInteger kMudOrbsMaxSearchIterations = 1024;

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * DEPRECATION WARNING
 *
 * For now there are no plans to use this skill in the near
 * future, so the code has not been updated with the recent
 * changes to skills (orb-activated, duration, logo, etc.)
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

@implementation SkillMud

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _initialSpawnCount = 0;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"INITIAL_SPAWN_COUNT"])
    _initialSpawnCount = value;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEnemyAppeared && !_logoShown)
  {
    if (execute)
    {
      _logoShown = YES;
      [self showSkillPopupOverlay:YES withCompletion:^{
        [self performAfterDelay:.5f block:^{
          [self spawnInitialMud];
        }];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) spawnRandomMudWithCallback:(SEL)callback
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleTile* tile = nil;
  
  // Find the tile
  NSInteger counter = 0;
  do {
    NSInteger row = rand() % layout.numRows;  // rand() here is calculated using the seed from spawnInitialMud
    NSInteger col = rand() % layout.numColumns;
    tile = [layout tileAtColumn:col row:row];
    ++counter;
  } while (tile.typeBottom != TileTypeNormal && counter < kMudOrbsMaxSearchIterations);
  
  if (counter < kMudOrbsMaxSearchIterations)
  {
    // Update model
    tile.typeBottom = TileTypeMud;
  
    // Update visuals
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    [bgdLayer updateTile:tile
                 keepLit:(_currentTrigger == SkillTriggerPointStartOfEnemyTurn) ? NO : [self.battleLayer.battleSchedule nextTurnIsPlayers]
              withTarget:self
             andCallback:callback];
  }
  else
    if (callback)
      SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([self performSelector:callback];);
}

- (void) spawnInitialMud
{
  // Calculating seed for pseudo-random generation (so upon deserialization pattern will be the same)
  [self preseedRandomization];
  
  for (NSInteger n = 0; n < _initialSpawnCount; ++n)
    [self spawnRandomMudWithCallback:(n == _initialSpawnCount - 1) ? @selector(skillTriggerFinished) : nil];
}

@end
