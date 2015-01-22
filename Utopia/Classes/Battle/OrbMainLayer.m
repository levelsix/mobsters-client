//
//  OrbMainLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbMainLayer.h"

#import "Globals.h"
#import "Protocols.pb.h"

#define OrbLog(...) LNLog(__VA_ARGS__)

@implementation OrbMainLayer

- (id) initWithLayoutProto:(BoardLayoutProto *)proto {
  BattleOrbLayout *layout = [[BattleOrbLayout alloc] initWithBoardLayout:proto];
  return [self initWithGridSize:CGSizeMake(layout.numColumns, layout.numRows) numColors:layout.numColors layout:layout];
}

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors {
  BattleOrbLayout *layout = [[BattleOrbLayout alloc] initWithGridSize:gridSize numColors:numColors];
  return [self initWithGridSize:gridSize numColors:numColors layout:layout];
}

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors layout:(BattleOrbLayout *)layout {
  if (self = [super init]) {
    self.layout = layout;
    
    self.bgdLayer = [[OrbBgdLayer alloc] initWithGridSize:gridSize layout:layout];
    [self.bgdLayer assembleBorder];
    self.swipeLayer = [[OrbSwipeLayer alloc] initWithContentSize:self.bgdLayer.contentSize layout:layout];
    [self addChild:self.bgdLayer];
    
    // Add the swipe layer in a clipping node
    OrbBgdLayer *stencil = [[OrbBgdLayer alloc] initWithGridSize:gridSize layout:layout];
    CCClippingNode *clip = [[CCClippingNode alloc] initWithStencil:stencil];
    stencil.anchorPoint = ccp(0, 0);
    [self.bgdLayer addChild:clip z:2];
    [clip addChild:self.swipeLayer];
    
    self.contentSize = self.bgdLayer.contentSize;
    self.bgdLayer.position = ccp(self.bgdLayer.contentSize.width/2, self.bgdLayer.contentSize.height/2);
    self.anchorPoint = ccp(0.5, 0.5);
    
    // This is the swipe handler. MyScene invokes this block whenever it
    // detects that the player performs a swipe.
    id block = ^(BattleSwap *swap) {
      [self checkSwap:swap];
    };
    
    self.swipeLayer.swipeHandler = block;
    
    block = ^(BattleOrb *orb) {
      [self.delegate orbKilled:orb];
    };
    
    self.swipeLayer.orbDestroyedHandler = block;
    
    block = ^(BattleChain *orb) {
      [self.delegate newComboFound];
    };
    
    self.swipeLayer.chainFiredHandler = block;
    
    [self beginGame];
  }
  return self;
}

- (void)beginGame {
  [self beginInitialBoard];
}

- (void) beginInitialBoard {
  
  // Fill up the level with new orbs, and create sprites for them.
  NSSet *newOrbs = [self.layout createInitialOrbs];
  
  OrbLog(@"Created layout: %@", newOrbs);
  OrbLog(@"Layout: %@", self.layout);
  
  [self.swipeLayer addSpritesForOrbs:newOrbs];
}

- (void) checkSwap:(BattleSwap *)swap {
  
  // While orbs are being matched and new orbs fall down to fill up
  // the holes, we don't want the player to tap on anything.
  [self disallowInput];
  
  if ([self.layout isPossibleSwap:swap]) {
    [self.delegate moveBegan];
    
    [self.layout performSwap:swap];
    [self.swipeLayer animateSwap:swap completion:^{
      [self handleMatches:swap];
    }];
    
  } else if ([swap.orbA isMovable] && [swap.orbB isMovable]) {
    [self.swipeLayer animateInvalidSwap:swap completion:^{
      [self allowInput];
    }];
  } else {
    [self allowInput];
  }
}

