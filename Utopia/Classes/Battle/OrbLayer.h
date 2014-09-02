//
//  OrbLayer.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <CCSprite.h>
#import "BattleOrb.h"

@interface OrbLayer : CCNode

@property (nonatomic, strong) CCSprite* orbSprite;

+ (OrbLayer*) orbLayerWithOrb:(BattleOrb*)orb;

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb;

@end
