//
//  BattleOrbPath.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleOrbPath.h"

@implementation BattleOrbPath

- (int) pathLength {
  NSValue *prev = nil;
  int pathLength = 0;
  for (id val in self.path) {
    if ([val isKindOfClass:[NSNumber class]]) {
      pathLength += [val intValue];
    } else {
      if (!prev) {
        prev = val;
        continue;
      }
      
      CGPoint prevPt = [prev CGPointValue];
      CGPoint valPt = [val CGPointValue];
      
      pathLength += MAX(1, prevPt.y-valPt.y);
      
      prev = val;
    }
  }
  
  return pathLength;
}

- (int) pathLengthToPoint:(CGPoint)pt {
  NSValue *prev = nil;
  int pathLength = 0;
  for (id val in self.path) {
    if ([val isKindOfClass:[NSNumber class]]) {
      pathLength += [val intValue];
    } else {
      if (!prev) {
        prev = val;
        continue;
      }
      
      CGPoint prevPt = [prev CGPointValue];
      CGPoint valPt = [val CGPointValue];
      
      if (prevPt.x == pt.x && prevPt.y == pt.y) {
        // Special case for when we start off with the right number, but there are delays after
        return pathLength;
      }
      
      // Used < instead of <= so that delays after this will still be processed
      else if (valPt.x == pt.x && valPt.y < pt.y && prevPt.y >= pt.y) {
        pathLength += prevPt.y-pt.y;
        return pathLength;
      } else {
        pathLength += MAX(1, prevPt.y-valPt.y);
      }
      
      prev = val;
    }
  }
  
  return 0;
}

- (NSString *)description {
  NSMutableString *s = [NSMutableString stringWithFormat:@"path length=%d\n", [self pathLength]];
  for (id val in self.path) {
    if ([val isKindOfClass:[NSNumber class]]) {
      [s appendFormat:@"delay %d\n", [val intValue]];
    } else {
      [s appendFormat:@"move to %@\n", NSStringFromCGPoint([val CGPointValue])];
    }
  }
  return s;
}

@end
