//
//  StaticStructure.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "StaticStructure.h"
#import "Protocols.pb.h"
#import "GameState.h"
#import "UserData.h"

@implementation ResourceGeneratorProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if (!index) {
    return @"Rate";
  } else {
    return @"Capacity";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @" Per Hour";
  } else {
    return @"";
  }
}

- (float) statValueForIndex:(int)index {
  if (!index) {
    return self.productionRate;
  } else {
    return self.capacity;
  }
}

- (float) statValueWithResearchBonusForIndex:(int)index {
  if (!index) {
    UserStruct *us = [[UserStruct alloc] init];
    us.structId = self.structInfo.structId;
    us.isComplete = YES;
    return us.productionRate;
  } else {
    return self.capacity;
  }
}

@end

@implementation MoneyTreeProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if (!index) {
    return @"Rate";
  } else {
    return @"Capacity";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @" Per Day";
  } else {
    return @"";
  }
}

- (float) statValueForIndex:(int)index {
  if (!index) {
    return self.productionRate*24;
  } else {
    return self.capacity;
  }
}

- (float) statValueWithResearchBonusForIndex:(int)index {
  if (!index) {
    UserStruct *us = [[UserStruct alloc] init];
    us.structId = self.structInfo.structId;
    us.isComplete = YES;
    return us.productionRate*24;
  } else {
    return self.capacity;
  }
}

@end

@implementation ResourceStorageProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Capacity";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.capacity;
}

- (float) statValueWithResearchBonusForIndex:(int)index {
  UserStruct *us = [[UserStruct alloc] init];
  us.structId = self.structInfo.structId;
  us.isComplete = YES;
  return us.storageCapacity;
}

- (BOOL) useSqrtForIndex:(int)index {
  return YES;
}

@end

@implementation HospitalProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if (!index) {
    return @"Queue Size";
  } else {
    return @"Heal Speed";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @"";
  } else {
    return @"%";
  }
}

- (float) statValueForIndex:(int)index {
  if (!index) {
    return self.queueSize;
  } else {
    return self.secsToFullyHealMultiplier*100;
  }
}

@end

@implementation ResidenceProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Slots";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.numMonsterSlots;
}

@end

@implementation TownHallProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Res. Capacity";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.resourceCapacity;
}

@end

@implementation LabProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if (!index) {
    return @"Queue Size";
  } else {
    return @"Multiplier";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @"";
  } else {
    return @"%";
  }
}

- (float) statValueForIndex:(int)index {
  if (!index) {
    return self.queueSize;
  } else {
    return self.pointsMultiplier*100;
  }
}

@end

@implementation EvoChamberProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Unlocks";
}

- (NSString *) statChangeStringForIndex:(int)index {
  return [NSString stringWithFormat:@"%@ Evo %d", [Globals stringForRarity:self.qualityUnlocked], self.evoTierUnlocked];
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.structInfo.level;
}

@end

@implementation MiniJobCenterProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Reward Tiers";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.structInfo.level;
}

@end

@implementation PvpBoardHouseProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Power Limit";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.pvpBoardPowerLimit;
}

@end

@implementation BattleItemFactoryProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Power Limit";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.powerLimit;
}

@end

@implementation ClanHouseProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if (!index) {
    return @"Help Limit";
  } else {
    return @"Donate Pwer";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  if (!index) {
    return self.maxHelpersPerSolicitation;
  } else {
    return self.teamDonationPowerLimit;
  }
}

@end

@implementation TeamCenterProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Power Limit";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (float) statValueForIndex:(int)index {
  return self.teamCostLimit;
}

@end

@implementation ResearchHouseProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Research Speed";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"%";
}

- (float) statValueForIndex:(int)index {
  return roundf(self.researchSpeedMultiplier*100);
}

@end

@implementation  StructureInfoProto (StaticStructure)

//this could be static but I don't see the point
- (float) barPercentWithNumerator:(float)num denominator:(float)denom useSqrt:(BOOL)useSqrt usePow:(BOOL)usePow {
  float sqrtVal = 0.75;
  float sqPowVal = 1.5;
  
  float powVal = useSqrt ? sqrtVal : usePow ? sqPowVal : 1;
  if (powVal) {
    return powf(num/denom, powVal);
  } else {
    return num/denom;
  }
}

- (NSString *) statChangeWith:(float)curStat prevStat:(float)prevStat suffix:(NSString *)suffix{
  if (prevStat) {
    return [NSString stringWithFormat:@"+%@%@", [Globals commafyNumber: curStat - prevStat], suffix];
  } else {
    return [NSString stringWithFormat:@"+%@%@", [Globals commafyNumber:curStat], suffix];
  }
}

- (NSString *) statChangeStringWith:(float)curStat nextStat:(float)nextStat suffix:(NSString *)suffix{
  if (nextStat) {
    return [NSString stringWithFormat:@"%@ + %@%@", [Globals commafyNumber:curStat], [Globals commafyNumber:nextStat - curStat], suffix];
  } else {
    return [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curStat], suffix];
  }
}

#pragma mark - Game Type Protocol

- (id<StaticStructure>) staticStruct {
  GameState *gs = [GameState sharedGameState];
  return [gs structWithId:self.structId];
}

- (StructureInfoProto *) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.predecessorStructId) {
    return [[gs structWithId:self.predecessorStructId] structInfo];
  } else {
    return nil;
  }
}

