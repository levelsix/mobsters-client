//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillController.h"
#import "SkillQuickAttack.h"

@implementation SkillController

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color // Factory call, can create different skill types
{
  switch( proto.type )
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

- (void) activateSkillWithBlock:(SkillControllerBlock)block
{
  _callbackBlock = block;
  [self skillExecutionStarted];
}

- (void) skillExecutionStarted
{
  
}

- (void) skillExecutionFinished
{
  _callbackBlock();
}

@end