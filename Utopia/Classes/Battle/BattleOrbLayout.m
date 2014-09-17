//
//  BattleLevel.m
//  OrbCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleOrbLayout.h"
#import "SkillManager.h"
#import "Globals.h"

// Make this 1 to allow user to swap wherever they want
#define FREE_BATTLE_MOVEMENT 0

@interface BattleOrbLayout ()

// The list of swipes that result in a valid swap. Used to determine whether
// the player can make a certain swap, whether the board needs to be shuffled,
// and to generate hints.
@property (strong, nonatomic) NSSet *possibleSwaps;

@end

@implementation BattleOrbLayout

- (instancetype) initWithGridSize:(CGSize)gridSize numColors:(int)numColors {
  if ((self = [super init])) {
    _numColumns = gridSize.width;
    _numRows = gridSize.height;
    _numColors = numColors;
    
    _tiles = (__strong id **)calloc(sizeof(id *), _numColumns);
    _orbs = (__strong id **)calloc(sizeof(id *), _numColumns);
    for (int i = 0; i < _numColumns; i++) {
      _tiles[i] = (__strong id *)calloc(sizeof(id *), _numRows);
      _orbs[i] = (__strong id *)calloc(sizeof(id *), _numRows);
      
      for (int j = 0; j < _numRows; j++) {
        _tiles[i][j] = [[BattleTile alloc] initWithColumn:i row:j typeTop:TileTypeNormal typeBottom:TileTypeNormal];
      }
    }
	}
	
	return self;
}

- (void) dealloc {
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      _tiles[i][j] = nil;
      _orbs[i][j] = nil;
    }
    
    free(_tiles[i]);
    free(_orbs[i]);
  }
  free(_tiles);
  free(_orbs);
}

#pragma mark - Restoration

- (void) restoreLayoutWithOrbs:(NSSet *)orbs {
  for (BattleOrb *orb in orbs) {
    if (orb.column >= 0 && orb.column < _numColumns &&
        orb.row >= 0 && orb.row < _numRows) {
      [self setOrb:orb column:orb.column row:orb.row];
    }
  }
  
  [self detectPossibleSwaps];
}

#pragma mark - Game Setup

- (NSSet *) shuffle {
  NSMutableSet *set;
  
  BOOL foundMatch;
  
  do {
    set = [NSMutableSet set];
    
    // Put all orbs in an array, shuffle, and put them back
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < _numColumns; i++) {
      for (int j = 0; j < _numRows; j++) {
        
        // Check if this is a special orb
        BattleOrb* orb = [self orbAtColumn:i row:j];
        if (orb.specialOrbType != SpecialOrbTypeNone)
          continue;
        
        [array addObject:orb];
        [self setOrb:nil column:i row:j];
      }
    }
    
    [array shuffle];
    
    foundMatch = NO;
    
    NSInteger counter = 0;
    for (int i = 0; i < _numColumns; i++) {
      for (int j = 0; j < _numRows; j++) {
        
        // Check if this a special orb
        BattleOrb* orb = [self orbAtColumn:i row:j];
        if (orb && orb.specialOrbType != SpecialOrbTypeNone)
          continue;
        
        orb = array[counter];
        [self setOrb:orb column:i row:j];
        orb.column = i;
        orb.row = j;
        
        counter++;
        
        [set addObject:orb];
        
        if ([self hasChainAtColumn:i row:j] || (j == 0 && [self orbIsBottomFeeder:orb])) {
          foundMatch = YES;
          continue;
        }
      }
    }
    
    // At the start of each turn we need to detect which orbs the player can
    // actually swap. If the player tries to swap two orbs that are not in
    // this set, then the game does not accept this as a valid move.
    // This also tells you whether no more swaps are possible and the game needs
    // to automatically reshuffle.
    [self detectPossibleSwaps];
    
    //NSLog(@"possible swaps: %@", self.possibleSwaps);
    
    // If there are no possible moves, then keep trying again until there are.
  }
  while ([self.possibleSwaps count] == 0 || foundMatch);
  
  return set;
}

- (void) generateRandomOrbData:(BattleOrb*)orb atColumn:(int)column row:(int)row {
  
  orb.orbColor = arc4random_uniform(_numColors) + OrbColorFire;
  orb.specialOrbType = SpecialOrbTypeNone;
  
  // Allow skill manager to override this info
  [skillManager generateSpecialOrb:orb atColumn:column row:row];
}

- (NSSet *) createInitialOrbs {
  
  NSMutableSet *set = [NSMutableSet set];
  
  // Loop through the rows and columns of the 2D array. Note that column 0,
  // row 0 is in the bottom-left corner of the array.
  do {
    for (NSInteger row = 0; row < _numRows; row++) {
      for (NSInteger column = 0; column < _numColumns; column++) {
        
        // Only make a new orb if there is a tile at this spot.
        if ([self tileAtColumn:column row:row] != nil) {
          
          // Pick the orb type at random, and make sure that this never
          // creates a chain of 3 or more. We want there to be 0 matches in
          // the initial state.
          BattleOrb *orb;
          do {
            // Create a new orb and add it to the 2D array.
            orb = [self createOrbAtColumn:column row:row type:OrbColorRock powerup:PowerupTypeNone special:SpecialOrbTypeNone];
            
            [self generateRandomOrbData:orb atColumn:column row:row];
          }
          // Can't afford to have a chain in initial set
          while ([self hasChainAtColumn:column row:row]);
          
          // Also add the orb to the set so we can tell our caller about it.
          [set addObject:orb];
        }
      }
    }
  }
  while (![self detectPossibleSwaps].count);
  
  return set;
}

