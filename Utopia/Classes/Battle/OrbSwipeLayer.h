//
//  OrbSwipeLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d.h>

#import "BattleOrbLayout.h"
#import "battleSwap.h"
#import "OrbSprite.h"

@interface OrbSwipeLayer : CCNode {
  int _numRows;
  int _numColumns;
  float _tileWidth;
  float _tileHeight;
  
  int _numOrbsStillAnimating;
  int _numPowerupsStillAnimating;
  dispatch_block_t _matchesCompletionBlock;
  
  BOOL _isPulsing;
}

@property (strong, nonatomic) BattleOrbLayout *layout;

@property (nonatomic, assign) float tileWidth;
@property (nonatomic, assign) float tileHeight;

// The scene handles touches. If it recognizes that the user makes a swipe,
// it will call this swipe handler. This is how it communicates back to the
// ViewController that a swap needs to take place. You can also use a delegate
// for this.
@property (copy, nonatomic) void (^tapDownHandler)(BattleOrb *orb);
@property (copy, nonatomic) void (^swipeHandler)(BattleSwap *swap);
@property (copy, nonatomic) void (^orbDestroyedHandler)(BattleOrb *orb);
@property (copy, nonatomic) void (^chainFiredHandler)(BattleChain *chain);

- (id) initWithContentSize:(CGSize)contentSize layout:(BattleOrbLayout *)layout;

- (OrbSprite*) createOrbSpriteForOrb:(BattleOrb *)orb;
- (void) addSpritesForOrbs:(NSSet *)orbs;
- (OrbSprite*) spriteForOrb:(BattleOrb*)orb;
- (void) removeAllOrbSprites;
- (void) destroyLock:(BattleOrb *)orb;

- (BOOL) isTrackingTouch;
- (CCColor *) colorForSparkle:(OrbColor)color;

- (CGPoint) pointForColumn:(NSInteger)column row:(NSInteger)row;
- (BOOL) convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row;

- (void)animateSwap:(BattleSwap *)swap completion:(dispatch_block_t)completion;
- (void)animateInvalidSwap:(BattleSwap *)swap completion:(dispatch_block_t)completion;
- (void)animateMatchedOrbs:(NSSet *)chains powerupCreations:(NSSet *)powerupCreations completion:(dispatch_block_t)completion;
- (void)animateFallingOrbs:(NSArray *)orbPaths newOrbs:(NSArray *)newOrbColumns bottomFeeders:(NSSet *)bottomFeeders completion:(dispatch_block_t)completion;
- (void)animateShuffle:(NSSet *)orbs completion:(dispatch_block_t)completion;

// Pulsing
- (void) pulseValidMove:(NSSet *)set;
- (void) stopValidMovePulsing;

// For the category
- (void) performOrbChange:(BattleOrb *)orb chains:(NSSet *)chains fromPowerup:(PowerupType)powerup;
- (void) animateChainedChainsFromBattleOrb:(BattleOrb *)orb chains:(NSSet *)chains;
- (void) checkIfAllOrbsAndPowerupsAreDone;

@end
