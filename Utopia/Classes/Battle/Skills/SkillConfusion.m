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
    [self addSkillSideEffectToOpponent:SideEffectTypeNerfConfusion turnsAffected:self.turnsLeft];
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
        self.player.isConfused = YES;
      }
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
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
          self.enemy.isConfused = YES;
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
        (self.belongsToPlayer ? self.enemy : self.player).isConfused = NO;
        
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
  
  [self addSkillSideEffectToOpponent:SideEffectTypeNerfConfusion turnsAffected:self.turnsLeft];

  return [super onDurationStart];
}

- (BOOL) onDurationReset
{
  SkillLogStart(@"Confusion -- Skill reactivated");
  
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnOpponent:SideEffectTypeNerfConfusion];
  
  return [super onDurationReset];
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Confusion -- Skill deactivated");
  
  // Tell NewBattleLayer that opponent is no longer confused
  (self.belongsToPlayer ? self.enemy : self.player).isConfused = NO;
  
  [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfConfusion];
  
  return [super onDurationEnd];
}

- (void) showLogo
{
  [self showSkillPopupMiniOverlay:NO
                       bottomText:@"CONFUSED"
                   withCompletion:^{}];
  
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

@end
