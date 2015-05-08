//
//  SkillSkewer
//  Utopia
//
//  NOTE: This skill is actually "Double Slap"
//  It was originally spec'd as "Skewer," and then
//  "Poison Skewer" wound up getting called skewer and everything
//  became a goddamn mess.
//
//  Created by Rob Giusti on 1/26/15
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillSkewer.h"
#import "MainBattleLayer.h"

@implementation SkillSkewer

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _lowDamage = 1;
  _highDamage = 10;
  _chance = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"LOW_DAMAGE"] )
    _lowDamage = value;
  else if ( [property isEqualToString:@"HIGH_DAMAGE"] )
    _highDamage = value;
  else if ( [property isEqualToString:@"CHANCE"] )
    _chance = value;
}

#pragma mark - Overrides

- (int) quickAttackDamage
{
  if ([self randomWithChance:_chance])
  {
    return _highDamage;
  }
  return _lowDamage;
}

@end