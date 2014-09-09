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
  SpecialOrbTypeCake = 1
} SpecialOrbType;

typedef enum {
  PowerupTypeNone = 0,
  PowerupTypeHorizontalLine,
  PowerupTypeVerticalLine,
  PowerupTypeExplosion,
  PowerupTypeAllOfOneColor,
  PowerupTypeEnd = 20
} PowerupType;

@interface BattleOrb : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) OrbColor orbColor;
@property (assign, nonatomic) SpecialOrbType specialOrbType;
@property (assign, nonatomic) PowerupType powerupType;

@end
