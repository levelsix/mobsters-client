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

- (NSString *) benefitName {
  
  switch (_research.researchType) {
    case ResearchTypeHealingCost:
      return @"Healing Cost";
    case ResearchTypeHealingSpeed:
      return @"Healing Speed";
    case ResearchTypeEnhanceCost:
      return @"Enhance Cost";
    case ResearchTypeDecreaseEnhanceTime:
      return @"Enhance Speed";
    case ResearchTypeXpBonus:
      return @"Xp Bonus";
    case ResearchTypeAttackIncrease:
      return @"Attack Increase";
    case ResearchTypeHpIncrease:
      return @"Health Increase";
    case ResearchTypeIncreaseConstructionSpeed:
      return @"Build Speed";
    case ResearchTypeItemProductionCost:
      return @"Item Create Cost";
    case ResearchTypeItemProductionSpeed:
      return @"Item Create Speed";
    case ResearchTypeResourceProduction:
      return @"Resource Rate";
    case ResearchTypeResourceStorage:
      return @"Storage Limit";
      
    case ResearchTypeSpeedIncrease:
      return @"Speed Increase";
    case ResearchTypeIncreaseEnhanceQueue:
    case ResearchTypeIncreaseHospitalQueue:
      return @"Queue Size";
    case ResearchTypeNumberOfHospitals:
      return @"Num Hospitals";
      
    case ResearchTypeUnlockItem:
      return @"Unlock Item";
    case ResearchTypeUnlockObstacle:
      return @"Unlock Obstacle";
      
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

- (float) percentBenefit {
  return [_research percentage] - [[_research predecessorResearch] percentage];
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"%@%% Increase", [Globals commafyNumber:roundf([self percentBenefit]*100)]];
}

- (NSString *) shortImprovementString {
  return [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:roundf([self percentBenefit]*100)]];
}

- (NSString *) benefitString {
  return [NSString stringWithFormat:@"+%@%%", [Globals commafyNumber:roundf([_research percentage]*100)]];
}

- (float) curPercent {
  float curVal = [_research percentage];
  float maxVal = [[_research maxLevelResearch] percentage];
  return curVal/maxVal;
}

@end

@implementation ResearchUnitController

- (int) amountBenefit {
  return [_research amountIncrease] - [[_research predecessorResearch] amountIncrease];
}

- (NSString *) longImprovementString {
  return [NSString stringWithFormat:@"+%@ Increase", [Globals commafyNumber:[self amountBenefit]]];
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