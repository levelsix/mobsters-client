//
//  BoardLayoutProto+Properties.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BoardLayoutProto+Properties.h"

@implementation BoardLayoutProto (Properties)

- (NSArray *) propertiesForColumn:(int)column row:(int)row {
  NSMutableArray *arr = [NSMutableArray array];
  
  for (BoardPropertyProto *prop in self.propertiesList) {
    if (prop.posX == column && prop.posY == row) {
      [arr addObject:prop];
    }
  }
  
  return arr;
}

@end