- (void) handleMatches:(BattleSwap *)initialSwap {
  
  // This is the main loop that removes any matching orbs and fills up the
  // holes with new orbs. While this happens, the user cannot interact with
  // the app.
  
  OrbLog(@"------------------------------------");
  OrbLog(@"Initial swap:\n%@", initialSwap);
  OrbLog(@"Initial layout: %@", self.layout);
  
  [self.layout resetOrbChangeTypes];
  
  NSSet *chains = nil;
  if (initialSwap && [self.layout isPowerupMatch:initialSwap.orbA otherOrb:initialSwap.orbB]) {
    chains = [self.layout performPowerupMatchWithSwap:initialSwap];
    
    OrbLog(@"Found powerup match with chains %@", chains);
    OrbLog(@"Layout: %@", self.layout);
  }
  else {
    // Detect if there are any matches left.
    chains = [self.layout removeMatches];
    
    OrbLog(@"Found regular chains %@", chains);
    OrbLog(@"Layout: %@", self.layout);
    
    // If there are no more matches, then the move is complete.
    if ([chains count] == 0) {
      NSSet *swaps = [self.layout detectPossibleSwaps];
      
      OrbLog(@"Turn ending.. Detecting swaps: %@", swaps);
      
      if (!swaps.count) {
        NSSet *newOrbs = [self.layout shuffle];
        
        OrbLog(@"No swaps found.. Shuffling.");
        OrbLog(@"Layout: %@", self.layout);
        
        [self.swipeLayer animateShuffle:newOrbs completion:^{
          [self.delegate moveComplete];
        }];
        
        [self.delegate reshuffleWithPrompt:@"No more moves!\nShuffling..."];
      } else {
        [self.delegate moveComplete];
      }
      
      OrbLog(@"------------------------------------");
      
      return;
    }
  }
  
  // Look for any powerup creations
  NSSet *powerupOrbs = [self.layout detectPowerupCreationFromChains:chains withInitialSwap:initialSwap];
  
  if (powerupOrbs.count) {
    OrbLog(@"Detecting powerup creations %@", powerupOrbs);
    OrbLog(@"Layout: %@", self.layout);
  }
  
  for (BattleOrb *powerup in powerupOrbs) {
    [self.delegate powerupCreated:powerup];
  }
  
  // Look for any chains caused by powerups that were destroyed;
  NSSet *powerupChains = [self.layout detectPowerupChainsWithMatchChains:chains];
  chains = [chains setByAddingObjectsFromSet:powerupChains];
  
  if (powerupChains.count) {
    OrbLog(@"Detecting powerup chains %@", powerupChains);
    OrbLog(@"Layout: %@", self.layout);
  }
  
  NSSet *adjacentChains = [self.layout detectAdjacentChainsWithMatchAndPowerupChains:chains];
  chains = [chains setByAddingObjectsFromSet:adjacentChains];
  
  if (adjacentChains.count) {
    OrbLog(@"Adjacent chains %@", adjacentChains);
    OrbLog(@"Layout: %@", self.layout);
  }
  
  // First, remove any matches...
  [self.swipeLayer animateMatchedOrbs:chains powerupCreations:powerupOrbs completion:^{
    
    NSMutableArray *orbPaths = [NSMutableArray array];
    
    NSMutableArray *newColumns = [NSMutableArray array];
    NSSet *bottomFeeders;
    
    BOOL foundChange;
    
    int iteration = 0;
    do {
      foundChange = NO;
      
      BOOL fillHoles = [self.layout fillHoles:orbPaths];
      
      if (fillHoles) {
        OrbLog(@"Fill Holes Layout: %@", self.layout);
      }
      
      NSArray *moreNewColumns = [self.layout topUpOrbs:orbPaths];
      BOOL foundNewColumns = NO;
      
      for (int i = 0; i < newColumns.count || i < moreNewColumns.count; i++) {
        NSMutableArray *firstArr;
        
        if (i < newColumns.count) {
          firstArr = newColumns[i];
        } else {
          firstArr = [NSMutableArray array];
          [newColumns addObject:firstArr];
        }
        
        NSArray *secondArr = moreNewColumns[i];
        
        foundNewColumns = foundNewColumns || secondArr.count > 0;
        [firstArr addObjectsFromArray:secondArr];
      }
      
      if (foundNewColumns) {
        OrbLog(@"New columns %@", moreNewColumns);
        OrbLog(@"Layout: %@", self.layout);
      }
      
      BOOL diagFillHoles = [self.layout diagonallyFillHoles:orbPaths];
      
      if (diagFillHoles) {
        OrbLog(@"Diag fill holes Layout: %@", self.layout);
      }
      
      NSSet *newBottomFeeders = [self.layout detectBottomFeeders];
      bottomFeeders = [bottomFeeders setByAddingObjectsFromSet:newBottomFeeders];
      
      if (newBottomFeeders.count) {
        OrbLog(@"New Bottom Feeders %@", newBottomFeeders);
        OrbLog(@"Layout: %@", self.layout);
      }
      
      foundChange = fillHoles || diagFillHoles || foundNewColumns || newBottomFeeders.count;
      
      iteration++; 
    } while (foundChange);
    
    OrbLog(@"Falling orbs: %@", orbPaths);
    OrbLog(@"New Columns: %@", newColumns);
    if (bottomFeeders.count) OrbLog(@"Bottom Feeders: %@", bottomFeeders);
    OrbLog(@"Final Layout: %@", self.layout);
    
    [self.swipeLayer animateFallingOrbs:orbPaths newOrbs:newColumns bottomFeeders:bottomFeeders completion:^{
      
      OrbLog(@"Re-running cycle.");
      OrbLog(@"Layout: %@", self.layout);
      
      // Keep repeating this cycle until there are no more matches.
      // Don't require swap here because these matches are organic.
      [self handleMatches:nil];
    }];
  }];
}

