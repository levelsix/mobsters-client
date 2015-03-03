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

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    SkillLogStart(@"Shallow Grave -- Skill activated");
    
    [self addDefensiveShieldForPlayer:self.belongsToPlayer ? self.player : self.enemy];
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffShallowGrave turnsAffected:self.belongsToPlayer ? self.turnsLeft : -1];
  }
}

- (NSInteger) getDuration
{
  // Defensive variation of Shallow Grave will remain active
  // for as longs there are grave orbs on the board
  return self.belongsToPlayer ? [super getDuration] : -1;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
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
  }
  
  /**********************
   * Defensive Triggers *
   **********************/
  
  // Grave orbs cleanup
  if ((trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer))
  {
    if ([self isActive])
    {
      if (trigger == SkillTriggerPointEnemyDefeated || [self specialsOnBoardCount:SpecialOrbTypeGrave] == 0)
      {
        if (execute)
        {
          [self endDurationNow];
        }
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
}

- (void) removeDefensiveShieldForPlayer:(BattlePlayer*)player
{
  player.minHealth = 0;
}

- (BOOL) onDurationStart
{
  SkillLogStart(@"Shallow Grave -- Skill activated");
  
  if (self.belongsToPlayer)
  {
    [self addDefensiveShieldForPlayer:self.player];
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffShallowGrave turnsAffected:self.turnsLeft];
  }
  else
  {
    [self spawnInitialGraveOrbs];
    [self addDefensiveShieldForPlayer:self.enemy];
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffShallowGrave turnsAffected:-1];
  }
  
  return [super onDurationStart];
}

- (BOOL) onDurationReset
{
  SkillLogStart(@"Shallow Grave -- Skill reactivated");
  
  if (self.belongsToPlayer)
  {
    [self addDefensiveShieldForPlayer:self.player];
    [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:SideEffectTypeBuffShallowGrave];
  }
  
  return NO;
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Shallow Grave -- Skill deactivated");
  
  [super onDurationEnd];
  
  if (self.belongsToPlayer)
  {
    [self removeDefensiveShieldForPlayer:self.player];
    [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffShallowGrave];
  }
  else
  {
    [self removeAllGraveOrbs];
    [self performAfterDelay:.3f block:^{
      [self removeDefensiveShieldForPlayer:self.enemy];
      [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffShallowGrave];
      [self skillTriggerFinished];
    }];
    return YES;
  }
  
  return NO;
}

- (void) showLogo
{
  /*
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
   */
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

@end