- (BattleOrb *)createOrbAtColumn:(NSInteger)column row:(NSInteger)row type:(OrbColor)orbColor powerup:(PowerupType)powerup special:(SpecialOrbType)special {
  BattleOrb *orb = [[BattleOrb alloc] init];
  orb.orbColor = orbColor;
  orb.column = column;
  orb.row = row;
  orb.powerupType = powerup;
  orb.specialOrbType = special;
  [self setOrb:orb column:column row:row];
  return orb;
}

#pragma mark - Detecting Swaps

- (NSSet *) detectPossibleSwaps {
  
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger row = 0; row < _numRows; row++) {
    for (NSInteger column = 0; column < _numColumns; column++) {
      
      BattleOrb *orb = [self orbAtColumn:column row:row];
      if (orb != nil) {
        
        // Is it possible to swap this orb with the one on the right?
        // Note: don't need to check the last column.
        if (column < _numColumns - 1) {
          
          // Have a orb in this spot? If there is no tile, there is no orb.
          BattleOrb *other = [self orbAtColumn:column+1 row:row];
          if (other != nil) {
            // Two powerups automatically count as a match
            if (FREE_BATTLE_MOVEMENT || [self isPowerupMatch:orb otherOrb:other]) {
              BattleSwap *swap = [[BattleSwap alloc] init];
              swap.orbA = orb;
              swap.orbB = other;
              [set addObject:swap];
            } else {
              // Swap them
              _orbs[column][row] = other;
              _orbs[column+1][row] = orb;
              
              // Is either orb now part of a chain?
              if ([self hasChainAtColumn:column + 1 row:row] ||
                  [self hasChainAtColumn:column row:row]) {
                
                BattleSwap *swap = [[BattleSwap alloc] init];
                swap.orbA = orb;
                swap.orbB = other;
                [set addObject:swap];
              }
              
              // Swap them back
              _orbs[column][row] = orb;
              _orbs[column+1][row] = other;
            }
          }
        }
        
        // Is it possible to swap this orb with the one above?
        // Note: don't need to check the last row.
        if (row < _numRows - 1) {
          
          // Have a orb in this spot? If there is no tile, there is no orb.
          BattleOrb *other = [self orbAtColumn:column row:row+1];
          if (other != nil) {
            if (FREE_BATTLE_MOVEMENT || [self isPowerupMatch:orb otherOrb:other]) {
              BattleSwap *swap = [[BattleSwap alloc] init];
              swap.orbA = orb;
              swap.orbB = other;
              [set addObject:swap];
            } else {
              // Swap them
              _orbs[column][row] = other;
              _orbs[column][row+1] = orb;
              
              // Is either orb now part of a chain?
              if ([self hasChainAtColumn:column row:row + 1] ||
                  [self hasChainAtColumn:column row:row]) {
                
                BattleSwap *swap = [[BattleSwap alloc] init];
                swap.orbA = orb;
                swap.orbB = other;
                [set addObject:swap];
              }
              
              // Swap them back
              _orbs[column][row] = orb;
              _orbs[column][row+1] = other;
            }
          }
        }
      }
    }
  }
  
  self.possibleSwaps = set;
  
  return set;
}

- (NSSet *) getRandomValidMove {
  if (self.possibleSwaps.count > 0) {
    NSUInteger idx = arc4random_uniform((int)self.possibleSwaps.count);
    BattleSwap *swap = self.possibleSwaps.allObjects[idx];
    
    if ([self isPowerupMatch:swap.orbA otherOrb:swap.orbB]) {
      return [NSSet setWithObjects:swap.orbA, swap.orbB, nil];
    } else {
      // If it's not a powerup match, we need to execute the swap and find a valid chain
      [self performSwap:swap];
      
      NSSet *horiz = [self detectHorizontalMatches];
      NSSet *vert = [self detectVerticalMatches];
      
      NSMutableArray *array = [NSMutableArray arrayWithArray:[horiz setByAddingObjectsFromSet:vert].allObjects];
      [array shuffle];
      
      BattleChain *chain = [array firstObject];
      
      // Swap the two orbs back to restore state
      [self performSwap:swap];
      
      return [NSSet setWithArray:chain.orbs];
    }
  }
  return nil;
}

- (BOOL)isPowerupMatch:(BattleOrb *)orb otherOrb:(BattleOrb *)other {
  return (orb.powerupType != PowerupTypeNone && other.powerupType != PowerupTypeNone) ||
  (orb.powerupType == PowerupTypeAllOfOneColor && other.orbColor != OrbColorNone) ||
  (other.powerupType == PowerupTypeAllOfOneColor && orb.orbColor != OrbColorNone);
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
  NSUInteger orbColor = [self orbAtColumn:column row:row].orbColor;
  
  if (orbColor != OrbColorNone) {
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && [self orbAtColumn:i row:row].orbColor == orbColor; i--, horzLength++) ;
    for (NSInteger i = column + 1; i < _numColumns && [self orbAtColumn:i row:row].orbColor == orbColor; i++, horzLength++) ;
    if (horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && [self orbAtColumn:column row:i].orbColor == orbColor; i--, vertLength++) ;
    for (NSInteger i = row + 1; i < _numRows && [self orbAtColumn:column row:i].orbColor == orbColor; i++, vertLength++) ;
    return (vertLength >= 3);
  }
  return NO;
}

