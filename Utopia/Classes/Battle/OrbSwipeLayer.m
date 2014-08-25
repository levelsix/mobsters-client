//
//  OrbSwipeLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbSwipeLayer.h"
#import "BattleOrb.h"
#import "BattleLayout.h"
#import "BattleSwap.h"

#import "OrbSwipeLayer+PowerupAnimations.h"

#import "Globals.h"
#import "SoundEngine.h"

#define ORB_NAME_TAG(d) [NSString stringWithFormat:@"%p", d]

#define ORB_ANIMATION_OFFSET 10
#define ORB_ANIMATION_TIME 0.15
#define ORB_CORNER_LEEWAY 0.07
#define NUMBER_OF_ORBS_FOR_MATCH 3
#define TIME_FOR_ORB_BOUNCE 0.3

@interface OrbSwipeLayer ()

// The column and row numbers of the orb that the player first touched
// when he started his swipe movement.
@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;

@end

@implementation OrbSwipeLayer

- (id) initWithContentSize:(CGSize)contentSize layout:(BattleLayout *)layout {
  if ((self = [super init])) {
    _numColumns = layout.numColumns;
    _numRows = layout.numRows;
    _tileWidth = contentSize.width/_numColumns;
    _tileHeight = contentSize.height/_numRows;
    
    self.contentSize = contentSize;
    self.layout = layout;
    
    // NSNotFound means that these properties have invalid values.
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
  }
  return self;
}

#pragma mark - Conversion Routines

// Converts a column,row pair into a CGPoint that is relative to the orbLayer.
- (CGPoint) pointForColumn:(NSInteger)column row:(NSInteger)row {
  return CGPointMake(column*_tileWidth + _tileWidth/2, row*_tileHeight + _tileHeight/2);
}

// Converts a point relative to the orbLayer into column and row numbers.
- (BOOL) convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
  
  // "column" and "row" are output parameters, so they cannot be nil.
  NSParameterAssert(column);
  NSParameterAssert(row);
  
  // Is this a valid location within the orbs layer? If yes,
  // calculate the corresponding row and column numbers.
  if (point.x >= 0 && point.x < _numColumns*_tileWidth &&
      point.y >= 0 && point.y < _numRows*_tileHeight) {
    
    *column = point.x / _tileWidth;
    *row = point.y / _tileHeight;
    return YES;
    
  } else {
    *column = NSNotFound;  // invalid location
    *row = NSNotFound;
    return NO;
  }
}

#pragma mark - Game Setup

- (NSString *) orbSpriteImageNameWithOrb:(BattleOrb *)orb {
  OrbColor orbColor = orb.orbColor;
  PowerupType powerupType = orb.powerupType;
  SpecialOrbType special = orb.specialOrbType;
  
  if (special != SpecialOrbTypeNone) {
    switch (special) {
      case SpecialOrbTypeCake:
        return @"cakeorb.png";
        break;
        
      default:
        break;
    }
  }
  
  NSString *colorPrefix = @"";
  switch (orbColor) {
    case OrbColorFire:
    case OrbColorDark:
    case OrbColorLight:
    case OrbColorEarth:
    case OrbColorWater:
    case OrbColorRock:
      colorPrefix = [Globals imageNameForElement:(Element)orbColor suffix:@""];
      break;
    case OrbColorNone:
      colorPrefix = @"all";
      break;
    default: return nil; break;
  }
  
  NSString *powerupSuffix = @"";
  switch (powerupType) {
    case PowerupTypeNone: powerupSuffix = @"orb"; break;
    case PowerupTypeHorizontalLine: powerupSuffix = @"sideways"; break;
    case PowerupTypeVerticalLine: powerupSuffix = @"updown"; break;
    case PowerupTypeExplosion: powerupSuffix = @"grenade"; break;
    case PowerupTypeAllOfOneColor:
      colorPrefix = @"all";
      powerupSuffix = @"cocktail";
      break;
    default: return nil; break;
  }
  
  return [NSString stringWithFormat:@"%@%@.png", colorPrefix, powerupSuffix];
}

- (CCSprite *) createOrbSpriteForOrb:(BattleOrb *)orb {
  // Create a new sprite for the orb.
  NSString *imageName = [self orbSpriteImageNameWithOrb:orb];
  CCSprite *sprite = [CCSprite spriteWithImageNamed:imageName];
  sprite.position = [self pointForColumn:orb.column row:orb.row];
  [self addChild:sprite z:0 name:ORB_NAME_TAG(orb)];
  return sprite;
}

