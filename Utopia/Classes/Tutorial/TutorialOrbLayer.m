//
//  TutorialOrbLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialOrbLayer.h"
#import "Globals.h"

@implementation TutorialOrbLayer

- (id) initWithContentSize:(CGSize)size gridSize:(CGSize)gridSize numColors:(int)numColors presetLayoutFile:(NSString *)presetLayoutFile {
  if ((self = [super initWithContentSize:size gridSize:gridSize numColors:numColors])) {
    NSString* path = [[NSBundle mainBundle] pathForResource:presetLayoutFile.stringByDeletingPathExtension
                                                     ofType:presetLayoutFile.pathExtension];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray* allLinedStrings = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.presetOrbIndices = [NSMutableArray array];
    self.presetOrbs = [NSMutableArray array];
    
    for (NSString *str in allLinedStrings.reverseObjectEnumerator) {
      NSMutableArray *nums = [NSMutableArray array];
      for (int i = 0; i < str.length; i++) {
        NSString *ch = [str substringWithRange:NSMakeRange(i, 1)];
        [nums addObject:@(ch.intValue)];
      }
      [self.presetOrbs addObject:nums];
      [self.presetOrbIndices addObject:@(0)];
    }
    [self initBoard];
    
    self.handSprite = [CCSprite spriteWithImageNamed:@"hand.png"];
    self.handSprite.anchorPoint = ccp(0.065, 0.735);
    self.handSprite.rotation = 30;
  }
  return self;
}

- (Gem *) createRandomGemForPosition:(CGPoint)pt {
  int idx = (int)pt.x;
  int curIndex = [self.presetOrbIndices[idx] intValue];
  if (curIndex < self.presetOrbs.count) {
    NSMutableArray *column = self.presetOrbs[curIndex];
    GemColorId color = (GemColorId)[column[idx] intValue];
    [self.presetOrbIndices replaceObjectAtIndex:idx withObject:@(curIndex+1)];
    return [self createGemWithColor:color powerup:powerup_none];
  } else {
    return [super createRandomGemForPosition:pt];
  }
}

- (void) createOverlayAvoidingPositions:(NSArray *)shownGems withForcedMove:(NSSet *)forcedMove {
  [self.forcedMoveLayer removeFromParent];
  self.forcedMoveLayer = [CCNode node];
  
  CGSize squareSize = self.squareSize;
  for (int i = 0; i < self.gridSize.width; i++) {
    for (int j = 0; j < self.gridSize.height; j++) {
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
    Gem *gem = self.gems[x+y*(int)self.gridSize.width];
    [sg addObject:gem];
  }
  self.shownGems = sg;
  
  NSMutableArray *fm = [NSMutableArray array];
  for (NSValue *val in forcedMove) {
    CGPoint pt = [val CGPointValue];
    int x = pt.x, y = pt.y;
    Gem *gem = self.gems[x+y*(int)self.gridSize.width];
    [fm addObject:gem];
  }
  self.forcedMove = fm;
  
  // Move the hand
  if (self.forcedMove.count >= 2) {
    Gem *gem1 = self.forcedMove[0];
    Gem *gem2 = self.forcedMove[1];
    
    self.handSprite.position = gem2.sprite.position;
    [self addChild:self.handSprite z:101];
    
    self.handSprite.opacity = 0.f;
    CCActionMoveBy *move = [CCActionEaseIn actionWithAction:[CCActionMoveBy actionWithDuration:0.5f position:ccpSub(gem1.sprite.position, self.handSprite.position)] rate:2.f];
    [self.handSprite runAction:
     [CCActionRepeatForever actionWithAction:
      [CCActionSequence actions:
       [CCActionDelay actionWithDuration:0.75f],
       [CCActionFadeIn actionWithDuration:0.1f],
       move,
       [CCActionDelay actionWithDuration:0.3f],
       [CCActionFadeOut actionWithDuration:0.3f],
       [CCActionCallBlock actionWithBlock:^{ self.handSprite.position = gem2.sprite.position; }],
       nil]]];
  }
  
  [self pulseValidMove];
}

- (void) doGemSwapAnimationWithGem:(Gem *)gem1 andGem:(Gem *)gem2 {
  if (self.forcedMove && !([self.forcedMove containsObject:gem1] && [self.forcedMove containsObject:gem2])) {
    _realDragGem.sprite.opacity = 1.f;
    [_dragGem.sprite removeFromParent];
    
    _realDragGem = nil;
    _dragGem = nil;
    _swapGem = nil;
    
    self.isTrackingTouch = NO;
  } else {
    self.forcedMove = nil;
    self.shownGems = nil;
    [self.forcedMoveLayer removeFromParent];
    self.forcedMoveLayer = nil;
    [self.handSprite removeFromParent];
    [super doGemSwapAnimationWithGem:gem1 andGem:gem2];
  }
}

- (NSSet *) getValidMove {
  if (!self.forcedMove) {
    return [super getValidMove];
  } else {
    NSMutableSet *set = [NSMutableSet setWithArray:self.shownGems];
    // Make sure shown gems is not a powerup match
    if (self.shownGems.count > 2) {
      Gem *toRemove = nil;
      for (Gem *gem in self.forcedMove) {
        int count = 0;
        for (Gem *gem2 in self.shownGems) {
          if (gem2.color == gem.color) {
            count++;
          }
        }
        
        // If the color is only equal to itself
        if (count == 1) {
          toRemove = gem;
        }
      }
      [set removeObject:toRemove];
    }
    return set;
  }
}

@end
