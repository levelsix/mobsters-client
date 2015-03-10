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
    self.userResearches = [NSMutableArray arrayWithArray:researches];
  }
  return self;
}

-(UserResearchProto *) currentResearch {
  for (UserResearchProto *urp in self.userResearches) {
    if (!urp.complete) {
      return urp;
    }
  }
  return nil;
}

-(BOOL) isResearched:(ResearchProto *)research {
  for (UserResearchProto *urp in self.userResearches) {
    MSDate *purchaseTime = [MSDate dateWithTimeIntervalSince1970:urp.timePurchased];
    if (urp.researchId == research.researchId && (urp.complete || -[purchaseTime timeIntervalSinceNow] > research.durationMin * 60)) {
      return YES;
    }
  }
  return NO;
}

-(BOOL)isResearching:(ResearchProto *)research {
  for (UserResearchProto *urp in self.userResearches) {
    MSDate *purchaseTime = [MSDate dateWithTimeIntervalSince1970:urp.timePurchased];
    if (urp.researchId == research.researchId && !urp.complete && -[purchaseTime timeIntervalSinceNow] < research.durationMin * 60) {
      return YES;
    }
  }
  return NO;
}

-(NSString *)uuidForResearch:(ResearchProto *)research {
  for (UserResearchProto *urp in self.userResearches) {
    if(urp.researchId == research.researchId) {
      return urp.userResearchUuid;
    }
  }
  return nil;
}

@end

@implementation ResearchProto (prereqObject)

-(ResearchProto *)successorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.succId)];
}

-(ResearchProto *)predecessorResearch {
  return [[GameState sharedGameState].staticResearch objectForKey:@(self.predId)];
}

-(ResearchProto *)maxLevelResearch {
  if(self.succId) {
    return [[self successorResearch] maxLevelResearch];
  }
  return self;
}

-(ResearchProto *)minLevelResearch {
  if(self.predId) {
    return [[self predecessorResearch] minLevelResearch];
  }
  return self;
}

-(ResearchPropertyProto *)firstProperty {
  return self.propertiesList[0];
}

-(float)researchBenefit {
  return [self firstProperty].researchValue - [[self predecessorResearch] firstProperty].researchValue;
}

-(NSArray *)fullResearchFamily{
  NSMutableArray *ar =[[NSMutableArray alloc] init];
  ResearchProto *research = [self minLevelResearch];
  [ar addObject:research];
  
  while (research.succId) {
    [ar addObject:[research successorResearch]];
    research = [research successorResearch];
  }
  return ar;
}

-(NSString *)simpleValue {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setMaximumFractionDigits:5];
  [formatter setMinimumFractionDigits:0];
  return [formatter stringFromNumber:[NSNumber numberWithFloat:[self researchBenefit]]];
}

-(BOOL)isComplete {
  GameState *gs = [GameState sharedGameState];
  return [gs.researchUtil isResearched:self];
}

-(BOOL)isResearching {
  GameState *gs = [GameState sharedGameState];
  return [gs.researchUtil isResearching:self];
}

-(BOOL)isAvailable {
  if([self predecessorResearch]) {
    return [[self predecessorResearch] isComplete] && ![self isComplete] && ![self isResearching];
  } else {
    return ![self isComplete] && ![self isResearching];
  }
}

-(BOOL)prereqsComplete {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *prereqs = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:self.researchId];
  for (PrereqProto *pp in prereqs) {
    if(![gl isPrerequisiteComplete:pp]) {
      return NO;
    }
  }
  return YES;
}

@end