- (void) addSpritesForOrbs:(NSSet *)orbs {
  for (BattleOrb *orb in orbs) {
    // Create a new sprite for the orb and add it to the orbsLayer.
    [self createOrbSpriteForOrb:orb];
  }
}

- (CCSprite *) spriteForOrb:(BattleOrb *)orb {
  return (CCSprite *)[self getChildByName:ORB_NAME_TAG(orb) recursively:NO];
}

- (void) removeAllOrbSprites {
  [self removeAllChildren];
}

#pragma mark - Detecting Swipes

- (BOOL) isTrackingTouch {
  return self.swipeFromColumn != NSNotFound;
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  
  // Convert the touch location to a point relative to the orbsLayer.
  CGPoint location = [touch locationInNode:self];
  
  // If the touch is inside a square, then this might be the start of a
  // swipe motion.
  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]) {
    
    // The touch must be on a orb, not on an empty tile.
    BattleOrb *orb = [self.layout orbAtColumn:column row:row];
    if (orb != nil) {
      
      // Remember in which column and row the swipe started, so we can compare
      // them later to find the direction of the swipe. This is also the first
      // orb that will be swapped.
      self.swipeFromColumn = column;
      self.swipeFromRow = row;
    }
  }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  
  // If swipeFromColumn is NSNotFound then either the swipe began outside
  // the valid area or the game has already swapped the orbs and we need
  // to ignore the rest of the motion.
  if (self.swipeFromColumn == NSNotFound) return;
  
  CGPoint location = [touch locationInNode:self];
  
  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]) {
    
    // Figure out in which direction the player swiped. Diagonal swipes
    // are not allowed.
    NSInteger horzDelta = 0, vertDelta = 0;
    if (column < self.swipeFromColumn) {          // swipe left
      horzDelta = -1;
    } else if (column > self.swipeFromColumn) {   // swipe right
      horzDelta = 1;
    } else if (row < self.swipeFromRow) {         // swipe down
      vertDelta = -1;
    } else if (row > self.swipeFromRow) {         // swipe up
      vertDelta = 1;
    }
    
    // Only try swapping when the user swiped into a new square.
    if (horzDelta != 0 || vertDelta != 0) {
      [self trySwapHorizontal:horzDelta vertical:vertDelta];
      
      // Ignore the rest of this swipe motion from now on. Just setting
      // swipeFromColumn is enough; no need to set swipeFromRow as well.
      self.swipeFromColumn = NSNotFound;
    }
  }
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
  // We get here after the user performs a swipe. This sets in motion a whole
  // chain of events: 1) swap the orbs, 2) remove the matching lines, 3)
  // drop new orbs into the screen, 4) check if they create new matches,
  // and so on.
  
  NSInteger toColumn = self.swipeFromColumn + horzDelta;
  NSInteger toRow = self.swipeFromRow + vertDelta;
  
  // Going outside the bounds of the array? This happens when the user swipes
  // over the edge of the grid. We should ignore such swipes.
  if (toColumn < 0 || toColumn >= _numColumns) return;
  if (toRow < 0 || toRow >= _numRows) return;
  
  // Can't swap if there is no orb to swap with. This happens when the user
  // swipes into a gap where there is no tile.
  BattleOrb *toOrb = [self.layout orbAtColumn:toColumn row:toRow];
  if (toOrb == nil) return;
  
  BattleOrb *fromOrb = [self.layout orbAtColumn:self.swipeFromColumn row:self.swipeFromRow];
  
  // Communicate this swap request back to the ViewController.
  if (self.swipeHandler != nil) {
    BattleSwap *swap = [[BattleSwap alloc] init];
    swap.orbA = fromOrb;
    swap.orbB = toOrb;
    
    self.swipeHandler(swap);
  }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  // If the gesture ended, regardless of whether if was a valid swipe or not,
  // reset the starting column and row numbers.
  self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
  [self touchEnded:touch withEvent:event];
}

#pragma mark - Animations

- (void)animateSwap:(BattleSwap *)swap completion:(dispatch_block_t)completion {
  CCSprite *spriteA = [self spriteForOrb:swap.orbA];
  CCSprite *spriteB = [self spriteForOrb:swap.orbB];
  
  // Put the orb you started with on top.
  spriteA.zOrder = 2;
  spriteB.zOrder = 1;
  
  CCAction *moveA = [CCActionEaseSineOut actionWithAction:
                     [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:spriteB.position]];
  [spriteA runAction:[CCActionSequence actionWithArray:@[moveA, [CCActionCallBlock actionWithBlock:completion]]]];
  
  CCAction *moveB = [CCActionEaseSineOut actionWithAction:
                     [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:spriteA.position]];
  [spriteB runAction:moveB];
}

