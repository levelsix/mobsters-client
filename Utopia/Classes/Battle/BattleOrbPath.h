//
//  BattleOrbPath.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattleOrb.h"

@interface BattleOrbPath : NSObject

@property (nonatomic, retain) BattleOrb *orb;
@property (nonatomic, retain) NSMutableArray *path;

- (int) pathLength;

@end
