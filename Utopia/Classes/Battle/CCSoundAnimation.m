//
//  CCSoundAnimation.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/19/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCSoundAnimation.h"
#import "SoundEngine.h"

@implementation CCAnimation (SoundAnimation)

- (void) repeatFrames:(NSRange)range numTimes:(int)numTimes {
  for (int i = 0; i < numTimes; i++) {
    if (range.location+range.length <= self.frames.count) {
      NSArray *arr = [self.frames subarrayWithRange:range];
      NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
      [self.frames insertObjects:arr atIndexes:indexes];
      _totalDelayUnits += arr.count;
    }
  }
}

- (void) addSoundEffect:(NSString *)effectName atIndex:(int)index {
  if (index < self.frames.count) {
    [self.frames insertObject:effectName atIndex:index];
  }
}

@end

@implementation CCSoundAnimate

- (id) initWithAnimation:(CCAnimation *)a {
  // Extract sounds out
  CCAnimation *anim = [a copy];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  int i = 0;
  while (i < anim.frames.count) {
    id obj = [anim.frames objectAtIndex:i];
    if ([obj isKindOfClass:[CCAnimationFrame class]]) {
      i++;
    } else {
      [dict setObject:obj forKey:[NSNumber numberWithInt:i]];
      [anim.frames removeObjectAtIndex:i];
    }
  }
  
  if ((self = [super initWithAnimation:anim])) {
    self.soundDictionary = dict;
    self.playedSounds = [NSMutableSet set];
  }
  return self;
}

- (void) startWithTarget:(id)target {
  [super startWithTarget:target];
  [self.playedSounds removeAllObjects];
}

- (void) update:(CCTime)t {
	[super update:t];
  
	NSUInteger idx = t * self.animation.frames.count;
  for (NSNumber *num in self.soundDictionary) {
    int intVal = num.intValue;
    NSString *sound = [self.soundDictionary objectForKey:num];
    if (idx == intVal && ![self.playedSounds containsObject:num]) {
      [[SoundEngine sharedSoundEngine] playEffect:sound];
      [self.playedSounds addObject:num];
    }
  }
}

@end