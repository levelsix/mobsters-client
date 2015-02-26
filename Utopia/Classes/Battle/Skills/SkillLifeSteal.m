//
//  SkillLifeSteal.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/20/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillLifeSteal.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"
#import "Globals.h"
#import "DestroyedOrb.h"

@implementation SkillLifeSteal

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _numOrbsToSpawn = 0;
  _lifeStealAmount = 0.f;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"LIFE_STEAL_AMOUNT"])
    _lifeStealAmount = value;
}

#pragma mark - Overrides

- (SpecialOrbType) specialType
{
  return SpecialOrbTypeLifeSteal;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL) skillDefCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillDefCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // End of player turn
  if (trigger == SkillTriggerPointEndOfPlayerTurn)
  {
    if (execute)
    {
      NSInteger orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeLifeSteal];
      if (orbsSpawned > 0)
      {
        // Life steal orbs left on the board at the end of turn, being stealing life
        [self beginLifeSteal];
      }
      else
        [self skillTriggerFinished];
    }
    return YES;
  }

  return NO;
}

#pragma mark - Skill logic

- (int) calculateLifeStealAmount
{
  return [self specialsOnBoardCount:SpecialOrbTypeLifeSteal] * _lifeStealAmount;
}

- (void) beginLifeSteal
{
  [self beginLifeStealOrbEffect];
}

- (void) beginLifeStealOrbEffect
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
  
  NSMutableArray* clonedOrbs = [NSMutableArray array];
  for (NSInteger column = 0; column < layout.numColumns; ++column)
  {
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeLifeSteal)
      {
        // Clone the orb sprite to be used in the visual effect
        OrbSprite* sprite = [layer spriteForOrb:orb];
        CCSprite* clonedSprite = [CCSprite spriteWithTexture:sprite.orbSprite.texture rect:sprite.orbSprite.textureRect];
        clonedSprite.position = [bgdLayer convertToNodeSpace:[sprite.orbSprite convertToWorldSpaceAR:sprite.orbSprite.position]];
        clonedSprite.zOrder = sprite.orbSprite.zOrder + 100;
        [clonedOrbs addObject:clonedSprite];
      }
    }
  }
  
  CGPoint playerSpritePosition = [bgdLayer convertToNodeSpace:[self.playerSprite.parent convertToWorldSpaceAR:self.playerSprite.position]];
  playerSpritePosition = ccp(playerSpritePosition.x, playerSpritePosition.y + self.playerSprite.contentSize.height * .5f);
  for (CCSprite* clonedSprite in clonedOrbs)
  {
    [bgdLayer addChild:clonedSprite];
    [clonedSprite runAction:[CCActionSequence actions:
                             [self flyToActionForSprite:clonedSprite start:clonedSprite.position end:playerSpritePosition],
                             [CCActionSpawn actions:
                              [CCActionEaseIn actionWithAction:
                               [CCActionScaleBy actionWithDuration:.25f scale:.1f]],
                              [CCActionEaseIn actionWithAction:
                               [CCActionFadeOut actionWithDuration:.25f]],
                              nil],
                             (clonedSprite == clonedOrbs.lastObject) ? [CCActionCallFunc actionWithTarget:self selector:@selector(dealEnemyDamage)] : [CCActionInstant action],
                             [CCActionRemove action],
                             nil]];
  }
}

