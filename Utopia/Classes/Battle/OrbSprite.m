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
  
  if ([Globals isiPhone6Plus]) {
    self.orbSprite.scale = 1.1;
  }
  
  // Handle specials
  _bombCounter = nil;
  _headshotCounter = nil;
  switch (_orb.specialOrbType)
  {
    case SpecialOrbTypeBomb: [self loadBombElements]; break;
    case SpecialOrbTypeHeadshot: if (_orb.headshotCounter > 0) [self loadHeadshotElements]; break;
    default: break;
  }
  
  if (_orb.isLocked) {
    [self loadLockElements];
  }
}

#pragma mark - Specials

- (void) loadBombElements
{
  // Particle effect
  CCParticleSystem* fire = [CCParticleSystem particleWithFile:@"bombparticle.plist"];
  fire.position = ccp(30/33.f, 31/34.f);
  fire.positionType = CCPositionTypeNormalized;
  fire.scale = 0.5;
  [_orbSprite addChild:fire];
  
  // Counter
  _bombCounter = [CCLabelTTF labelWithString:@"0" fontName:@"Gotham-Ultra" fontSize:10];
  _bombCounter.color = [CCColor blackColor];
  _bombCounter.position = CGPointMake(9/33.f, 9.5/34.f);
  _bombCounter.positionType = CCPositionTypeNormalized;
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
                           [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.0]],
                           nil]];
    else
      _bombCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.bombCounter];
    
    if (_orb.bombCounter <= 2 && _orb.bombCounter > 0)
    {
      [_bombCounter stopActionByTag:1812];
      CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                             [RecursiveTintTo actionWithDuration:0.4*_orb.bombCounter color:[CCColor redColor]],
                             [RecursiveTintTo actionWithDuration:0.4*_orb.bombCounter color:[CCColor clearColor]],
                             nil]];
      action.tag = 1812;
      [_bombCounter runAction:action];
    }
  }
}

- (void) loadHeadshotElements
{
  // Counter background
  CCSprite* counterBg = [CCSprite spriteWithImageNamed:@"headshotcounter.png"];
  counterBg.position = CGPointMake(6.f / 33.f, 6.5f / 34.f);
  counterBg.positionType = CCPositionTypeNormalized;
  [_orbSprite addChild:counterBg];
  
  // Counter label
  _headshotCounter = [CCLabelTTF labelWithString:@"0" fontName:@"Gotham-Ultra" fontSize:8.f];
  _headshotCounter.position = CGPointMake(6.f / 33.f, 5.5f / 34.f);
  _headshotCounter.positionType = CCPositionTypeNormalized;
  _headshotCounter.color = [CCColor colorWithUIColor:[UIColor colorWithHexString:@"414141"]];
  _headshotCounter.horizontalAlignment = CCTextAlignmentCenter;
  [_orbSprite addChild:_headshotCounter];
  
  [self updateHeadshotCounter:NO];
}

- (void) updateHeadshotCounter:(BOOL)animated
{
  if (_headshotCounter)
  {
    if (animated)
      [_orbSprite runAction:[CCActionSequence actions:
                             [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:.8f]],
                             [CCActionCallBlock actionWithBlock:^{ _headshotCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.headshotCounter]; }],
                             [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:1.f]],
                             nil]];
    else
      _headshotCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.headshotCounter];
    
    if (_orb.headshotCounter <= 2 && _orb.headshotCounter > 0)
    {
      [_headshotCounter stopActionByTag:1620];
      CCAction* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                  [RecursiveTintTo actionWithDuration:.4f * _orb.headshotCounter color:[CCColor redColor]],
                                                                  [RecursiveTintTo actionWithDuration:.4f * _orb.headshotCounter color:[CCColor clearColor]],
                                                                  nil]];
      [action setTag:1620];
      [_headshotCounter runAction:action];
    }
  }
}

- (void) loadLockElements {
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  
  _lockedSprite = [CCSprite spriteWithImageNamed:[resPrefix stringByAppendingString:@"lockedorb.png"]];
  [self addChild:_lockedSprite];
}

- (void) removeLockElements {
  [_lockedSprite runAction:
   [CCActionSequence actions:
    [CCActionFadeOut actionWithDuration:0.2],
    [CCActionRemove action], nil]];
}

#pragma mark - Helpers

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb {
  OrbColor orbColor = orb.orbColor;
  PowerupType powerupType = orb.powerupType;
  SpecialOrbType special = orb.specialOrbType;
  
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  
  switch (special) {
    case SpecialOrbTypeCake:
      return [resPrefix stringByAppendingString:@"cakeorb.png"];
      break;
      
    case SpecialOrbTypeCloud:
      return [resPrefix stringByAppendingFormat:@"cloud%d.png", (int)orb.cloudCounter];
      break;
    
    case SpecialOrbTypeBomb:
      if (orbColor == OrbColorRock || orbColor == OrbColorNone)
        return nil;
      return [NSString stringWithFormat:@"%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"bomb"] ];
      break;
      
    case SpecialOrbTypeHeadshot:
      if (orbColor == OrbColorNone)
        return nil;
      return [NSString stringWithFormat:@"%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"headshot"] ];
      break;
      
    case SpecialOrbTypePoison:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"poison"] ];
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
  
  return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, colorPrefix, powerupSuffix];
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
