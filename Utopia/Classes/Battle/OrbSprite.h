//
//  OrbSprite.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <CCSprite.h>
#import "BattleOrb.h"

@interface OrbSprite : CCNode

@property (nonatomic, strong) CCSprite* orbSprite;

+ (OrbSprite*) orbSpriteWithOrb:(BattleOrb*)orb;

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb;

@end
