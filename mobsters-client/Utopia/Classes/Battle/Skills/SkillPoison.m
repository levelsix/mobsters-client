//
//  SkillPoison.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPoison.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillPoison

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _orbDamage = 1;
  
  _tempDamageDealt = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"ORB_DAMAGE"] )
    _orbDamage = value;
}

#pragma mark - Overrides

- (BOOL) generateSpecialOrb:(BattleOrb *)orb atColumn:(int)column row:(int)row
{
  if (orb.orbColor == self.orbColor)
  {
    orb.specialOrbType = SpecialOrbTypePoison;
    return YES;
  }
  
  return [super generateSpecialOrb:orb atColumn:column row:row];
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  // Accumulate damage here
  if (type == SpecialOrbTypePoison)
    _tempDamageDealt += _orbDamage;
  
  [super orbDestroyed:color special:type];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Add skulls
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
    {
      [self showSkillPopupOverlay:YES withCompletion:^(){
        
        [self addSkullsToOrbs:YES];
        [self performAfterDelay:0.5 block:^{
          [self skillTriggerFinished];
        }];
      }];
    }
    return YES;
  }
  
  // Deal damage
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    if (_tempDamageDealt > 0)
    {
      if (execute)
      {
        [self.battleLayer.orbLayer disallowInput];
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self dealPoisonDamage];
        }];
      }
      return YES;
    }
  }
  
  // Cleanup
  if (trigger == SkillTriggerPointEnemyDefeated)
  {
    if (execute)
    {
      [self removeSkullsFromOrbs];
      [self performAfterDelay:0.3 block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  return NO;
}

- (BOOL) shouldSpawnRibbon
{
  return YES;
}

#pragma mark - Skill Logic

static NSString* const skullId = @"skull";

- (void) addSkullsToOrbs:(BOOL)fromTrigger
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger col = 0; col < layout.numColumns; col++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:col row:row];
      OrbSprite* sprite = [layer spriteForOrb:orb];
      
      // Wrong color
      if (orb.orbColor != self.orbColor)
        continue;
      if (orb.powerupType != PowerupTypeNone)
        continue;
      
      if (orb.specialOrbType != SpecialOrbTypePoison)
      {
        orb.specialOrbType = SpecialOrbTypePoison;
        
        // Update orb
        [sprite reloadSprite:YES];
        
        // Update tile
        if (fromTrigger)
        {
          OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
          BattleTile* tile = [layout tileAtColumn:col row:row];
          [bgdLayer updateTile:tile keepLit:NO withTarget:nil andCallback:nil];
        }
      }
    }
}

- (void) removeSkullsFromOrbs
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  for (NSInteger col = 0; col < layout.numColumns; col++)
    for (NSInteger row = 0; row < layout.numRows; row++)
    {
      BattleOrb* orb = [layout orbAtColumn:col row:row];
      OrbSprite* sprite = [layer spriteForOrb:orb];
      
      if (orb.specialOrbType == SpecialOrbTypePoison)
      {
        orb.specialOrbType = SpecialOrbTypeNone;
        [sprite reloadSprite:YES];
      }
    }
}

- (void) dealPoisonDamage
{
  // Flinch
  [self.playerSprite performFarFlinchAnimationWithDelay:0.4];
  
  // Flash red
  [self.playerSprite.sprite runAction:[CCActionSequence actions:
                                [CCActionDelay actionWithDuration:0.3],
                                [RecursiveTintTo actionWithDuration:0.2 color:[CCColor redColor]],
                                [RecursiveTintTo actionWithDuration:0.2 color:[CCColor whiteColor]],
                                nil]];
  
  // Skull and bones
  CCSprite* skull = [CCSprite spriteWithImageNamed:@"poisonplayer.png"];
  skull.position = ccp(20, self.playerSprite.contentSize.height/2);
  skull.scale = 0.01;
  skull.opacity = 0.0;
  [self.playerSprite addChild:skull z:10];
  [skull runAction:[CCActionSequence actions:
                          [CCActionSpawn actions:
                           [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:0.3f scale:1]],
                           [CCActionFadeIn actionWithDuration:0.3f],
                           nil],
                          [CCActionCallFunc actionWithTarget:self selector:@selector(dealPoisonDamage2)],
                          [CCActionDelay actionWithDuration:0.5],
                          [CCActionEaseElasticIn actionWithAction:[CCActionScaleTo actionWithDuration:0.7f scale:0]],
                          [CCActionRemove action],
                          nil]];
}

- (void) dealPoisonDamage2
{
  // Deal damage
  [self.battleLayer dealDamage:(int)_tempDamageDealt enemyIsAttacker:YES usingAbility:YES withTarget:self withSelector:@selector(dealPoisonDamage3)];
  _tempDamageDealt = 0;
}

- (void) dealPoisonDamage3
{
  // Turn on the lights for the board and finish skill execution
  [self performAfterDelay:1.3 block:^{
    [self.battleLayer.orbLayer allowInput];
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  }];
  [self skillTriggerFinished];
}

@end
