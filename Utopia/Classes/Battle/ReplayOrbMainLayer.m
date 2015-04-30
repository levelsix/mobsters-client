//
//  ReplayOrbMainLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplayOrbMainLayer.h"
#import "ReplayBattleOrbLayout.h"

@implementation ReplayOrbMainLayer

- (id)initWithLayoutProto:(BoardLayoutProto *)proto andHistory:(NSArray *)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithBoardLayout:proto andOrbHistory:orbHistory];
  return [self initWithGridSize:CGSizeMake(layout.numColumns, layout.numRows) numColors:layout.numColors layout:layout];
}

@end