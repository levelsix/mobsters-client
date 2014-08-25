
//
//  DestroyedOrb.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "DestroyedOrb.h"

@implementation DestroyedOrb

- (id) initWithColor:(CCColor *)color {
  if ((self = [super initWithImageNamed:@"orbball.png"])) {
    self.color = color;
    
    self.streak = [CCMotionStreak streakWithFade:0.5 minSeg:0.1f width:8 color:color textureFilename:@"streak.png"];
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  if (parent && !self.streak.parent) {
    [self.parent addChild:self.streak z:self.zOrder];
  }
}

- (void) update:(CCTime)delta {
	[self.streak setPosition:self.position];
}

- (void) dealloc {
  [self.streak removeFromParent];
}

@end
