//
//  SkillBombs.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBombs.h"
#import "MainBattleLayer.h"
#import "Globals.h"
#import <CCTextureCache.h>
#import "SoundEngine.h"
#import "SkillManager.h"

@implementation SkillBombs

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  // Properties
  _bombDamage = 0;
  
  _currDamage = 0;
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
  return [self specialsOnBoardCount:[self specialType]] > 0;
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
  
  //Player flinches
  [self.playerSprite performFarFlinchAnimationWithDelay:delay];
  
  //Deal damage
  [self.battleLayer performBlockAfterDelay:delay block:^{
    self.battleLayer.enemyDamageDealt = (int)_currDamage;
    [self.battleLayer dealDamage:(int)_currDamage enemyIsAttacker:YES usingAbility:YES withTarget:nil withSelector:nil];
  }];
  
  [self dropBombsOnPlayer:numOrbs];
  
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%li DMG", (long)_currDamage]];

  
  return YES;
}

- (void)makeSpecialOrb:(BattleOrb *)orb
{
  [super makeSpecialOrb:orb];
  orb.bombDamage = _bombDamage;
}

- (NSInteger)updateSpecialOrbs
{
  if ([skillManager.enemySkillControler isKindOfClass:[SkillBombs class]] && self != skillManager.enemySkillControler)
    return 0;
  
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  _currDamage = 0;
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
              _currDamage += orb.bombDamage;
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
    [self.battleLayer.mainView.bgdContainer addChild:bomb];
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
         [self.battleLayer.mainView.bgdContainer addChild:q];
         
         [bomb removeFromParentAndCleanup:YES];
         
         if (i == bombCount-1) {
           [self performBlockAfterDelay:0.5 block:^{
             [self skillTriggerFinished];
           }];
         }
         
         if (i == 0) {
           [self.battleLayer.mainView shakeScreenWithIntensity:2.f];
         }
         
         [SoundEngine puzzleBoardExplosion];
       }],
      nil]];
  }
}

@end
