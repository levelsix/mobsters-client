//
//  SkillEnergize.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillEnergize.h"
#import "NewBattleLayer.h"
#import "Globals.h"

static const NSInteger kBatteryOrbsMaxSearchIterations = 256;

@implementation SkillEnergize

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _speedIncrease = 0.f;
  _attackIncrease = 0.f;
  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _curSpeedMultiplier = 1.f;
  _curAttackMultiplier = 1.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"SPEED_INCREASE_PERC"])
    _speedIncrease = value;
  if ([property isEqualToString:@"ATTACK_INCREASE_PERC"])
    _attackIncrease = value;
  if ([property isEqualToString:@"DEF_NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  if ([property isEqualToString:@"DEF_ORBS_SPAWN_COUNTER"])
    _orbsSpawnCounter = value;
}

#pragma mark - Overrides

- (void) restoreVisualsIfNeeded
{
  if (!self.belongsToPlayer)
    _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeBattery];
}

- (BOOL) doesRefresh
{
  return !self.belongsToPlayer;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (player == self.belongsToPlayer)
    {
      SkillLogStart(@"Energize -- Multiplying damage by %.2f", _curAttackMultiplier);
      
      return damage * _curAttackMultiplier;
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Update counters on special orbs
      if (_orbsSpawned > 0 && [self updateSpecialOrbs])
      {
        SkillLogStart(@"Energize -- Skill activated");
        
        _curSpeedMultiplier += _speedIncrease;
        _curAttackMultiplier += _attackIncrease;
        
        [self updateSkillOwnerSpeed];
        return YES;
      }
      
      //[self skillTriggerFinished];
    }
    //return YES;
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
  
  if ((trigger == SkillTriggerPointPlayerInitialized && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyInitialized && !self.belongsToPlayer))
  {
    if (execute)
    {
      _initialSpeed = self.belongsToPlayer ? self.player.speed : self.enemy.speed;
      
      SkillLogStart(@"Energize -- Inital speed is %d", _initialSpeed);
      
      if ([self isActive] && _curSpeedMultiplier > 1.f)
      {
        // Restore speed if coming back to a battle after leaving midway
        [self updateSkillOwnerSpeed];
      }
      
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  if ([self isActive])
  {
    if ((trigger == SkillTriggerPointPlayerDealsDamage && self.belongsToPlayer) ||
        (trigger == SkillTriggerPointEnemyDealsDamage && !self.belongsToPlayer))
    {
      if (execute)
      {
        if (_curAttackMultiplier > 1.f)
        {
          [self showAttackMultiplier];
        }
        
        [self performAfterDelay:.3f block:^{
          [self skillTriggerFinished];
        }];
      }
      return YES;
    }
    
    if ((trigger == SkillTriggerPointStartOfPlayerTurn && self.belongsToPlayer) ||
        (trigger == SkillTriggerPointStartOfEnemyTurn && !self.belongsToPlayer))
    {
      if (execute)
      {
        [self tickDuration];
        if ([self isActive])
          [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    return [self resetDuration];
  }
  else
  {
    [self spawnSpecialOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
    return YES;
  }
}

- (BOOL) onDurationStart
{
  SkillLogStart(@"Energize -- Skill activated");
  
  _curSpeedMultiplier += _speedIncrease;
  _curAttackMultiplier += _attackIncrease;
  
  [self updateSkillOwnerSpeed];
  
  return YES;
}

- (BOOL) onDurationReset
{
  SkillLogStart(@"Energize -- Skill reactivated (buffs will stack)");
  
  return [self onDurationStart];
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Energize -- Skill deactivated");
  
  _curSpeedMultiplier = 1.f;
  _curAttackMultiplier = 1.f;
  
  [self updateSkillOwnerSpeed];
  
  return [super onDurationEnd];
}

- (void) updateSkillOwnerSpeed
{
  BattlePlayer* bp = self.belongsToPlayer ? self.player : self.enemy;
  bp.speed = _initialSpeed * _curSpeedMultiplier;
  
  SkillLogStart(@"Energize -- Setting speed to %d", bp.speed);
  
  // Recalculate battle schedule based on new speeds
  [self.battleLayer.battleSchedule createScheduleForPlayerA:self.player.speed
                                                    playerB:self.enemy.speed
                                                   andOrder:[self.battleLayer.battleSchedule getNthMove:-1] ? ScheduleFirstTurnPlayer : ScheduleFirstTurnEnemy];
  [self.battleLayer prepareScheduleView];
  
  [self performAfterDelay:1 block:^{
    [self skillTriggerFinished];
  }];
}

- (void) showAttackMultiplier
{
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 20.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display damage modifier label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.3gX DAMAGE", _curAttackMultiplier] fontName:@"GothamNarrow-Ultra" fontSize:12];
  floatingLabel.position = ccp(logoSprite.spriteFrame.rect.size.width * .5f, -13.f);
  floatingLabel.fontColor = [CCColor colorWithRed:255.f / 225.f green:44.f / 225.f blue:44.f / 225.f];
  floatingLabel.outlineColor = [CCColor whiteColor];
  floatingLabel.shadowOffset = ccp(0.f, -1.f);
  floatingLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.75f];
  floatingLabel.shadowBlurRadius = 2.f;
  [logoSprite addChild:floatingLabel];
  
  // Animate both
  [logoSprite runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:.3f],
                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
                         [CCActionDelay actionWithDuration:.5f],
                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
                         [CCActionRemove action],
                         nil]];
}

- (int) updateSpecialOrbs
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
      if (orb.specialOrbType == SpecialOrbTypeBattery && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the special orb
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

- (void) spawnSpecialOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
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
           counter < kBatteryOrbsMaxSearchIterations);
    
    // Nothing found (just in case), continue and perform selector if the last special orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeBattery;
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

- (void) removeAllSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeBattery)
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
  [result setObject:@(_curSpeedMultiplier) forKey:@"curSpeedMultiplier"];
  [result setObject:@(_curAttackMultiplier) forKey:@"curAttackMultiplier"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* curSpeedMultiplier = [dict objectForKey:@"curSpeedMultiplier"];
  if (curSpeedMultiplier) _curSpeedMultiplier = [curSpeedMultiplier floatValue];
  NSNumber* curAttackMultiplier = [dict objectForKey:@"curAttackMultiplier"];
  if (curAttackMultiplier) _curAttackMultiplier = [curAttackMultiplier floatValue];
  
  return YES;
}

@end
