//
//  ResearchController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchController.h"
#import "ResearchUtil.h"
#import "GameState.h"
#import "Globals.h"

@implementation ResearchController

+ (id) researchControllerWithProto:(ResearchProto *)proto {
  switch (proto.researchType) {
    case ResearchTypeHealingCost:
    case ResearchTypeHealingSpeed:
    case ResearchTypeEnhanceCost:
    case ResearchTypeDecreaseEnhanceTime:
    case ResearchTypeXpBonus:
    case ResearchTypeAttackIncrease:
    case ResearchTypeHpIncrease:
    case ResearchTypeIncreaseConstructionSpeed:
    case ResearchTypeItemProductionCost:
    case ResearchTypeItemProductionSpeed:
    case ResearchTypeResourceProduction:
    case ResearchTypeResourceStorage:
    case ResearchTypeResourceGeneratorStorage:
      return [[ResearchPercentController alloc] initWithProto:proto];
      
    case ResearchTypeSpeedIncrease:
    case ResearchTypeIncreaseEnhanceQueue:
    case ResearchTypeIncreaseHospitalQueue:
    case ResearchTypeNumberOfHospitals:
      return [[ResearchUnitController alloc] initWithProto:proto];
      
    case ResearchTypeUnlockItem:
    case ResearchTypeUnlockObstacle:
      return [[ResearchUnlockController alloc] initWithProto:proto];
      
    case ResearchTypeNoResearch:
      return nil;
  }
  return nil;
}

- (id) initWithProto:(ResearchProto *)proto {
  if ((self = [super init])) {
    _research = proto;
  }
  return self;
}

- (NSString *) benefitName {
  
  switch (_research.researchType) {
    case ResearchTypeHealingCost:
      return @"Cash Discount";
    case ResearchTypeHealingSpeed:
      return @"Healing Speed";
    case ResearchTypeEnhanceCost:
      return @"Oil Discount";
    case ResearchTypeDecreaseEnhanceTime:
      return @"Enhance Speed";
    case ResearchTypeXpBonus:
      return @"Enhance Xp";
    case ResearchTypeAttackIncrease:
      return @"Attack";
    case ResearchTypeHpIncrease:
      return @"HP";
    case ResearchTypeIncreaseConstructionSpeed:
      return @"Builder Speed";
    case ResearchTypeItemProductionCost:
      return @"Cost Discount";
    case ResearchTypeItemProductionSpeed:
      return @"Creation Speed";
    case ResearchTypeResourceProduction:
      return @"Production";
    case ResearchTypeResourceStorage:
    case ResearchTypeResourceGeneratorStorage:
      return [NSString stringWithFormat:@"%@ Storage", _research.resourceType == ResourceTypeCash ? @"Cash" : @"Oil"];
      
    case ResearchTypeSpeedIncrease:
      return @"Speed";
    case ResearchTypeIncreaseEnhanceQueue:
    case ResearchTypeIncreaseHospitalQueue:
      return @"Bonus Slots";
    case ResearchTypeNumberOfHospitals:
      return @"Bonus Hospitals";
      
    case ResearchTypeUnlockItem:
    case ResearchTypeUnlockObstacle:
      return @"Unlocks";
      
    case ResearchTypeNoResearch:
      return nil;
  }
}

- (NSString *) suffix {
  
  switch (_research.researchType) {
    case ResearchTypeHealingCost:
    case ResearchTypeHealingSpeed:
    case ResearchTypeEnhanceCost:
    case ResearchTypeDecreaseEnhanceTime:
    case ResearchTypeIncreaseConstructionSpeed:
    case ResearchTypeResourceProduction:
    case ResearchTypeItemProductionCost:
    case ResearchTypeItemProductionSpeed:
      return @"Boost";
      
    case ResearchTypeXpBonus:
    case ResearchTypeAttackIncrease:
    case ResearchTypeHpIncrease:
    case ResearchTypeResourceStorage:
    case ResearchTypeResourceGeneratorStorage:
      return @"Increase";
      
    case ResearchTypeSpeedIncrease:
      return @"Bonus Speed";
      
    case ResearchTypeIncreaseEnhanceQueue:
    case ResearchTypeIncreaseHospitalQueue:
    case ResearchTypeNumberOfHospitals:
    case ResearchTypeUnlockItem:
    case ResearchTypeUnlockObstacle:
      return @"";
      
    case ResearchTypeNoResearch:
      return nil;
  }
}

- (NSString *) longImprovementString{ return @""; }
- (NSString *) shortImprovementString{ return @""; }
- (NSString *) benefitString{ return @""; }
- (float) curPercent { return 0.f; };
- (float) nextPercent { return 0.f; };

@end

@implementation ResearchPercentController

- (float) prevBenefit {
  return [[_research predecessorResearch] percentage];
}

- (float) percentBenefit {
  return [_research percentage] - [[_research predecessorResearch] percentage];
}

- (float) makePercent:(float)val {
  return roundf(val*1000)/10.f;
}

- (NSString *) longImprovementString {
  float prevBenefit = [self prevBenefit];
  NSString *pre = prevBenefit > 0 ? [NSString stringWithFormat:@"%@%%", [Globals commafyNumber:[self makePercent:prevBenefit]]] : @"";
  return [NSString stringWithFormat:@"%@ + %@%% %@", pre, [Globals commafyNumber:[self makePercent:[self percentBenefit]]], [self suffix]];
}

- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:[self makePercent:[self percentBenefit]]]];
}

- (NSString *) benefitString {
  return [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:[self makePercent:[_research percentage] ]]];
}

- (float) curPercent {
  float curVal = [_research percentage];
  float maxVal = [[_research maxLevelResearch] percentage];
  return curVal/maxVal;
}

@end

@implementation ResearchUnitController

- (float) prevBenefit {
  return [[_research predecessorResearch] amountIncrease];
}

- (int) amountBenefit {
  return [_research amountIncrease] - [[_research predecessorResearch] amountIncrease];
}

- (NSString *) longImprovementString {
  float prevBenefit = [self prevBenefit];
  NSString *pre = prevBenefit > 0 ? [NSString stringWithFormat:@"%@", [Globals commafyNumber:prevBenefit]] : @"";
  return [NSString stringWithFormat:@"%@ + %@ %@", pre, [Globals commafyNumber:[self amountBenefit]], [self suffix]];
}

- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"+%@", [Globals commafyNumber:[self amountBenefit]]];
}

- (NSString *) benefitString {
  return [NSString stringWithFormat:@"+%@", [Globals commafyNumber:[_research amountIncrease]]];
}

- (float) curPercent {
  float curVal = [_research amountIncrease];
  float maxVal = [[_research maxLevelResearch] amountIncrease];
  return curVal/maxVal;
}

@end

@implementation ResearchUnlockController

- (NSString *) unlockedName {
  GameState *gs = [GameState sharedGameState];
  
  if (_research.researchType == ResearchTypeUnlockItem) {
    BattleItemProto *bip = [gs battleItemWithId:_research.staticDataId];
    return bip.name;
  } else {
    PvpBoardObstacleProto *bop = gs.staticPvpBoardObstacles[@(_research.staticDataId)];
    return bop.name;
  }
  
  return @"Item";
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"%@", [self unlockedName]];
}
                                             
- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"Unlock %@", [self unlockedName]];
}

- (NSString *) benefitString {
  return [NSString stringWithFormat:@"%@", [self unlockedName]];
}

- (float) curPercent {
  return _research.level/(float)[_research maxLevelResearch].level;
}

@end