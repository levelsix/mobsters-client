//
//  ResearchUtil.m
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchUtil.h"
#import "GameState.h"
#import "ResearchController.h"

@implementation UserResearch

+ (id) userResearchWithProto:(UserResearchProto *)proto {
  return [[UserResearch alloc] initWithProto:proto];
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
  
  int seconds = [gl calculateSecondsToResearch:self.staticResearch];
  
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

- (ResearchProto *) staticResearch {
  GameState *gs = [GameState sharedGameState];
  return self.fakeResearch ?: [gs researchWithId:self.researchId];
}

- (ResearchProto *) staticResearchForNextLevel {
  return self.staticResearchForBenefitLevel.successorResearch;
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

- (UserResearch *) currentResearch {
  for (UserResearch *ur in self.userResearches) {
    if (!ur.complete) {
      return ur;
    }
  }
  return nil;
}

- (UserResearch *) userResearchForProto:(ResearchProto *)research {
  for (UserResearch *ur in self.userResearches) {
    if (ur.staticResearch.researchId == research.researchId) {
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
  for (ResearchProto *rp in research.fullResearchFamily) {
    UserResearch *ur = [self userResearchForProto:rp];
    if (ur) {
      return ur;
    }
  }
  
  // Create a fake zero level one
  UserResearch *ur = [[UserResearch alloc] init];
  ur.fakeResearch = [research fakeRankZeroResearch];
  ur.complete = YES;
  
  return ur;
}

- (void) cancelCurrentResearch {
  for (UserResearch *ur in self.userResearches) {
    if (!ur.complete) {
      ur.timeStarted = nil;
      ur.complete = YES;
      ur.researchId = ur.staticResearch.predId;
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

@implementation ResearchProto (PrereqObject)

- (ResearchProto *) successorResearch {
  GameState *gs = [GameState sharedGameState];
  return self.succId ? [gs researchWithId:self.succId] : nil;
}

- (ResearchProto *) predecessorResearch {
  GameState *gs = [GameState sharedGameState];
  return self.predId ? [gs researchWithId:self.predId] : self.fakeRankZeroResearch;
}

- (ResearchProto *) maxLevelResearch {
  if(self.succId) {
    return [[self successorResearch] maxLevelResearch];
  }
  return self;
}

- (ResearchProto *) minLevelResearch {
  if (self.predId) {
    return [[self predecessorResearch] minLevelResearch];
  }
  return self;
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

- (ResearchProto *) fakeRankZeroResearch {
  ResearchProto_Builder *bldr = [ResearchProto builder];
  bldr.succId = self.minLevelResearch.researchId;
  bldr.name = self.name;
  bldr.level = 0;
  bldr.desc = self.desc;
  bldr.iconImgName = self.iconImgName;
  bldr.name = self.name;
  bldr.priority = self.priority;
  bldr.tier = self.tier;
  bldr.researchDomain = self.researchDomain;
  bldr.researchType = self.researchType;
  
  // Make its predId the min one as well so that this guy's minLevelResearch returns the right one.
  // Hopefully this won't cause other issues..
  bldr.predId = self.minLevelResearch.researchId;
  
  return bldr.build;
}

#pragma mark - Game Type Protocol

- (ResearchController *) researchController {
  return [ResearchController researchControllerWithProto:self];
}

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  ResearchController *rc = [self researchController];
  return [rc benefitName];
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (NSString *) shortStatChangeForIndex:(int)index {
  ResearchController *rc = [self researchController];
  return [rc shortImprovementString];
}

- (NSString *) longStatChangeForIndex:(int)index {
  ResearchController *rc = self.succId ? [[self successorResearch] researchController] : [self researchController];
  return [rc longImprovementString];
}

- (float) barPercentForIndex:(int)index {
  ResearchController *rc = [self researchController];
  return [rc curPercent];
}

- (int) strengthGain {
  ResearchProto *successor = [self successorResearch];
  if (successor) {
    return successor.strength - self.strength;
  } else {
    return self.strength;
  }
}

- (NSArray *) prereqs {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:self.predId];
  
  arr = [arr sortedArrayUsingComparator:^NSComparisonResult(PrereqProto *obj1, PrereqProto *obj2) {
    return [@(obj1.prereqId) compare:@(obj2.prereqId)];
  }];
  
  return arr;
}

- (int) rank {
  return self.level;
}

- (int) totalRanks {
  return self.maxLevelResearch.level;
}

- (id<GameTypeProtocol>) predecessor {
  return [self predecessorResearch];
}

- (id<GameTypeProtocol>) successor {
  return [self successorResearch];
}

- (NSArray *) fullFamilyList {
  return [self fullResearchFamily];
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

#pragma mark - Prereqs

- (BOOL) prereqsComplete {
  return [self numIncompletePrereqs] == 0;
}

- (int) numIncompletePrereqs {
  Globals *gl = [Globals sharedGlobals];
  int num = 0;
  for (PrereqProto *pp in [self prereqs]) {
    if(![gl isPrerequisiteComplete:pp]) {
      num++;
    }
  }
  return num;
}

@end
