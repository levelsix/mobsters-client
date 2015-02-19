//
//  SkillShallowGrave.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillShallowGrave.h"
#import "NewBattleLayer.h"
#import "Globals.h"

static const NSInteger kGraveOrbsMaxSearchIterations = 256;

@implementation SkillShallowGrave

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _minHPAllowed = 0;
  _graveSpawnCount = 0;
  _skillActive = NO;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"MIN_HP_ALLOWED"])
    _minHPAllowed = value;
  if ([property isEqualToString:@"DEF_SPAWN_COUNT"])
    _graveSpawnCount = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffShallowGrave), nil];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ((trigger == SkillTriggerPointEnemyAppeared      && !_logoShown) ||
      (trigger == SkillTriggerPointStartOfPlayerTurn  && !_logoShown) ||
      (trigger == SkillTriggerPointStartOfEnemyTurn   && !_logoShown))
  {
    if (execute)
    {
      _logoShown = YES;
      /*
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
       */
      
      // Will restore visuals if coming back to a battle after leaving midway
      if ((self.belongsToPlayer && [self isActive]) || (!self.belongsToPlayer && _skillActive))
      {
        SkillLogStart(@"Shallow Grave -- Skill activated");
        
        [self addDefensiveShieldForPlayer:self.belongsToPlayer ? self.player : self.enemy];
        
        BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
        [bs addSkillSideEffect:SideEffectTypeBuffShallowGrave];
      }
      
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  /**********************
   * Offensive Triggers *
   **********************/
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer)
    {
      if (execute)
      {
        [self tickDuration];
        [self showLogo];
        [self performAfterDelay:.3f block:^{
          [self skillTriggerFinished];
        }];
      }
      return YES;
    }
    
    if (trigger == SkillTriggerPointEnemyDefeated && self.belongsToPlayer)
    {
      if (execute)
      {
        [self endDurationNow];
      }
      return NO;
    }
  }
  
  /**********************
   * Defensive Triggers *
   **********************/
  
  // Initial grave orbs spawn
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (!_skillActive && [self skillIsReady])
    {
      if (execute)
      {
        SkillLogStart(@"Shallow Grave -- Skill activated");
        
        _skillActive = YES;
        
        [self showSkillPopupOverlay:YES withCompletion:^{
          [self performSelector:@selector(spawnInitialGraveOrbs) withObject:nil afterDelay:.5f];
          [self addDefensiveShieldForPlayer:self.enemy];
          
          [self.enemySprite addSkillSideEffect:SideEffectTypeBuffShallowGrave];
        }];
      }
      return YES;
    }
  }
  
  // Grave orbs cleanup
  if ((trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer))
  {
    if (_skillActive)
    {
      if (trigger == SkillTriggerPointEnemyDefeated || [self specialsOnBoardCount:SpecialOrbTypeGrave] == 0)
      {
        if (execute)
        {
          SkillLogStart(@"Shallow Grave -- Skill deactivated");
          
          _skillActive = NO;
          [self resetOrbCounter];
          
          [self removeAllGraveOrbs];
          [self performAfterDelay:.3f block:^{
            [self removeDefensiveShieldForPlayer:self.enemy];
            [self.enemySprite removeSkillSideEffect:SideEffectTypeBuffShallowGrave];
            [self skillTriggerFinished];
          }];
        }
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) addDefensiveShieldForPlayer:(BattlePlayer*)player
{
  // Do not allow player's health to fall below a certain
  // threshold for a predefined number of turns
  player.minHealth = _minHPAllowed;
  
  // TODO - Add some visual effect to the player to signify the active skill
}

- (void) removeDefensiveShieldForPlayer:(BattlePlayer*)player
{
  player.minHealth = 0;
  
  // TODO - Remove visual effect from the player
}

- (BOOL) onDurationStart
{
  if (self.belongsToPlayer)
  {
    SkillLogStart(@"Shallow Grave -- Skill activated");
    
    [self addDefensiveShieldForPlayer:self.player];
    [self.playerSprite addSkillSideEffect:SideEffectTypeBuffShallowGrave];
    return [super onDurationStart];
  }
  
  return NO;
}

- (BOOL) onDurationReset
{
  if (self.belongsToPlayer)
  {
    SkillLogStart(@"Shallow Grave -- Skill reactivated");
    
    [self addDefensiveShieldForPlayer:self.player];
  }
  
  return NO;
}

- (BOOL) onDurationEnd
{
  if (self.belongsToPlayer)
  {
    SkillLogStart(@"Shallow Grave -- Skill deactivated");
   
    [super onDurationEnd];
    [self removeDefensiveShieldForPlayer:self.player];
    [self.playerSprite removeSkillSideEffect:SideEffectTypeBuffShallowGrave];
  }
  
  return NO;
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

- (void) spawnInitialGraveOrbs
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleOrb* orb = nil;
  
  for (NSInteger n = 0; n < _graveSpawnCount; ++n)
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
           counter < kGraveOrbsMaxSearchIterations);
    
    // Nothing found (just in case), continue and perform selector if the last grave orb
    if (!orb)
    {
      if (n == _graveSpawnCount - 1)
        [self skillTriggerFinishedActivated];
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeGrave;
    orb.orbColor = OrbColorNone;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:column row:row];
    [bgdLayer updateTile:tile
                 keepLit:YES
              withTarget:(n == _graveSpawnCount - 1) ? self : nil
             andCallback:@selector(skillTriggerFinishedActivated)];
    
    // Update orb
    [self performAfterDelay:.5f block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
  
  // Update available swaps list
  [layout detectPossibleSwaps];
}

- (void) removeAllGraveOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeGrave)
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
  [result setObject:@(_skillActive) forKey:@"skillActive"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* skillActive = [dict objectForKey:@"skillActive"];
  if (skillActive) _skillActive = [skillActive boolValue];
  
  return YES;
}

@end
