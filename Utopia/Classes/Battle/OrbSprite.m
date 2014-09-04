//
//  OrbSprite.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbSprite.h"
#import "Globals.h"

@implementation OrbSprite

#pragma mark - Initialization

+ (OrbSprite*) orbSpriteWithOrb:(BattleOrb*)orb
{
  return [[OrbSprite alloc] initWithOrb:orb];
}

- (id) initWithOrb:(BattleOrb*)orb
{
  self = [super init];
  if ( ! self )
    return nil;
    
  // Create a new sprite for the orb
  NSString *imageName = [OrbSprite orbSpriteImageNameWithOrb:orb];
  self.orbSprite = [CCSprite spriteWithImageNamed:imageName];
  [self addChild:self.orbSprite];
  
  return self;
}

#pragma mark - Helpers

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb {
  OrbColor orbColor = orb.orbColor;
  PowerupType powerupType = orb.powerupType;
  SpecialOrbType special = orb.specialOrbType;
  
  if (special != SpecialOrbTypeNone) {
    switch (special) {
      case SpecialOrbTypeCake:
        return @"cakeorb.png";
        break;
        
      default:
        break;
    }
  }
  
  NSString *colorPrefix = @"";
  switch (orbColor) {
    case OrbColorFire:
    case OrbColorDark:
    case OrbColorLight:
    case OrbColorEarth:
    case OrbColorWater:
    case OrbColorRock:
      colorPrefix = [Globals imageNameForElement:(Element)orbColor suffix:@""];
      break;
    case OrbColorNone:
      colorPrefix = @"all";
      break;
    default: return nil; break;
  }
  
  NSString *powerupSuffix = @"";
  switch (powerupType) {
    case PowerupTypeNone: powerupSuffix = @"orb"; break;
    case PowerupTypeHorizontalLine: powerupSuffix = @"sideways"; break;
    case PowerupTypeVerticalLine: powerupSuffix = @"updown"; break;
    case PowerupTypeExplosion: powerupSuffix = @"grenade"; break;
    case PowerupTypeAllOfOneColor:
      colorPrefix = @"all";
      powerupSuffix = @"cocktail";
      break;
    default: return nil; break;
  }
  
  return [NSString stringWithFormat:@"%@%@.png", colorPrefix, powerupSuffix];
}

@end
