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
  
  // Handle specials
  _bombCounter = nil;
  switch (_orb.specialOrbType)
  {
    case SpecialOrbTypeBomb: [self loadBombElements]; break;
    default: break;
  }
}

#pragma mark - Specials

- (void) loadBombElements
{
  // Particle effect
  CCParticleSystem* fire = [CCParticleSystem particleWithFile:@"bombparticle.plist"];
  fire.position = ccp(30, 31);
  fire.scale = 0.5;
  [_orbSprite addChild:fire];
  
  // Counter
  _bombCounter = [CCLabelTTF labelWithString:@"0" fontName:@"Gotham-Ultra" fontSize:10];
  _bombCounter.color = [CCColor blackColor];
  _bombCounter.position = CGPointMake(9, 9.5);
  _bombCounter.color = [CCColor colorWithUIColor:[UIColor colorWithHexString:@"414141"]];
  _bombCounter.horizontalAlignment = CCTextAlignmentCenter;
  [_orbSprite addChild:_bombCounter];
  
  [self updateBombCounter:NO];
}

- (void) updateBombCounter:(BOOL)animated
{
  if (_bombCounter)
  {
    if (animated)
      [_orbSprite runAction:[CCActionSequence actions:
                           [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:0.8]],
                           [CCActionCallBlock actionWithBlock:^{
                             _bombCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.bombCounter];
                           }],
                           [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.0]],
                           nil]];
    else
      _bombCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.bombCounter];
  }
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
      
      case SpecialOrbTypePoison:
          if (orbColor == OrbColorNone)
              return nil;
          return [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)orbColor suffix:@"poison"] ];
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