#pragma mark - Swapping

- (void) performSwap:(BattleSwap *)swap {
  // Need to make temporary copies of these because they get overwritten.
  NSInteger columnA = swap.orbA.column;
  NSInteger rowA = swap.orbA.row;
  NSInteger columnB = swap.orbB.column;
  NSInteger rowB = swap.orbB.row;
  
  // Swap the orbs. We need to update the array as well as the column
  // and row properties of the BattleOrb objects, or they go out of sync!
  [self setOrb:swap.orbB column:columnA row:rowA];
  swap.orbB.column = columnA;
  swap.orbB.row = rowA;
  
  [self setOrb:swap.orbA column:columnB row:rowB];
  swap.orbA.column = columnB;
  swap.orbA.row = rowB;
}

#pragma mark - Detecting Matches

- (NSSet *) removeMatches {
  NSSet *horizontalChains = [self detectHorizontalMatches];
  NSSet *verticalChains = [self detectVerticalMatches];
  
  // Note: to detect more advanced patterns such as an L shape, you can see
  // whether a orb is in both the horizontal & vertical chains sets and
  // whether it is the first or last in the array (at a corner). Then you
  // create a new BattleChain object with the new type and remove the other two.
  
  [self removeOrbs:horizontalChains];
  [self removeOrbs:verticalChains];
  
  return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (NSSet *) detectHorizontalMatches {
  
  // Contains the BattleOrb objects that were part of a horizontal chain.
  // These orbs must be removed.
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger row = 0; row < _numRows; row++) {
    
    // Don't need to look at last two columns.
    // Note: for-loop without increment.
    for (NSInteger column = 0; column < _numColumns - 2; ) {
      NSUInteger matchType = [self orbAtColumn:column row:row].orbColor;
      
      if (matchType != OrbColorNone) {
        
        // If there is a orb/tile at this position...
        if ([self orbAtColumn:column row:row] != nil) {
          
          // And the next two columns have the same type...
          if ([self orbAtColumn:column+1 row:row].orbColor == matchType
              && [self orbAtColumn:column+2 row:row].orbColor == matchType) {
            
            // ...then add all the orbs from this chain into the set.
            BattleChain *chain = [[BattleChain alloc] init];
            chain.chainType = ChainTypeMatch;
            do {
              [chain addOrb:[self orbAtColumn:column row:row]];
              column += 1;
            }
            while (column < _numColumns && [self orbAtColumn:column row:row].orbColor == matchType);
            
            [set addObject:chain];
            continue;
          }
        }
      }
      
      // Orb did not match or empty tile, so skip over it.
      column += 1;
    }
  }
  return set;
}

// Same as the horizontal version but just steps through the array differently.
- (NSSet *) detectVerticalMatches {
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger column = 0; column < _numColumns; column++) {
    for (NSInteger row = 0; row < _numRows - 2; ) {
      if ([self orbAtColumn:column row:row] != nil) {
        OrbColor matchType = [self orbAtColumn:column row:row].orbColor;
        
        if (matchType != OrbColorNone) {
          if ([self orbAtColumn:column row:row+1].orbColor == matchType
              && [self orbAtColumn:column row:row+2].orbColor == matchType) {
            
            BattleChain *chain = [[BattleChain alloc] init];
            chain.chainType = ChainTypeMatch;
            do {
              [chain addOrb:[self orbAtColumn:column row:row]];
              row += 1;
            }
            while (row < _numRows && [self orbAtColumn:column row:row].orbColor == matchType);
            
            [set addObject:chain];
            continue;
          }
        }
      }
      row += 1;
    }
  }
  return set;
}

- (void)removeOrbs:(NSSet *)chains {
  for (BattleChain *chain in chains) {
    for (BattleOrb *orb in chain.orbs) {
      [self setOrb:nil column:orb.column row:orb.row];
    }
  }
}

- (BOOL) orbCanBeRemoved:(BattleOrb *)orb {
  return orb.specialOrbType != SpecialOrbTypeCake;
}

- (BOOL) orbIsBottomFeeder:(BattleOrb *)orb {
  return orb.specialOrbType == SpecialOrbTypeCake;
}

#pragma mark - Powerup Matches

