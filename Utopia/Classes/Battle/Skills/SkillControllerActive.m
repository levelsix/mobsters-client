//
//  SkillControllerActive.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@implementation SkillControllerActive

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _orbRequirement = proto.orbCost;
  _orbCounter = _orbRequirement;
  
  _duration = 2; //TODO: Fix this to use the proto's value
  _turnsLeft = 0;
  
  return self;
}

- (BOOL) skillIsReady
{
  return _orbCounter == 0;
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  //If owner is cursed, don't tick down counter
  if ((self.belongsToPlayer && !self.player.isCursed)
      || (!self.belongsToPlayer && !self.enemy.isCursed))
    if ( color == self.orbColor && _orbCounter > 0)
      _orbCounter--;
}

- (void) resetOrbCounter
{
  _orbCounter = _orbRequirement;
}

- (BOOL) isActive
{
  return _turnsLeft != 0;
}

- (void) resetDuration
{
  _turnsLeft = _duration;
}

- (void) tickDuration
{
  _turnsLeft--;
  if (_turnsLeft == 0)
    [self onDurationEnd];
}

- (void) onDurationEnd
{
  //Overriden in children
}

- (BOOL) shouldSpawnRibbon
{
  return YES;
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_orbCounter) forKey:@"orbCounter"];
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* orbCounter = [dict objectForKey:@"orbCounter"];
  if (orbCounter)
    _orbCounter = [orbCounter integerValue];
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft)
    _turnsLeft = [turnsLeft integerValue];
  
  return YES;
}

@end