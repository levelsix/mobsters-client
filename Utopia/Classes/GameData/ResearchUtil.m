//
//  ResearchUtil.m
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchUtil.h"
#import "GameState.h"

@implementation UserResearch
+ (id) userResearchWithProto:(UserResearchProto *)proto {
  return [[UserResearch alloc] initWithProto:proto];
}

+ (id) userResearchWithResearch:(ResearchProto *)proto {
  GameState *gs = [GameState sharedGameState];
  
  UserResearch *userResearch = [gs.researchUtil userResearchForProto:proto];
  if(userResearch) {
    return userResearch;
  }
  
  return [[UserResearch alloc] initWithResearch:proto];
}

- (id) initWithResearch:(ResearchProto *)proto {
  self.userResearchUuid = nil;
  self.researchId = proto.researchId;
  self.complete = NO;
  self.timeStarted = nil;
  return self;
}

- (id) initWithProto:(UserResearchProto *)proto {
  self.userResearchUuid = proto.userResearchUuid;
  self.researchId = proto.researchId;
  self.complete = proto.complete;
  self.timeStarted = [MSDate dateWithTimeIntervalSince1970:proto.timePurchased / 1000.];
  return self;
}

- (MSDate *)tentativeCompletionDate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int seconds = self.staticResearch.durationMin * 60;
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypePerformingResearch userDataUuid:self.userResearchUuid];
  if (numHelps > 0) {
    int secsToDockPerHelp = MAX(gl.researchClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.researchClanHelpConstants.percentRemovedPerHelp));
    seconds -= numHelps*secsToDockPerHelp;
  }
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypePerformingResearch userDataUuid:self.userResearchUuid earliestDate:self.timeStarted];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return [self.timeStarted dateByAddingTimeInterval:seconds];
}

- (void) updateForUserResearch:(UserResearch *)userResearch {
  self.userResearchUuid = self.userResearchUuid ? self.userResearchUuid : userResearch.userResearchUuid;
  self.researchId = userResearch.researchId;
  self.complete = userResearch.complete;
  self.timeStarted = userResearch.timeStarted;
}

- (BOOL) isResearching {
  return !self.complete && self.timeStarted;
}

- (ResearchProto *) staticResearch {
  GameState *gs = [GameState sharedGameState];
  return [gs researchWithId:self.researchId];
}

- (ResearchProto *) staticResearchForBenefitLevel {
  return self.complete ? self.staticResearch : self.staticResearch.predecessorResearch;
}

@end

@implementation ResearchUtil


- (id) initWithResearches:(NSArray *)researches {
  if((self = [super init])) {
    self.userResearches = [NSMutableArray array];
    for (UserResearchProto *urp in researches) {
      [self.userResearches addObject:[UserResearch userResearchWithProto:urp]];
    }
  }
  return self;
}

- (void) startResearch:(UserResearch *)userResearch {
  //update existing userResearch if another research of the same id exists
  for (UserResearch *ur in self.userResearches) {
    if (ur.userResearchUuid == userResearch.userResearchUuid) {
      [ur updateForUserResearch:userResearch];
      return;
    }
  }
  //add the new user research to the list
  [self.userResearches addObject:userResearch];
}

- (UserResearch *) researchForTimer {
  //to be used only for starting the gameState timer
  //returns potentially expired researches
  //with the goal of having the timer complete them
  for (UserResearch *ur in self.userResearches) {
    if (!ur.complete && ur.timeStarted) {
      return ur;
    }
  }
  return nil;
}

