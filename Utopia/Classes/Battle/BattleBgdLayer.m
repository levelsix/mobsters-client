//
//  BattleBgdLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/13/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BattleBgdLayer.h"
#import "MainBattleLayer.h"

@implementation BattleBgdLayer

- (id) initWithPrefix:(NSString *)prefix {
  if ((self = [super init])) {
    self.prefix = prefix;
    [self addNewScene];
    
    _curBasePoint = ccp(-175, 0);
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  
  // Add any additional scenes
  [self addAdditionalScenes];
}

- (void) scrollToNewScene {
  [self addAdditionalScenes];
  
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float nextBaseY = self.position.y-Y_MOVEMENT_FOR_NEW_SCENE;
  float nextBaseX = self.position.x-Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y;
  [self runAction:[CCActionSequence actions:
                   [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:ccp(nextBaseX, nextBaseY)],
                   [CCActionCallFunc actionWithTarget:self selector:@selector(removePastScenes)],
                   [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(reachedNextScene)],
                   nil]];
}

- (void) addAdditionalScenes {
  // Get max y pos
  float maxY = _curBasePoint.y;
  
  // Base Y will be negative
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float nextBaseY = self.position.y-Y_MOVEMENT_FOR_NEW_SCENE;
  int numScenesToAdd = ceilf((-1*nextBaseY+self.parent.contentSize.height-maxY)/offsetPerScene.y);
  for (int i = 0; i < numScenesToAdd; i++) {
    [self addNewScene];
  }
}

- (void) addNewScene {
  [self addSceneAtBasePosition:_curBasePoint];
  _curBasePoint = ccpAdd(_curBasePoint, POINT_OFFSET_PER_SCENE);
}

- (void) removePastScenes {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (CCNode *n in self.children) {
    if (n.position.y+n.contentSize.height/2 < -1*self.position.y) {
      [toRemove addObject:n];
    }
  }
  
  for (CCNode *n in toRemove) {
    [n removeFromParent];
  }
}

- (void) addSceneAtBasePosition:(CGPoint)pos {
  CCSprite *left1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene.png"]];
  
  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
  
  [self addChild:left1];
}

@end

