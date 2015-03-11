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

+ (OrbSprite*) orbSpriteWithOrb:(BattleOrb*)orb suffix:(NSString *)suffix
{
  return [[OrbSprite alloc] initWithOrb:orb suffix:suffix];
}

- (id) initWithOrb:(BattleOrb*)orb suffix:(NSString *)suffix
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _orb = orb;
  _suffix = suffix;
  
  // Create a new sprite for the orb
  [self reloadSprite:NO];
  
  return self;
}

- (void) resetOrbSpriteScale {
  if ([Globals isiPhone6Plus]) {
    self.orbSprite.scale = 1.1;
  } else {
    self.orbSprite.scale = 1.f;
  }
}

- (void) loadSprite
{
  NSString *imageName = [OrbSprite orbSpriteImageNameWithOrb:_orb withSuffix:_suffix];
  _orbSprite = [CCSprite spriteWithImageNamed:imageName];
  [self addChild:self.orbSprite];
  
  [self resetOrbSpriteScale];
  
  // Handle specials
  _turnCounter = nil;
  _damageMultiplier = nil;
  switch (_orb.specialOrbType)
  {
    case SpecialOrbTypeNone: if (_orb.damageMultiplier > 1) [self loadDamageMultiplierElements]; break;
    case SpecialOrbTypeBomb: if (_orb.turnCounter > 0) [self loadBombElements]; break;
    case SpecialOrbTypeCloud: [self loadCloudElements]; break;
    case SpecialOrbTypeHeadshot:
    case SpecialOrbTypeBullet:
    case SpecialOrbTypeGlove:
    case SpecialOrbTypeSword:
    case SpecialOrbTypeFryingPan:
    case SpecialOrbTypeBattery:
    case SpecialOrbTypePoisonFire:
      if (_orb.turnCounter > 0) [self loadHeadshotElements]; break;
    default: break;
  }
  
  if (_orb.isLocked) {
    [self loadLockElements];
  }
}

#pragma mark - Specials

- (void) decrementCloud
{
  CCNode *topLayer;
  for (CCNode *child in _orbSprite.children)
  {
    if ([child isKindOfClass:[CCSprite class]])
    {
      topLayer = child;
    }
  }
  
  CCActionFadeOut *fade = [CCActionFadeOut actionWithDuration:.2];
//  CCActionScaleTo *scale = [CCActionScaleTo actionWithDuration:0.2 scale:0];
  CCActionCallBlock *completion = [CCActionCallBlock actionWithBlock:^{
    [_orbSprite removeChild:topLayer cleanup:YES];
  }];
  
  [topLayer runAction:[CCActionSequence actions:fade, completion, nil]];
}

- (void) loadCloudElements
{
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  for (int i = 2; i <= _orb.cloudCounter; i++)
  {
    CCSprite* cloudLayer = [CCSprite node];
    cloudLayer.position = ccp(.5f, .5f);
    cloudLayer.positionType = CCPositionTypeNormalized;
    [Globals imageNamed:[NSString stringWithFormat:@"%@cloud%d.png", resPrefix, i] toReplaceSprite:cloudLayer];
    [_orbSprite addChild:cloudLayer];
  }
}

- (void) loadBombElements
{
  // Particle effect
  CCParticleSystem* fire = [CCParticleSystem particleWithFile:@"bombparticle.plist"];
  fire.position = ccp(30/33.f, 31/34.f);
  fire.positionType = CCPositionTypeNormalized;
  fire.scale = 0.5;
  [_orbSprite addChild:fire];
  
  // Counter
  _turnCounter = [CCLabelTTF labelWithString:@"0" fontName:@"Gotham-Ultra" fontSize:10];
  _turnCounter.color = [CCColor blackColor];
  _turnCounter.position = CGPointMake(9/33.f, 9.5/34.f);
  _turnCounter.positionType = CCPositionTypeNormalized;
  _turnCounter.color = [CCColor colorWithUIColor:[UIColor colorWithHexString:@"414141"]];
  _turnCounter.horizontalAlignment = CCTextAlignmentCenter;
  [_orbSprite addChild:_turnCounter];
  
  // Counter bgd
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  CCSprite *bgd = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@bomblabel.png", resPrefix]];
  [_turnCounter addChild:bgd z:-1];
  bgd.position = ccp(0.5, 0.58);
  bgd.positionType = CCPositionTypeNormalized;
  
  [self updateTurnCounter:NO];
}

- (void) loadHeadshotElements
{
  // Counter background
  CCSprite* counterBg = [CCSprite spriteWithImageNamed:@"headshotcounter.png"];
  counterBg.position = CGPointMake(6.f / 33.f, 6.5f / 34.f);
  counterBg.positionType = CCPositionTypeNormalized;
  [_orbSprite addChild:counterBg];
  
  // Counter label
  _turnCounter = [CCLabelTTF labelWithString:@"0" fontName:@"Gotham-Ultra" fontSize:8.f];
  _turnCounter.position = CGPointMake(6.f / 33.f, 5.5f / 34.f);
  _turnCounter.positionType = CCPositionTypeNormalized;
  _turnCounter.color = [CCColor colorWithUIColor:[UIColor colorWithHexString:@"414141"]];
  _turnCounter.horizontalAlignment = CCTextAlignmentCenter;
  [_orbSprite addChild:_turnCounter];
  
  [self updateTurnCounter:NO];
}

