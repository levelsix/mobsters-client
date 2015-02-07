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
#import "BattleOrbPath.h"

#import "BoardLayoutProto+Properties.h"

// Make this 1 to allow user to swap wherever they want
#ifdef DEBUG_BATTLE_MODE
#define FREE_BATTLE_MOVEMENT 1
#endif

@interface BattleOrbLayout ()

// The list of swipes that result in a valid swap. Used to determine whether
// the player can make a certain swap, whether the board needs to be shuffled,
// and to generate hints.
@property (strong, nonatomic) NSSet *possibleSwaps;

@end

@implementation BattleOrbLayout

- (instancetype) initWithGridSize:(CGSize)gridSize numColors:(int)numColors {
  BoardLayoutProto_Builder *bldr = [BoardLayoutProto builder];
  bldr.width = gridSize.width;
  bldr.height = gridSize.height;
  bldr.orbElements = 111111;
  
//    BoardPropertyProto_Builder *prop;
  //
  //  prop = [BoardPropertyProto builder];
  //  prop.posX = 4;
  //  prop.posY = 4
  //  prop.name = @"PASSABLE_HOLE";
  //  [bldr addProperties:prop.build];
  //
  //  prop = [BoardPropertyProto builder];
  //  prop.posX = 4;
  //  prop.posY = 7;
  //  prop.name = @"NOT_SPAWN_TILE";
  //  [bldr addProperties:prop.build];
  //
  //  for (int i = 0; i < gridSize.width; i++) {
  //    prop = [BoardPropertyProto builder];
  //    prop.posX = i;
  //    prop.posY = 2;
  //    prop.name = @"ORB_SPECIAL";
  //    prop.value = SpecialOrbTypeCloud;
  //    prop.quantity = 2;
  //    [bldr addProperties:prop.build];
  //
  //    prop = [BoardPropertyProto builder];
  //    prop.posX = i;
  //    prop.posY = 2;
  //    prop.name = @"ORB_POWERUP";
  //    prop.value = PowerupTypeVerticalLine;
  //    [bldr addProperties:prop.build];
  //  }
  //
  //  for (int i = 0; i < gridSize.width; i++) {
  //    prop = [BoardPropertyProto builder];
  //    prop.posX = i;
  //    prop.posY = 1;
  //    prop.name = @"ORB_EMPTY";
  //    prop.value = 5;
  //    [bldr addProperties:prop.build];
  //
  //    prop = [BoardPropertyProto builder];
  //    prop.posX = i;
  //    prop.posY = 0;
  //    prop.name = @"ORB_EMPTY";
  //    prop.value = 5;
  //    [bldr addProperties:prop.build];
  //  }
  //
//    prop = [BoardPropertyProto builder];
//    prop.posX = 4;
//    prop.posY = 0;
//    prop.name = INITIAL_SKILL;
//    prop.value = 1;
//    [bldr addProperties:prop.build];
  
  return [self initWithBoardLayout:bldr.build];
}

- (instancetype) initWithBoardLayout:(BoardLayoutProto *)proto {
  if ((self = [super init])) {
    _numColumns = proto.width;
    _numRows = proto.height;
    
    // orbElements will be an int with the mask. i.e. 111000 means only fire, earth, water orbs
    NSString *str = [NSString stringWithFormat:@"%d", proto.orbElements];
    for (int i = OrbColorFire; i <= OrbColorNone && str.length > 0; i++) {
      NSString *cur = [str substringToIndex:1];
      int val = [cur intValue];
      
      _numColors |= val << i;
      
      str = [str substringFromIndex:1];
    }
    
    _layoutProto = proto;
    
    _tiles = (__strong id **)calloc(sizeof(id *), _numColumns);
    _orbs = (__strong id **)calloc(sizeof(id *), _numColumns);
    for (int i = 0; i < _numColumns; i++) {
      _tiles[i] = (__strong id *)calloc(sizeof(id *), _numRows);
      _orbs[i] = (__strong id *)calloc(sizeof(id *), _numRows);
      
      for (int j = 0; j < _numRows; j++) {
        [self createTileAtColumn:i row:j boardLayout:proto];
      }
    }
  }
  
  return self;
}

