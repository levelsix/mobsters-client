//
//  SkillControllerActive.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"
#import "NewBattleLayer.h"

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

- (BOOL) doesRefresh
{
  return NO;
}

- (BOOL) isActive
{
  return NO;
}

- (BOOL) activate
{
  return NO;
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
    // 2/24/15 - BN - Special orbs no longer count towards skill activation
    if (type == SpecialOrbTypeNone && color == self.orbColor && _orbCounter > 0)
      _orbCounter--;
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

- (void) resetOrbCounter
{
  _orbCounter = _orbRequirement;
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