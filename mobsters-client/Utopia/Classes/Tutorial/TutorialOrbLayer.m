//
//  TutorialOrbLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialOrbLayer.h"
#import "Globals.h"
#import "TutorialBattleLayout.h"

@implementation TutorialOrbLayer

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors presetLayoutFile:(NSString *)presetLayoutFile {
  
  TutorialBattleLayout *layout = [[TutorialBattleLayout alloc] initWithGridSize:gridSize numColors:numColors presetLayoutFile:presetLayoutFile];
  
  if ((self = [super initWithGridSize:gridSize numColors:numColors layout:layout])) {
    self.handSprite = [CCSprite spriteWithImageNamed:@"hand.png"];
    self.handSprite.anchorPoint = ccp(0.065, 0.735);
    self.handSprite.rotation = 30;
  }
  return self;
}

- (void) createOverlayAvoidingPositions:(NSArray *)shownGems withForcedMove:(NSArray *)forcedMove {
  [self.forcedMoveLayer removeFromParent];
  self.forcedMoveLayer = [CCNode node];
  
  CGSize squareSize = CGSizeMake(self.swipeLayer.tileWidth, self.swipeLayer.tileHeight);
  for (int i = 0; i < self.layout.numColumns; i++) {
    for (int j = 0; j < self.layout.numRows; j++) {
      BOOL shouldBeCovered = YES;
      for (NSValue *val in shownGems) {
        CGPoint pt = [val CGPointValue];
        if (pt.x == i && pt.y == j) {
          shouldBeCovered = NO;
        }
      }
      
      if (shouldBeCovered) {
        CCNodeColor *nc = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4f:ccc4f(0, 0, 0, 0.6f)] width:squareSize.width height:squareSize.height];
        [self.forcedMoveLayer addChild:nc];
        nc.position = ccp(i*squareSize.width, j*squareSize.height);
      }
    }
  }
  [self addChild:self.forcedMoveLayer z:100];
  
  NSMutableArray *sg = [NSMutableArray array];
  for (NSValue *val in shownGems) {
    CGPoint pt = [val CGPointValue];
    int x = pt.x, y = pt.y;
    BattleOrb *orb = [self.layout orbAtColumn:x row:y];
    [sg addObject:orb];
  }
  self.shownGems = sg;
  
  NSMutableArray *fm = [NSMutableArray array];
  for (NSValue *val in forcedMove) {
    CGPoint pt = [val CGPointValue];
    int x = pt.x, y = pt.y;
    BattleOrb *orb = [self.layout orbAtColumn:x row:y];
    [fm addObject:orb];
  }
  self.forcedMove = fm;
  
  // Move the hand
  if (self.forcedMove.count >= 2) {
    BattleOrb *gem1 = self.forcedMove[0];
    BattleOrb *gem2 = self.forcedMove[1];
    
    CGPoint startPos = [self.swipeLayer pointForColumn:gem2.column row:gem2.row];
    CGPoint endPos = [self.swipeLayer pointForColumn:gem1.column row:gem1.row];
    
    self.handSprite.position = startPos;
    [self addChild:self.handSprite z:101];
    
    self.handSprite.opacity = 0.f;
    CCActionMoveBy *move = [CCActionEaseIn actionWithAction:[CCActionMoveBy actionWithDuration:0.5f position:ccpSub(endPos, startPos)] rate:2.f];
    [self.handSprite runAction:
     [CCActionRepeatForever actionWithAction:
      [CCActionSequence actions:
       [CCActionDelay actionWithDuration:0.75f],
       [CCActionFadeIn actionWithDuration:0.1f],
       move,
       [CCActionDelay actionWithDuration:0.3f],
       [CCActionFadeOut actionWithDuration:0.3f],
       [CCActionCallBlock actionWithBlock:^{ self.handSprite.position = startPos; }],
       nil]]];
  }
  
  [self pulseValidMove];
}

- (void) pulseValidMove {
  if (self.forcedMove) {
    NSMutableSet *set = [NSMutableSet setWithArray:self.shownGems];
    
    // Remove the odd one out.. This will be the first orb of the forced move assuming its not a powerup match
    if (set.count > 2) {
      [set removeObject:self.forcedMove[0]];
    }
    
    [self.swipeLayer pulseValidMove:set];
  } else {
    [super pulseValidMove];
  }
}

- (void) schedulePulse {
  // Do nothing
  if (!self.forcedMove) {
    [super schedulePulse];
  }
}

- (void) checkSwap:(BattleSwap *)swap {
  if (self.forcedMove && !([self.forcedMove containsObject:swap.orbA] && [self.forcedMove containsObject:swap.orbB])) {
    // Do nothing
  } else {
    self.forcedMove = nil;
    self.shownGems = nil;
    [self.forcedMoveLayer removeFromParent];
    self.forcedMoveLayer = nil;
    [self.handSprite removeFromParent];
    
    [super checkSwap:swap];
  }
}

@end
