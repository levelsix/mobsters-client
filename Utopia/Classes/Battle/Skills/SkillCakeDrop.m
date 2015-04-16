//
//  SkillCakeDrop.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillCakeDrop.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"
#import "SkillManager.h"

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
  _skillLockActive = NO;
  
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
    [self performBlockAfterDelay:1.5 block:^{
      
      _startedEating = NO;
      
      // Eat the cake and reload schedule UI then
      self.enemySprite.muteAttacks = YES;
      self.enemySprite.animationType = MonsterProto_AnimationTypeRanged;
      [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldEvade:NO shouldMiss:NO shouldFlinch:NO
                                                     target:self selector:@selector(finishedEating) animCompletion:nil];
    }];
  }
}

- (void) finishedEating
{
  _startedEating = NO;
  if (_skillLockActive)
  {
    [self skillTriggerFinished];
  }
  
  _skillLockActive = NO;
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
    orb.damageMultiplier = 1;
    return YES;
  }
  
  return NO;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (_startedEating)
  {
    if (execute)
    {
      _skillLockActive = YES;
    }
    return YES;
  }
  
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
    [self.battleLayer.orbLayer toggleArrows:YES];
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
      [self performBlockAfterDelay:0.3 block:^{
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
  [SoundEngine puzzleSkillActivated];
  [self showSkillPopupOverlay:YES withCompletion:^{
    [self performSelector:@selector(initialSequence2) withObject:nil afterDelay:0.5];
  }];
}

// Adding cake
- (void) initialSequence2
{
  [self preseedRandomization];
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  
  for (NSInteger n = 0; n < _initialCakes; n++)
  {
    BattleOrb* orb;
    
    do {
      orb = [layout findOrbWithColorPreference:OrbColorNone isInitialSkill:YES];
    } while (orb.row < layout.numColumns/2);
    
    // Update data
    orb.specialOrbType = SpecialOrbTypeCake;
    orb.orbColor = OrbColorNone;
    orb.damageMultiplier = 1;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:orb.column row:orb.row];
    [bgdLayer updateTile:tile keepLit:YES withTarget:((n==_initialCakes-1)?self:nil) andCallback:@selector(skillTriggerFinished)]; // returning from the skill
    
    // Update orb
    [self performBlockAfterDelay:0.5 block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
  }
  
  // Update available swaps list
  [layout detectPossibleSwaps];
}

- (void) startAttackingPlayer
{
//[self makeSkillOwnerJumpWithTarget:self selector:@selector(startAttackingPlayerPhase2)];
  [self startAttackingPlayerPhase2];
  [self showSkillPopupMiniOverlay:@"CAKESPLOSION"];
}

- (void) startAttackingPlayerPhase2
{
  self.enemySprite.animationType = MonsterProto_AnimationTypeMelee; // To ensure that enemy will run
  [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:NO shouldEvade:NO shouldMiss:NO shouldFlinch:NO
                                                 target:self selector:@selector(startAttackingPlayerPhase3) animCompletion:nil];
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
  [self.battleLayer.mainView blowupBattleSprite:self.enemySprite withBlock:^{
    [self destroyAllCakes];
  }];
  
  [self.battleLayer.mainView blowupBattleSprite:self.playerSprite withBlock:^{}];
  
  // Deal damage to the enemy and erase him/her
  self.enemy.curHealth = 0.0;
  self.battleLayer.enemyDamageDealt = YES;
  [self.battleLayer updateHealthBars];
  self.battleLayer.enemyPlayerObject = nil;
  self.battleLayer.mainView.currentEnemy = nil;
  [self.battleLayer.mainView.hudView removeBattleScheduleView];
  
  // Finish the skill execution
  [self skillTriggerFinished];
  
  // Send server updated values for health
  [self.battleLayer.droplessStageNums addObject:@(self.battleLayer.currentStageNum)];
  [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  
  // Checking player's health (it will effectively call moveToNextEnemy when no enemy is found)
  if ([self.battleLayer stagesLeft] == 0)
  {
    // You only get the win if you beat at least one stage in the match
    if ([self.battleLayer playerMobstersLeft] > 0) {
      [self.battleLayer youWon];
    }
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
          orb.orbColor = [layout generateRandomOrbColor];
        } while ([layout hasChainAtColumn:column row:row]);
        
        [skillManager generateSpecialOrb:orb atColumn:column row:row];
        
        OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  
  [self.battleLayer.orbLayer toggleArrows:NO];
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
