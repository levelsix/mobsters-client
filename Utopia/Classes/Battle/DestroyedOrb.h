//
//  DestroyedOrb.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d.h>
#import "BattleOrb.h"

@interface DestroyedOrb : CCSprite

@property (nonatomic, retain) CCMotionStreak *streak;
@property (nonatomic, assign) int scoreValue;

- (id) initWithColor:(CCColor *)color;
- (id) initWithCake;

@end

@interface SparklingTail : CCParticleSystem

- (id) initWithColor:(OrbColor)color;

@end

@interface LifeStealParticleEffect : CCParticleSystem

@end
