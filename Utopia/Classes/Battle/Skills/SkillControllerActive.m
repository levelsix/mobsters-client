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

- (void) orbDestroyed:(OrbColor)color
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

@end