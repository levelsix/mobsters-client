//
//  RWTCookie.m
//  CookieCrunch
//
//  Created by Matthijs on 25-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleOrb.h"

@implementation BattleOrb

- (id) copy {
  BattleOrb *cp = [[BattleOrb alloc] init];
  cp.column = self.column;
  cp.row = self.row;
  cp.orbColor = self.orbColor;
  cp.specialOrbType = self.specialOrbType;
  cp.powerupType = self.powerupType;
  return cp;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@: type - %ld powerup - %ld square - (%ld,%ld)", [super description], (long)self.orbColor, (long)self.powerupType, (long)self.column, (long)self.row];
}

@end
