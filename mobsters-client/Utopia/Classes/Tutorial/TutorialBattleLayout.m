//
//  TutorialBattleLayout.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBattleLayout.h"

@implementation TutorialBattleLayout

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors presetLayoutFile:(NSString *)presetLayoutFile {
  if ((self = [super initWithGridSize:gridSize numColors:numColors])) {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:presetLayoutFile.stringByDeletingPathExtension
                                                     ofType:presetLayoutFile.pathExtension];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray* allLinedStrings = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.presetOrbs = [NSMutableArray array];
    
    // Preset orbs is arranged by columns, not rows, so access by arr[col][row]
    for (NSString *str in allLinedStrings.reverseObjectEnumerator) {
      for (int i = 0; i < str.length; i++) {
        NSMutableArray *nums;
        if (i < self.presetOrbs.count) {
          nums = self.presetOrbs[i];
        } else {
          nums = [NSMutableArray array];
          [self.presetOrbs addObject:nums];
        }
        
        NSString *ch = [str substringWithRange:NSMakeRange(i, 1)];
        [nums addObject:@(ch.intValue)];
      }
    }
  }
  return self;
}

- (void) generateRandomOrbData:(BattleOrb*)orb atColumn:(int)column row:(int)row {
  if (column < self.presetOrbs.count) {
    NSMutableArray *arr = self.presetOrbs[column];
    if (arr.count) {
      NSNumber *num = [arr firstObject];
      orb.orbColor = num.intValue;
      orb.specialOrbType = SpecialOrbTypeNone;
      
      [arr removeObjectAtIndex:0];
      
      return;
    }
  }
  
  [super generateRandomOrbData:orb atColumn:column row:row];
}

@end
