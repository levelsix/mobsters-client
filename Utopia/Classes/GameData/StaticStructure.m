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
    return @"Rate:";
  } else {
    return @"Capacity:";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @" Per Hour";
  } else {
    return @"";
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  ResourceGeneratorProto *maxStruct = (ResourceGeneratorProto *)self.structInfo.maxStaticStruct;
  if(!index) {
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
    if(!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.productionRate Denominator:maxStruct.productionRate useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation ResourceStorageProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Capacity:";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
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

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation HospitalProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if(!index) {
    return @"Queue Size:";
  } else {
    return @"Heal Speed:";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if(!index) {
    return @"";
  } else {
    return @"%";
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  HospitalProto *maxStruct = (HospitalProto *)self.structInfo.maxStaticStruct;
  if(!index) {
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
    if(!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.secsToFullyHealMultiplier*100 Denominator:maxStruct.secsToFullyHealMultiplier*100 useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation ResidenceProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Slots:";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
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

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation TownHallProto (StaticStructureImpl)

- (int) numBars { return 0; }
- (NSString *) statNameForIndex:(int)index { return @""; }
- (NSString *) statSuffixForIndex:(int)index { return @""; }
- (float) curBarPercentForIndex:(int)index {return 0.f; }
- (float) nextBarPercentForIndex:(int)index {return 0.f; }

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation LabProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if(!index) {
    return @"Queue Size:";
  } else {
    return @"Multiplier:";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @"";
  } else {
    return @"%";
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  LabProto *maxStruct = (LabProto *)self.structInfo.maxStaticStruct;
  if(!index) {
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
    if(!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.queueSize Denominator:maxStruct.queueSize useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.pointsMultiplier*100 Denominator:maxStruct.pointsMultiplier*100 useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation MiniJobCenterProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Reward Tiers:";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
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

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation MoneyTreeProto (StaticStructureImpl)

- (int) numBars {
  return 2;
}

- (NSString *) statNameForIndex:(int)index {
  if(!index) {
    return @"Rate:";
  } else {
    return @"Capacity:";
  }
}

- (NSString *) statSuffixForIndex:(int)index {
  if (!index) {
    return @" Per Day";
  } else {
    return @"";
  }
}

- (float) curBarPercentForIndex:(int)index {
  float result = 0.f;
  
  MoneyTreeProto *maxStruct = (MoneyTreeProto *)self.structInfo.maxStaticStruct;
  if(!index) {
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
    if(!index) {
      result = [self.structInfo barPercentWithNumerator:nextStruct.productionRate*24 Denominator:maxStruct.productionRate*24 useSqrt:NO usePow:NO];
    } else {
      result = [self.structInfo barPercentWithNumerator:nextStruct.capacity Denominator:maxStruct.capacity useSqrt:NO usePow:NO];
    }
  }
  
  return result;
}

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation PvpBoardHouseProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Power Limit:";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
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

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
}

@end

@implementation BattleItemFactoryProto (StaticStructureImpl)

- (int) numBars {
  return 1;
}

- (NSString *) statNameForIndex:(int)index {
  return @"Power Limit:";
}

- (NSString *) statSuffixForIndex:(int)index {
  return @"";
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

- (int) numPrereqs {
  return [self.structInfo numPrereqs];
}

- (PrereqProto *) prereqForIndex:(int)index {
  return [self.structInfo prereqForIndex:index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  return [self.structInfo prereqCompleteForIndex:index];
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

//could be static
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

- (int) numPrereqs {
  GameState *gs = [GameState sharedGameState];
  return (int)[gs prerequisitesForGameType:GameTypeStructure gameEntityId:self.structId].count;
}

- (PrereqProto *) prereqForIndex:(int)index {
  GameState *gs = [GameState sharedGameState];
  return [gs prerequisitesForGameType:GameTypeStructure gameEntityId:self.structId][index];
}

- (BOOL) prereqCompleteForIndex:(int)index {
  Globals *gl = [Globals sharedGlobals];
  PrereqProto *prereq = [self prereqForIndex:index];
  return [gl isPrerequisiteComplete:prereq];
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