- (NSSet *) performPowerupMatchWithSwap:(BattleSwap *)swap {
  NSMutableSet *chains = [NSMutableSet set];
  
  BattleOrb *orbA = swap.orbA;
  BattleOrb *orbB = swap.orbB;
  
  BOOL addSwapChain = YES;
  
  // Check if it is a double powerup match or a rainbow + color
  if (orbA.powerupType != PowerupTypeNone && orbB.powerupType != PowerupTypeNone) {
    NSSet *set = nil;
    
    if ((orbA.powerupType == PowerupTypeHorizontalLine || orbA.powerupType == PowerupTypeVerticalLine) &&
        (orbB.powerupType == PowerupTypeHorizontalLine || orbB.powerupType == PowerupTypeVerticalLine)) {
      set = [self createDoubleLinePowerupWithSwap:swap];
    }
    
    else if (((orbA.powerupType == PowerupTypeHorizontalLine || orbA.powerupType == PowerupTypeVerticalLine) && orbB.powerupType == PowerupTypeExplosion) ||
             ((orbB.powerupType == PowerupTypeHorizontalLine || orbB.powerupType == PowerupTypeVerticalLine) && orbA.powerupType == PowerupTypeExplosion)) {
      set = [self createLineExplosionPowerupWithSwap:swap];
    }
    
    else if (orbA.powerupType == PowerupTypeExplosion && orbB.powerupType == PowerupTypeExplosion) {
      set = [self createDoubleExplosionPowerupWithSwap:swap];
    }
    
    else if (((orbA.powerupType == PowerupTypeHorizontalLine || orbA.powerupType == PowerupTypeVerticalLine) && orbB.powerupType == PowerupTypeAllOfOneColor) ||
             ((orbB.powerupType == PowerupTypeHorizontalLine || orbB.powerupType == PowerupTypeVerticalLine) && orbA.powerupType == PowerupTypeAllOfOneColor)) {
      set = [self createRainbowLinePowerupWithSwap:swap];
      addSwapChain = NO;
    }
    
    else if ((orbA.powerupType == PowerupTypeExplosion && orbB.powerupType == PowerupTypeAllOfOneColor) ||
             (orbB.powerupType == PowerupTypeExplosion && orbA.powerupType == PowerupTypeAllOfOneColor)) {
      set = [self createRainbowExplosionPowerupWithSwap:swap];
      addSwapChain = NO;
    }
    
    else if (orbA.powerupType == PowerupTypeAllOfOneColor && orbB.powerupType == PowerupTypeAllOfOneColor) {
      set = [self createDoubleRainbowPowerupWithSwap:swap];
    }
    
    [chains addObjectsFromArray:set.allObjects];
  }
  
  // Consider a molotov + regular orb as a powerup match as well..
  else if (orbA.powerupType == PowerupTypeAllOfOneColor || orbB.powerupType == PowerupTypeAllOfOneColor) {
    // Grab the orb that is the rainbow
    BattleOrb *orb = orbA.powerupType == PowerupTypeAllOfOneColor ? orbA : orbB;
    BattleOrb *otherOrb = orbA.powerupType == PowerupTypeAllOfOneColor ? orbB : orbA;
    
    orb.orbColor = otherOrb.orbColor;
    
    BattleChain *chain = [self chainFromRainbowPowerupOrb:orb.copy];
    [chains addObject:chain];
  }
  
  if (addSwapChain) {
    // Make sure to manually create a chain with the two powerups to start off the powerup chain.
    BattleChain *chain = [[BattleChain alloc] init];
    chain.chainType = ChainTypeMatch;
    [chain addOrb:swap.orbA];
    [chain addOrb:swap.orbB];
    [chains addObject:chain];
    
    // Remove the powerups from the orbs so they don't try to spawn additional powerups
    swap.orbA.powerupType = PowerupTypeNone;
    swap.orbB.powerupType = PowerupTypeNone;
    
    // Delete any chains that have no orbs
    for (BattleChain *chain in chains.copy) {
      if (!chain.orbs.count) {
        [chains removeObject:chain];
      }
    }
    
    // Only remove orbs in this case because otherwise the rockets won't chain in rainbow-line
    [self removeOrbs:chains];
  }
  
  return chains;
}

- (NSSet *) createDoubleLinePowerupWithSwap:(BattleSwap *)swap {
  NSMutableSet *set = [NSMutableSet set];
  
  // Fake new battle orbs
  
  BattleOrb *orbH = swap.orbA.copy;
  orbH.powerupType = PowerupTypeHorizontalLine;
  BattleChain *chainH = [self chainFromHorizontalLinePowerupOrb:orbH];
  [set addObject:chainH];
  
  BattleOrb *orbV = swap.orbA.copy;
  orbV.powerupType = PowerupTypeVerticalLine;
  BattleChain *chainV = [self chainFromVerticalLinePowerupOrb:orbV];
  [set addObject:chainV];
  
  return set;
}

- (NSSet *) createLineExplosionPowerupWithSwap:(BattleSwap *)swap {
  NSMutableSet *set = [NSMutableSet set];
  
  BattleOrb *lineOrb = swap.orbA.powerupType == PowerupTypeExplosion ? swap.orbB : swap.orbA;
  BOOL isHorizontal = lineOrb.powerupType == PowerupTypeHorizontalLine;
  
  if (isHorizontal) {
    for (NSInteger i = swap.orbA.row-1; i <= swap.orbA.row+1; i++) {
      if (i >= 0 && i < _numRows) {
        BattleOrb *orb = swap.orbA.copy;
        orb.row = i;
        orb.powerupType = PowerupTypeHorizontalLine;
        BattleChain *chain = [self chainFromHorizontalLinePowerupOrb:orb];
        
        // The chain's prerequisite orb must be orbA or else it won't be spawned since the
        // powerupInitiator orb does not ever get destroyed.
        chain.prerequisiteOrb = swap.orbA;
        
        [set addObject:chain];
      }
    }
  } else {
    for (NSInteger i = swap.orbA.column-1; i <= swap.orbA.column+1; i++) {
      if (i >= 0 && i < _numColumns) {
        BattleOrb *orb = swap.orbA.copy;
        orb.column = i;
        orb.powerupType = PowerupTypeVerticalLine;
        BattleChain *chain = [self chainFromVerticalLinePowerupOrb:orb];
        chain.prerequisiteOrb = swap.orbA;
        [set addObject:chain];
      }
    }
  }
  
  return set;
}

