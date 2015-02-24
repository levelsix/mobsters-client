//
//  SkillCritAndEvade.m
//  Utopia
//
//  Created by Behrouz N. on 12/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillCritAndEvade.h"
#import "NewBattleLayer.h"
#import "SkillManager.h"
#import "Globals.h"
#import "GameState.h"

@implementation SkillCritAndEvade

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _critChance = 0.f;
  _critMultiplier = 1.f;
  _evadeChance = 0.f;
  _missChance = 0.f;
  _criticalHit = NO;
  _sideEffectType = SideEffectTypeNoSideEffect;
  _evaded = NO;
  _missed = NO;
  _logoShown = NO;
  _fromSave = NO;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CRIT_CHANCE"])
    _critChance = value;
  if ([property isEqualToString:@"CRIT_MULTIPLIER"])
    _critMultiplier = value;
  if ([property isEqualToString:@"EVADE_CHANCE"])
    _evadeChance = value;
  if ([property isEqualToString:@"MISS_CHANCE"])
    _missChance = value;
  if ([property isEqualToString:@"SKILL_SIDE_EFFECT_ID"])
  {
    NSDictionary* skillSideEffects = [GameState sharedGameState].staticSkillSideEffects;
    SkillSideEffectProto* proto = [skillSideEffects objectForKey:[NSNumber numberWithInteger:(int)value]];
    if (proto)
      _sideEffectType = proto.type;
  }
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(_sideEffectType), nil];
}

-(BOOL)skillOwnerWillEvade
{
  // Last time defending an attack led to an evasion
  return _evaded;
}

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  _evaded = NO;
  
  if ([self isActive])
  {
    SkillLogStart(@"Crit and Evade -- %@ skill invoked from %@ with damage %ld",
                  self.belongsToPlayer ? @"PLAYER" : @"ENEMY",
                  player ? @"PLAYER" : @"ENEMY",
                  (long)damage);
    
    if (player == self.belongsToPlayer) // The character attacking has the skill
    {
      
      if (_missChance > 0 || _critChance > 0)
      {
        // Chance of missing
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _missChance)
        {
          damage = 0;
          [self showDodged:YES];
          SkillLogStart(@"Crit and Evade -- Skill caused a miss");
        }
        else
        {
          // Chance of critical hit
          rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
          if (rand < _critChance)
          {
            damage *= _critMultiplier;
            
            [self showCriticalHit];
            
            SkillLogStart(@"Crit and Evade -- Skill caused a critical hit, increasing damage to %ld", (long)damage);
          }
        }
      }
    }
    else // The character defending has the skill
    {
      if (_evadeChance)
      {
        // Chance of evading
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _evadeChance)
        {
          damage = 0;
          [self showDodged:NO];
          _evaded = YES;
          SkillLogStart(@"Crit and Evade -- Skill caused an evade");
        }
      }
    }
  }
  
  return damage;
}

-(BOOL)skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (([self ticksOnPlayerTurn] && (trigger == SkillTriggerPointEndOfPlayerTurn || trigger == SkillTriggerPointEnemyDefeated))
       || (![self ticksOnPlayerTurn] && (trigger == SkillTriggerPointEndOfEnemyTurn || trigger == SkillTriggerPointPlayerMobDefeated)))
    {
      if (execute)
      {
        [self tickDuration];
      }
    }
  }
  return NO;
}

#pragma mark - Skill logic
      
- (BOOL) ticksOnPlayerTurn
{
  return self.belongsToPlayer == (_missChance > 0 || _critChance > 0);
}

-(void)showCriticalHit
{
  [self showSkillPopupMiniOverlay:NO
                       bottomText:[NSString stringWithFormat:@"%.3gX ATK", _critMultiplier]
                   withCompletion:^{}];
  
  /*
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display damage modifier label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.1gX DAMAGE", _critMultiplier] fontName:@"GothamNarrow-Ultra" fontSize:12];
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
}

-(void)showDodged:(BOOL)missed
{
  [self showSkillPopupMiniOverlay:NO
                       bottomText:missed ? @"MISSED" : @"EVADED"
                   withCompletion:^{}];
  
  /*
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display missed/evaded label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:missed ? @"MISSED" : @"EVADED" fontName:@"GothamNarrow-Ultra" fontSize:12];
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
   */
}

- (BOOL) deserialize:(NSDictionary *)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  _fromSave = [self isActive];
  
  return YES;
}

@end
