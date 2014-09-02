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
  
  // Properties
  [self setDefaultValuesForProperties];
  for (SkillPropertyProto* property in proto.propertiesList)
  {
    NSString* name = property.name;
    float value = property.skillValue;
    [self setValue:value forProperty:name];
  }
  
  return self;
}

#pragma mark - External calls

- (BOOL) skillIsReady
{
  CustomAssert(NO, @"Calling skillIsReady for SkillController class - should be overrided.");
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

#pragma mark - Placeholders to be overriden

- (void) skillExecutionStarted
{
  
}

- (void) skillExecutionFinished
{
  _callbackBlock();
}

- (void) setDefaultValuesForProperties
{
  
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  CustomAssert(NO, @"Calling setProperty for SkillController class - override it in inherited class to load properties");
  // There could be some cases where a skill doesn't have any properties at all. Implement empty setProperty.
}

@end