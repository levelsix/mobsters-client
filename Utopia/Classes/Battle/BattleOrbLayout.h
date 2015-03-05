//
//  BattleLevel.h
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleOrb.h"
#import "BattleTile.h"
#import "BattleSwap.h"
#import "BattleChain.h"
#import "BattleOrbPath.h"

#import "Board.pb.h"

// This will set moves to 50, make you always have first hit, and allow you to move anywhere, and have orb log
#ifdef DEBUG
#define DEBUG_BATTLE_MODE
#endif

#define SPAWN_TILE @"SPAWN_TILE"
#define NOT_SPAWN_TILE @"NOT_SPAWN_TILE"
#define HOLE @"HOLE"
#define PASSABLE_HOLE @"PASSABLE_HOLE"
#define TILE_TYPE @"TILE_TYPE"
#define INITIAL_SKILL @"INITIAL_SKILL"

#define ORB_COLOR @"ORB_COLOR"
#define ORB_POWERUP @"ORB_POWERUP"
#define ORB_SPECIAL @"ORB_SPECIAL"
#define ORB_LOCKED @"ORB_LOCKED"
#define ORB_EMPTY @"ORB_EMPTY"

@interface BattleOrbLayout : NSObject {
  int _numColumns;
  int _numRows;
  int _numColors;
  
  // The 2D array that contains the layout of the level.
  // Will contain BattleTile objects
  __strong id **_tiles;
  
  // The 2D array that keeps track of where the BattleOrbs are.
  // Will contain BattleOrb objects
  __strong id **_orbs;
  
  BoardLayoutProto *_layoutProto;
}

@property (nonatomic, readonly) int numColumns;
@property (nonatomic, readonly) int numRows;
@property (nonatomic, readonly) int numColors;

@property (nonatomic, retain) NSDictionary *specialOrbPercentages;

- (instancetype) initWithBoardLayout:(BoardLayoutProto *)proto;
- (instancetype) initWithGridSize:(CGSize)gridSize numColors:(int)numColors;

// Can be overwritten to provide harder combos and what not
- (OrbColor) generateRandomOrbColor;
- (void) generateRandomOrbData:(BattleOrb*)orb atColumn:(int)column row:(int)row;

// Used to restore state
- (void) restoreLayoutWithOrbs:(NSSet *)orbs;

// Checks if this swap is a powerup match. If not, it could still be a regular match.
- (BOOL)isPowerupMatch:(BattleOrb *)orb otherOrb:(BattleOrb *)other;

// This is mainly to prevent orbs like cake from being destroyed by powerups.
- (BOOL)orbCanBeRemoved:(BattleOrb *)orb;

// Fills up the level with new BattleOrb objects. The level is guaranteed free
// from matches at this point.
// You call this method at the beginning of a new game and whenever the player
// taps the Shuffle button.
// Returns a set containing all the new BattleOrb objects.
- (NSSet *)createInitialOrbs;

// Can be called to rearrange the current board
- (NSSet *)shuffle;

- (BattleOrbPath *) orbPathForOrb:(BattleOrb *)orb withOrbPaths:(NSArray *)orbPaths;
- (void) addPoint:(CGPoint)pt forOrb:(BattleOrb *)orb withOrbPaths:(NSMutableArray *)orbPaths;

// Returns the orb at the specified column and row, or nil when there is none.
- (BattleOrb *)orbAtColumn:(NSInteger)column row:(NSInteger)row;

// Determines whether there's a tile at the specified column and row.
- (BattleTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

// Swaps the positions of the two orbs from the BattleSwap object.
- (void)performSwap:(BattleSwap *)swap;

- (void) resetOrbChangeTypes;

// Determines whether the suggested swap is a valid one, i.e. it results in at
// least one new chain of 3 or more orbs of the same type.
- (BOOL)isPossibleSwap:(BattleSwap *)swap;

// Recalculates which moves are valid.
- (NSSet *)detectPossibleSwaps;

// Gets a random valid swap (for pulsing).
- (NSSet *) getRandomValidMove;

// Detects whether there are any chains of 3 or more orbs, and removes them
// from the level.
// Returns a set containing BattleChain objects, which describe the BattleOrbs
// that were removed.
- (NSSet *)removeMatches;

// This will get the sequence of chains from an initial powerup match.
- (NSSet *) performPowerupMatchWithSwap:(BattleSwap *)swap;

// Takes in a set of chains and checks whether any powerups were created from them
// Requires the initial swap to determine placement of the powerup orb.
- (NSSet *) detectPowerupCreationFromChains:(NSSet *)chains withInitialSwap:(BattleSwap *)swap;

// Look in the match chains and see if any of the destroyed orbs were powerups,
// If they are, then fire them off and return chains representing destroyed orbs.
- (NSSet *) detectPowerupChainsWithMatchChains:(NSSet *)chains;

- (NSSet *) detectAdjacentChainsWithMatchAndPowerupChains:(NSSet *)chains;

// Detect if there are any chains for this position (used by skillManager
- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row;

// Detects where there are holes and shifts any orbs down to fill up those
// holes. In effect, this "bubbles" the holes up to the top of the column.
// Returns an array that contains a sub-array for each column that had holes,
// with the BattleOrb objects that have shifted. Those orbs are already
// moved to their new position. The objects are ordered from the bottom up.
- (BOOL) fillHoles:(NSMutableArray *)orbPaths;
- (BOOL) diagonallyFillHoles:(NSMutableArray *)orbPaths;

// Where necessary, adds new orbs to fill up the holes at the top of the
// columns.
// Returns an array that contains a sub-array for each column that had holes,
// with the new BattleOrb objects. Orbs are ordered from the top down.
- (NSArray *)topUpOrbs:(NSMutableArray *)orbPaths;

// This will detect if any specials like cake are at the bottom so that they can be
// deleted. This will probably be followed by another set of calls to fillHoles and topUpOrbs.
- (NSSet *)detectBottomFeeders:(NSMutableArray *)orbPaths;

- (BattleOrb *) findOrbWithColorPreference:(OrbColor)orbColor isInitialSkill:(BOOL)isInitialSkill;

@end