- (UserResearch *) currentResearch {
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

- (UserResearch *) userResearchForProto:(ResearchProto *)research {
  for (UserResearch *ur in self.userResearches) {
    if(ur.staticResearch.researchId == research.researchId) {
      return ur;
    }
  }
  return nil;
}

- (BOOL) prerequisiteFullfilledForResearch:(ResearchProto *)research {
  UserResearch *userResearch = [self userResearchForProto:research];
  UserResearch *curRank = [self currentRankForResearch:research];
  if (curRank.staticResearch.level > research.level) {
    return YES;
  } else if(curRank.staticResearch.level < research.level) {
    return NO;
  }
  if (userResearch) {
    return userResearch.complete;
  }
  return NO;
}

- (UserResearch *) currentRankForResearch:(ResearchProto *) research {
  UserResearch *result = [self findCurRankForResearch:[UserResearch userResearchWithResearch:[research minLevelResearch]]];
  return result ? result : [UserResearch userResearchWithResearch: [research minLevelResearch]];
}

- (UserResearch *) findCurRankForResearch:(UserResearch *) userResearch {
  ResearchProto *succesorResearch = [userResearch.staticResearch successorResearch];
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

- (void) cancelCurrentResearch {
  for (UserResearch *ur in self.userResearches) {
    if ([ur isResearching]) {
      NSString *userDataId = ur.userResearchUuid;
      [ur updateForUserResearch:[UserResearch userResearchWithResearch:[ur.staticResearch predecessorResearch]]];
      ur.timeStarted = nil;
      ur.complete = YES;
      ur.userResearchUuid = userDataId;
      _curResearch = nil;
      return;
    }
  }
}

#pragma mark - Hooks

- (float) percentageBenefitForType:(ResearchType)type element:(Element)element rarity:(Quality)rarity resType:(ResourceType)resType {
  float perc = 0.f;
  
  for (UserResearch *ur in self.userResearches) {
    ResearchProto *rp = ur.staticResearchForBenefitLevel;
    if (rp.researchType == type &&
        (!rp.hasElement || rp.element == element) &&
        (!rp.hasRarity || rp.rarity == rarity) &&
        (!rp.hasResourceType || rp.resourceType == resType)) {
      perc += rp.percentage;
    }
  }
  
  return perc;
}

- (float) percentageBenefitForType:(ResearchType)type {
  return [self percentageBenefitForType:type element:ElementNoElement rarity:QualityNoQuality resType:ResourceTypeNoResource];
}

- (float) percentageBenefitForType:(ResearchType)type element:(Element)element rarity:(Quality)rarity {
  return [self percentageBenefitForType:type element:element rarity:rarity resType:ResourceTypeNoResource];
}

- (float) percentageBenefitForType:(ResearchType)type resType:(ResourceType)resType {
  return [self percentageBenefitForType:type element:ElementNoElement rarity:QualityNoQuality resType:resType];
}

- (int) amountBenefitForType:(ResearchType)type element:(Element)element rarity:(Quality)rarity {
  int amt = 0;
  
  for (UserResearch *ur in self.userResearches) {
    ResearchProto *rp = ur.staticResearchForBenefitLevel;
    if (rp.researchType == type &&
        (!rp.hasElement || rp.element == element) &&
        (!rp.hasRarity || rp.rarity == rarity)) {
      amt += rp.amountIncrease;
    }
  }
  
  return amt;
}

- (int) amountBenefitForType:(ResearchType)type {
  return [self amountBenefitForType:type element:ElementNoElement rarity:QualityNoQuality];
}

- (BOOL) isMonsterType:(ResearchType)type {
  // List out all the types so if new ones get added they will not be forgotten here, i.e. no default.
  
  switch (type) {
    case ResearchTypeAttackIncrease:
    case ResearchTypeSpeedIncrease:
    case ResearchTypeHpIncrease:
    case ResearchTypeHealingCost:
    case ResearchTypeHealingSpeed:
    case ResearchTypeDecreaseEnhanceTime:
    case ResearchTypeEnhanceCost:
    case ResearchTypeXpBonus:
      return YES;
      
    case ResearchTypeIncreaseConstructionSpeed:
    case ResearchTypeIncreaseEnhanceQueue:
    case ResearchTypeIncreaseHospitalQueue:
    case ResearchTypeItemProductionCost:
    case ResearchTypeItemProductionSpeed:
    case ResearchTypeNoResearch:
    case ResearchTypeNumberOfHospitals:
    case ResearchTypeResourceProduction:
    case ResearchTypeResourceStorage:
    case ResearchTypeUnlockItem:
    case ResearchTypeUnlockObstacle:
      return NO;
  }
  return NO;
}

- (NSArray *) allUserResearchesForElement:(Element)element rarity:(Quality)rarity {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserResearch *ur in self.userResearches) {
    ResearchProto *rp = ur.staticResearchForBenefitLevel;
    if ([self isMonsterType:rp.researchType] &&
        (!rp.hasElement || rp.element == element) &&
        (!rp.hasRarity || rp.rarity == rarity)) {
      [arr addObject:ur];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserResearch *ur1, UserResearch *ur2) {
    ResearchProto *obj1 = ur1.staticResearch;
    ResearchProto *obj2 = ur2.staticResearch;
    if (obj1.researchType != obj2.researchType) {
      return [@(obj1.researchType) compare:@(obj2.researchType)];
    } else {
      return [@(obj1.tier) compare:@(obj2.tier)];
    }
  }];
  
  return arr;
}

- (NSArray *) allResearchProtosForElement:(Element)element rarity:(Quality)rarity {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *arr = [NSMutableArray array];
  for (ResearchProto *rp in gs.staticResearches.allValues) {
    if (!rp.predId &&
        [self isMonsterType:rp.researchType] &&
        (!rp.hasElement || rp.element == element) &&
        (!rp.hasRarity || rp.rarity == rarity)) {
      [arr addObject:rp];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(ResearchProto *obj1, ResearchProto *obj2) {
    if (obj1.researchType != obj2.researchType) {
      return [@(obj1.researchType) compare:@(obj2.researchType)];
    } else {
      return [@(obj1.tier) compare:@(obj2.tier)];
    }
  }];
  
  return arr;
}

@end

@implementation ResearchProto (prereqObject)

- (ResearchProto *) successorResearch {
  GameState *gs = [GameState sharedGameState];
  return self.succId ? [gs researchWithId:self.succId] : nil;
}

- (ResearchProto *) predecessorResearch {
  GameState *gs = [GameState sharedGameState];
  return self.predId ? [gs researchWithId:self.predId] : nil;
}

- (ResearchProto *) maxLevelResearch {
  if(self.succId) {
    return [[self successorResearch] maxLevelResearch];
  }
  return self;
}

- (ResearchProto *) minLevelResearch {
  if(self.predId) {
    return [[self predecessorResearch] minLevelResearch];
  }
  return self;
}

#pragma mark - Properties

- (float) hasProperty:(NSString *)p {
  for (ResearchPropertyProto *prop in self.propertiesList) {
    if ([prop.name isEqualToString:p]) {
      return YES;
    }
  }
  return NO;
}

- (float) valueForProperty:(NSString *)p {
  for (ResearchPropertyProto *prop in self.propertiesList) {
    if ([prop.name isEqualToString:p]) {
      return prop.researchValue;
    }
  }
  return 0.f;
}

- (Element) element {
  int val = [self valueForProperty:@"ELEMENT"];
  return (Element)val;
}

- (Quality) rarity {
  int val = [self valueForProperty:@"RARITY"];
  return (Quality)val;
}

- (ResourceType) resourceType {
  int val = [self valueForProperty:@"RESOURCE_TYPE"];
  return (ResourceType)val;
}

- (float) percentage {
  return [self valueForProperty:@"PERCENTAGE"];
}

- (int) amountIncrease {
  return (int)[self valueForProperty:@"AMOUNT_INCREASE"];
}

- (int) staticDataId {
  return (int)[self valueForProperty:@"STATIC_DATA_ID"];
}

- (BOOL) hasElement {
  return [self hasProperty:@"ELEMENT"];
}

- (BOOL) hasRarity {
  return [self hasProperty:@"RARITY"];
}

- (BOOL) hasResourceType {
  return [self hasProperty:@"RESOURCE_TYPE"];
}

- (BOOL) hasPercentage {
  return [self hasProperty:@"PERCENTAGE"];
}

- (BOOL) hasAmountIncrease {
  return [self hasProperty:@"AMOUNT_INCREASE"];
}

- (BOOL) hasStaticDataId {
  return [self hasProperty:@"STATIC_DATA_ID"];
}

- (NSArray *) fullResearchFamily {
  NSMutableArray *ar =[[NSMutableArray alloc] init];
  ResearchProto *research = [self minLevelResearch];
  [ar addObject:research];
  
  while (research.succId) {
    [ar addObject:[research successorResearch]];
    research = [research successorResearch];
  }
  return ar;
}

#pragma mark - Prereqs

- (BOOL) prereqsComplete {
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
