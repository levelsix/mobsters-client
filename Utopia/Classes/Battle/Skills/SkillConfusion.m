//
//  SkillConfusion.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/22/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillConfusion.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillConfusion

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];

  _chanceToHitSelf = 0.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CHANCE_TO_HIT_SELF"])
    _chanceToHitSelf = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfConfusion), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
    if (opponent.isConfused)
    {
      BattleSprite *bs = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
      [bs addSkillSideEffect:SideEffectTypeNerfConfusion];
    }
  }
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player && !self.belongsToPlayer)
  {
    if ([self isActive])
    {
      // Chance of player hitting self
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _chanceToHitSelf)
      {
        SkillLogStart(@"Confusion -- Skill caused player to hit himself");
        
        [self showLogo];
        
        // Tell NewBattleLayer that player will be confused on his next turn
        [self.player setIsConfused:YES];
        [self.playerSprite addSkillSideEffect:SideEffectTypeNerfConfusion];
      }
    }
  }
  
  return damage;
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
      if ([self isActive])
      {
        SkillLogStart(@"Confusion -- Skill activated");
        
        // Display confused symbol on opponent's next turn indicator
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                          onUpcomingTurns:(int)self.turnsLeft
                                                               forMonster:self.belongsToPlayer ? self.enemy.monsterId : self.player.monsterId
                                                                forPlayer:!self.belongsToPlayer];
      }
      
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointStartOfEnemyTurn && self.belongsToPlayer)
    {
      if (execute)
      {
        // Chance of enemy hitting self
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chanceToHitSelf)
        {
          SkillLogStart(@"Confusion -- Skill caused enemy to hit himself");

          [self showLogo];
          
          // Tell NewBattleLayer that enemy will be confused on his next turn
          [self.enemy setIsConfused:YES];
          [self.enemySprite addSkillSideEffect:SideEffectTypeNerfConfusion];
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
    
    if ((trigger == SkillTriggerPointEndOfEnemyTurn && self.belongsToPlayer) ||
        (trigger == SkillTriggerPointEndOfPlayerTurn && !self.belongsToPlayer))
    {
      if (execute)
      {
        [self tickDuration];
        [self skillTriggerFinished];
      }
      return YES;
    }
    
    if (trigger == SkillTriggerPointEnemyDefeated || trigger == SkillTriggerPointPlayerMobDefeated)
    {
      if (execute)
      {
        [self endDurationNow];
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) onDurationStart
{
  SkillLogStart(@"Confusion -- Skill activated");
  
  // Display confused symbol on opponent's next turn indicator
  [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                    onUpcomingTurns:(int)self.turnsLeft
                                                         forMonster:self.belongsToPlayer ? self.enemy.monsterId : self.player.monsterId
                                                          forPlayer:!self.belongsToPlayer];

  return NO;
}

- (BOOL) onDurationReset
{
  SkillLogStart(@"Confusion -- Skill reactivated");
  
  // Display confused symbol on opponent's next turn indicator
  [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                    onUpcomingTurns:(int)self.turnsLeft
                                                         forMonster:self.belongsToPlayer ? self.enemy.monsterId : self.player.monsterId
                                                          forPlayer:!self.belongsToPlayer];
  
  return NO;
}

- (BOOL) onDurationEnd
{
  [super onDurationEnd];
  
  SkillLogStart(@"Confusion -- Skill deactivated");
  
  // Tell NewBattleLayer that opponent is no longer confused
  // and remove confused symbol from his next turn indicator
  (self.belongsToPlayer ? self.enemy : self.player).isConfused = NO;
  [self.battleLayer.hudView.battleScheduleView updateConfusionState:NO
                                                    onUpcomingTurns:(int)self.turnsLeft
                                                         forMonster:self.belongsToPlayer ? self.enemy.monsterId : self.player.monsterId
                                                          forPlayer:!self.belongsToPlayer];
  
  BattleSprite *bs = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  [bs removeSkillSideEffect:SideEffectTypeNerfConfusion];
  
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

@end
