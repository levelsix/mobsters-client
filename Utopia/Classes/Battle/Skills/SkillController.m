//
//  SkillController.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillQuickAttack.h"
#import "SkillJelly.h"
#import "NewBattleLayer.h"
#import "GameViewController.h"

@implementation SkillController

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color // Factory call, can create different skill types
{
  switch( proto.type )
  {
    case SkillTypeQuickAttack: return [[SkillQuickAttack alloc] initWithProto:proto andMobsterColor:color];
    case SkillTypeJelly: return [[SkillJelly alloc] initWithProto:proto andMobsterColor:color];
    default: CustomAssert(NO, @"Trying to create a skill with the factory for undefined skill."); return nil;
  }
}

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _orbColor = color;
  _skillType = proto.type;
  _activationType = proto.activationType;
  
  // Properties
  [self setDefaultValues];
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

- (void) triggerSkillWithBlock:(SkillControllerBlock)block andTrigger:(SkillTriggerPoint)trigger
{
  // Try to trigger the skill and use callback right away if it's not responding
  _callbackBlock = block;
  BOOL triggered = [self skillCalledWithTrigger:trigger];
  if (! triggered)
    _callbackBlock(NO);
}

#pragma mark - Placeholders to be overriden

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger
{
  return NO;
}

- (void) skillTriggerFinished
{
  _callbackBlock();
}

- (void) setDefaultValues
{
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
}

#pragma mark - UI

- (void) showSkillPopupOverlayWithBlock:(SkillControllerBlock)block
{
  GameViewController *gvc = [GameViewController baseController];
  UIView *parentView = gvc.view;
  SkillPopupOverlay* popupOverlay = [[[NSBundle mainBundle] loadNibNamed:@"SkillPopupOverlay" owner:self options:nil] objectAtIndex:0];
  [parentView addSubview:popupOverlay];
  [popupOverlay animateForSkill:_skillType forPlayer:_belongsToPlayer withBlock:block];
}

@end