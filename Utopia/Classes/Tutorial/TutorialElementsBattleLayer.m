//
//  TutorialElementsBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialElementsBattleLayer.h"
#import "TutorialOrbLayer.h"
#import "Globals.h"

@implementation TutorialElementsBattleLayer

- (void) initOrbLayer {
  [super initOrbLayer];
  
  BattlePlayer *bp = [self firstMyPlayer];
  Element strongElem = bp.element;
  Element strongSwap = ElementFire;
  Element weakElem = [Globals elementForNotVeryEffective:bp.element];
  Element weakSwap = ElementWater;
  
  BOOL useThirdElem = NO;
  Element thirdElem = 0;
  Element thirdSwap = ElementEarth;
  if (strongElem == weakSwap) {
    thirdElem = strongSwap;
    useThirdElem = YES;
  } else if (weakElem == strongSwap) {
    thirdElem = weakSwap;
    useThirdElem = YES;
  }
  
  for (int i = 0; i < self.orbLayer.presetOrbs.count; i++) {
    NSMutableArray *row = self.orbLayer.presetOrbs[i];
    for (int j = 0; j < row.count; j++) {
      Element val = [row[j] intValue];
      Element newColor = val;
      if (val == strongSwap) {
        newColor = strongElem;
      } else if (val == weakSwap) {
        newColor = weakElem;
      } else if (useThirdElem) {
        if (val == thirdSwap) {
          newColor = thirdElem;
        }
      } else {
        if (val == strongElem) {
          newColor = strongSwap;
        } else if (val == weakElem) {
          newColor = weakSwap;
        }
      }
      
      [row replaceObjectAtIndex:j withObject:@(newColor)];
    }
    [self.orbLayer.presetOrbIndices replaceObjectAtIndex:i withObject:@(0)];
  }
  [self.orbLayer initBoard];
  
  _isFirstHit = YES;
}

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(5, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(1, 3)],
                                                 [NSValue valueWithCGPoint:ccp(2, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(2, 4)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(2, 3)],
                                                 [NSValue valueWithCGPoint:ccp(2, 4)], nil]];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector {
  if (!enemyIsAttacker) {
    // Make sure first hit does not kill
    if (_isFirstHit) {
      damageDone = MIN(damageDone, self.enemyPlayerObject.curHealth*0.9);
      _isFirstHit = NO;
    }
  }
  
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker withSelector:selector];
}

- (void) arrowOnMyHealthBar {
  CCSprite *spr = [CCSprite spriteWithImageNamed:@"arrow.png"];
  [self.myPlayer.healthBgd addChild:spr z:1000 name:@"TutorialArrow"];
  spr.position = ccp(self.myPlayer.healthBgd.contentSize.width/2, self.myPlayer.healthBgd.contentSize.height+spr.contentSize.height/2+5);
  [spr runAction:[CCActionFadeIn actionWithDuration:0.4]];
  [Globals animateCCArrow:spr atAngle:-M_PI_2];
}

- (void) removeArrowOnMyHealthBar {
  CCSprite *arrow = (CCSprite *)[self getChildByName:@"TutorialArrow" recursively:YES];
  [arrow runAction:[CCActionFadeOut actionWithDuration:0.4]];
}

- (void) arrowOnElements {
  self.elementButton.hidden = NO;
  [Globals createUIArrowForView:self.elementButton atAngle:0];
}

- (void) elementButtonClicked:(id)sender {
  [super elementButtonClicked:sender];
  [Globals removeUIArrowFromViewRecursively:self.elementButton.superview];
  
  if ([self.delegate respondsToSelector:@selector(elementButtonClicked)]) {
    [self.delegate elementButtonClicked];
  }
}

- (NSString *) presetLayoutFile {
  return @"TutorialElementsBattleLayout.txt";
}

@end
