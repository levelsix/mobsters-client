//
//  OrbSwipeLayer+PowerupAnimations.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbSwipeLayer.h"

@interface OrbSwipeLayer (PowerupAnimations)

- (void) spawnHorizontalLineWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;
- (void) spawnVerticalLineWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;
- (void) spawnExplosionWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;
- (void) spawnRainbowWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;

- (void) spawnRainbowLineOrExplosionWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;
- (void) spawnDoubleRainbowWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains;

@end
