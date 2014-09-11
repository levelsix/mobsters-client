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
  
  return self;
}

- (BOOL) skillIsReady
{
  return _orbCounter == 0;
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if (color == self.orbColor && _orbCounter > 0)
    _orbCounter--;
}

// To be called by every specific skill when execution is finished
- (void) skillTriggerFinished
{
  _orbCounter = _orbRequirement;
  [super skillTriggerFinished];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_orbCounter) forKey:@"orbCounter"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* orbCounter = [dict objectForKey:@"orbCounter"];
  if (orbCounter)
    _orbCounter = [orbCounter integerValue];
  
  return YES;
}

@end