- (void) updateTurnCounter:(BOOL)animated
{
  if (_turnCounter)
  {
    if (animated)
      [_orbSprite runAction:[CCActionSequence actions:
                           [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:0.8]],
                           [CCActionCallBlock actionWithBlock:^{
                             _turnCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.turnCounter];
                           }],
                           [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:1.0]],
                           nil]];
    else
      _turnCounter.string = [NSString stringWithFormat:@"%d", (int)_orb.turnCounter];
    
    if (_orb.turnCounter <= 2 && _orb.turnCounter > 0)
    {
      [_turnCounter stopActionByTag:1812];
      CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                             [CCActionTintTo actionWithDuration:0.4*_orb.turnCounter color:[CCColor redColor]],
                             [CCActionTintTo actionWithDuration:0.4*_orb.turnCounter color:[CCColor clearColor]],
                             nil]];
      action.tag = 1812;
      [_turnCounter runAction:action];
    }
  }
}

- (void) loadLockElements {
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  
  _lockedSpriteLeft = [CCSprite spriteWithImageNamed:[resPrefix stringByAppendingString:@"lockedorbleft.png"]];
  [self addChild:_lockedSpriteLeft];
  _lockedSpriteRight = [CCSprite spriteWithImageNamed:[resPrefix stringByAppendingString:@"lockedorbright.png"]];
  [self addChild:_lockedSpriteRight];
}

#define LOCK_REMOVE_TIME .2
#define LOCK_REMOVE_MOVE_UP_PORTION .15

- (void) removeLockElements {
  
  CCActionEaseInOut *fadeOut = [CCActionEaseInOut actionWithAction:[CCActionFadeOut actionWithDuration:LOCK_REMOVE_TIME]];
  
  [_lockedSpriteRight runAction:
   [CCActionSequence actions:
    fadeOut, [CCActionRemove action], nil]];
  
  [_lockedSpriteLeft runAction:
   [CCActionSequence actions:
    fadeOut, [CCActionRemove action], nil]];
}

- (void) loadDamageMultiplierElements
{
  // Damage multiplier label
  _damageMultiplier = [CCLabelTTF labelWithString:@"1x" fontName:@"Gotham-Ultra" fontSize:10.f];
  _damageMultiplier.position = CGPointMake(28.f / 33.f, 6.5f / 34.f);
  _damageMultiplier.positionType = CCPositionTypeNormalized;
  _damageMultiplier.fontColor = [CCColor colorWithUIColor:[UIColor colorWithHexString:@"e2643d"]];
  _damageMultiplier.outlineColor = [CCColor whiteColor];
  _damageMultiplier.shadowOffset = ccp(0.f, -1.f);
  _damageMultiplier.shadowColor = [CCColor colorWithWhite:0.f alpha:0.75f];
  _damageMultiplier.shadowBlurRadius = 2.f;
  _damageMultiplier.horizontalAlignment = CCTextAlignmentCenter;
  _damageMultiplier.string = [NSString stringWithFormat:@"%dx", (int)_orb.damageMultiplier];
  [_orbSprite addChild:_damageMultiplier];
  
  // Particle effect
  CCParticleSystem* pfx = [CCParticleSystem particleWithFile:@"powermove.plist"];
  pfx.position = CGPointMake(28.f / 33.f, 6.5f / 34.f);
  pfx.positionType = CCPositionTypeNormalized;
  pfx.scale = .6f;
  [_orbSprite addChild:pfx];
}

#pragma mark - Helpers

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb withSuffix:(NSString *)suffix {
  OrbColor orbColor = orb.orbColor;
  PowerupType powerupType = orb.powerupType;
  SpecialOrbType special = orb.specialOrbType;
  
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  
  switch (special) {
    case SpecialOrbTypeCake:
      return [NSString stringWithFormat:@"%@cakeorb%@.png", resPrefix, suffix];
      break;
      
    case SpecialOrbTypeGrave:
      return [NSString stringWithFormat:@"%@graveorb%@.png", resPrefix, suffix];
      break;
      
    case SpecialOrbTypeBullet:
      return [NSString stringWithFormat:@"%@bulletorb%@.png", resPrefix, suffix];
      break;
      
    case SpecialOrbTypeSword:
      return [NSString stringWithFormat:@"%@swordorb%@.png", resPrefix, suffix];
      break;
      
    case SpecialOrbTypeBattery:
      return [NSString stringWithFormat:@"%@energizeorb%@.png", resPrefix, suffix];
      break;
      
    case SpecialOrbTypeCloud:
      return [NSString stringWithFormat:@"%@cloud1%@.png", resPrefix, suffix ];
      break;
    
    case SpecialOrbTypeBomb:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"bomb"], suffix ];
      break;
      
    case SpecialOrbTypeHeadshot:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"headshot"], suffix ];
      break;
      
    case SpecialOrbTypeGlove:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"glove"], suffix ];
      break;
      
    case SpecialOrbTypeFryingPan:
//      if (orbColor == OrbColorNone)
//        return nil;
//      if (orb.powerupType == PowerupTypeNone)
//        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"poison"], suffix ];
      return [NSString stringWithFormat:@"%@fireglove%@.png", resPrefix, suffix];
      break;
      
      //TODO: This suffix needs to change! Currently reusing poison orbs for this ability
    case SpecialOrbTypeLifeSteal:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"lsorb"], suffix ];
      break;
      
    case SpecialOrbTypePoison:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"poison"], suffix ];
      break;
      
      //TODO: This suffix needs to change! Currently reusing headshot orbs for this ability
    case SpecialOrbTypeTakeAim:
      if (orbColor == OrbColorNone)
        return nil;
      if (orb.powerupType == PowerupTypeNone)
        return [NSString stringWithFormat:@"%@%@%@.png", resPrefix, [Globals imageNameForElement:(Element)orbColor suffix:@"headshot"], suffix ];
      break;
      
    case SpecialOrbTypePoisonFire:
      return [NSString stringWithFormat:@"%@energizeorb%@.png", resPrefix, suffix];
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
  
  return [NSString stringWithFormat:@"%@%@%@%@.png", resPrefix, colorPrefix, powerupSuffix, suffix];
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
