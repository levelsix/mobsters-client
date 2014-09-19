//
//  SkillPoison.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillPoison.h"
#import "NewBattleLayer.h"

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
        [self showSkillPopupOverlay:YES withCompletion:^(){
          
          // Deal damage
          // Reset temp damage
          [self skillTriggerFinished];
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
      
      if (orb.specialOrbType != SpecialOrbTypePoison)
      {
        orb.specialOrbType = SpecialOrbTypePoison;
        
        // Update orb
        [sprite updatePoisonElements];
        
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
        [sprite updatePoisonElements];
      }
    }
}

@end