- (StructureInfoProto *) successor {
  GameState *gs = [GameState sharedGameState];
  if (self.successorStructId) {
    return [[gs structWithId:self.successorStructId] structInfo];
  } else {
    return nil;
  }
}

- (StructureInfoProto *) maxStructInfo {
  StructureInfoProto *succ = self;
  id temp;
  
  while ((temp = [succ successor])) {
    succ = temp;
  }
  
  return succ;
}

- (int) numBars {
  return [self.staticStruct numBars];
}

- (NSString *) statNameForIndex:(int)index {
  return [self.staticStruct statNameForIndex:index];
}

- (NSString *) statSuffixForIndex:(int)index {
  return [self.staticStruct statSuffixForIndex:index];
}

- (NSString *) shortStatChangeForIndex:(int)index {
  id<StaticStructure> curStruct = [self staticStruct];
  id<StaticStructure> prevStruct = [(StructureInfoProto *)[self predecessor] staticStruct];
  
  // Use cur since we want what is being unlocked by this
  if ([curStruct respondsToSelector:@selector(statChangeStringForIndex:)]) {
    return [curStruct statChangeStringForIndex:index];
  }
  
  float curValue = [curStruct statValueForIndex:index];
  float nextValue = [prevStruct statValueForIndex:index];
  return [self statChangeWith:curValue prevStat:nextValue suffix:[curStruct statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  id<StaticStructure> curStruct = [self staticStruct];
  id<StaticStructure> nextStruct = [(StructureInfoProto *)[self successor] staticStruct];
  
  // Use next since we want what is going to be unlocked
  if ([nextStruct respondsToSelector:@selector(statChangeStringForIndex:)]) {
    return [nextStruct statChangeStringForIndex:index];
  }
  
  float curValue = [curStruct respondsToSelector:@selector(statValueWithResearchBonusForIndex:)] ? [curStruct statValueWithResearchBonusForIndex:index] : [curStruct statValueForIndex:index];
  float nextValue = [nextStruct respondsToSelector:@selector(statValueWithResearchBonusForIndex:)] ? [nextStruct statValueWithResearchBonusForIndex:index] : [nextStruct statValueForIndex:index];
  return [self statChangeStringWith:curValue nextStat:nextValue suffix:[self statSuffixForIndex:index]];
}

- (float) barPercentForIndex:(int)index {
  id<StaticStructure> curStruct = [self staticStruct];
  id<StaticStructure> maxStruct = [[self maxStructInfo] staticStruct];
  
  float curValue = [curStruct statValueForIndex:index];
  float maxValue = [maxStruct statValueForIndex:index];
  
  BOOL usePow = [curStruct respondsToSelector:@selector(usePowForIndex:)] ? [curStruct usePowForIndex:index] : NO;
  BOOL useSqrt = [curStruct respondsToSelector:@selector(useSqrtForIndex:)] ? [curStruct useSqrtForIndex:index] : NO;
  
  return [self barPercentWithNumerator:curValue denominator:maxValue useSqrt:useSqrt usePow:usePow];
}

- (int) strengthGainForNextLevel {
  StructureInfoProto *successor = [self successor];
  if (successor) {
    return successor.strength - self.strength;
  } else {
    return self.strength;
  }
}

- (int) strengthGainForCurrentLevel {
  StructureInfoProto *predecessor = [self predecessor];
  return self.strength - predecessor.strength;
}

- (NSArray *) prereqs {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [gs prerequisitesForGameType:GameTypeStructure gameEntityId:self.successorStructId];
  
  arr = [arr sortedArrayUsingComparator:^NSComparisonResult(PrereqProto *obj1, PrereqProto *obj2) {
    return [@(obj1.prereqId) compare:@(obj2.prereqId)];
  }];
  
  return arr;
}

- (int) rank {
  return self.level;
}

- (int) totalRanks {
  return self.maxStructInfo.level;
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structId];
  while (curId) {
    StructureInfoProto *ss = [[gs structWithId:curId] structInfo];
    
    // Don't do the level 0 ones since those are fixing the building
    if (ss.level > 0) {
      [arr addObject:ss];
    }
    
    curId = ss.successorStructId;
  }
  
  return arr;
}

@end


@implementation PrereqProto (Stringify)

- (NSString *) prereqString {
  GameState *gs = [GameState sharedGameState];
  if (self.prereqGameType == GameTypeStructure) {
    id<StaticStructure> ss = [gs structWithId:self.prereqGameEntityId];
    StructureInfoProto *sip = [ss structInfo];
    
    NSString *quant = self.quantity <= 1 ? @"" : [NSString stringWithFormat:@"%d ", self.quantity];
    NSString *lvl = [NSString stringWithFormat:@"LVL %d ", sip.level];
    NSString *name = [NSString stringWithFormat:@"%@%@", sip.name, self.quantity == 1 ? @"" : @"s"];
    
    return [NSString stringWithFormat:@"%@%@%@", quant, lvl, name];
    
  } else if (self.prereqGameType == GameTypeTask) {
    TaskMapElementProto *elem = [gs mapElementWithTaskId:self.prereqGameEntityId];
    return [NSString stringWithFormat:@"Defeat Level %d", elem.mapElementId];
    
  } else if (self.prereqGameType == GameTypeResearch) {
    ResearchProto *research = [gs researchWithId:self.prereqGameEntityId];
    NSString *lvl = research.predId || research.succId ? [NSString stringWithFormat:@"Rank %d", research.level] : @"";
    return [NSString stringWithFormat:@"%@ %@",research.name, lvl];
    
  }
  return nil;
}

@end
