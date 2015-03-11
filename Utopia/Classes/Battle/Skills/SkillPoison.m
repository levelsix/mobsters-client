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
  if ([self isActive] && orb.orbColor == self.orbColor)
  {
    orb.specialOrbType = [self specialType];
    return YES;
  }
  
  return [super generateSpecialOrb:orb atColumn:column row:row];
}

- (SpecialOrbType)specialType
{
  return SpecialOrbTypePoison;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (BOOL) shouldPersist
{
  return ([self specialsOnBoardCount:SpecialOrbTypePoison]) || [self isActive];
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
        [self dealPoisonDamage];
      }
      return YES;
    }
  }
  
  return NO;
}

- (BOOL) activate
{
  if (_tempDamageDealt)
    [self dealPoisonDamage];
  else
  {
    [super activate];
    [self resetDuration];
  }
  return YES;
}

- (BOOL) onDurationStart
{
  [self addVisualEffects:NO];
  return YES;
}

- (void) onFinishPoisonDamage
{
  _tempDamageDealt = 0;
  if ([self skillIsReady] && ![self isActive])
    [self activate];
  else
    [self skillTriggerFinished];
}

- (BOOL) onDurationReset
{
  [self dealPoisonDamage];
  return YES;
}

//Pop this special logic in here.
- (void)spawnSpecialOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector
{
  [self addSkullsToOrbs:YES withTarget:target andCallback:selector];
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
          if (lastOrbLayer)
            [lastOrbLayer updateTile:lastTile];
          lastOrbLayer = self.battleLayer.orbLayer.bgdLayer;
          lastTile = [layout tileAtColumn:col row:row];
        }
      }
    }
  
  if (lastOrbLayer) {
    [lastOrbLayer updateTile:lastTile keepLit:NO withTarget:self andCallback:callback];
  }
  else
  {
    if (target && callback)
      [target performSelector:callback withObject:nil afterDelay:0.f];
  }
}

@end
