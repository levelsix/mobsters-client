//
//  SkillTakeAim.m
//  Utopia
//  Description: Targets are thrown on the attackers board. Each target grants 25% critical strike on attack (stackable.) Targets defused via match (like bombs away!).
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillTakeAim.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"

@implementation SkillTakeAim

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _numOrbsToSpawn = 0;
  _maxOrbs = 10;
  _critChancePerOrb = 0.25;
  _critDamageMultiplier = 2;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"NUM_ORBS_TO_SPAWN"])
    _numOrbsToSpawn = value;
  else if ([property isEqualToString:@"MAX_ORBS"])
    _maxOrbs = value;
  else if ([property isEqualToString:@"CHANCE_PER_ORB"])
    _critChancePerOrb = value;
  else if ([property isEqualToString:@"CRIT_DAMAGE_MULTIPLIER"])
    _critDamageMultiplier = value;
  else if ([property isEqualToString:@"PLAYER_CRIT_CHANCE"])
    _playerCritChance = value;
}

#pragma mark - Overrides


- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  _orbsSpawned = (int)[self specialsOnBoardCount:SpecialOrbTypeTakeAim];
  if (!player && _orbsSpawned)
  {
    float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
    if (rand < _orbsSpawned * _critChancePerOrb)
    {
      [self showCriticalHit];
      damage = damage * _critDamageMultiplier;
    }
  }
  else if ([self isActive])
  {
    float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
    if (rand < _playerCritChance)
    {
      [self showCriticalHit];
      damage = damage * _critDamageMultiplier;
    }
    [self tickDuration];
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && !self.belongsToPlayer)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self resetOrbCounter];
        }];
      }
      return YES;
    }
  }
  
  //On user death, delete all orbs
  if ((trigger == SkillTriggerPointEnemyDefeated && !self.belongsToPlayer))
  {
    if (execute)
    {
      // Remove all speical orbs added by this enemy
      [self removeAllTakeAimOrbs];
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

- (BOOL) onDurationStart
{
  if (!self.belongsToPlayer)
  {
    [self spawnTakeAimOrbs:_numOrbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
    [self endDurationNow];
    return YES;
  }
  return NO;
}

#pragma mark - Skill Logic

- (void) spawnTakeAimOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self preseedRandomization];
  
  _orbsSpawned = (int)[self specialsOnBoardCount:SpecialOrbTypeTakeAim];
  for (NSInteger n = 0; n < count && _orbsSpawned < _maxOrbs; ++n)
  {
    BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
    BattleOrb* orb = [layout findOrbWithColorPreference:self.orbColor isInitialSkill:NO];
    
    // Nothing found (just in case), continue and perform selector if the last special orb
    if (!orb)
    {
      if (n == count - 1)
        if (target && selector)
          SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:selector withObject:nil];);
      continue;
    }
    
    orb.specialOrbType = SpecialOrbTypeTakeAim;
    orb.orbColor = self.orbColor;
    
    // Update tile
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    BattleTile* tile = [layout tileAtColumn:orb.column row:orb.row];
    [bgdLayer updateTile:tile keepLit:NO withTarget:(n == count - 1 || _orbsSpawned == _maxOrbs - 1) ? target : nil andCallback:selector];
    
    // Update orb
    [self performAfterDelay:.5f block:^{
      OrbSprite* orbSprite = [self.battleLayer.orbLayer.swipeLayer spriteForOrb:orb];
      [orbSprite reloadSprite:YES];
    }];
    
    ++_orbsSpawned;
  }
}

- (void) removeAllTakeAimOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeTakeAim)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
  }
}

-(void)showCriticalHit
{
  /*
   * 2/4/15 - BN - Disabling skills displaying logos
   *
   
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display damage modifier label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.1gX DAMAGE", _critDamageMultiplier] fontName:@"GothamNarrow-Ultra" fontSize:12];
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
   */
  
  // Finish trigger execution
//  [self performAfterDelay:.3f block:^{
//    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
//    [self.battleLayer.orbLayer allowInput];
//    [self skillTriggerFinished];
//  }];
}

@end