- (NSSet *) createDoubleExplosionPowerupWithSwap:(BattleSwap *)swap {
  NSMutableSet *set = [NSMutableSet set];
  
  BattleOrb *orbL = swap.orbA.copy;
  orbL.column -= 1;
  BattleChain *chainL = [self chainFromExplosionPowerupOrb:orbL];
  chainL.prerequisiteOrb = swap.orbA;
  [set addObject:chainL];
  
  BattleOrb *orbR = swap.orbA.copy;
  orbR.column += 1;
  BattleChain *chainR = [self chainFromExplosionPowerupOrb:orbR];
  chainR.prerequisiteOrb = swap.orbA;
  [set addObject:chainR];
  
  BattleOrb *orbU = swap.orbA.copy;
  orbU.row += 1;
  BattleChain *chainU = [self chainFromExplosionPowerupOrb:orbU];
  chainU.prerequisiteOrb = swap.orbA;
  [set addObject:chainU];
  
  BattleOrb *orbD = swap.orbA.copy;
  orbD.row -= 1;
  BattleChain *chainD = [self chainFromExplosionPowerupOrb:orbD];
  chainD.prerequisiteOrb = swap.orbA;
  [set addObject:chainD];
  
  return set;
}

- (NSSet *) createRainbowLinePowerupWithSwap:(BattleSwap *)swap {
  BattleOrb *lineOrb = swap.orbA.powerupType == PowerupTypeAllOfOneColor ? swap.orbB : swap.orbA;
  BattleOrb *rainbowOrb = swap.orbA.powerupType == PowerupTypeAllOfOneColor ? swap.orbA : swap.orbB;
  
  NSMutableSet *set = [NSMutableSet set];
  
  BattleChain *chain = [[BattleChain alloc] init];
  chain.chainType = ChainTypeRainbowLine;
  
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      BattleOrb *orb = [self orbAtColumn:i row:j];
      if (orb.orbColor == lineOrb.orbColor) {
        orb.powerupType = arc4random_uniform(2) ? PowerupTypeHorizontalLine : PowerupTypeVerticalLine;
        [chain addOrb:orb];
      }
    }
  }
  
  chain.prerequisiteOrb = rainbowOrb;
  chain.powerupInitiatorOrb = rainbowOrb;
  
  [set addObject:chain];
  
  // Create a chain with just the rainbow so that it can spur this other chain
  rainbowOrb.orbColor = lineOrb.orbColor;
  rainbowOrb.powerupType = PowerupTypeNone;
  
  chain = [[BattleChain alloc] init];
  chain.chainType = ChainTypeMatch;
  [chain addOrb:rainbowOrb];
  [set addObject:chain];
  
  return set;
}

- (NSSet *) createRainbowExplosionPowerupWithSwap:(BattleSwap *)swap {
  BattleOrb *explOrb = swap.orbA.powerupType == PowerupTypeExplosion ? swap.orbA : swap.orbB;
  BattleOrb *rainbowOrb = swap.orbA.powerupType == PowerupTypeAllOfOneColor ? swap.orbA : swap.orbB;
  
  NSMutableSet *set = [NSMutableSet set];
  
  BattleChain *chain = [[BattleChain alloc] init];
  chain.chainType = ChainTypeRainbowExplosion;
  
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      BattleOrb *orb = [self orbAtColumn:i row:j];
      if (orb.orbColor == explOrb.orbColor) {
        orb.powerupType = PowerupTypeExplosion;
        [chain addOrb:orb];
      }
    }
  }
  
  chain.prerequisiteOrb = rainbowOrb;
  chain.powerupInitiatorOrb = rainbowOrb;
  
  [set addObject:chain];
  
  // Create a chain with just the rainbow so that it can spur this other chain
  rainbowOrb.orbColor = explOrb.orbColor;
  rainbowOrb.powerupType = PowerupTypeNone;
  
  chain = [[BattleChain alloc] init];
  chain.chainType = ChainTypeMatch;
  [chain addOrb:rainbowOrb];
  [set addObject:chain];
  
  return set;
}

- (NSSet *) createDoubleRainbowPowerupWithSwap:(BattleSwap *)swap {
  NSMutableSet *set = [NSMutableSet set];
  
  BattleChain *chain = [[BattleChain alloc] init];
  chain.chainType = ChainTypeDoubleRainbow;
  
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      BattleOrb *orb = [self orbAtColumn:i row:j];
      if ([self orbCanBeRemoved:orb]) {
        orb.powerupType = PowerupTypeNone;
        [chain addOrb:orb];
      }
    }
  }
  
  chain.prerequisiteOrb = swap.orbA;
  chain.powerupInitiatorOrb = swap.orbA;
  
  [set addObject:chain];
  
  return set;
}

#pragma mark - Detecting Powerup Creation

- (BattleOrb *) findIntersectingOrbForChainA:(BattleChain *)chainA chainB:(BattleChain *)chainB {
  for (BattleOrb *orb in chainA.orbs) {
    if ([chainB.orbs containsObject:orb]) {
      return orb;
    }
  }
  return nil;
}

- (BattleChain *) findIntersectingChain:(NSArray *)allChains baseChains:(NSArray *)baseChains {
  // Loop through both lists and find any orbs that are shared.
  for (BattleChain *checkChain in allChains) {
    
    // Make sure the chain isn't already in base chains.
    if (![baseChains containsObject:checkChain]) {
      
      for (BattleChain *alreadyUsedChain in baseChains) {
        
        if ([self findIntersectingOrbForChainA:checkChain chainB:alreadyUsedChain]) {
          return checkChain;
        }
      }
    }
  }
  return nil;
}