- (void)animateInvalidSwap:(BattleSwap *)swap completion:(dispatch_block_t)completion {
  CCSprite *spriteA = [self spriteForOrb:swap.orbA];
  CCSprite *spriteB = [self spriteForOrb:swap.orbB];
  
  // Put the orb you started with on top.
  spriteA.zOrder = 2;
  spriteB.zOrder = 1;
  
  CCAction *moveA = [CCActionEaseSineOut actionWithAction:
                     [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:spriteB.position]];
  CCAction *moveB = [CCActionEaseSineOut actionWithAction:
                     [CCActionMoveTo actionWithDuration:ORB_ANIMATION_TIME position:spriteA.position]];
  
  [spriteA runAction:[CCActionSequence actionWithArray:@[moveA.copy, moveB.copy, [CCActionCallBlock actionWithBlock:completion]]]];
  [spriteB runAction:[CCActionSequence actionWithArray:@[moveB.copy, moveA.copy]]];
}

#pragma mark -

- (CCColor *) colorForSparkle:(OrbColor)color {
  UIColor *c = [Globals colorForElementOnDarkBackground:(Element)color];
  CGFloat r = 1.f, g = 1.f, b = 1.f, a = 1.f;
  [c getRed:&r green:&g blue:&b alpha:&a];
  return [CCColor colorWithCcColor3b:ccc3(r*255, g*255, b*255)];
}

// Color and powerup of gem that destroyed this gem
- (void) destroyOrb:(BattleOrb *)orb chains:(NSSet *)chains fromPowerup:(PowerupType)powerup {
  
  CCSprite *orbSprite = [self spriteForOrb:orb];
  
  if (orbSprite) {
    _numOrbsStillAnimating++;
    
    CCActionCallBlock *crack = [CCActionCallBlock actionWithBlock:^{
      if (powerup == PowerupTypeHorizontalLine || powerup == PowerupTypeVerticalLine || powerup == PowerupTypeAllOfOneColor) {
        CCParticleSystem *q = [CCParticleSystem particleWithFile:@"molotov.plist"];
        [self addChild:q z:100];
        q.position = orbSprite.position;
        q.autoRemoveOnFinish = YES;
        
        [SoundEngine puzzleBoardExplosion];
      } else {
        CCSprite *q = [CCSprite spriteWithImageNamed:@"ring.png"];
        [self addChild:q];
        q.position = orbSprite.position;
        q.scale = 0.5;
        [q runAction:[CCActionSequence actions:
                      [CCActionSpawn actions:[CCActionFadeOut actionWithDuration:0.2], [CCActionScaleTo actionWithDuration:0.2 scale:1], nil],
                      [CCActionCallBlock actionWithBlock:
                       ^{
                         [q removeFromParentAndCleanup:YES];
                       }], nil]];
        
        CCParticleSystem *x = [CCParticleSystem particleWithFile:@"sparkle1.plist"];
        [self addChild:x z:12];
        x.position = orbSprite.position;
        x.autoRemoveOnFinish = YES;
        x.startColor = [self colorForSparkle:orb.orbColor];
      }
    }];
    
    CCActionScaleTo *scale = [CCActionScaleTo actionWithDuration:0.2 scale:0];
    CCActionCallBlock *completion = [CCActionCallBlock actionWithBlock:^{
      _numOrbsStillAnimating--;
      [self checkIfAllOrbsAndPowerupsAreDone];
      
      [orbSprite removeFromParentAndCleanup:YES];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actions:crack, scale, completion, nil];
    [orbSprite runAction:sequence];
    
    // Spawn any chains that rely on this orb
    [self animateChainedChainsFromBattleOrb:orb chains:chains];
    
    if (self.orbDestroyedHandler) {
      self.orbDestroyedHandler(orb);
    }
    
    // It may happen that the same BattleOrb object is part of two chains
    // (L-shape match). In that case, its sprite should only be removed
    // once.
    orbSprite.name = nil;
  }
}

- (void)animateMatchedOrbs:(NSSet *)chains powerupCreations:(NSSet *)powerupCreations completion:(dispatch_block_t)completion {
  float duration = 0.2;
  
  _numOrbsStillAnimating = 0;
  for (BattleChain *chain in chains) {
    if (!chain.prerequisiteOrb) {
      for (BattleOrb *orb in chain.orbs) {
        CCSprite *sprite = [self spriteForOrb:orb];
        if (sprite != nil) {
          [self destroyOrb:orb chains:chains fromPowerup:PowerupTypeNone];
        }
      }
      
      if (self.chainFiredHandler) {
        self.chainFiredHandler(chain);
      }
    }
  }
  
  for (BattleOrb *orb in powerupCreations) {
    CCSprite *sprite = [self createOrbSpriteForOrb:orb];
    // Make sure it appears on top of the orb it is replacing
    sprite.zOrder = 100;
    
    [sprite runAction:
     [CCActionSequence actions:
      [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:duration scale:1.3]],
      [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:duration scale:1]], nil]];
  }
  
  _matchesCompletionBlock = completion;
}

