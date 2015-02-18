//
//  SkillHammerTime.m
//  Utopia
//  Description: [chance] to stun enemy for [turns].
//
//  Created by Rob Giusti on 1/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillHammerTime.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillHammerTime

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _chance = .25;
  _stunTurns = 1;
  _stunTurnsLeft = 0;
  _showLogo = NO;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"CHANCE"])
    _chance = value;
  else if ( [property isEqualToString:@"STUN_TURNS"])
    _stunTurns = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return _stunTurnsLeft > 0;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffHammerTime), @(SideEffectTypeNerfStun), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
    [bs addSkillSideEffect:SideEffectTypeBuffHammerTime];
    
    BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
    if (opponent.isStunned)
    {
      [self addStunAnimations];
    }
  }
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  //At the end of the turn, diminish stun stacks
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn) ||
      (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn))
  {
    if (_stunTurnsLeft>0)
    {
      _stunTurnsLeft--;
      if (_stunTurnsLeft == 0)
        [self endStun];
    }
  }
  
  if ([self isActive])
  {
    //If the character dies before the stun runs up, make sure the stun doesn't persist
    if (_stunTurnsLeft>0 && ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
             || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized)))
    {
      [self endStun];
    }
    
    //Note: You can refresh a stun!
    if ((self.belongsToPlayer && trigger == SkillTriggerPointPlayerDealsDamage) ||
             (!self.belongsToPlayer && trigger == SkillTriggerPointEnemyDealsDamage))
    {
      if (execute)
      {
        [self tickDuration];
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chance){
          [self stunOpponent];
          [self showLogo];
        }
      }
      return YES;
    }
  }
  
  return NO;
}

- (void) stunOpponent
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  
  opponent.isStunned = YES;
  
  _stunTurnsLeft = _stunTurns;
  [self addStunAnimations];
  
  // Finish trigger execution
//  [self performAfterDelay:0.3 block:^{
//    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
//    [self.battleLayer.orbLayer allowInput];
//    [self skillTriggerFinished];
//  }];
}

- (void) addStunAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink yellow
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor yellowColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
  
  [opponent addSkillSideEffect:SideEffectTypeNerfStun];
}

- (void) endStun
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.enemy : self.player;
  
  opponent.isStunned = NO;
  
  _stunTurnsLeft = 0;
  [self endStunAnimations];
}

- (void) endStunAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent runAction:[CCActionEaseBounceIn actionWithAction:
                       [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
  
  [opponent removeSkillSideEffect:SideEffectTypeNerfStun];
}

- (BOOL) onDurationStart
{
  BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [bs addSkillSideEffect:SideEffectTypeBuffHammerTime];
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [bs removeSkillSideEffect:SideEffectTypeBuffHammerTime];
  
  return [super onDurationEnd];
}

- (void) showLogo
{
  /*
   * 2/4/15 - BN - Disabling skills displaying logos
   */
  const CGFloat yOffset = self.belongsToPlayer ? 40.f : -20.f;
  
  // Display logo
  CCSprite* logoSprite = [CCSprite node];
  [Globals imageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix] toReplaceSprite:logoSprite];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f + yOffset);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display missed/evaded label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:@"STUNNED" fontName:@"GothamNarrow-Ultra" fontSize:12];
  floatingLabel.position = ccp(logoSprite.spriteFrame.rect.size.width * .5f, -13.f);
  floatingLabel.fontColor = [CCColor colorWithRed:255.f / 225.f green:44.f / 225.f blue:44.f / 225.f];
  floatingLabel.outlineColor = [CCColor whiteColor];
  floatingLabel.shadowOffset = ccp(0.f, -1.f);
  floatingLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:.75f];
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
  
  // Finish trigger execution
  [self performAfterDelay:.3f block:^{
    [self skillTriggerFinished];
  }];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_stunTurnsLeft) forKey:@"stunTurnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* stunTurnsLeft = [dict objectForKey:@"stunTurnsLeft"];
  if (stunTurnsLeft)
    _stunTurnsLeft = [stunTurnsLeft intValue];
  
  return YES;
}

@end