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
  
  _orb = orb;
  
  // Create a new sprite for the orb
  [self reloadSprite:NO];
  
  return self;
}

- (void) loadSprite
{
  NSString *imageName = [OrbSprite orbSpriteImageNameWithOrb:_orb];
  _orbSprite = [CCSprite spriteWithImageNamed:imageName];
  [self addChild:self.orbSprite];
}

#pragma mark - Helpers

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb {
  OrbColor orbColor = orb.orbColor;
  PowerupType powerupType = orb.powerupType;
  SpecialOrbType special = orb.specialOrbType;
  
  switch (special) {
    case SpecialOrbTypeCake:
      return @"cakeorb.png";
      break;
    
    case SpecialOrbTypeBomb:
      if (orbColor == OrbColorRock || orbColor == OrbColorNone)
        return nil;
      return [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)orbColor suffix:@"bomb"] ];
      break;
    
    default:
      break;
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

- (void) reloadSprite:(BOOL)animated
{
  if (! animated)
    [_orbSprite removeFromParent];
  else
  {
    [_orbSprite runAction:[CCActionSequence actions:
                           [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:orbUpdateAnimDuration scale:0.0]],
                           [CCActionRemove action],
                           nil]];
  }
  
  [self loadSprite];
  
  if (animated)
  {
    [_orbSprite setScale:0.0];
    [_orbSprite runAction:[CCActionSequence actions:
                     [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:orbUpdateAnimDuration scale:1.0]],
                     nil]];
  }
}

@end
