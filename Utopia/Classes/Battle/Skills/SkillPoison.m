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

- (BOOL) shouldPersist
{
  return ([self specialsOnBoardCount:SpecialOrbTypePoison]) || [self isActive];
}

- (BOOL) generateSpecialOrb:(BattleOrb *)orb atColumn:(int)column row:(int)row
{
  if ([self isActive] && orb.orbColor == self.orbColor)
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

- (int) poisonDamage
{
  return _tempDamageDealt;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
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
  
  if ([self isActive] && trigger == SkillTriggerPointEndOfEnemyTurn)
  {
    [self tickDuration];
  }
  
  return NO;
}

- (BOOL) shouldSpawnRibbon
{
  return YES;
}

- (BOOL) onDurationStart
{
  [self addSkullsToOrbs:YES withTarget:self andCallback:@selector(skillTriggerFinishedActivated)];
  return YES;
}

- (BOOL) onDurationReset
{
  [self dealPoisonDamage];
  return YES;
}

#pragma mark - Skill Logic

static NSString* const skullId = @"skull";

- (void) addSkullsToOrbs:(BOOL)fromTrigger withTarget:(id)target andCallback:(SEL)callback
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  
  OrbBgdLayer* lastOrbLayer;
  BattleTile* lastTile;
  
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
//          BattleTile* tile = [layout tileAtColumn:col row:row];
          if (lastOrbLayer)
            [lastOrbLayer updateTile:lastTile];
          lastOrbLayer = self.battleLayer.orbLayer.bgdLayer;
          lastTile = [layout tileAtColumn:col row:row];
//          OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
//          [bgdLayer updateTile:tile keepLit:NO withTarget:nil andCallback:nil];
        }
      }
    }
  
  if (lastOrbLayer) {
    [lastOrbLayer updateTile:lastTile keepLit:NO withTarget:self andCallback:callback];
  }
  else
  {
    if (target && callback)
      SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([target performSelector:callback];);
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

@end
