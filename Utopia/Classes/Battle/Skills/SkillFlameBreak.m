//
//  SkillFlameBreak.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/4/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillFlameBreak.h"
#import "NewBattleLayer.h"
#import "Globals.h"

static const NSInteger kSwordOrbsMaxSearchIterations = 256;

@implementation SkillFlameBreak

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];

  _maxDamage = 0.f;
  _maxStunTurns = 0;
  _numOrbsToSpawn = 0;
  _orbsSpawnCounter = 0;
  _skillActive = NO;
  _turnsLeft = 0;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"RAND_DAMAGE_UPPER_LIMIT"])
    _maxDamage = value;
  if ([property isEqualToString:@"STUN_TURNS_UPPER_LIMIT"])
    _maxStunTurns = value;
  if ([property isEqualToString:@"DEF_NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  if ([property isEqualToString:@"DEF_ORBS_SPAWN_COUNTER"])
    _orbsSpawnCounter = value;
}

#pragma mark - Overrides

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  [super orbDestroyed:color special:type];
  
  if (type == SpecialOrbTypeSword)
  {
    _orbsSpawned--;
    if (_orbsSpawned == 0)
    {
      [self resetOrbCounter];
    }
  }
}

- (BOOL) shouldPersist
{
  return _skillActive;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfStun), nil];
}

- (void) restoreVisualsIfNeeded
{
  if (!self.belongsToPlayer)
    _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeSword];
  
  if (_skillActive)
    [self stunOpponent];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  /**********************
   * Offensive Triggers *
   **********************/
  
  /*
  if (trigger == SkillTriggerPointEnemyAppeared && !_logoShown)
  {
    if (execute)
    {
      _logoShown = YES;
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
    }
    return YES;
  }
   */
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (!_skillActive && [self skillIsReady])
    {
      if (execute)
      {
        _skillActive = YES;
        
        // Deal out of turn damage of a random amount
        _damageDone = arc4random_uniform((int)_maxDamage - 1) + 1;
        [self showSkillPopupOverlay:YES withCompletion:^{
          [self performAfterDelay:.5f block:^{
            [self beginOutOfTurnAttack];
          }];
        }];
        
        // Number of turns for the opponent to be stunned is inversely correlated
        // with the random damage done, e.g. max damage stuns for zero turns,
        // while min damage stuns for max turns allowed
        _turnsLeft = _maxStunTurns - floorf((_maxStunTurns + 1) * ((float)_damageDone / _maxDamage));
      }
      return YES;
    }
  }
  
  // At the end of the turn, diminish stun stacks
  if (trigger == SkillTriggerPointEndOfEnemyTurn && self.belongsToPlayer)
  {
    if (_skillActive && --_turnsLeft == 0)
    {
      _skillActive = NO;
      
      [self resetOrbCounter];
      [self endStun];
    }
  }
  
  // If the character dies before the stun runs up, make sure the stun doesn't persist
  if (trigger == SkillTriggerPointEnemyDefeated && self.belongsToPlayer)
  {
    _skillActive = NO;
    
    [self resetOrbCounter];
    [self endStun];
  }
  
  /**********************
   * Defensive Triggers *
   **********************/
  
  // Initial sword orbs spawn
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (!_skillActive && _orbsSpawned == 0 && [self skillIsReady])
    {
      if (execute)
      {
        [self showSkillPopupOverlay:YES withCompletion:^{
          [self performAfterDelay:.5f block:^{
            [self spawnSwordOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
          }];
        }];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if (!_skillActive)
    {
      if (execute)
      {
        // Update counters on sword orbs
        int usedUpOrbCount = [self updateSwordOrbs];
        if (usedUpOrbCount > 0)
        {
          _skillActive = YES;
          
          // If any orbs have reached zero turns left, deal out of turn damage of a random amount
          _damageReceived = arc4random_uniform((int)_maxDamage - 1) + 1;
          [self beginOutOfTurnAttack];
          
          // Number of turns for the opponent to be stunned is inversely correlated
          // with the random damage done, e.g. max damage stuns for zero turns,
          // while min damage stuns for max turns allowed
          _turnsLeft = _maxStunTurns - floorf((_maxStunTurns + 1) * ((float)_damageReceived / _maxDamage));
          
          _damageReceived *= usedUpOrbCount;
        }
        else
          [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  // At the end of the turn, diminish stun stacks
  if (trigger == SkillTriggerPointEndOfPlayerTurn && !self.belongsToPlayer)
  {
    if (_skillActive && --_turnsLeft == 0)
    {
      _skillActive = NO;
      
      [self resetOrbCounter];
      [self endStun];
    }
  }
  
  // If the character dies before the stun runs up, make sure the stun doesn't persist
  if (trigger == SkillTriggerPointPlayerMobDefeated && !self.belongsToPlayer)
  {
    _skillActive = NO;
    
    [self resetOrbCounter];
    [self endStun];
  }
  
  if (trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer)
  {
    if (execute)
    {
      // Remove all sword orbs added by this enemy
      [self removeAllSwordOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showLogo];
  
  // Perform attack animation
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f
                                                 shouldEvade:NO
                                                       enemy:self.enemySprite
                                                      target:self
                                                    selector:@selector(dealDamage)
                                              animCompletion:nil];
  else
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
  SkillLogStart(@"Flame Break -- Skill caused %d damage", self.belongsToPlayer ? _damageDone : _damageReceived);
  
  [self.battleLayer dealDamage:self.belongsToPlayer ? _damageDone : _damageReceived
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(stunOpponent)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:_damageReceived];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
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

- (void) stunOpponent
{
  SkillLogStart(@"Flame Break -- Skill caused opponent to stun for %ld turns", (long)_turnsLeft);
  
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isStunned = YES;
  
  [self addStunAnimations];
  
  if (!self.belongsToPlayer)
  {
    // Being stunned while in the middle of a turn
    // causes the player's turn to end immediately
    [self.battleLayer endMyTurnAfterDelay:.5f];
  }
  
  // Finish trigger execution
  [self performAfterDelay:.3f block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
      [self skillTriggerFinished];
    }];
  }];
}

- (void) addStunAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  // Make character blink yellow
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5f color:[CCColor yellowColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5f color:[CCColor whiteColor]],
                                                                           nil]];
  [action setTag:1914];
  [opponent.sprite runAction:action];
  
  [self addSkillSideEffectToOpponent:SideEffectTypeNerfStun turnsAffected:_turnsLeft];
}

- (void) endStun
{
  SkillLogStart(@"Flame Break -- Opponent no longer stunned");
  
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isStunned = NO;
  
  _turnsLeft = 0;
  
  [self endStunAnimations];
}

- (void) endStunAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:.3f color:[CCColor whiteColor]]];
  
  [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfStun];
}

- (int) updateSwordOrbs
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
      if (orb.specialOrbType == SpecialOrbTypeSword && orb.turnCounter > 0)
      {
        // Update counter
        --orb.turnCounter;
        
        // Update sprite
        OrbSprite* sprite = [layer spriteForOrb:orb];
        if (orb.turnCounter <= 0) // Use up the sword orb
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

- (void) spawnSwordOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
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
           counter < kSwordOrbsMaxSearchIterations);
    
    // Nothing found (just in case), continue and perform selector if the last sword orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeSword;
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

- (void) removeAllSwordOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeSword)
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
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* skillActive = [dict objectForKey:@"skillActive"];
  if (skillActive) _skillActive = [skillActive boolValue];
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft) _turnsLeft = [turnsLeft intValue];
  
  return YES;
}

@end
