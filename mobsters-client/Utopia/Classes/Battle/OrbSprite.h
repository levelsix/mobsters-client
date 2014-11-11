//
//  OrbSprite.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <CCSprite.h>
#import <CCLabelTTF.h>
#import "BattleOrb.h"

static const float orbUpdateAnimDuration = 0.3f;

@interface OrbSprite : CCNode
{
  BattleOrb*  _orb;
  
  // Specials
  CCLabelTTF* _bombCounter;
}

@property (nonatomic, strong, readonly) CCSprite* orbSprite;

+ (OrbSprite*) orbSpriteWithOrb:(BattleOrb*)orb;

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb;

- (void) reloadSprite:(BOOL)animated;

// Specials
- (void) updateBombCounter:(BOOL)animated;

@end
