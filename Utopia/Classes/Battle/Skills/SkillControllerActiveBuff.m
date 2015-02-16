//
//  SkillControllerActiveBuff.m
//  Utopia
//
//  Created by Rob Giusti on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "SkillControllerActiveBuff.h"

@implementation SkillControllerActiveBuff

- (id) initWithProto:(SkillProto *)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if (!self)
    return nil;
  
  if (proto.skillEffectDuration)
    _duration = proto.skillEffectDuration;
  _turnsLeft = 0;
  
  return self;
  
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self doesRefresh] || ![self isActive])
  {
    if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
        (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
    {
      if ([self skillIsReady])
      {
        if (execute)
        {
          [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
          [self.battleLayer.orbLayer disallowInput];
          [self showSkillPopupOverlay:YES withCompletion:^(){
            if ([self doesRefresh])
              [self resetOrbCounter];
            if (![self activate])
              [self skillTriggerFinished:YES];
          }];
        }
        return YES;
      }
    }
  }
  
  return NO;
}

- (BOOL) isActive
{
  return _turnsLeft != 0;
}

- (BOOL) doesRefresh
{
  return NO;
}

- (NSInteger) getDuration
{
  return _duration;
}

- (BOOL) activate
{
  return [self resetDuration];
}

- (BOOL) resetDuration
{
  NSInteger tempOldTurns = _turnsLeft;
  _turnsLeft = [self getDuration];
  
  if (tempOldTurns == 0)
    return [self onDurationStart];
  else
    return [self onDurationReset];
}

- (void) tickDuration
{
  if (_turnsLeft > 0)
    _turnsLeft--;
  if (_turnsLeft == 0)
    [self onDurationEnd];
}

- (BOOL) onDurationStart
{
  [self skillTriggerFinished:YES];
  return YES;
}

- (BOOL) onDurationReset
{
  [self skillTriggerFinished:YES];
  return YES;
}

- (BOOL) onDurationEnd
{
  if (![self doesRefresh])
    [self resetOrbCounter];
  return NO;
}

- (void) endDurationNow
{
  if (_turnsLeft != 0)
  {
    _turnsLeft = 0;
    [self onDurationEnd];
  }
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft)
    _turnsLeft = [turnsLeft integerValue];
  
  return YES;
}

@end