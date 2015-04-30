//
//  ReplayBattleOrbLayout.m
//  Utopia
//
//  Created by Rob Giusti on 4/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplayBattleOrbLayout.h"
#import "Replay.pb.h"

@implementation ReplayBattleOrbLayout

- (instancetype)initWithBoardLayout:(BoardLayoutProto *)proto andOrbHistory:(NSArray *)orbHistory {
  if (self = [super initWithBoardLayout:proto]) {
    self.orbRecords = [NSMutableDictionary dictionary];
    for (NSArray *arr in orbHistory)
    {
      for (CombatReplayOrbProto *crop in arr) {
        if (![self.orbRecords objectForKey:@(crop.spawnedCol)])
            [self.orbRecords setObject:[NSMutableArray array] forKey:@(crop.spawnedCol)];
        
        NSMutableArray *orbsForCol = [self.orbRecords objectForKey:@(crop.spawnedCol)];
        [orbsForCol addObject:crop];
      }
    }
  }
  return self;
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
  }
  
  return orb;
}

- (BattleOrb *)createOrbFromHistory:(CombatReplayOrbProto*)crop {
  BattleOrb *orb = [[BattleOrb alloc] init];
  orb.orbColor = (OrbColor)crop.spawnedElement;
  orb.column = crop.spawnedCol;
  orb.row = crop.spawnedRow;
  orb.powerupType = crop.type;
  orb.damageMultiplier = 1;
  return orb;
}

- (void)generateRandomOrbData:(BattleOrb *)orb atColumn:(int)column row:(int)row {
  
  NSMutableArray *orbsForCol = [self.orbRecords objectForKey:@(column)];
  
  if (orbsForCol.count) {
    CombatReplayOrbProto *crop = orbsForCol[0];
    [orbsForCol removeObject:crop];
    orb.orbColor = (OrbColor)crop.spawnedElement;
    orb.specialOrbType = (SpecialOrbType)crop.type;
  }
  else
    @throw [NSException exceptionWithName:@"No Orbs Exception" reason:@"Not enough orbs in the data to put on the board" userInfo:nil];
}

- (void)recordOrb:(BattleOrb *)orb initialOrb:(BOOL)initialOrb {
  //Make sure that this doesn't record anything in replay mode
}

@end
