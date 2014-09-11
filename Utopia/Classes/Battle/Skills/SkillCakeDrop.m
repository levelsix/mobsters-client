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
  _initialSpeed = 2;
  _speedMultiplier = 1.1;
  _cakeChance = 0.1;
  _damage = 1;
  
  _currentSpeed = _initialSpeed;
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
  else if ( [property isEqualToString:@"DAMAGE"] )
    _damage = value;
}

#pragma mark - Overrides

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if (type == SpecialOrbTypeCake)
  {
    // Accelerate enemy
    _currentSpeed *= _speedMultiplier;
    self.enemy.speed = _currentSpeed;
    
    // Reset schedule
    [self.battleLayer.battleSchedule createScheduleForPlayerA:self.player.speed playerB:self.enemy.speed andOrder:ScheduleFirstTurnPlayer];
    
    // Reload schedule UI
    [self.battleLayer prepareScheduleView];
  }
}

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
  if ([super skillCalledWithTrigger:trigger])
    return YES;
  
  // Change enemy speed
  if (trigger == SkillTriggerPointEnemyInitialized)
  {
    self.enemy.speed = _currentSpeed;
    [self skillTriggerFinished];
    return YES;
  }
  
  // Initial cake spawn
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
/*      // Do nothing if there are some cakes already or start jumping and spawning otherwise
      if ([self cakesOnBoardCount] > 0)
        [self skillTriggerFinished];
      else*/
    [self initialSequence];
    return YES;
  }
  
  // Player destruction
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    [self startAttackingPlayer];
    return YES;
  }
  
  // Cakes cleanup
  if (trigger == SkillTriggerPointEnemyDefeated)
  {
    [self destroyAllCakes];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

// Jumping and showing overlay
- (void) initialSequence
{
  [self showSkillPopupOverlay:YES withCompletion:^{
    [self initialSequence2];
  }];
}

// Adding cake
- (void) initialSequence2
{
  // Calculate position
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  NSInteger column = arc4random_uniform(layout.numColumns);
  NSInteger row = layout.numRows - 1;
  
  // Replace one of the top orbs with a cake
  BattleOrb* orb = [layout orbAtColumn:column row:row];
  orb.specialOrbType = SpecialOrbTypeCake;
  orb.orbColor = OrbColorNone;
  
  // Update available swaps list
  [layout detectPossibleSwaps];
  
  // Update visuals
  OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
  BattleTile* tile = [layout tileAtColumn:column row:row];
  [bgdLayer updateTile:tile withTarget:self andCallback:@selector(skillTriggerFinished)]; // returning from the skill
  
  [self performAfterDelay:0.5 block:^{
    OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
    [orbSprite reloadSprite:YES];
  }];
}

- (void) startAttackingPlayer
{
  [self makeSkillOwnerJumpWithTarget:self selector:@selector(startAttackingPlayerPhase2)];
}

- (void) startAttackingPlayerPhase2
{
  self.enemySprite.animationType = MonsterProto_AnimationTypeMelee; // To ensure that enemy will run
  [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:NO target:self selector:@selector(startAttackingPlayerPhase3)];
}

- (void) startAttackingPlayerPhase3
{
  // Blow up the bigger explosion
  CCParticleSystem* explosion = [CCParticleSystem particleWithFile:@"cakekidexplode.plist"];
  explosion.position = self.enemySprite.position;
  explosion.scale = 0.5;
  explosion.autoRemoveOnFinish = YES;
  [self.enemySprite.parent addChild:explosion];
  
  // Deal damage to the player
  self.battleLayer.enemyDamageDealt = self.player.curHealth;
  self.player.curHealth = 0.0;
  
  // Remove enemy sprite
  [self.battleLayer blowupBattleSprite:self.enemySprite withBlock:^{}];
  
  // Deal damage to the enemy and erase him/her
  self.enemy.curHealth = 0.0;
  self.battleLayer.enemyDamageDealt = YES;
  [self.battleLayer updateHealthBars];
  self.battleLayer.enemyPlayerObject = nil;
  self.battleLayer.currentEnemy = nil;
  [self.battleLayer.hudView removeBattleScheduleView];
  
  // Finish the skill execution
  [self skillTriggerFinished];
  
  // Send server updated values for health
  [self.battleLayer sendServerUpdatedValues];
  
  // Checking player's health (it will effectively call moveToNextEnemy when no enemy is found)
  if ([self.battleLayer stagesLeft] == 0)
  {
    [self.battleLayer blowupBattleSprite:self.playerSprite withBlock:^{}];
    if ([self.battleLayer playerMobstersLeft] > 0)
      [self.battleLayer youWon];
    else
      [self.battleLayer youLost];
  }
  else
    [self.battleLayer checkMyHealth]; // Switch mobster and proceed to new enemy or fail if no mobsters left
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

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_currentSpeed) forKey:@"currentSpeed"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* currentSpeed = [dict objectForKey:@"currentSpeed"];
  if (currentSpeed)
    _currentSpeed = [currentSpeed floatValue];
  
  return YES;
}

@end
