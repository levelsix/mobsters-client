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
  CCLabelTTF* _turnCounter;
  CCLabelTTF* _damageMultiplier;
  
  CCSprite* _lockedSpriteLeft;
  CCSprite* _lockedSpriteRight;
  
  CCSprite* _vinesSprite;
  
  NSString *_suffix;
}

@property (nonatomic, strong, readonly) CCSprite* orbSprite;
@property (nonatomic, strong, readonly) NSString* suffix;

+ (OrbSprite*) orbSpriteWithOrb:(BattleOrb*)orb suffix:(NSString *)suffix;

+ (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb withSuffix:(NSString *)suffix;

- (void) reloadSprite:(BOOL)animated;

// Specials
- (void) decrementCloudWithBlock:(dispatch_block_t)comp;

- (void) updateTurnCounter:(BOOL)animated;

- (void) resetOrbSpriteScale;
- (void) removeLockElementsWithBlock:(dispatch_block_t)completion;
- (void) removeVineElementsWithBlock:(dispatch_block_t)completion;

- (void) playVineExpansion:(NSString*)directionString withCompletion:(void(^)())withCompletion;


@end
