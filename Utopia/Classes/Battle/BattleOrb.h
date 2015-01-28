//
//  RWTCookie.h
//  CookieCrunch
//
//  Created by Matthijs on 25-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Protocols.pb.h"

typedef enum {
  OrbColorFire = ElementFire,
  OrbColorEarth = ElementEarth,
  OrbColorWater = ElementWater,
  OrbColorLight = ElementLight,
  OrbColorDark = ElementDark,
  OrbColorRock = ElementRock,
  OrbColorNone = ElementNoElement
} OrbColor;

typedef enum {
  SpecialOrbTypeNone = 0,
  SpecialOrbTypeCake = 1,
  SpecialOrbTypeBomb = 2,
  SpecialOrbTypePoison = 3,
  SpecialOrbTypeHeadshot = 4,
  SpecialOrbTypeCloud = 5,
  SpecialOrbTypeLifeSteal = 6,
  SpecialOrbTypeTakeAim = 7,
  SpecialOrbTypeGrave = 8
} SpecialOrbType;

typedef enum {
  PowerupTypeNone = 0,
  PowerupTypeHorizontalLine = 1,
  PowerupTypeVerticalLine = 2,
  PowerupTypeExplosion = 3,
  PowerupTypeAllOfOneColor = 4,
  PowerupTypeEnd = 20
} PowerupType;

typedef enum {
  OrbChangeTypeNone = 0,
  OrbChangeTypeDestroyed,
  OrbChangeTypePowerupCreated,
  OrbChangeTypeLockRemoved,
  OrbChangeTypeCloudDecremented
} OrbChangeType;

@interface BattleOrb : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) OrbColor orbColor;
@property (assign, nonatomic) SpecialOrbType specialOrbType;
@property (assign, nonatomic) PowerupType powerupType;

@property (assign, nonatomic) BOOL isLocked;

// Special orb variables
@property (assign, nonatomic) NSInteger bombCounter;
@property (assign, nonatomic) NSInteger bombDamage;
@property (assign, nonatomic) NSInteger headshotCounter;
@property (assign, nonatomic) NSInteger damageMultiplier;

@property (assign, nonatomic) NSInteger cloudCounter;

// Keeping state of orb
// This is used for 2 purposes:
// a) Swipe layer uses this value to figure out what happened to this orb
// b) Orb layout uses this value to determine if the orb can be operated on,
//    i.e. in 1 cyle, a locked orb can't be destroyed
@property (assign, nonatomic) OrbChangeType changeType;

- (BOOL) isMovable;

- (NSDictionary*) serialize;
- (void) deserialize:(NSDictionary*)dic;

@end
