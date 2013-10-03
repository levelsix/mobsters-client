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
  return [spriteFrames_ objectForKey:frameName] != nil;
}

@end

@implementation CCAnimation (SpriteLoading)

+ (id) animationWithSpritePrefix:(NSString *)prefix delay:(float)delay {
  return [[[self alloc] initWithSpritePrefix:prefix delay:delay] autorelease];
}

- (id) initWithSpritePrefix:(NSString *)prefix delay:(float)delay {
  //create the animation for Near
  NSMutableArray *anim = [NSMutableArray array];
  for(int i = 0; true; i++) {
    NSString *file = [NSString stringWithFormat:@"%@%02d@2x.png",prefix, i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      [anim addObject:frame];
    } else {
      break;
    }
  }
  return [self initWithFrames:anim delay:delay];
}

@end
