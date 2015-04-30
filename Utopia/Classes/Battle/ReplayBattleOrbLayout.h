//
//  ReplayBattleOrbLayout.h
//  Utopia
//
//  Created by Rob Giusti on 4/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleOrbLayout.h"

@interface ReplayBattleOrbLayout : BattleOrbLayout

- (instancetype) initWithBoardLayout:(BoardLayoutProto*)proto andOrbHistory:(NSArray*)orbHistory;

- (void) performSwap:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2;

@end
