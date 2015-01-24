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
  _skillActive = NO;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CHANCE_TO_HIT_SELF"])
    _chanceToHitSelf = value;
  
  // DEBUG
  _chanceToHitSelf = 1.f;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
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
      
      // Will restore visuals if coming back to a battle after leaving midway
      if (self.belongsToPlayer && _skillActive)
      {
        SkillLogStart(@"Confusion -- Skill activated");
        
        // Display confused symbol on enemy's next turn indicator
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                 onUpcomingTurnForMonster:self.battleLayer.enemyPlayerObject.monsterId];
      }
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (!_skillActive && [self skillIsReady])
    {
      if (execute)
      {
        SkillLogStart(@"Confusion -- Skill activated");
        
        _skillActive = YES;
        
        // Display confused symbol on enemy's next turn indicator
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:YES
                                                 onUpcomingTurnForMonster:self.battleLayer.enemyPlayerObject.monsterId];
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn && self.belongsToPlayer)
  {
    if (_skillActive)
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
          self.battleLayer.enemyPlayerObject.isConfused = YES;
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyDefeated && self.belongsToPlayer))
  {
    if (_skillActive)
    {
      if (execute)
      {
        SkillLogStart(@"Confusion -- Skill deactivated");
        
        _skillActive = NO;
        [self resetOrbCounter];
        
        // Tell NewBattleLayer that enemy is no longer confused,
        // remove confused symbol from enemy's next turn indicator
        self.battleLayer.enemyPlayerObject.isConfused = NO;
        [self.battleLayer.hudView.battleScheduleView updateConfusionState:NO
                                                 onUpcomingTurnForMonster:self.battleLayer.enemyPlayerObject.monsterId];
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

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