- (NSSet *) detectPowerupCreationFromChains:(NSSet *)chains withInitialSwap:(BattleSwap *)swap {
  NSMutableSet *newOrbs = [NSMutableSet set];
  NSMutableArray *chainsArr = [NSMutableArray arrayWithArray:chains.allObjects];
  
  // Sort by longest chains
  [chainsArr sortUsingComparator:^NSComparisonResult(BattleChain *obj1, BattleChain *obj2) {
    return [@(obj2.orbs.count) compare:@(obj1.orbs.count)];
  }];
  
  while (chainsArr.count > 0) {
    // This will be the longest chain in the group since the list is ordered.
    BattleChain *mainChain = chainsArr[0];
    
    // This is all the chains that are connected to main chain
    NSMutableArray *chainSequence = [NSMutableArray arrayWithObject:mainChain];
    BattleChain *nextChain;
    while ((nextChain = [self findIntersectingChain:chainsArr baseChains:chainSequence])) {
      [chainSequence addObject:nextChain];
    }
    
    // If this chain is the result of a powerup, it is impossible to create a new powerup orb
    if (!mainChain.powerupInitiatorOrb) {
      
      // We know the non-powerup chains are in a straight line, but we still must look for L or T shapes
      // Priority: rainbow, grenade, rocket
      NSUInteger chainLength = mainChain.orbs.count;
      
      if (chainLength >= 5) {
        
        // Get the middle orb, or randomize if it is 6 orbs for example
        NSUInteger idx = chainLength % 2 == 1 ? (chainLength-1)/2 : (chainLength-1)/2.f+arc4random_uniform(2)-0.5f;
        
        BattleOrb *replacedOrb = mainChain.orbs[idx];
        BattleOrb *newOrb = [self createOrbAtColumn:replacedOrb.column row:replacedOrb.row type:OrbColorNone powerup:PowerupTypeAllOfOneColor special:SpecialOrbTypeNone];
        [newOrbs addObject:newOrb];
        
      }
      
      // If the chain sequence has more than 1 chain and none are 5 length, create a grenade on a random intersection
      else if (chainSequence.count > 1) {
        
        // Keep picking two random chains and try to find intersection orb
        BattleOrb *replacedOrb;
        do {
          [chainSequence shuffle];
          replacedOrb = [self findIntersectingOrbForChainA:chainSequence[0] chainB:chainSequence[1]];
        } while (!replacedOrb);
        
        BattleOrb *newOrb = [self createOrbAtColumn:replacedOrb.column row:replacedOrb.row type:replacedOrb.orbColor powerup:PowerupTypeExplosion special:SpecialOrbTypeNone];
        [newOrbs addObject:newOrb];
      }
      
      // Now as long as length is 4, it will be rocket
      else if (chainLength >= 4) {
        // Check if any of the orbs are one of the swapped orbs
        BattleOrb *replacedOrb = nil;
        if ([mainChain.orbs containsObject:swap.orbA]) {
          replacedOrb = swap.orbA;
        } else if ([mainChain.orbs containsObject:swap.orbB]) {
          replacedOrb = swap.orbB;
        } else {
          // Get one of the middle orbs
          NSUInteger idx = chainLength % 2 == 1 ? (chainLength-1)/2 : (chainLength-1)/2.f+arc4random_uniform(2)-0.5f;
          replacedOrb = mainChain.orbs[idx];
        }
        
        BattleOrb *firstOrb = mainChain.orbs[0];
        BattleOrb *secondOrb = mainChain.orbs[1];
        BOOL isHorizontal = (firstOrb.row == secondOrb.row);
        
        // Horizontal chains will create vertical rocket powerup and vice versa
        PowerupType powerupType = isHorizontal ? PowerupTypeVerticalLine : PowerupTypeHorizontalLine;
        BattleOrb *newOrb = [self createOrbAtColumn:replacedOrb.column row:replacedOrb.row type:replacedOrb.orbColor powerup:powerupType special:SpecialOrbTypeNone];
        [newOrbs addObject:newOrb];
      }
    }
    
    // Remove all chains from this group
    [chainsArr removeObjectsInArray:chainSequence];
  }
  return newOrbs;
}

#pragma mark - Detecting Powerup Chains

- (void) changeOrb:(BattleOrb *)orb fromPowerupInitiatorOrb:(BattleOrb *)powerupOrb {
  
  // Give rainbow orbs the color of the chain creator
  if (orb.powerupType == PowerupTypeAllOfOneColor) {
    orb.orbColor = powerupOrb.orbColor;
  }
  
  if (orb.powerupType == PowerupTypeHorizontalLine || orb.powerupType == PowerupTypeVerticalLine) {
    if (powerupOrb.powerupType == PowerupTypeHorizontalLine) {
      orb.powerupType = PowerupTypeVerticalLine;
    } else if (powerupOrb.powerupType == PowerupTypeVerticalLine) {
      orb.powerupType = PowerupTypeHorizontalLine;
    }
  }
}