- (void) shuffleWithCompletion:(void(^)())completion
{
  [self.swipeLayer animateShuffle:[self.layout shuffle] completion:completion];
  [self.delegate reshuffleWithPrompt:@"Shuffling..."];
}

#pragma mark - Allowing input

- (void) pulseValidMove {
  OrbLog(@"Firing pulse..");
  
  NSSet *set = [self.layout getRandomValidMove];
  [self.swipeLayer pulseValidMove:set];
  
  _isPulseScheduled = NO;
}

- (void) schedulePulse {
  if (!_isPulseScheduled) {
    OrbLog(@"Scheduling pulse..");
    
    [self scheduleOnce:@selector(pulseValidMove) delay:3.f];
    //[self schedule:@selector(pulseValidMove) interval:1.f];
    _isPulseScheduled = YES;
  }
}

- (void) stopPulse {
  if (_isPulseScheduled) {
    OrbLog(@"Unscheduling pulse..");
    [self unschedule:@selector(pulseValidMove)];
    _isPulseScheduled = NO;
  }
  [self.swipeLayer stopValidMovePulsing];
}

- (void) allowInput {
  self.swipeLayer.userInteractionEnabled = YES;
  
  [self schedulePulse];
}

- (void) disallowInput {
  self.swipeLayer.userInteractionEnabled = NO;
  
  [self stopPulse];
}

#pragma mark - Serialization

#define ORB_KEY @"OrbKey"
#define POSITION_X_KEY @"PositionXKey"
#define POSITION_Y_KEY @"PositionYKey"
#define TILE_TOP_KEY @"TileTopKey"
#define TILE_BOTTOM_KEY @"TileBottomKey"

- (id) serialize {
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < self.layout.numColumns; i++) {
    for (int j = 0; j < self.layout.numRows; j++) {
      
      NSMutableDictionary *gemInfo = [NSMutableDictionary dictionary];
      
      // Orb info
      BattleOrb *orb = [self.layout orbAtColumn:i row:j];
      
      if (orb) {
        [gemInfo setObject:orb.serialize forKey:ORB_KEY];
        
        // Tile info
        BattleTile *tile = [self.layout tileAtColumn:i row:j];
        [gemInfo setObject:@(tile.typeTop) forKey:TILE_TOP_KEY];
        [gemInfo setObject:@(tile.typeBottom) forKey:TILE_BOTTOM_KEY];
        
        [gemInfo setObject:@(orb.column) forKey:POSITION_X_KEY];
        [gemInfo setObject:@(orb.row) forKey:POSITION_Y_KEY];
        
        [arr addObject:gemInfo];
      }
    }
  }
  return arr;
}

- (void) deserialize:(NSArray *)arr {
  NSMutableSet *set = [NSMutableSet set];
  for (NSDictionary *gemInfo in arr) {
    NSDictionary* orbData = [gemInfo objectForKey:ORB_KEY];
    
    int x = (int)[[gemInfo objectForKey:POSITION_X_KEY] integerValue];
    int y = (int)[[gemInfo objectForKey:POSITION_Y_KEY] integerValue];
    
    BattleOrb *orb = [[BattleOrb alloc] init];
    orb.powerupType = PowerupTypeNone;
    orb.orbColor = OrbColorRock;
    orb.specialOrbType = SpecialOrbTypeNone;
    orb.column = x;
    orb.row = y;
    [orb deserialize:orbData];
    
    // Tile info
    BattleTile* tile = [self.layout tileAtColumn:x row:y];
    tile.typeTop = (int)[[gemInfo objectForKey:TILE_TOP_KEY] integerValue];
    tile.typeBottom = (int)[[gemInfo objectForKey:TILE_BOTTOM_KEY] integerValue];
    [self.bgdLayer updateTile:tile];
    
    [set addObject:orb];
  }
  
  [self.swipeLayer removeAllOrbSprites];
  [self.layout restoreLayoutWithOrbs:set];
  [self.swipeLayer addSpritesForOrbs:set];
}

@end
