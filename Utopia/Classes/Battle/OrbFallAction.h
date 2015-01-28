//
//  OrbFallAction.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <cocos2d.h>
#import "BattleOrbPath.h"
#import "OrbSprite.h"
#import "OrbSwipeLayer.h"

@interface OrbFallAction : CCActionEase

+ (id) actionWithOrbPath:(BattleOrbPath *)orbPath orb:(OrbSprite *)orbLayer swipeLayer:(OrbSwipeLayer *)swipeLayer isBottomFeeder:(BOOL)isBottomFeeder;

@end
