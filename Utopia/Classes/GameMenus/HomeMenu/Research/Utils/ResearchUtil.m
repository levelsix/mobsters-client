//
//  ResearchUtil.m
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchUtil.h"
#import "GameState.h"

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

@implementation ResearchProto (prereqObject)

- (ResearchProto *)successorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.succId)];
}

- (ResearchProto *)predecessorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.predId)];
}

- (ResearchProto *)maxLevelResearch {
  if(self.succId) {
    return [[self successorResearch] maxLevelResearch];
  }
  return self;
}

- (ResearchProto *)minLevelResearch {
  if(self.predId) {
    return [[self predecessorResearch] minLevelResearch];
  }
  return self;
}

- (ResearchPropertyProto *)firstProperty {
  return self.propertiesList[0];
}

- (float)researchBenefit {
  return [self firstProperty].researchValue - [[self predecessorResearch] firstProperty].researchValue;
}

- (NSArray *)fullResearchFamily{
  NSMutableArray *ar =[[NSMutableArray alloc] init];
  ResearchProto *research = [self minLevelResearch];
  [ar addObject:research];
  
  while (research.succId) {
    [ar addObject:[research successorResearch]];
  }
  return ar;
}

- (NSString *)description {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setMaximumFractionDigits:5];
  [formatter setMinimumFractionDigits:0];
  return [formatter stringFromNumber:[NSNumber numberWithFloat:[self researchBenefit]]];
}

@end
