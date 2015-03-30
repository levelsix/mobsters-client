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

- (NSString *) longImprovementString{ return @""; }
- (NSString *) shortImprovementString{ return @""; }
- (float) curPercent { return 0.f; };
- (float) nextPercent { return 0.f; };

@end

@implementation ResearchPercentController

- (float) percentBenefit {
  return [_research percentage] - [[_research predecessorResearch] percentage];
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"%@%% Increase", [Globals commafyNumber:roundf([self percentBenefit]*100)]];
}

- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:roundf([self percentBenefit]*100)]];
}

- (float) curPercent {
  float curVal = [_research percentage];
  float maxVal = [[_research maxLevelResearch] percentage];
  return curVal/maxVal;
}

- (float) nextPercent {
  float nextVal = [[_research successorResearch] percentage];
  float maxVal = [[_research maxLevelResearch] percentage];
  return nextVal/maxVal;
}

@end

@implementation ResearchUnitController

- (int) amountBenefit {
  return [_research amountIncrease] - [[_research predecessorResearch] amountIncrease];
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"%@ Increase", [Globals commafyNumber:[self amountBenefit]]];
}

- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"+%@", [Globals commafyNumber:[self amountBenefit]]];
}

- (float) curPercent {
  float curVal = [_research amountIncrease];
  float maxVal = [[_research maxLevelResearch] amountIncrease];
  return curVal/maxVal;
}

- (float) nextPercent {
  float nextVal = [[_research successorResearch] amountIncrease];
  float maxVal = [[_research maxLevelResearch] amountIncrease];
  return nextVal/maxVal;
}

@end

@implementation ResearchUnlockController
#warning implement once we merge
- (NSString *) unlockedName {
  return @"Item";
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"Unlock %@", [self unlockedName]];
}
                                             
- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"Unlock %@", [self unlockedName]];
}

- (float) curPercent {
  return 0.f;
}

- (float) nextPercent {
  return 1.f;
}

@end