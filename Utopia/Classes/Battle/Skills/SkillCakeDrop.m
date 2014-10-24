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
  [super setDefaultValues];
  
  _minCakes = 1;
  _maxCakes = 1;
  _initialCakes = 1;
  _initialSpeed = 2;
  _speedMultiplier = 1.1;
  _cakeChance = 0.1;
  _damage = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_CAKES"] )
    _minCakes = value;
  else if ( [property isEqualToString:@"MAX_CAKES"] )
    _maxCakes = value;
  else if ( [property isEqualToString:@"INITIAL_CAKES"] )
    _initialCakes = value;
  else if ( [property isEqualToString:@"INITIAL_SPEED"] )
    _initialSpeed = value;
  else if ( [property isEqualToString:@"SPEED_MULTIPLIER"] )
    _speedMultiplier = value;
  else if ( [property isEqualToString:@"CAKE_CHANCE"] )
    _cakeChance = value;
  else if ( [property isEqualToString:@"DAMAGE"] )
    _damage = value;
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _currentSpeed = _initialSpeed;
  _startedEating = NO;
  
  return self;
}

#pragma mark - Overrides

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if (type == SpecialOrbTypeCake && ! _startedEating)
  {
    _startedEating = YES;
    
    // Accelerate enemy
    _currentSpeed *= _speedMultiplier;
    self.enemy.speed = _currentSpeed;
    
    // Reset schedule data
    self.battleLayer.movesLeft = 0;
    [self.battleLayer.battleSchedule createScheduleForPlayerA:self.player.speed playerB:self.enemy.speed andOrder:ScheduleFirstTurnPlayer];
    self.battleLayer.shouldDisplayNewSchedule = YES;
    
    // Eat the cake animation
    [self performAfterDelay:1.5 block:^{
      
      _startedEating = NO;
      
      // Eat the cake and reload schedule UI then
      self.enemySprite.animationType = MonsterProto_AnimationTypeRanged;
      [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldFlinch:NO target:nil selector:nil];
    }];
  }
}

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  // Don't spawn cake in bottom half of the board
  if (row < 4)
    return NO;
  
  NSInteger cakesOnBoard = [self specialsOnBoardCount:SpecialOrbTypeCake];
  float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
  if ((rand < _cakeChance && cakesOnBoard < _maxCakes) || cakesOnBoard < _minCakes)
  {
    orb.specialOrbType = SpecialOrbTypeCake;
    orb.orbColor = OrbColorNone;
    return YES;
  }
  
  return NO;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Change enemy speed
  if (trigger == SkillTriggerPointEnemyInitialized)
  {
    if (execute)
    {
      self.enemy.speed = _currentSpeed;
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  // Initial cake spawn
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
      [self initialSequence];
    return YES;
  }
  
  // Player destruction
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    if (execute)
      [self startAttackingPlayer];
    return YES;
  }
  
  // Cakes cleanup
  if (trigger == SkillTriggerPointEnemyDefeated)
  {
    if (execute)
    {
      [self destroyAllCakes];
      [self performAfterDelay:0.3 block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

// Jumping and showing overlay
- (void) initialSequence
{
  [self showSkillPopupOverlay:YES withCompletion:^{
    [self performSelector:@selector(initialSequence2) withObject:nil afterDelay:0.5];
  }];
}

// Adding cake
- (void) initialSequence2
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleOrb* orb = nil;
  
  for (NSInteger n = 0; n < _initialCakes; n++)
  {
    NSInteger column, row;
    NSInteger counter = 0;
    do {
      column = rand() % layout.numColumns;
      row = layout.numRows - 1;
      orb = [layout orbAtColumn:column row:row];
      counter++;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone || orb.powerupType != PowerupTypeNone) && counter < 1000);
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeCake;
    orb.orbColor = OrbColorNone;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:column row:row];
    [bgdLayer updateTile:tile keepLit:YES withTarget:((n==_initialCakes-1)?self:nil) andCallback:@selector(skillTriggerFinished)]; // returning from the skill
    
    // Update orb
    [self performAfterDelay:0.5 block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
  
  // Update available swaps list
  [layout detectPossibleSwaps];
}

- (void) startAttackingPlayer
{
  [self makeSkillOwnerJumpWithTarget:self selector:@selector(startAttackingPlayerPhase2)];
}

- (void) startAttackingPlayerPhase2
{
  self.enemySprite.animationType = MonsterProto_AnimationTypeMelee; // To ensure that enemy will run
  [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:NO shouldFlinch:NO target:self selector:@selector(startAttackingPlayerPhase3)];
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
  
  // Remove enemy sprite and destroy all cakes after that
  [self.battleLayer blowupBattleSprite:self.enemySprite withBlock:^{
    [self destroyAllCakes];
  }];
  
  [self.battleLayer blowupBattleSprite:self.playerSprite withBlock:^{}];
  
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
  [self.battleLayer.droplessStageNums addObject:@(self.battleLayer.currentStageNum)];
  [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  
  // Checking player's health (it will effectively call moveToNextEnemy when no enemy is found)
  if ([self.battleLayer stagesLeft] == 0)
  {
    if ([self.battleLayer playerMobstersLeft] > 0)
      [self.battleLayer youWon];
    else
    {
      self.battleLayer.shouldShowContinueButton = NO;
      [self.battleLayer youLost];
    }
  }
  else {
    [self.battleLayer checkMyHealth]; // Switch mobster and proceed to new enemy or fail if no mobsters left
  }
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
      }
    }
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
