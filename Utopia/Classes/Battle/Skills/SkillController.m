//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillController.h"
#import "SkillQuickAttack.h"

///////////////////////////////////////////////////////////
// Generic skill controller
///////////////////////////////////////////////////////////

@interface SkillController()

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color;

@end

@implementation SkillController

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color // Factory call, can create different skill types
{
  switch( proto.skillId )
  {
    case SkillTypeQuickAttack: return [[SkillQuickAttack alloc] initWithProto:proto andMobsterColor:color];
    default: return nil;
  }
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _skillType = proto.type;
  _activationType = proto.activationType;
  
  return self;
}

- (BOOL) skillIsReady
{
  return NO;
}

- (void) orbDestroyed:(OrbColor)color
{
  return;
}

@end


///////////////////////////////////////////////////////////
// Active skill controller
///////////////////////////////////////////////////////////

@implementation SkillControllerActive

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _orbColor = color;
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
  if ( color == _orbColor && _orbCounter > 0 )
    _orbCounter--;
}

@end