- (void) createTileAtColumn:(int)column row:(int)row boardLayout:(BoardLayoutProto *)proto {
  NSArray *properties = [proto propertiesForColumn:column row:row];
  
  BOOL isHole = NO;
  BOOL canPassThrough = YES;
  BOOL canSpawnOrbs = row == _numRows-1;
  TileType typeTop = TileTypeNormal;
  TileType typeBottom = TileTypeNormal;
  BOOL shouldSpawnInitialSkill = NO;
  
  for (BoardPropertyProto *prop in properties) {
    if ([prop.name isEqualToString:SPAWN_TILE]) {
      canSpawnOrbs = YES;
    } else if ([prop.name isEqualToString:NOT_SPAWN_TILE]) {
      canSpawnOrbs = NO;
    } else if ([prop.name isEqualToString:HOLE]) {
      isHole = YES;
      canPassThrough = NO;
    } else if ([prop.name isEqualToString:PASSABLE_HOLE]) {
      isHole = YES;
      canPassThrough = YES;
    } else if ([prop.name isEqualToString:TILE_TYPE]) {
      typeBottom = prop.value;
    } else if ([prop.name isEqualToString:INITIAL_SKILL]) {
      shouldSpawnInitialSkill = YES;
    }
  }
  
  _tiles[column][row] = [[BattleTile alloc] initWithColumn:column row:row typeTop:typeTop typeBottom:typeBottom isHole:isHole canPassThrough:canPassThrough canSpawnOrbs:canSpawnOrbs shouldSpawnInitialSkill:shouldSpawnInitialSkill];
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
  for (int i = 0; i < _numColumns; i++) {
    for (int j = 0; j < _numRows; j++) {
      [self setOrb:nil column:i row:j];
    }
  }
  
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
        
        if (orb) {
          if (orb.specialOrbType != SpecialOrbTypeNone ||
              orb.powerupType != PowerupTypeNone ||
              ![orb isMovable])
            continue;
          
          [array addObject:orb];
        }
      }
    }
    
    [array shuffle];
    
    foundMatch = NO;
    
    NSInteger counter = 0;
    for (int i = 0; i < _numColumns; i++) {
      for (int j = 0; j < _numRows; j++) {
        
        // Check if this a special orb
        BattleOrb* orb = [self orbAtColumn:i row:j];
        
        if (orb) {
          if (orb.specialOrbType != SpecialOrbTypeNone ||
              orb.powerupType != PowerupTypeNone ||
              ![orb isMovable])
            continue;
          
          orb = array[counter];
          [self setOrb:orb column:i row:j];
          orb.column = i;
          orb.row = j;
          
          counter++;
          
          [set addObject:orb];
        }
        
        if ([self hasChainAtColumn:i row:j] || (j == 0 && [self orbIsBottomFeeder:orb])) {
          foundMatch = YES;
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

- (OrbColor) generateRandomOrbColor {
  // Get a random color based on the available colors
  int rand;
  
  // Get a rand that is valid
  while (!(1 << (rand = arc4random_uniform(OrbColorNone)) & _numColors));
  
  return rand;
}

- (void) generateRandomOrbData:(BattleOrb*)orb atColumn:(int)column row:(int)row {
  // Get a random color based on the available colors
  orb.orbColor = [self generateRandomOrbColor];
  orb.specialOrbType = SpecialOrbTypeNone;
  
  // Allow skill manager to override this info
  [skillManager generateSpecialOrb:orb atColumn:column row:row];
}

- (NSSet *) createInitialOrbs {
  
  NSMutableSet *set = [NSMutableSet set];
  
  // Loop through the rows and columns of the 2D array. Note that column 0,
  // row 0 is in the bottom-left corner of the array.
  
  BOOL redo;
  
  do {
    redo = NO;
    
    [set removeAllObjects];
    
    // This will only add to the set if there are properties defined for inital colors/powerups
    for (int row = 0; row < _numRows; row++) {
      for (int column = 0; column < _numColumns; column++) {
        BattleOrb *orb = [self createInitialOrbAtColumn:column row:row layout:_layoutProto];
        
        if (orb) {
          [set addObject:orb];
        }
      }
    }
    
    
    for (int row = 0; row < _numRows; row++) {
      for (int column = 0; column < _numColumns; column++) {
        
        // Only make a new orb if there is a tile at this spot.
        BattleTile *tile = [self tileAtColumn:column row:row];
        if (!tile.isHole) {
          
          // Pick the orb type at random, and make sure that this never
          // creates a chain of 3 or more. We want there to be 0 matches in
          // the initial state.
          BattleOrb *orb = [self orbAtColumn:column row:row];
          
          if (!orb) {
            do {
              // Create a new orb and add it to the 2D array.
              orb = [self createOrbAtColumn:column row:row type:OrbColorRock powerup:PowerupTypeNone special:SpecialOrbTypeNone];
              
              [self generateRandomOrbData:orb atColumn:column row:row];
            }
            // Can't afford to have a chain in initial set
            while ([self hasChainAtColumn:column row:row]);
            
            // Also add the orb to the set so we can tell our caller about it.
            [set addObject:orb];
            
          } else {
            // Empty tile
            if (orb.orbColor == OrbColorNone && orb.powerupType == PowerupTypeNone && orb.specialOrbType == SpecialOrbTypeNone) {
              [self setOrb:nil column:column row:row];
              
              [set removeObject:orb];
            }
            
            // Make sure there are no chains
            if ([self hasChainAtColumn:column row:row]) {
              redo = YES;
            }
          }
        }
      }
    }
  }
  while (redo || ![self detectPossibleSwaps].count);
  
  return set;
}

// Will return YES if something should be randomly generated
- (BattleOrb *) createInitialOrbAtColumn:(int)column row:(int)row layout:(BoardLayoutProto *)proto {
  
  NSArray *properties = [proto propertiesForColumn:column row:row];
  
  BattleOrb *orb = [self createOrbAtColumn:column row:row type:OrbColorRock powerup:PowerupTypeNone special:SpecialOrbTypeNone];
  
  OrbColor color = 0;
  PowerupType powerup = 0;
  SpecialOrbType special = 0;
  
  BOOL shouldCreate = NO;
  for (BoardPropertyProto *prop in properties) {
    if ([prop.name isEqualToString:ORB_COLOR]) {
      color = prop.value;
      shouldCreate = YES;
    } else if ([prop.name isEqualToString:ORB_POWERUP]) {
      powerup = prop.value;
      
      if (powerup == PowerupTypeAllOfOneColor) {
        color = OrbColorNone;
      }
      
      shouldCreate = YES;
    } else if ([prop.name isEqualToString:ORB_SPECIAL]) {
      special = prop.value;
      shouldCreate = YES;
      
      if (special == SpecialOrbTypeCloud) {
        orb.cloudCounter = MAX(1, prop.quantity);
      }
    } else if ([prop.name isEqualToString:ORB_EMPTY]) {
      color = OrbColorNone;
      powerup = PowerupTypeNone;
      special = SpecialOrbTypeNone;
      shouldCreate = YES;
    } else if ([prop.name isEqualToString:ORB_LOCKED]) {
      orb.isLocked = YES;
      shouldCreate = YES;
    }
  }
  
  if (!shouldCreate) {
    [self setOrb:nil column:column row:row];
    orb = nil;
  } else {
    [self generateRandomOrbData:orb atColumn:column row:row];
    
    if (color) {
      orb.orbColor = color;
    }
    if (powerup) {
      orb.powerupType = powerup;
    }
    if (special) {
      orb.specialOrbType = special;
    }
  }
  
  return orb;
}

- (BattleOrb *)createOrbAtColumn:(NSInteger)column row:(NSInteger)row type:(OrbColor)orbColor powerup:(PowerupType)powerup special:(SpecialOrbType)special {
  BattleOrb *orb = [[BattleOrb alloc] init];
  orb.orbColor = orbColor;
  orb.column = column;
  orb.row = row;
  orb.powerupType = powerup;
  orb.specialOrbType = special;
  orb.damageMultiplier = 1;
  [self setOrb:orb column:column row:row];
  return orb;
}

#pragma mark - Detecting Swaps

- (NSSet *) detectPossibleSwaps {
  
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger row = 0; row < _numRows; row++) {
    for (NSInteger column = 0; column < _numColumns; column++) {
      
      BattleOrb *orb = [self orbAtColumn:column row:row];
      if ([orb isMovable]) {
        
        // Is it possible to swap this orb with the one on the right?
        // Note: don't need to check the last column.
        if (column < _numColumns - 1) {
          
          // Have a orb in this spot? If there is no tile, there is no orb.
          BattleOrb *other = [self orbAtColumn:column+1 row:row];
          if ([other isMovable]) {
            // Two powerups automatically count as a match
            if ([self isPowerupMatch:orb otherOrb:other]) {
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
          if ([other isMovable]) {
            if ([self isPowerupMatch:orb otherOrb:other]) {
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
  OrbColor orbColor = [self orbAtColumn:column row:row].orbColor;
  return [self willHaveChainAtColumn:column row:row color:orbColor];
}

- (BOOL)willHaveChainAtColumn:(NSInteger)column row:(NSInteger)row color:(OrbColor)color {
  NSUInteger orbColor = color;
  
  if (orbColor && orbColor != OrbColorNone) {
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

- (void) resetOrbChangeTypes {
  for (NSInteger row = 0; row < _numRows; row++) {
    for (NSInteger col = 0; col < _numColumns; col++) {
      BattleOrb *orb = [self orbAtColumn:col row:row];
      orb.changeType = OrbChangeTypeNone;
    }
  }
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
  [self removeOrbs:chains forceDestroy:NO];
}

- (void)removeOrbs:(NSSet *)chains forceDestroy:(BOOL)forceDestroy {
  for (BattleChain *chain in chains) {
    for (BattleOrb *orb in chain.orbs) {
      if (forceDestroy) {
        // Used for rainbow-line/grenade so that lock gets removed and orb gets destroyed
        [self setOrb:nil column:orb.column row:orb.row];
        orb.changeType = OrbChangeTypeDestroyed;
      } else {
        // Orbs can only undergo one change per turn
        if (!orb.changeType) {
          if (orb.isLocked) {
            orb.isLocked = NO;
            orb.changeType = OrbChangeTypeLockRemoved;
          } else if (orb.specialOrbType == SpecialOrbTypeCloud && orb.cloudCounter > 1) {
            orb.cloudCounter--;
            orb.changeType = OrbChangeTypeCloudDecremented;
          } else {
            [self setOrb:nil column:orb.column row:orb.row];
            orb.changeType = OrbChangeTypeDestroyed;
          }
        }
      }
    }
  }
}

- (BOOL) orbCanBeRemoved:(BattleOrb *)orb {
  return (orb.specialOrbType != SpecialOrbTypeCake &&
          orb.specialOrbType != SpecialOrbTypeGrave &&
          orb.specialOrbType != SpecialOrbTypeBullet &&
          orb.specialOrbType != SpecialOrbTypeSword);
}

- (BOOL) orbIsBottomFeeder:(BattleOrb *)orb {
  return (orb.specialOrbType == SpecialOrbTypeCake ||
          orb.specialOrbType == SpecialOrbTypeGrave ||
          orb.specialOrbType == SpecialOrbTypeBullet ||
          orb.specialOrbType == SpecialOrbTypeSword);
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
  
  [self removeOrbs:set forceDestroy:YES];
  
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
  
  [self removeOrbs:set forceDestroy:YES];
  
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
      
      // Make a list of orbs that can be substituted for the powerup since we can't spawn on orbs that still exist
      NSMutableArray *replacableOrbs = [NSMutableArray array];
      for (BattleOrb *orb in mainChain.orbs) {
        if (![self orbAtColumn:orb.column row:orb.row]) {
          [replacableOrbs addObject:orb];
        }
      }
      
      // We know the non-powerup chains are in a straight line, but we still must look for L or T shapes
      // Priority: rainbow, grenade, rocket
      NSUInteger chainLength = mainChain.orbs.count;
      NSUInteger replacableOrbsLength = replacableOrbs.count;
      
      if (chainLength >= 5) {
        
        BattleOrb *replacedOrb = nil;
        if ([mainChain.orbs containsObject:swap.orbA]) {
          replacedOrb = swap.orbA;
        } else if ([mainChain.orbs containsObject:swap.orbB]) {
          replacedOrb = swap.orbB;
        } else {
          // Get the middle orb, or randomize if it is 6 orbs for example
          NSUInteger idx = replacableOrbsLength % 2 == 1 ? (replacableOrbsLength-1)/2 : (replacableOrbsLength-1)/2.f+arc4random_uniform(2)-0.5f;
          replacedOrb = replacableOrbs[idx];
        }
        
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
        
        // Check that the replaced orb has been removed, otherwise use any orb
        if ([self orbAtColumn:replacedOrb.column row:replacedOrb.row]) {
          replacedOrb = [replacableOrbs firstObject];
        }
        
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
          NSUInteger idx = replacableOrbsLength % 2 == 1 ? (replacableOrbsLength-1)/2 : (replacableOrbsLength-1)/2.f+arc4random_uniform(2)-0.5f;
          replacedOrb = replacableOrbs[idx];
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
  
  // Set the new orbs' change type to powerup creation so they don't explode this cycle
  for (BattleOrb *newOrb in newOrbs) {
    newOrb.changeType = OrbChangeTypePowerupCreated;
  }
  
  return newOrbs;
}

#pragma mark - Detecting Powerup Chains

- (void) changeOrb:(BattleOrb *)orb fromPowerupInitiatorOrb:(BattleOrb *)powerupOrb {
  
  // Give rainbow orbs the color of the chain creator
  if (orb.powerupType == PowerupTypeAllOfOneColor) {
    // Choose a color of an orb that
    int rand;
    BOOL foundColor = NO;
    int numTries = 0;
    while (!foundColor && numTries < 100) {
      while (!(1 << (rand = arc4random_uniform(OrbColorNone)) & _numColors));
      
      // Go through list of orbs and make sure there is at least one
      for (int i = 0; i < _numColumns; i++) {
        for (int j = 0; j < _numRows; j++) {
          BattleOrb *orb = [self orbAtColumn:i row:j];
          if (orb.orbColor == rand) {
            foundColor = YES;
          }
        }
      }
      
      numTries++;
    }
    
    orb.orbColor = rand;
  }
  
  if (orb.powerupType == PowerupTypeHorizontalLine || orb.powerupType == PowerupTypeVerticalLine) {
    if (powerupOrb.powerupType == PowerupTypeHorizontalLine) {
      orb.powerupType = PowerupTypeVerticalLine;
    } else if (powerupOrb.powerupType == PowerupTypeVerticalLine) {
      orb.powerupType = PowerupTypeHorizontalLine;
    }
  }
}

- (NSSet *) detectAdjacentChainsWithMatchAndPowerupChains:(NSSet *)chains {
  NSMutableSet *adjacentChains = [NSMutableSet set];
  
  for (BattleChain *chain in chains) {
    for (BattleOrb *orb in chain.orbs) {
      if (orb.changeType == OrbChangeTypeDestroyed) {
        // Check orbs around for clouds
        BattleOrb *left = orb.column > 0 ? [self orbAtColumn:orb.column-1 row:orb.row] : nil;
        BattleOrb *top = orb.row < _numRows-1 ? [self orbAtColumn:orb.column row:orb.row+1] : nil;
        BattleOrb *right = orb.column < _numColumns-1 ? [self orbAtColumn:orb.column+1 row:orb.row] : nil;
        BattleOrb *below = orb.row > 0 ? [self orbAtColumn:orb.column row:orb.row-1] : nil;
        
        BattleChain *chain = [[BattleChain alloc] init];
        chain.chainType = ChainTypeAdjacent;
        chain.prerequisiteOrb = orb;
        
        if (left.specialOrbType == SpecialOrbTypeCloud) {
          [chain addOrb:left];
        } if (right.specialOrbType == SpecialOrbTypeCloud) {
          [chain addOrb:right];
        } if (top.specialOrbType == SpecialOrbTypeCloud) {
          [chain addOrb:top];
        } if (below.specialOrbType == SpecialOrbTypeCloud) {
          [chain addOrb:below];
        }
        
        if (chain.orbs.count > 0) {
          [adjacentChains addObject:chain];
        }
      }
    }
  }
  
  [self removeOrbs:adjacentChains];
  
  return adjacentChains;
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
      if (orb.changeType == OrbChangeTypeDestroyed && orb.powerupType) {
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
    
    [self removeOrbs:[NSSet setWithObject:powerupChain]];
    
    [powerupChains addObject:powerupChain];
    
    // Add any new powerups that were destroyed as long as they haven't been used before
    for (BattleOrb *orb in powerupChain.orbs) {
      if (orb.changeType == OrbChangeTypeDestroyed && orb.powerupType && ![usedPowerupOrbs containsObject:orb]) {
        [self changeOrb:orb fromPowerupInitiatorOrb:powerupChain.powerupInitiatorOrb];
        
        [powerupOrbs addObject:orb];
        [usedPowerupOrbs addObject:orb];
      }
    }
    
    [powerupOrbs removeObject:powerupOrb];
  }
  
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

- (BattleOrbPath *) orbPathForOrb:(BattleOrb *)orb withOrbPaths:(NSArray *)orbPaths {
  BattleOrbPath *path = nil;
  
  for (BattleOrbPath *op in orbPaths) {
    if (op.orb == orb) {
      path = op;
    }
  }
  
  return path;
}

- (void) addPoint:(CGPoint)pt forOrb:(BattleOrb *)orb withOrbPaths:(NSMutableArray *)orbPaths {
  BattleOrbPath *path = [self orbPathForOrb:orb withOrbPaths:orbPaths];
  
  if (!path) {
    path = [[BattleOrbPath alloc] init];
    path.orb = orb;
    path.path = [NSMutableArray array];
    [path.path addObject:[NSValue valueWithCGPoint:ccp(orb.column, orb.row)]];
    
    [orbPaths addObject:path];
  }
  
  [path.path addObject:[NSValue valueWithCGPoint:pt]];
  
  if (orb.row < _numRows) {
    [self setOrb:nil column:orb.column row:orb.row];
  }
  
  [self setOrb:orb column:pt.x row:pt.y];
  orb.column = pt.x;
  orb.row = pt.y;
  
  
  // Need to delay by path length up till orb right underneath.
  
  BattleOrbPath *curPath = [self orbPathForOrb:orb withOrbPaths:orbPaths];
  
  int maxDiff = 0;
  
  BattleOrbPath *longestPath = nil;
  for (BattleOrbPath *p in orbPaths) {
    if (p != curPath) {
      int newDiff = [p pathLengthToPoint:pt]-[curPath pathLength]+1;
      if (newDiff > maxDiff) {
        maxDiff = newDiff;
        longestPath = p;
      }
    }
  }
  
  if (maxDiff > 0) {
    [curPath.path insertObject:[NSNumber numberWithInt:maxDiff] atIndex:curPath.path.count-1];
  }
}

// Send in an array of orbPaths that will be modified
- (BOOL) fillHoles:(NSMutableArray *)orbPaths {
  BOOL madeChange = NO;
  
  // Loop through the rows, from bottom to top. It's handy that our row 0 is
  // at the bottom already. Because we're scanning from bottom to top, this
  // automatically causes an entire stack to fall down to fill up a hole.
  // We scan one column at a time.
  for (NSInteger column = 0; column < _numColumns; column++) {
    
    for (NSInteger row = 0; row < _numRows; row++) {
      
      // If there is a tile at this position but no orb, then there's a hole.
      if (![self tileAtColumn:column row:row].isHole && [self orbAtColumn:column row:row] == nil) {
        
        // Scan upward to find a orb.
        for (NSInteger lookup = row + 1; lookup < _numRows; lookup++) {
          BattleTile *tile = [self tileAtColumn:column row:lookup];
          BattleOrb *orb = [self orbAtColumn:column row:lookup];
          
          if ([tile isBlocked] || (orb && ![orb isMovable])) {
            // This tile is a blocker. Need to rely on diagonal falling orbs.
            break;
          }
          if (orb != nil) {
            [self addPoint:ccp(column, row) forOrb:orb withOrbPaths:orbPaths];
            
            madeChange = YES;
            
            // Don't need to scan up any further.
            break;
          }
        }
      }
    }
  }
  
  return madeChange;
}

// Send in an array of orbPaths that will be modified
- (BOOL) diagonallyFillHoles:(NSMutableArray *)orbPaths {
  
  BOOL madeChange = NO;
  
  for (NSInteger column = 0; column < _numColumns; column++) {
    
    for (NSInteger row = _numRows-1; row >= 0; row--) {
      
      // If there is a tile at this position but no orb, then there's a hole.
      if (![self tileAtColumn:column row:row].isHole && [self orbAtColumn:column row:row] == nil) {
        
        if (row+1 < _numRows) {
          
          // The two possible places for the orb to come from is from the top right or top left.
          BattleOrb *topRightOrb = column+1 < _numColumns ? [self orbAtColumn:column+1 row:row+1] : nil;
          BattleOrb *topLeftOrb = column-1 >= 0 ? [self orbAtColumn:column-1 row:row+1] : nil;
          
          BattleOrb *chosen = nil;
          if ([topRightOrb isMovable] && [topLeftOrb isMovable]) {
            int trPathLength = [[self orbPathForOrb:topRightOrb withOrbPaths:orbPaths] pathLength];
            int tlPathLength = [[self orbPathForOrb:topLeftOrb withOrbPaths:orbPaths] pathLength];
            
            // Choose orb with shorter path, otherwise randomize
            if (trPathLength !=  tlPathLength) {
              chosen = trPathLength > tlPathLength ? topLeftOrb : topRightOrb;
            } else {
              chosen = arc4random() % 2 ? topRightOrb : topLeftOrb;
            }
          } else {
            chosen = [topRightOrb isMovable] ? topRightOrb : [topLeftOrb isMovable] ? topLeftOrb : nil;
          }
          
          if (chosen) {
            [self addPoint:ccp(column, row) forOrb:chosen withOrbPaths:orbPaths];
            
            // Return after 1, so we can re-vertical fill holes.
            return YES;
          }
        }
      }
    }
  }
  
  return madeChange;
}

// Send in an array of orbPaths that will be modified
- (NSArray *)topUpOrbs:(NSMutableArray *)orbPaths {
  
  NSMutableArray *columns = [NSMutableArray array];
  
  // Detect where we have to add the new orbs. If a column has X holes,
  // then it also needs X new orbs. The holes are all on the top of the
  // column now, but the fact that there may be gaps in the tiles makes this
  // a little trickier.
  for (NSInteger column = 0; column < _numColumns; column++) {
    
    NSMutableArray *array = [NSMutableArray array];
    [columns addObject:array];
    
    for (NSInteger row = 0; row < _numRows; row++) {
      
      // Found a hole?
      if (![self tileAtColumn:column row:row].isHole && [self orbAtColumn:column row:row] == nil) {
        
        // Scan upward to find a spawner tile.
        for (NSInteger lookup = row; lookup < _numRows; lookup++) {
          BattleTile *tile = [self tileAtColumn:column row:lookup];
          BattleOrb *orb = [self orbAtColumn:column row:lookup];
          
          if ([tile isBlocked] || orb != nil) {
            // This tile is a blocker. Need to rely on diagonal falling orbs.
            break;
          }
          
          if (tile.canSpawnOrbs) {
            // Create a new orb.
            BattleOrb *orb = [self createOrbAtColumn:tile.column row:tile.row type:OrbColorRock powerup:PowerupTypeNone special:SpecialOrbTypeNone];
            
            // Randomly create a new orb type. The only restriction is that
            // it cannot be equal to the previous type. This prevents too many
            // "freebie" matches.
            
            // Commented out while loop because it screws up tutorial..
            //do {
            [self generateRandomOrbData:orb atColumn:(int)tile.column row:(int)tile.row];
            //} while (newOrbColor == orbColor && special == newSpecial);
            
            [array addObject:orb];
            
            // Need it to fall from the slot above the spawner tile
            [self setOrb:nil column:orb.column row:orb.row];
            orb.row += 1;
            
            [self addPoint:ccp(column, row) forOrb:orb withOrbPaths:orbPaths];
            
            break;
          }
        }
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
      orb.changeType = OrbChangeTypeDestroyed;
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
#ifdef FREE_BATTLE_MOVEMENT
  return [swap.orbA isMovable] && [swap.orbB isMovable];
#endif
  
  return [self.possibleSwaps containsObject:swap];
}

#pragma mark - For Skills

static const NSInteger maxSearchIterations = 800;

- (BattleOrb *) findOrbWithColorPreference:(OrbColor)orbColor isInitialSkill:(BOOL)isInitialSkill {
  BattleOrbLayout *layout = self;
  BattleOrb *orb = nil;
  NSInteger column, row;
  NSInteger counter = 0;
  
  // Search for all tiles that have initial skill spawnability and prioritize
  if (isInitialSkill) {
    NSMutableArray *orbs = [NSMutableArray array];
    for (int i = 0; i < _numColumns; i++) {
      for (int j = 0; j < _numRows; j++) {
        BattleTile *tile = [layout tileAtColumn:i row:j];
        if (tile.shouldSpawnInitialSkill) {
          BattleOrb *orb = [layout orbAtColumn:i row:j];
          if (!([layout willHaveChainAtColumn:i row:j color:orbColor] ||
                orb.specialOrbType != SpecialOrbTypeNone ||
                orb.powerupType != PowerupTypeNone ||
                orb.isLocked)) {
            [orbs addObject:orb];
          }
        }
      }
    }
    
    if (orbs.count) {
      [orbs shuffle];
      return orbs[0];
    }
  }
  
  // Trying to find orbs of the same color first
  do {
    column = rand() % (layout.numColumns-2) + 1;  // So we'll never spawn at the edge of the board
    row = rand() % (layout.numRows-2) + 1;
    orb = [layout orbAtColumn:column row:row];
    counter++;
  }
  while ((orb.specialOrbType != SpecialOrbTypeNone ||
          orb.powerupType != PowerupTypeNone ||
          orb.orbColor != orbColor ||
          orb.isLocked) &&
         counter < maxSearchIterations);
  
  // Spawn at the edge of the board if we have to
  if (counter == maxSearchIterations)
  {
    counter = 0;
    do {
      column = rand() % layout.numColumns;
      row = rand() % layout.numRows;
      orb = [layout orbAtColumn:column row:row];
      counter++;
    }
    while ((orb.specialOrbType != SpecialOrbTypeNone ||
            orb.powerupType != PowerupTypeNone ||
            orb.orbColor != orbColor ||
            orb.isLocked) &&
           counter < maxSearchIterations);
  }
  
  // Another loop if we haven't found the orb of the same color (avoiding chain)
  if (counter == maxSearchIterations)
  {
    counter = 0;
    do {
      column = rand() % layout.numColumns;
      row = rand() % layout.numRows;
      orb = [layout orbAtColumn:column row:row];
      counter++;
    } while (([layout willHaveChainAtColumn:column row:row color:orbColor] ||
              orb.specialOrbType != SpecialOrbTypeNone ||
              orb.powerupType != PowerupTypeNone ||
              orb.isLocked) &&
             counter < maxSearchIterations);
  }
  
  return counter == maxSearchIterations ? nil : orb;
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
        [str appendFormat:@" -----------"];
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
