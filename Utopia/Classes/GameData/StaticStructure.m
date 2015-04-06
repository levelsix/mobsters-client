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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResourceGeneratorProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (ResourceGeneratorProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeWith:self.productionRate prevStat:nextStruct.productionRate suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeWith:self.capacity prevStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
  }
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResourceGeneratorProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (ResourceGeneratorProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeStringWith:self.productionRate nextStat:nextStruct.productionRate suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeStringWith:self.capacity nextStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  ResourceGeneratorProto *maxStruct = (ResourceGeneratorProto *)self.structInfo.maxStaticStruct;
  if (!index) {
    result = [self.structInfo barPercentWithNumerator:self.productionRate Denominator:maxStruct.productionRate useSqrt:NO usePow:NO];
  } else {
    result = [self.structInfo barPercentWithNumerator:self.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
  }
  
  
  return result;
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  ResourceGeneratorProto *maxStruct = (ResourceGeneratorProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    ResourceGeneratorProto *nextStruct = (ResourceGeneratorProto *)[gs structWithId:self.structInfo.successorStructId];
    if (!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.productionRate Denominator:maxStruct.productionRate useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResourceStorageProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (ResourceStorageProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.capacity prevStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResourceStorageProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (ResourceStorageProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.capacity nextStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  ResourceStorageProto *maxStruct = (ResourceStorageProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.capacity Denominator:maxStruct.capacity useSqrt:YES usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  ResourceStorageProto *maxStruct = (ResourceStorageProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    ResourceStorageProto *nextStruct = (ResourceStorageProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.capacity Denominator:maxStruct.capacity useSqrt:YES usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  HospitalProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (HospitalProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeWith:self.queueSize prevStat:nextStruct.queueSize suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeWith:self.secsToFullyHealMultiplier*100 prevStat:nextStruct.secsToFullyHealMultiplier*100 suffix:[self statSuffixForIndex:index]];
  }
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  HospitalProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (HospitalProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeStringWith:self.queueSize nextStat:nextStruct.queueSize suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeStringWith:self.secsToFullyHealMultiplier*100 nextStat:nextStruct.secsToFullyHealMultiplier*100 suffix:[self statSuffixForIndex:index]];
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  HospitalProto *maxStruct = (HospitalProto *)self.structInfo.maxStaticStruct;
  if (!index) {
    result = [self.structInfo barPercentWithNumerator:self.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
  } else {
    result = [self.structInfo barPercentWithNumerator:self.secsToFullyHealMultiplier*100 Denominator:maxStruct.secsToFullyHealMultiplier*100 useSqrt:NO usePow:NO];
  }
  
  
  return result;
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  HospitalProto *maxStruct = (HospitalProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    HospitalProto *nextStruct = (HospitalProto *)[gs structWithId:self.structInfo.successorStructId];
    if (!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.secsToFullyHealMultiplier*100 Denominator:maxStruct.secsToFullyHealMultiplier*100 useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResidenceProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (ResidenceProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.numMonsterSlots prevStat:nextStruct.numMonsterSlots suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResidenceProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (ResidenceProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.numMonsterSlots nextStat:nextStruct.numMonsterSlots suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  ResidenceProto *maxStruct = (ResidenceProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.numMonsterSlots Denominator:maxStruct.numMonsterSlots useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  ResidenceProto *maxStruct = (ResidenceProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    ResidenceProto *nextStruct = (ResidenceProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.numMonsterSlots Denominator:maxStruct.numMonsterSlots useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
}

@end

@implementation TownHallProto (StaticStructureImpl)

- (int) numBars { return 0; }
- (NSString *) statNameForIndex:(int)index { return @""; }
- (NSString *) statSuffixForIndex:(int)index { return @""; }
- (NSString *) shortStatChangeForIndex:(int)index {return @""; }
- (NSString *) longStatChangeForIndex:(int)index { return @""; }
- (float) curBarPercentForIndex:(int)index {return 0.f; }
- (float) nextBarPercentForIndex:(int)index {return 0.f; }

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  LabProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (LabProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeWith:self.queueSize prevStat:nextStruct.queueSize suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeWith:self.pointsMultiplier*100 prevStat:nextStruct.pointsMultiplier*100 suffix:[self statSuffixForIndex:index]];
  }
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  LabProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (LabProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeStringWith:self.queueSize nextStat:nextStruct.queueSize suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeStringWith:self.pointsMultiplier*100 nextStat:nextStruct.pointsMultiplier*100 suffix:[self statSuffixForIndex:index]];
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  LabProto *maxStruct = (LabProto *)self.structInfo.maxStaticStruct;
  if (!index) {
    result = [self.structInfo barPercentWithNumerator:self.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
  } else {
    result = [self.structInfo barPercentWithNumerator:self.pointsMultiplier*100 Denominator:maxStruct.pointsMultiplier*100 useSqrt:NO usePow:NO];
  }
  
  
  return result;
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  LabProto *maxStruct = (LabProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    LabProto *nextStruct = (LabProto *)[gs structWithId:self.structInfo.successorStructId];
    if (!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.pointsMultiplier*100 Denominator:maxStruct.pointsMultiplier*100 useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
}

@end

@implementation EvoChamberProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  
  EvoChamberProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (EvoChamberProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  
  return [NSString stringWithFormat:@"%@ Evo %d", [Globals stringForRarity:nextStruct.qualityUnlocked], nextStruct.evoTierUnlocked];
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
}

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  EvoChamberProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (EvoChamberProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.structInfo.level prevStat:nextStruct.structInfo.level suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  EvoChamberProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (EvoChamberProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.structInfo.level nextStat:nextStruct.structInfo.level suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  EvoChamberProto *maxStruct = (EvoChamberProto *)self.structInfo.maxStaticStruct;
  result = [self.structInfo barPercentWithNumerator:self.structInfo.level Denominator:maxStruct.structInfo.level useSqrt:NO usePow:NO];
  
  
  return result;
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  EvoChamberProto *maxStruct = (EvoChamberProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    EvoChamberProto *nextStruct = (EvoChamberProto *)[gs structWithId:self.structInfo.successorStructId];
      result = [self.structInfo barPercentWithNumerator:nextStruct.structInfo.level Denominator:maxStruct.structInfo.level useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  MiniJobCenterProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (MiniJobCenterProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.structInfo.level prevStat:nextStruct.structInfo.level suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  MiniJobCenterProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (MiniJobCenterProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.structInfo.level nextStat:nextStruct.structInfo.level suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  MiniJobCenterProto *maxStruct = (MiniJobCenterProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.structInfo.level Denominator:maxStruct.structInfo.level useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  MiniJobCenterProto *maxStruct = (MiniJobCenterProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    MiniJobCenterProto *nextStruct = (MiniJobCenterProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.structInfo.level Denominator:maxStruct.structInfo.level useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  MoneyTreeProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (MoneyTreeProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeWith:self.productionRate*24 prevStat:nextStruct.productionRate*24 suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeWith:self.capacity prevStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
  }
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  MoneyTreeProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (MoneyTreeProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeStringWith:self.productionRate*24 nextStat:nextStruct.productionRate*24 suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeStringWith:self.capacity nextStat:nextStruct.capacity suffix:[self statSuffixForIndex:index]];
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  MoneyTreeProto *maxStruct = (MoneyTreeProto *)self.structInfo.maxStaticStruct;
  if (!index) {
    result = [self.structInfo barPercentWithNumerator:self.productionRate*24 Denominator:maxStruct.productionRate*24 useSqrt:NO usePow:NO];
  } else {
    result = [self.structInfo barPercentWithNumerator:self.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
  }
  
  
  return result;
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  MoneyTreeProto *maxStruct = (MoneyTreeProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    MoneyTreeProto *nextStruct = (MoneyTreeProto *)[gs structWithId:self.structInfo.successorStructId];
    if (!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.productionRate*24 Denominator:maxStruct.productionRate*24 useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  PvpBoardHouseProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (PvpBoardHouseProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.pvpBoardPowerLimit prevStat:nextStruct.pvpBoardPowerLimit suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  PvpBoardHouseProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (PvpBoardHouseProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.pvpBoardPowerLimit nextStat:nextStruct.pvpBoardPowerLimit suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  PvpBoardHouseProto *maxStruct = (PvpBoardHouseProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.pvpBoardPowerLimit Denominator:maxStruct.pvpBoardPowerLimit useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  PvpBoardHouseProto *maxStruct = (PvpBoardHouseProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    PvpBoardHouseProto *nextStruct = (PvpBoardHouseProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.pvpBoardPowerLimit Denominator:maxStruct.pvpBoardPowerLimit useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  BattleItemFactoryProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (BattleItemFactoryProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.powerLimit prevStat:nextStruct.powerLimit suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  BattleItemFactoryProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (BattleItemFactoryProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.powerLimit nextStat:nextStruct.powerLimit suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  BattleItemFactoryProto *maxStruct = (BattleItemFactoryProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.powerLimit Denominator:maxStruct.powerLimit useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  BattleItemFactoryProto *maxStruct = (BattleItemFactoryProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    BattleItemFactoryProto *nextStruct = (BattleItemFactoryProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.powerLimit Denominator:maxStruct.powerLimit useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ClanHouseProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (ClanHouseProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeWith:self.maxHelpersPerSolicitation prevStat:nextStruct.maxHelpersPerSolicitation suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeWith:self.teamDonationPowerLimit prevStat:nextStruct.teamDonationPowerLimit suffix:[self statSuffixForIndex:index]];
  }
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ClanHouseProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (ClanHouseProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  if (!index) {
    return [self.structInfo statChangeStringWith:self.maxHelpersPerSolicitation nextStat:nextStruct.maxHelpersPerSolicitation suffix:[self statSuffixForIndex:index]];
  } else {
    return [self.structInfo statChangeStringWith:self.teamDonationPowerLimit nextStat:nextStruct.teamDonationPowerLimit suffix:[self statSuffixForIndex:index]];
  }
}

- (float) curBarPercentForIndex:(int)index {
  ClanHouseProto *maxStruct = (ClanHouseProto *)self.structInfo.maxStaticStruct;
  if (!index) {
    return [self.structInfo barPercentWithNumerator:self.maxHelpersPerSolicitation Denominator:maxStruct.maxHelpersPerSolicitation useSqrt:NO usePow:NO];
  } else {
    return [self.structInfo barPercentWithNumerator:self.teamDonationPowerLimit Denominator:maxStruct.teamDonationPowerLimit useSqrt:NO usePow:NO];
  }
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  ClanHouseProto *maxStruct = (ClanHouseProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    ClanHouseProto *nextStruct = (ClanHouseProto *)[gs structWithId:self.structInfo.successorStructId];
    if (!index) {
      return [self.structInfo barPercentWithNumerator:nextStruct.maxHelpersPerSolicitation Denominator:maxStruct.maxHelpersPerSolicitation useSqrt:NO usePow:NO];
    } else {
      return [self.structInfo barPercentWithNumerator:nextStruct.teamDonationPowerLimit Denominator:maxStruct.teamDonationPowerLimit useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  TeamCenterProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (TeamCenterProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.teamCostLimit prevStat:nextStruct.teamCostLimit suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  TeamCenterProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (TeamCenterProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.teamCostLimit nextStat:nextStruct.teamCostLimit suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  TeamCenterProto *maxStruct = (TeamCenterProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.teamCostLimit Denominator:maxStruct.teamCostLimit useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  TeamCenterProto *maxStruct = (TeamCenterProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    TeamCenterProto *nextStruct = (TeamCenterProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.teamCostLimit Denominator:maxStruct.teamCostLimit useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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

- (NSString *) shortStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResearchHouseProto *nextStruct;
  if (self.structInfo.predecessorStructId) {
    nextStruct = (ResearchHouseProto *)[gs structWithId:self.structInfo.predecessorStructId];
  }
  return [self.structInfo statChangeWith:self.researchSpeedMultiplier*100 prevStat:nextStruct.researchSpeedMultiplier*100 suffix:[self statSuffixForIndex:index]];
}

- (NSString *) longStatChangeForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  ResearchHouseProto *nextStruct;
  if (self.structInfo.successorStructId) {
    nextStruct = (ResearchHouseProto *)[gs structWithId:self.structInfo.successorStructId];
  }
  return [self.structInfo statChangeStringWith:self.researchSpeedMultiplier*100 nextStat:nextStruct.researchSpeedMultiplier*100 suffix:[self statSuffixForIndex:index]];
}

- (float) curBarPercentForIndex:(int)index {
  ResearchHouseProto *maxStruct = (ResearchHouseProto *)self.structInfo.maxStaticStruct;
  return [self.structInfo barPercentWithNumerator:self.researchSpeedMultiplier*100 Denominator:maxStruct.researchSpeedMultiplier*100 useSqrt:NO usePow:NO];
}

- (float) nextBarPercentForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  float result = 0.f;
  
  ResearchHouseProto *maxStruct = (ResearchHouseProto *)self.structInfo.maxStaticStruct;
  if (self.structInfo.successorStructId) {
    ResearchHouseProto *nextStruct = (ResearchHouseProto *)[gs structWithId:self.structInfo.successorStructId];
    return [self.structInfo barPercentWithNumerator:nextStruct.researchSpeedMultiplier*100 Denominator:maxStruct.researchSpeedMultiplier*100 useSqrt:NO usePow:NO];
  }
  
  return result;
}

- (int) strength {
  GameState *gs = [GameState sharedGameState];
  
  if (self.structInfo.successorStructId) {
    id<StaticStructure> successor = [gs structWithId:self.structInfo.successorStructId];
    return successor.structInfo.strength - self.structInfo.strength;
  } else {
    return self.structInfo.strength;
  }
}

- (NSArray *) prereqs {
  return self.structInfo.prereqs;
}

- (int) rank {
  return self.structInfo.level;
}

- (int) totalRanks {
  return self.structInfo.maxStaticStruct.structInfo.level;
}

- (NSString *) name {
  return self.structInfo.name;
}

- (id<GameTypeProto>) predecessor {
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.predecessorStructId) {
    return [gs structWithId:self.structInfo.predecessorStructId];
  } else {
    return nil;
  }
}

- (id<GameTypeProto>) successor{
  GameState *gs = [GameState sharedGameState];
  if (self.structInfo.successorStructId) {
    return [gs structWithId:self.structInfo.successorStructId];
  } else {
    return nil;
  }
}

- (NSArray *) fullFamilyList {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  int curId = [gl baseStructIdForStructId:self.structInfo.structId];
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
}

@end

@implementation  StructureInfoProto (StaticStructure)

- (id<StaticStructure>) maxStaticStruct {
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = [gs structWithId:self.structId];
  while (ss.structInfo.successorStructId) {
    ss = [gs structWithId:ss.structInfo.successorStructId];
  }
  return ss;
}

//this could be static but I don't see the point
- (float) barPercentWithNumerator:(float)num Denominator:(float)denom useSqrt:(BOOL)useSqrt usePow:(BOOL)usePow {
  float sqrtVal = 0.75;
  float sqPowVal = 1.5;
  
  float powVal = useSqrt ? sqrtVal : usePow ? sqPowVal : 1;
  if (powVal) {
    return powf(num/denom, powVal);
  } else {
    return num/denom;
  }
}

- (NSArray *) prereqs {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [gs prerequisitesForGameType:GameTypeStructure gameEntityId:successorStructId];
  
  arr = [arr sortedArrayUsingComparator:^NSComparisonResult(PrereqProto *obj1, PrereqProto *obj2) {
    return [@(obj1.prereqId) compare:@(obj2.prereqId)];
  }];
  
  return arr;
}

- (NSString *) statChangeWith:(float)curStat prevStat:(float)prevStat suffix:(NSString *)suffix{
  if (prevStat) {
    return [NSString stringWithFormat:@"+%@%@", [Globals commafyNumber: curStat - prevStat], suffix];
  } else {
    return [NSString stringWithFormat:@"+%@", [Globals commafyNumber:curStat]];
  }
}

- (NSString *) statChangeStringWith:(float)curStat nextStat:(float)nextStat suffix:(NSString *)suffix{
  if (nextStat) {
    return [NSString stringWithFormat:@"%@ + %@%@", [Globals commafyNumber:curStat], [Globals commafyNumber:nextStat - curStat], suffix];
  } else {
    return [NSString stringWithFormat:@"%@%@", [Globals commafyNumber:curStat], suffix];
  }
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
