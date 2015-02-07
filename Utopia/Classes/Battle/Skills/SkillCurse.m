//
//  SkillCurse.m
//  Utopia
//  Description: Casts a status ailment on the enemy for X turns.
//  Enemy skill orb counter does not work while cursed.
//
//  Created by Rob Giusti on 2/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillCurse.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillCurse

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return [self isActive];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    //Reset on new target
    if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
        || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
    {
      [self removeCurse];
    }
    else if (trigger == SkillTriggerPointEndOfPlayerMove)
    {
      [self tickDuration];
    }
  }
  
  return NO;
}

#pragma mark - Skill Logic

- (void) onDurationStart
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isCursed = YES;
  
  [self addCurseAnimations];
  
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

- (void) onDurationEnd
{
  [self removeCurse];
}

- (void) removeCurse
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  opponent.isCursed = NO;
  
  [self endCurseAnimations];
}

#pragma mark - Animations

- (void) addCurseAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink purple
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor purpleColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
}

- (void) endCurseAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent runAction:[CCActionEaseBounceIn actionWithAction:
                       [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}

@end