- (NSSet *) detectPowerupChainsWithMatchChains:(NSSet *)chains {
  NSMutableSet *powerupChains = [NSMutableSet set];
  
  // Use this to detect which powerups have already been fired.
  // Without this, we could enter a recursive loop where two powerups
  // keep firing each other off.
  NSMutableSet *usedPowerupOrbs = [NSMutableSet set];
  
  // Create initial set of powerup orbs
  NSMutableArray *powerupOrbs = [NSMutableArray array];
  for (BattleChain *chain in chains) {
    for (BattleOrb *orb in chain.orbs) {
      if (orb.powerupType) {
        if (chain.powerupInitiatorOrb) {
          [self changeOrb:orb fromPowerupInitiatorOrb:chain.powerupInitiatorOrb];
        }
        
        [powerupOrbs addObject:orb];
        [usedPowerupOrbs addObject:orb];
      }
    }
  }
  
  // Loop through the powerups and fire them off
  while (powerupOrbs.count > 0) {
    BattleOrb *powerupOrb = powerupOrbs[0];
    BattleChain *powerupChain = nil;
    
    if (powerupOrb.powerupType == PowerupTypeHorizontalLine) {
      powerupChain = [self chainFromHorizontalLinePowerupOrb:powerupOrb];
    } else if (powerupOrb.powerupType == PowerupTypeVerticalLine) {
      powerupChain = [self chainFromVerticalLinePowerupOrb:powerupOrb];
    } else if (powerupOrb.powerupType == PowerupTypeExplosion) {
      powerupChain = [self chainFromExplosionPowerupOrb:powerupOrb];
    } else if (powerupOrb.powerupType == PowerupTypeAllOfOneColor) {
      powerupChain = [self chainFromRainbowPowerupOrb:powerupOrb];
    }
    
    [powerupChains addObject:powerupChain];
    
    // Add any new powerups that were destroyed as long as they haven't been used before
    for (BattleOrb *orb in powerupChain.orbs) {
      if (orb.powerupType && ![usedPowerupOrbs containsObject:orb]) {
        [self changeOrb:orb fromPowerupInitiatorOrb:powerupChain.powerupInitiatorOrb];
        
        [powerupOrbs addObject:orb];
        [usedPowerupOrbs addObject:orb];
      }
    }
    
    [powerupOrbs removeObject:powerupOrb];
  }
  
  [self removeOrbs:powerupChains];
  
  return powerupChains;
}

- (BattleChain *) chainFromHorizontalLinePowerupOrb:(BattleOrb *)orb {
  BattleChain *chain = [[BattleChain alloc] init];
  chain.powerupInitiatorOrb = orb;
  chain.prerequisiteOrb = orb;
  chain.chainType = ChainTypePowerupNormal;
  for (int i = 0; i < _numColumns; i++) {
    BattleOrb *testOrb = [self orbAtColumn:i row:orb.row];
    if ([self orbCanBeRemoved:testOrb]) {
      [chain addOrb:testOrb];
    }
  }
  return chain;
}

- (BattleChain *) chainFromVerticalLinePowerupOrb:(BattleOrb *)orb {
  BattleChain *chain = [[BattleChain alloc] init];
  chain.powerupInitiatorOrb = orb;
  chain.prerequisiteOrb = orb;
  chain.chainType = ChainTypePowerupNormal;
  for (int i = 0; i < _numRows; i++) {
    BattleOrb *testOrb = [self orbAtColumn:orb.column row:i];
    if ([self orbCanBeRemoved:testOrb]) {
      [chain addOrb:testOrb];
    }
  }
  return chain;
}

- (BattleChain *) chainFromExplosionPowerupOrb:(BattleOrb *)orb {
  BattleChain *chain = [[BattleChain alloc] init];
  chain.powerupInitiatorOrb = orb;
  chain.prerequisiteOrb = orb;
  chain.chainType = ChainTypePowerupNormal;
  
  for (NSInteger i = orb.column-1; i <= orb.column+1; i++) {
    for (NSInteger j = orb.row-1; j <= orb.row+1; j++) {
      if (i >= 0 && i < _numColumns && j >= 0 && j < _numRows) {
        BattleOrb *testOrb = [self orbAtColumn:i row:j];
        if ([self orbCanBeRemoved:testOrb]) {
          [chain addOrb:testOrb];
        }
      }
    }
  }
  return chain;
}

- (BattleChain *) chainFromRainbowPowerupOrb:(BattleOrb *)orb {
  BattleChain *chain = [[BattleChain alloc] init];
  chain.powerupInitiatorOrb = orb;
  chain.prerequisiteOrb = orb;
  chain.chainType = ChainTypePowerupNormal;
  
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      BattleOrb *testOrb = [self orbAtColumn:i row:j];
      if (testOrb.orbColor == orb.orbColor) {
        if ([self orbCanBeRemoved:testOrb]) {
          [chain addOrb:testOrb];
        }
      }
    }
  }
  
  return chain;
}

#pragma mark - Detecting Holes

