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
    for (UserResearchProto *urp in researches) {
      [self.userResearches addObject:[UserResearch userResearchWithProto:urp]];
    }
  }
  return self;
}

-(void)startResearch:(UserResearch *)userResearch {
  //update existing userResearch if another research of the same id exists
  for(UserResearch *ur in self.userResearches) {
    if (ur.userResearchUuid == userResearch.userResearchUuid) {
      [ur updateForUserResearch:userResearch];
      return;
    }
  }
  //add the new user research to the list
  [self.userResearches addObject:userResearch];
}

-(UserResearch *) researchForTimer {
  //to be used only for starting the gameState timer
  //returns potentially expired researches
  //with the goal of having the timer complete them
  for (UserResearch *ur in self.userResearches) {
    if( !ur.complete && ur.timeStarted && ur.endTime) {
      return ur;
    }
  }
  return nil;
}

-(UserResearch *) currentResearch {
  if (_curResearch && !_curResearch.complete) {
    return _curResearch;
  } else {
    _curResearch = nil;
  }
  
  for (UserResearch *ur in self.userResearches) {
    if ([ur isResearching]) {
      _curResearch = ur;
      return ur;
    }
  }
  return nil;
}

-(UserResearch *) userResearchForProto:(ResearchProto *)research {
  for (UserResearch *ur in self.userResearches) {
    if(ur.research.researchId == research.researchId) {
      return ur;
    }
  }
  return nil;
}

-(BOOL)prerequisiteFullfilledForResearch:(ResearchProto *)research {
  UserResearch *userResearch = [self userResearchForProto:research];
  UserResearch *curRank = [self currentRankForResearch:research];
  if (curRank.research.level > research.level) {
    return YES;
  } else if(curRank.research.level < research.level) {
    return NO;
  }
  if (userResearch) {
    return userResearch.complete;
  }
  return NO;
}

-(UserResearch *)currentRankForResearch:(ResearchProto *) research {
  UserResearch *result = [self findCurRankForResearch:[UserResearch userResearchWithResearch:[research minLevelResearch]]];
  return result ? result : [UserResearch userResearchWithResearch: [research minLevelResearch]];
}

-(UserResearch *)findCurRankForResearch:(UserResearch *) userResearch {
  ResearchProto *succesorResearch = [userResearch.research successorResearch];
  if (userResearch.isResearching){
    return userResearch;
  }
  if (userResearch.complete) {
    if (succesorResearch) {
      UserResearch *nextResearch = [UserResearch userResearchWithResearch:succesorResearch];
      nextResearch.userResearchUuid = userResearch.userResearchUuid;
      return nextResearch;
    } else {
      return userResearch;
    }
  } else if (succesorResearch) {
    return [self findCurRankForResearch:[UserResearch userResearchWithResearch:succesorResearch]];
  }
  return nil;
}

-(void)cancelCurrentResearch {
  for (UserResearch *ur in self.userResearches) {
    if ([ur isResearching]) {
      NSString *userDataId = ur.userResearchUuid;
      [ur updateForUserResearch:[UserResearch userResearchWithResearch:[ur.research predecessorResearch]]];
      ur.timeStarted = nil;
      ur.complete = YES;
      ur.userResearchUuid = userDataId;
      [ur updateEndTime];
      _curResearch = nil;
      return;
    }
  }
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
