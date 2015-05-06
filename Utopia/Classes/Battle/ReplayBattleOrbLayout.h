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

@end