- (NSArray *)fillHoles {
  NSMutableArray *columns = [NSMutableArray array];
  
  // Loop through the rows, from bottom to top. It's handy that our row 0 is
  // at the bottom already. Because we're scanning from bottom to top, this
  // automatically causes an entire stack to fall down to fill up a hole.
  // We scan one column at a time.
  for (NSInteger column = 0; column < _numColumns; column++) {
    
    NSMutableArray *array = [NSMutableArray array];
    [columns addObject:array];
    
    for (NSInteger row = 0; row < _numRows; row++) {
      
      // If there is a tile at this position but no orb, then there's a hole.
      if ([self tileAtColumn:column row:row] != nil && [self orbAtColumn:column row:row] == nil) {
        
        // Scan upward to find a orb.
        for (NSInteger lookup = row + 1; lookup < _numRows; lookup++) {
          BattleOrb *orb = [self orbAtColumn:column row:lookup];
          if (orb != nil) {
            // Swap that orb with the hole.
            [self setOrb:nil column:column row:lookup];
            [self setOrb:orb column:column row:row];
            orb.row = row;
            
            // For each column, we return an array with the orbs that have
            // fallen down. Orbs that are lower on the screen are first in
            // the array. We need an array to keep this order intact, so the
            // animation code can apply the correct kind of delay.
            [array addObject:orb];
            
            // Don't need to scan up any further.
            break;
          }
        }
      }
    }
  }
  return columns;
}

- (NSArray *)topUpOrbs {
  NSMutableArray *columns = [NSMutableArray array];
  
  // Detect where we have to add the new orbs. If a column has X holes,
  // then it also needs X new orbs. The holes are all on the top of the
  // column now, but the fact that there may be gaps in the tiles makes this
  // a little trickier.
  for (NSInteger column = 0; column < _numColumns; column++) {
    
    // This time scan from top to bottom. We can end when we've found the
    // first orb.
    NSMutableArray *array = [NSMutableArray array];
    [columns addObject:array];
    
    for (NSInteger row = 0; row < _numRows; row++) {
      
      // Found a hole?
      if ([self tileAtColumn:column row:row] != nil && [self orbAtColumn:column row:row] == nil) {
        
        // Create a new orb.
        BattleOrb *orb = [self createOrbAtColumn:column row:row type:OrbColorRock powerup:PowerupTypeNone special:SpecialOrbTypeNone];
        
        // Randomly create a new orb type. The only restriction is that
        // it cannot be equal to the previous type. This prevents too many
        // "freebie" matches.
        
        // Commented out while loop because it screws up tutorial..
        //do {
        [self generateRandomOrbData:orb atColumn:column row:row];
        //} while (newOrbColor == orbColor && special == newSpecial);
        
        // Add them in reverse order so they go bottom up
        [array addObject:orb];
      }
    }
  }
  return columns;
}

- (NSSet *)detectBottomFeeders {
  NSMutableSet *set = [NSMutableSet set];
  
  for (int i = 0; i < _numColumns; i++) {
    BattleOrb *orb = [self orbAtColumn:i row:0];
    if ([self orbIsBottomFeeder:orb]) {
      [set addObject:orb];
      [self setOrb:nil column:i row:0];
    }
  }
  
  return set;
}

#pragma mark - Querying the Level

- (BattleTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
  CustomAssert(column >= 0 && column < _numColumns, @"Invalid column: %ld", (long)column);
  CustomAssert(row >= 0 && row < _numRows, @"Invalid row: %ld", (long)row);
  
  return _tiles[column][row];
}

- (BattleOrb *)orbAtColumn:(NSInteger)column row:(NSInteger)row {
  CustomAssert(column >= 0 && column < _numColumns, @"Invalid column: %ld", (long)column);
  CustomAssert(row >= 0 && row < _numRows, @"Invalid row: %ld", (long)row);
  
  return _orbs[column][row];
}

- (void) setTile:(BattleTile *)tile column:(NSInteger)column row:(NSInteger)row {
  CustomAssert(column >= 0 && column < _numColumns, @"Invalid column: %ld", (long)column);
  CustomAssert(row >= 0 && row < _numRows, @"Invalid row: %ld", (long)row);
  
  _tiles[column][row] = tile;
}

- (void) setOrb:(BattleOrb *)orb column:(NSInteger)column row:(NSInteger)row {
  CustomAssert(column >= 0 && column < _numColumns, @"Invalid column: %ld", (long)column);
  CustomAssert(row >= 0 && row < _numRows, @"Invalid row: %ld", (long)row);
  
  //LNLog(@"Changing (%d, %d) orb from %@ to %@.", column, row, _orbs[column][row], orb);
  
  _orbs[column][row] = orb;
}

- (BOOL)isPossibleSwap:(BattleSwap *)swap {
  return [self.possibleSwaps containsObject:swap];
}

#pragma mark - Description

- (NSString *) description {
  NSMutableString *str = [NSMutableString stringWithFormat:@"\n"];
  
  for (int i = _numRows-1; i >= 0; i--) {
    [str appendFormat:@"%d |", i];
    for (int j = 0; j < _numColumns; j++) {
      BattleOrb *orb = [self orbAtColumn:j row:i];
      
      if (orb) {
        [str appendFormat:@" %d", orb.orbColor];
      } else {
        [str appendFormat:@"  "];
      }
    }
    
    [str appendFormat:@"\t\t\t\t\t\t"];
    
    // Print addresses far to the right
    for (int j = 0; j < _numColumns; j++) {
      BattleOrb *orb = [self orbAtColumn:j row:i];
      
      if (orb) {
        [str appendFormat:@" %p", orb];
      } else {
        [str appendFormat:@" ----------"];
      }
    }
    
    [str appendFormat:@"\n"];
  }
  
  [str appendFormat:@"  |"];
  
  for (int i = 0; i < _numColumns; i++) {
    [str appendFormat:@"--"];
  }
  
  [str appendFormat:@"\n   "];
  for (int i = 0; i < _numColumns; i++) {
    [str appendFormat:@" %d", i];
  }
  
  return str;
}

@end
