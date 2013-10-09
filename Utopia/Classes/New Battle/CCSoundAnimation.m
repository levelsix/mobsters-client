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

- (void) repeatFrames:(NSRange)range {
  NSArray *arr = [self.frames subarrayWithRange:range];
  NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
  [self.frames insertObjects:arr atIndexes:indexes];
}

- (void) addSoundEffect:(NSString *)effectName atIndex:(int)index {
  [self.frames insertObject:effectName atIndex:index];
}

@end

@implementation CCSoundAnimate

- (id) initWithAnimation:(CCAnimation *)a restoreOriginalFrame:(BOOL)b {
  // Extract sounds out
  CCAnimation *anim = [[a copy] autorelease];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  int i = 0;
  while (i < anim.frames.count) {
    id obj = [anim.frames objectAtIndex:i];
    if ([obj isKindOfClass:[CCSpriteFrame class]]) {
      i++;
    } else {
      [dict setObject:obj forKey:[NSNumber numberWithInt:i]];
      [anim.frames removeObjectAtIndex:i];
    }
  }
  
  if ((self = [super initWithAnimation:anim restoreOriginalFrame:b])) {
    self.soundDictionary = dict;
    self.playedSounds = [NSMutableSet set];
  }
  return self;
}

- (void) startWithTarget:(id)target {
  [super startWithTarget:target];
  [self.playedSounds removeAllObjects];
}

- (void) update:(ccTime)t {
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

- (void) dealloc {
  self.soundDictionary = nil;
  self.playedSounds = nil;
  [super dealloc];
}

@end