- (CCActionFiniteTime*) flyToActionForSprite:(CCSprite*)sprite start:(CGPoint)startPosition end:(CGPoint)endPosition
{
  // Create random bezier
  ccBezierConfig bez;
  bez.endPosition = endPosition;
  
  // basePt1 is chosen with any y and x is between some neg num and approx .5
  // basePt2 is chosen with any y and x is anywhere between basePt1's x and .85
  BOOL chooseRight = arc4random() % 2;
  CGPoint basePt1 = ccp(drand48() - .8f, drand48());
  CGPoint basePt2 = ccp(basePt1.x + drand48() * (.7f - basePt1.x), drand48());
  
  // Outward potential increases based on distance between orbs
  float xScale = ccpDistance(startPosition, bez.endPosition);
  float yScale = (50.f + xScale * .2f) * (chooseRight ? -1.f : 1.f);
  float angle = ccpToAngle(ccpSub(bez.endPosition, startPosition));
  
  CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
  bez.controlPoint_1 = ccpAdd(startPosition, CGPointApplyAffineTransform(basePt1, t));
  bez.controlPoint_2 = ccpAdd(startPosition, CGPointApplyAffineTransform(basePt2, t));
  
  CCActionBezierTo* flyToAction = [CCActionBezierTo actionWithDuration:.6f + xScale / 600.f bezier:bez];
  return flyToAction;
}

- (void) dealEnemyDamage
{
  // Flinch
  [self.playerSprite performFarFlinchAnimationWithDelay:0.f];
  
  // Flash red
  [self.playerSprite.sprite runAction:[CCActionSequence actions:
                                       [RecursiveTintTo actionWithDuration:.2f color:[CCColor redColor]],
                                       [RecursiveTintTo actionWithDuration:.2f color:[CCColor whiteColor]],
                                       nil]];
  
  [self beginLifeStealEffect];
  
  int damage = [self calculateLifeStealAmount];
  
  // Deal damage to player
  [self.battleLayer dealDamage:damage
               enemyIsAttacker:YES
                  usingAbility:YES
                    withTarget:nil
                  withSelector:nil];
  [self.battleLayer setEnemyDamageDealt:(int)damage];
  [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  
}

- (void) beginLifeStealEffect
{
//  if (self.battleLayer.myPlayerObject.curHealth <= 0)
//  {
//    [self endLifeSteal];
//    return;
//  }
  
  const CGPoint startPosition = ccp(self.playerSprite.position.x, self.playerSprite.position.y + self.playerSprite.contentSize.height * .5f);
  const CGPoint endPosition = ccp(self.enemySprite.position.x, self.enemySprite.position.y + self.enemySprite.contentSize.height * .5f);
  
  // Create random bezier
  ccBezierConfig bez;
  bez.endPosition = endPosition;
  
  // basePt1 is chosen with any y and x is between some neg num and approx .5
  // basePt2 is chosen with any y and x is anywhere between basePt1's x and .85
  BOOL chooseRight = arc4random() % 2;
  CGPoint basePt1 = ccp(drand48() * .5f, drand48());
  CGPoint basePt2 = ccp(basePt1.x + drand48() * .5f, drand48());
  
  // Outward potential increases based on distance between orbs
  float xScale = ccpDistance(startPosition, bez.endPosition);
  float yScale = (50.f + xScale * .2f) * (chooseRight ? -1.f : 1.f);
  float angle = ccpToAngle(ccpSub(bez.endPosition, startPosition));
  
  CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
  bez.controlPoint_1 = ccpAdd(startPosition, CGPointApplyAffineTransform(basePt1, t));
  bez.controlPoint_2 = ccpAdd(startPosition, CGPointApplyAffineTransform(basePt2, t));
  
  CCNode* pfx = [[LifeStealParticleEffect alloc] init];
  [pfx setPosition:startPosition];
  [self.playerSprite.parent addChild:pfx z:50];
  [pfx runAction:[CCActionSequence actions:
                  [CCActionBezierTo actionWithDuration:1.f bezier:bez],
                  [CCActionFadeOut actionWithDuration:0.25f],
                  [CCActionCallFunc actionWithTarget:self selector:@selector(healEnemy)],
                  [CCActionRemove action],
                  nil]];
}

- (void) healEnemy
{
  [self.battleLayer healForAmount:[self calculateLifeStealAmount] enemyIsHealed:YES withTarget:self andSelector:@selector(endLifeSteal)];
}

- (void) endLifeSteal
{
  [self skillTriggerFinished];
}
@end