- (void) animateChainedChainsFromBattleOrb:(BattleOrb *)orb chains:(NSSet *)chains {
  for (BattleChain *chain in chains) {
    BattleOrb *prereqOrb = chain.prerequisiteOrb;
    BattleOrb *baseOrb = chain.powerupInitiatorOrb;
    
    // Actually check the rows and columns in case this is a fake orb. (Look at powerup matches.)
    // Regular matches should never reach here...
    if (prereqOrb.column == orb.column && prereqOrb.row == orb.row) {
      if (chain.chainType == ChainTypePowerupNormal) {
        if (baseOrb.powerupType == PowerupTypeHorizontalLine) {
          [self spawnHorizontalLineWithChain:chain otherChains:chains];
        } else if (baseOrb.powerupType == PowerupTypeVerticalLine) {
          [self spawnVerticalLineWithChain:chain otherChains:chains];
        } else if (baseOrb.powerupType == PowerupTypeExplosion) {
          [self spawnExplosionWithChain:chain otherChains:chains];
        } else if (baseOrb.powerupType == PowerupTypeAllOfOneColor) {
          [self spawnRainbowWithChain:chain otherChains:chains];
        }
      } else if (chain.chainType == ChainTypeRainbowLine || chain.chainType == ChainTypeRainbowExplosion) {
        [self spawnRainbowLineOrExplosionWithChain:chain otherChains:chains];
      } else if (chain.chainType == ChainTypeDoubleRainbow) {
        [self spawnDoubleRainbowWithChain:chain otherChains:chains];
      }
      
      // Tell the delegate that a chain fired
      if (self.chainFiredHandler) {
        self.chainFiredHandler(chain);
      }
    }
  }
}

- (void) checkIfAllOrbsAndPowerupsAreDone {
  if (_numOrbsStillAnimating == 0 && _numPowerupsStillAnimating == 0) {
    if (_matchesCompletionBlock) {
      _matchesCompletionBlock();
      _matchesCompletionBlock = nil;
    }
  }
}

#pragma mark -

- (void)animateFallingOrbs:(NSArray *)fallingOrbColumns newOrbs:(NSArray *)newOrbColumns bottomFeeders:(NSSet *)bottomFeeders completion:(dispatch_block_t)completion {
  NSTimeInterval longestDuration = 0;
  
  // First, place the new orbs above the board
  for (NSArray *array in newOrbColumns) {
    for (int i = 0; i < array.count; i++) {
      BattleOrb *orb = array[i];
      CCSprite *spr = [self createOrbSpriteForOrb:orb];
      
      // Orbs are given in top down order so we must subtract i from count
      spr.position = [self pointForColumn:orb.column row:_numRows+i];
    }
  }
  
  // Now, consolidate newOrbs and fallingOrbs and run same animations
  NSMutableArray *allOrbs = [NSMutableArray array];
  for (NSArray *arr in @[fallingOrbColumns, newOrbColumns]) {
    for (NSArray *subarr in arr) {
      for (BattleOrb *orb in subarr) {
        [allOrbs addObject:orb];
      }
    }
  }
  
  for (BattleOrb *orb in allOrbs) {
    if (![bottomFeeders containsObject:orb]) {
      CCSprite *sprite = [self spriteForOrb:orb];
      CGPoint newPosition = [self pointForColumn:orb.column row:orb.row];
      
      int numSquares = (sprite.position.y - newPosition.y) / _tileHeight;
      float duration = 0.4+0.1*numSquares;
      CCActionMoveTo * moveTo = [CCActionMoveTo actionWithDuration:duration position:newPosition];
      [sprite runAction:[CCActionEaseBounceOut actionWithAction:moveTo]];
      
      longestDuration = MAX(longestDuration, duration);
    }
  }
  
  // Make the bottomFeeders just go to the bottom
  for (BattleOrb *orb in bottomFeeders) {
    CCSprite *sprite = [self spriteForOrb:orb];
    CGPoint newPosition = [self pointForColumn:orb.column row:orb.row];
    
    int numSquares = (sprite.position.y - newPosition.y) / _tileHeight;
    float duration = 0.05+0.05*numSquares;
    CCActionMoveTo * moveTo = [CCActionMoveTo actionWithDuration:duration position:newPosition];
    [sprite runAction:
     [CCActionSequence actions:
      [CCActionEaseSineOut actionWithAction:moveTo],
      [CCActionCallBlock actionWithBlock:
       ^{
         [self destroyOrb:orb chains:nil fromPowerup:PowerupTypeNone];
       }], nil]];
    
    longestDuration = MAX(longestDuration, duration);
  }
  
  // Wait until all the orbs have fallen down before we continue.
  [self runAction:
   [CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:longestDuration],
                                       [CCActionCallBlock actionWithBlock:completion]
                                       ]]];
}

