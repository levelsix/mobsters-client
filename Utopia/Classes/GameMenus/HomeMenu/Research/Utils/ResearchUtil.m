//
//  ResearchUtil.m
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchUtil.h"

@implementation ResearchUtil


-(id) initWithResearches:(NSArray *)researches {
  if((self = [super init])) {
    self.userResearches = [NSMutableArray array];
    self.userResearches = [NSMutableArray arrayWithArray:researches];
  }
  return self;
}

-(ResearchProto *) currentResearch {
  return self.userResearches[0];
}

-(BOOL) isResearched:(ResearchProto *)research {
  return NO;
}

@end
