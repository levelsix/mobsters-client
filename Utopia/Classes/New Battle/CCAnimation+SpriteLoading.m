//
//  CCAnimation+SpriteLoading.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCAnimation+SpriteLoading.h"

@implementation CCSpriteFrameCache (FrameCheck)

- (BOOL) containsFrame:(NSString *)frameName {
  return [_spriteFrames objectForKey:frameName] != nil;
}

@end

@implementation CCAnimation (SpriteLoading)

+ (id) animationWithSpritePrefix:(NSString *)prefix delay:(float)delay {
  return [[self alloc] initWithSpritePrefix:prefix delay:delay];
}

- (id) initWithSpritePrefix:(NSString *)prefix delay:(float)delay {
  //create the animation for Near
  NSMutableArray *anim = [NSMutableArray array];
  for(int i = 0; true; i++) {
    NSString *file = [NSString stringWithFormat:@"%@%02d.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      [anim addObject:frame];
    } else if (i > 0) {
      break;
    } else {
      NSLog(@"Attempting sprite frame 01 for prefix %@..", prefix);
    }
  }
  
  if (anim.count == 0) {
    NSLog(@"Created animation with 0 frames for prefix %@..", prefix);
  }
  
  return [self initWithSpriteFrames:anim delay:delay];
}

- (id) copy {
  CCAnimation *anim = [[CCAnimation alloc] initWithAnimationFrames:self.frames delayPerUnit:self.delayPerUnit loops:self.loops];
  return anim;
}

@end