- (void) animateShuffle:(NSSet *)orbs completion:(dispatch_block_t)completion {
  for (BattleOrb *orb in orbs) {
    CCSprite *orbSprite = [self spriteForOrb:orb];
    CCAction *move = [CCActionMoveTo actionWithDuration:0.3 position:[self pointForColumn:orb.column row:orb.row]];
    [orbSprite runAction:move];
  }
  
  // Wait until all the orbs have swapped before we continue.
  [self runAction:
   [CCActionSequence actionWithArray:@[[CCActionDelay actionWithDuration:0.3],
                                       [CCActionCallBlock actionWithBlock:completion]
                                       ]]];
}

#pragma mark - Pulsing



#define PULSING_ANIMATION_TAG 82930

//- (void) pulseValidMove {
//  if (_isPulsing) return;
//  _isPulsing = YES;
//  
//  NSSet *move = [self getValidMove];
//  for (Gem *gem in move) {
//    NSString *key = [NSString stringWithFormat:@"%d%dOverlay", gem.color, gem.powerup];
//    CCTexture *texture = [[CCTextureCache sharedTextureCache] textureForKey:key];
//    if (!texture) {
//      UIImage *img = [Globals imageNamed:[self gemSpriteImageNameWithColor:gem.color powerup:gem.powerup]];
//      img = [Globals maskImage:img withColor:[UIColor whiteColor]];
//      texture = [[CCTextureCache sharedTextureCache] addCGImage:img.CGImage forKey:key];
//      texture.contentScale = gem.sprite.texture.contentScale;
//    }
//    CCSprite *spr = [CCSprite spriteWithTexture:texture];
//    spr.position = ccp(gem.sprite.contentSize.width/2, gem.sprite.contentSize.height/2);
//    [gem.sprite addChild:spr z:0 name:@"Overlay"];
//    spr.opacity = 0.f;
//    spr.blendFunc = (ccBlendFunc) {GL_DST_COLOR, GL_ONE};
//    
//    float pulseDur = 0.4f;
//    float numTimes = 4;
//    float delay = 1.3f;
//    CCAction *action =
//    [CCActionRepeatForever actionWithAction:
//     [CCActionSequence actions:
//      [CCActionRepeat actionWithAction:
//       [CCActionSequence actions:
//        [CCActionScaleTo actionWithDuration:pulseDur scale:1.15f],
//        [CCActionScaleTo actionWithDuration:pulseDur scale:1.f], nil] times:numTimes],
//      [CCActionDelay actionWithDuration:delay], nil]];
//    action.tag = PULSING_ANIMATION_TAG;
//    [gem.sprite runAction:action];
//    
//    [spr runAction:
//     [CCActionRepeatForever actionWithAction:
//      [CCActionSequence actions:
//       [CCActionRepeat actionWithAction:
//        [CCActionSequence actions:
//         [CCActionFadeTo actionWithDuration:pulseDur opacity:0.4f],
//         [CCActionFadeTo actionWithDuration:pulseDur opacity:0.f], nil] times:numTimes],
//       [CCActionDelay actionWithDuration:delay], nil]]];
//  }
//}
//
//- (void) stopValidMovePulsing {
//  // Stop the pulsing gems
//  for (Gem *gem in self.gems) {
//    [gem.sprite stopActionByTag:PULSING_ANIMATION_TAG];
//    gem.sprite.scale = 1.f;
//    
//    CCNode *n = [gem.sprite getChildByName:@"Overlay" recursively:NO];
//    [n removeFromParent];
//  }
//  _isPulsing = NO;
//}

@end
