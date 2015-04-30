//
//  ReplayOrbMainLayer.h
//  Utopia
//
//  Created by Rob Giusti on 4/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#include "OrbMainLayer.h"

@interface ReplayOrbMainLayer : OrbMainLayer

- (id) initWithLayoutProto:(BoardLayoutProto *)proto andHistory:(NSArray*)orbHistory;

@end
