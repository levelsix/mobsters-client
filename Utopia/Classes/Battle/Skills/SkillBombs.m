//
//  SkillBombs.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBombs.h"
#import "NewBattleLayer.h"
#import "Globals.h"
#import <CCTextureCache.h>
#import "SoundEngine.h"

@implementation SkillBombs

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  // Properties
  _bombDamage = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ( [property isEqualToString:@"BOMB_DAMAGE"] )
    _bombDamage = value;
}

#pragma mark - Overrides

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL)shouldPersist
{
  return _orbsSpawned > 0;
}

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeBomb;
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  float delay = 1.5 + 0.05*numOrbs;
  NSInteger totalDamage = numOrbs * _bombDamage;
  
  //Player flinches
  [self.playerSprite performFarFlinchAnimationWithDelay:delay];
  
  //Deal damage
  [self.battleLayer performAfterDelay:delay block:^{
    self.battleLayer.enemyDamageDealt = (int)totalDamage;
    [self.battleLayer dealDamage:(int)totalDamage enemyIsAttacker:YES usingAbility:YES withTarget:nil withSelector:nil];
  }];
  
  [self dropBombsOnPlayer:numOrbs];
  
  return YES;
}

- (NSInteger)updateSpecialOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  CGPoint position = self.playerSprite.position;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  NSInteger totalDamage = 0;
  NSInteger bombCount = 0;
  for (NSInteger column = 0; column < layout.numColumns; column++)
    for (NSInteger row = 0; row < layout.numRows; row++)
      {
        BattleOrb* orb = [layout orbAtColumn:column row:row];
        if (orb.specialOrbType == SpecialOrbTypeBomb)
          {
            // Update counter
            orb.turnCounter--;
            
            // Update sprite
            OrbSprite* sprite = [layer spriteForOrb:orb];
            if (orb.turnCounter <= 0) // Blow up the bomb
            {
              // Change sprite type
              orb.specialOrbType = SpecialOrbTypeNone;
              
              // Reload sprite
              [sprite reloadSprite:YES];
              
              // Add explosion
              CCParticleSystem* blast = [CCParticleSystem particleWithFile:@"bombskillexplosion.plist"];
              blast.scale = 0.5;
              blast.autoRemoveOnFinish = YES;
              blast.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
              [sprite addChild:blast];
              
              // Count damage and bombs
              totalDamage += orb.bombDamage;
              bombCount++;
              
              [SoundEngine puzzleBoardExplosion];
              }
        else
          [sprite updateTurnCounter:YES];
        }
      }
  
  return bombCount;
}

- (void)dropBombsOnPlayer:(NSInteger)bombCount
{
  CGPoint position = self.playerSprite.position;
  
  for (int i = 0; i < bombCount; i++) {
    CCSprite *bomb = [CCSprite spriteWithImageNamed:@"bomb.png"];
    [self.battleLayer.bgdContainer addChild:bomb];
    bomb.scale = 0.3;
    
    CGPoint endPos = ccpAdd(position, ccp(5,10));
    endPos = ccpAdd(endPos, ccpMult(POINT_OFFSET_PER_SCENE, 0.02*(i-bombCount/2)));
    
    bomb.position = ccp(endPos.x, endPos.y+250);
    
    [bomb runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:0.75f+0.1*i],
      [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.9f position:endPos]],
      [CCActionCallBlock actionWithBlock:
       ^{
         [[CCTextureCache sharedTextureCache] addImage:@"bombdrop.png"];
         CCParticleSystem *q = [CCParticleSystem particleWithFile:@"bombdrop.plist"];
         q.autoRemoveOnFinish = YES;
         q.position = bomb.position;
         [self.battleLayer.bgdContainer addChild:q];
         
         [bomb removeFromParentAndCleanup:YES];
         
         if (i == bombCount-1) {
           [self performAfterDelay:0.5 block:^{
             [self skillTriggerFinished];
           }];
         }
         
         if (i == 0) {
           [self.battleLayer shakeScreenWithIntensity:2.f];
         }
         
         [SoundEngine puzzleBoardExplosion];
       }],
      nil]];
  }
}

@end
