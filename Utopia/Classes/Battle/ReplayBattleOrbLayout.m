//
//  ReplayBattleOrbLayout.m
//  Utopia
//
//  Created by Rob Giusti on 4/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplayBattleOrbLayout.h"
#import "BoardLayoutProto+Properties.h"
#import "Replay.pb.h"

@implementation ReplayBattleOrbLayout

- (void) storeHistory:(NSArray*)orbHistory {
  self.orbRecords = [NSMutableDictionary dictionary];
  for (NSArray *arr in orbHistory) {
    for (CombatReplayOrbProto *crop in arr) {
      if (![self.orbRecords objectForKey:@(crop.spawnedCol)])
        [self.orbRecords setObject:[NSMutableArray array] forKey:@(crop.spawnedCol)];
      
      NSMutableArray *orbsForCol = [self.orbRecords objectForKey:@(crop.spawnedCol)];
      [orbsForCol addObject:crop];
    }
  }
}

- (instancetype)initWithBoardLayout:(BoardLayoutProto *)proto andOrbHistory:(NSArray *)orbHistory {
  if (self = [super initWithBoardLayout:proto]) {
    [self storeHistory:orbHistory];
  }
  return self;
}

- (instancetype)initWithGridSize:(CGSize)gridSize numColors:(int)numColors andOrbHistory:(NSArray *)orbHistory {
  if (self = [super initWithGridSize:gridSize numColors:numColors]) {
    [self storeHistory:orbHistory];
  }
  return self;
}

- (NSSet *)createInitialOrbs {
  
  NSMutableSet *set = [NSMutableSet set];
  
  for (int row = 0; row < _numRows; row++) {
    for (int column = 0; column < _numColumns; column++) {
      BattleOrb *orb = [self createInitialOrbAtColumn:column row:row layout:_layoutProto];
      
      if (orb) {
        [set addObject:orb];
      }
    }
  }
  
  return set;
}

- (BattleOrb *)createInitialOrbAtColumn:(int)column row:(int)row layout:(BoardLayoutProto *)proto {
  BattleOrb* orb;
  
  NSMutableArray *orbsForCol = [self.orbRecords objectForKey:@(column)];
  CombatReplayOrbProto *crop;
  for (CombatReplayOrbProto *c in orbsForCol) {
    if (c.initialOrb && c.spawnedRow == row)
      crop = c;
  }
  
  if (crop) {
    [orbsForCol removeObject:crop];
    orb = [self createOrbFromHistory:crop];
    NSLog(@"Generated orb %i: %u at column %i", crop.orbId, orb.orbColor, column);
  } else {
    NSLog(@"The fuck? Failed to generate orb at column %i...", column);
  }
  
  if (orb) {
    for (BoardPropertyProto *prop in [proto propertiesForColumn:column row:row]) {
      if ([prop.name isEqualToString:ORB_LOCKED]) {
        orb.isLocked = YES;
      } else if ([prop.name isEqualToString:ORB_VINES]) {
        orb.isLocked = YES;
        orb.isVines = YES;
      }
    }
    
    [self setOrb:orb column:column row:row];
  }
  
  return orb;
}

- (BattleOrb *)createOrbFromHistory:(CombatReplayOrbProto*)crop {
  BattleOrb *orb = [[BattleOrb alloc] init];
  orb.orbColor = (OrbColor)crop.spawnedElement;
  orb.column = crop.spawnedCol;
  orb.row = crop.spawnedRow;
  orb.powerupType = crop.power;
  orb.specialOrbType = crop.special;
  orb.damageMultiplier = 1;
  return orb;
}

//Make this not random.
- (void)generateRandomOrbData:(BattleOrb *)orb atColumn:(int)column row:(int)row {
  
  NSMutableArray *orbsForCol = [self.orbRecords objectForKey:@(column)];
  
  if (orbsForCol.count) {
    CombatReplayOrbProto *crop = orbsForCol[0];
    [orbsForCol removeObject:crop];
    orb.orbColor = (OrbColor)crop.spawnedElement;
    orb.specialOrbType = (SpecialOrbType)crop.special;
    orb.powerupType = (PowerupType)crop.power;
    NSLog(@"Generated orb %i: %u at column %i", crop.orbId, orb.orbColor, column);
  }
  else
    @throw [NSException exceptionWithName:@"No Orbs Exception" reason:@"Not enough orbs in the data to put on the board" userInfo:nil];
}

- (void)recordOrb:(BattleOrb *)orb initialOrb:(BOOL)initialOrb {
  //Make sure that this doesn't record anything in replay mode
}

- (BOOL)isPossibleSwap:(BattleSwap *)swap {
  return YES;
}

@end
