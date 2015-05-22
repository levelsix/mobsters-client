//
//  Reward.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "Reward.h"

#import "GameState.h"

@implementation Reward

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto droplessStageNums:(NSArray *)droplessStageNums {
  return [self createRewardsForDungeon:proto tillStage:(int)proto.tspList.count-1 droplessStageNums:droplessStageNums];
}

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto tillStage:(int)stageNum droplessStageNums:(NSArray *)droplessStageNums {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *rewards = [NSMutableArray array];
  
  int silverAmount = 0, oilAmount = 0, expAmount = 0;
  for (int i = 0; i <= stageNum && i < proto.tspList.count; i++) {
    TaskStageProto *tsp = proto.tspList[i];
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      silverAmount += tsm.cashReward;
      oilAmount += tsm.oilReward;
      expAmount += tsm.expReward;
      
      if (![droplessStageNums containsObject:@(i)]) {
        if (tsm.puzzlePieceDropped) {
          Reward *r = [[Reward alloc] initWithMonsterId:tsm.puzzlePieceMonsterId monsterLvl:tsm.puzzlePieceMonsterDropLvl];
          [rewards addObject:r];
        } else if (tsm.hasItemId) {
          Reward *r = [[Reward alloc] initWithItemId:tsm.itemId quantity:1];
          [rewards addObject:r];
        }
      }
    }
  }
  
  // Check if this is the first time they are completing this task, and if there is a map element associated with it
  if (![gs isTaskCompleted:proto.taskId]) {
    TaskMapElementProto *elem = nil;
    for (TaskMapElementProto *e in gs.staticMapElements) {
      if (e.taskId == proto.taskId) {
        elem = e;
      }
    }
    
    if (elem) {
      silverAmount += elem.cashReward;
      oilAmount += elem.oilReward;
    }
  }
  else
  {
    //Remainder resources
    UserTaskCompletedProto *taskCompleteData = [gs.completedTaskData objectForKey:@(proto.taskId)];
    
    silverAmount += taskCompleteData.unclaimedCash;
    oilAmount += taskCompleteData.unclaimedOil;
  }
  
  if (gs.cash + silverAmount > gs.maxCash)
  {
    silverAmount = gs.maxCash - gs.cash;
  }
  
  if (gs.oil + oilAmount > gs.maxOil)
  {
    oilAmount = gs.maxOil - gs.oil;
  }
  
  if (silverAmount) {
    Reward *r = [[Reward alloc] initWithCashAmount:silverAmount];
    [rewards addObject:r];
  }
  if (oilAmount) {
    Reward *r = [[Reward alloc] initWithOilAmount:oilAmount];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (quest.gemReward) {
    Reward *r = [[Reward alloc] initWithGemAmount:quest.gemReward];
    [rewards addObject:r];
  }
  
  if (quest.monsterIdReward) {
    Reward *r = [[Reward alloc] initWithMonsterId:quest.monsterIdReward monsterLvl:quest.isCompleteMonster];
    [rewards addObject:r];
  }
  
  if (quest.cashReward) {
    Reward *r = [[Reward alloc] initWithCashAmount:quest.cashReward];
    [rewards addObject:r];
  }
  
  if (quest.oilReward) {
    Reward *r = [[Reward alloc] initWithOilAmount:quest.oilReward];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForMiniJob:(MiniJobProto *)miniJob {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (miniJob.hasRewardOne) {
    Reward *r = [[Reward alloc] initWithReward:miniJob.rewardOne];
    [rewards addObject:r];
  }
  
  if (miniJob.hasRewardTwo) {
    Reward *r = [[Reward alloc] initWithReward:miniJob.rewardTwo];
    [rewards addObject:r];
  }
  
  if (miniJob.hasRewardThree) {
    Reward *r = [[Reward alloc] initWithReward:miniJob.rewardThree];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForPvpProto:(PvpProto *)pvp droplessStageNums:(NSArray *)droplessStageNums isWin:(BOOL)isWin {
  NSMutableArray *rewards = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  PvpLeagueProto *league = [gs leagueForId:gs.pvpLeague.leagueId];
  Reward *lr = [[Reward alloc] initWithPvpLeague:league];
  [rewards addObject:lr];
  
  if (!isWin) {
    return rewards;
  }
  
  for (int i = 0; i < pvp.defenderMonstersList.count; i++) {
    if (![droplessStageNums containsObject:@(i)]) {
      PvpMonsterProto *mon = pvp.defenderMonstersList[i];
      if (mon.monsterIdDropped > 0) {
        Reward *r = [[Reward alloc] initWithMonsterId:mon.monsterIdDropped monsterLvl:0];
        [rewards addObject:r];
      }
    }
  }
  
  // Donated monster
  if (pvp.monsterIdDropped && ![droplessStageNums containsObject:@(pvp.defenderMonstersList.count)]) {
    Reward *r = [[Reward alloc] initWithMonsterId:pvp.monsterIdDropped monsterLvl:0];
    [rewards addObject:r];
  }
  
  if (pvp.prospectiveCashWinnings) {
    Reward *r = [[Reward alloc] initWithCashAmount:pvp.prospectiveCashWinnings];
    [rewards addObject:r];
  }
  
  if (pvp.prospectiveOilWinnings) {
    Reward *r = [[Reward alloc] initWithOilAmount:pvp.prospectiveOilWinnings];
    [rewards addObject:r];
  }
  
  return rewards;
}

- (id) initWithMonsterId:(int)monsterId monsterLvl:(int)monsterLvl {
  if ((self = [super init])) {
    self.type = RewardTypeMonster;
    self.monsterId = monsterId;
    self.monsterLvl = monsterLvl;
  }
  return self;
}

- (id) initWithItemId:(int)itemId quantity:(int)quantity {
  if ((self = [super init])) {
    self.type = RewardTypeItem;
    self.itemId = itemId;
    self.itemQuantity = quantity;
  }
  return self;
}

- (id) initWithCashAmount:(int)cashAmount {
  if ((self = [super init])) {
    self.type = RewardTypeCash;
    self.cashAmount = cashAmount;
  }
  return self;
}

- (id) initWithOilAmount:(int)oilAmount {
  if ((self = [super init])) {
    self.type = RewardTypeOil;
    self.oilAmount = oilAmount;
  }
  return self;
}

- (id) initWithGemAmount:(int)gemAmount {
  if ((self = [super init])) {
    self.type = RewardTypeGems;
    self.gemAmount = gemAmount;
  }
  return self;
}

- (id) initWithTokenAmount:(int)tokenAmount {
  if ((self = [super init])) {
    self.type = RewardTypeGachaToken;
    self.gemAmount = tokenAmount;
  }
  return self;
}

- (id) initWithPvpLeague:(PvpLeagueProto *)league {
  if ((self = [super init])) {
    self.type = RewardTypePvpLeague;
    self.league = league;
  }
  return self;
}

- (id) initWithReward:(RewardProto *)reward {
  if ((self = [super init])) {
    switch (reward.typ) {
      case RewardProto_RewardTypeCash:
        self.type = RewardTypeCash;
        self.cashAmount = reward.amt;
        break;
      case RewardProto_RewardTypeOil:
        self.type = RewardTypeOil;
        self.oilAmount = reward.amt;
        break;
      case RewardProto_RewardTypeGems:
        self.type = RewardTypeGems;
        self.gemAmount = reward.amt;
        break;
      case RewardProto_RewardTypeGachaCredits:
        self.type = RewardTypeGachaToken;
        self.tokenAmount = reward.amt;
        break;
        
      case RewardProto_RewardTypeItem:
        self.type = RewardTypeItem;
        self.itemId = reward.staticDataId;
        self.itemQuantity = reward.amt;
        break;
        
      case RewardProto_RewardTypeMonster:
        self.type = RewardTypeMonster;
        self.monsterId = reward.staticDataId;
        self.monsterLvl = reward.amt;
        break;
        
      case RewardProto_RewardTypeReward:
        self.type = RewardTypeReward;
        self.innerReward = [[Reward alloc] initWithReward:reward.actualReward];
        self.rewardQuantity = reward.amt;
        break;
        
      case RewardProto_RewardTypeClanGift:
      case RewardProto_RewardTypeTangoGift:
      case RewardProto_RewardTypeNoReward:
        break;
    }
  }
  return self;
}

- (NSString *) imgName {
  
  GameState *gs = [GameState sharedGameState];
  Reward *reward = self.type != RewardTypeReward ? self : self.innerReward;
  NSString *imgName = nil;
  
  switch (reward.type) {
    case RewardTypeMonster:
    {
      MonsterProto *mp = [gs monsterWithId:reward.monsterId];
      imgName = [mp.imagePrefix  stringByAppendingString:@"Card.png"];
      break;
    }
      
    case RewardTypeItem:
    {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = reward.itemId;
      
      imgName = ui.iconImageName;
      
      break;
    }
      
    case RewardTypeCash:
      imgName = @"moneystack.png";
      break;
    case RewardTypeOil:
      imgName = @"oilicon.png";
      break;
    case RewardTypeGems:
      imgName = @"diamond.png";
      break;
    case RewardTypeGachaToken:
      imgName = @"grabchip.png";
      break;
      
    case RewardTypePvpLeague:
      imgName = [reward.league.imgPrefix stringByAppendingString:@"icon.png"];
      break;
      
    case RewardTypeReward:
      break;
  }
  
  return imgName;
}

- (NSString *) name {
  
  GameState *gs = [GameState sharedGameState];
  
  Reward *reward = self.type != RewardTypeReward ? self : self.innerReward;
  NSString* name  = nil;
  
  switch (reward.type)
  {
    case RewardTypeItem:
    {
      ItemProto* item = [gs itemForId:reward.itemId];
      name  = item.name;
      break;
    }
    case RewardTypeGems:
      name  = [NSString stringWithFormat:@"%@ %@", [Globals commafyNumber:reward.gemAmount], [Globals stringForResourceType:ResourceTypeGems]];
      break;
    case RewardTypeCash:
      name  = [NSString stringWithFormat:@"%@ %@", [Globals commafyNumber:reward.cashAmount], [Globals stringForResourceType:ResourceTypeCash]];
      break;
    case RewardTypeOil:
      name  = [NSString stringWithFormat:@"%@ %@", [Globals commafyNumber:reward.oilAmount], [Globals stringForResourceType:ResourceTypeOil]];
      break;
    case RewardTypeGachaToken:
      name  = [NSString stringWithFormat:@"%@ %@", [Globals commafyNumber:reward.tokenAmount], [Globals stringForResourceType:ResourceTypeGachaCredits]];
      break;
    case RewardTypeMonster:
    {
      MonsterProto* monster = [gs monsterWithId:reward.monsterId];
      name  = [NSString stringWithFormat:@"%@%@", monster.displayName, reward.monsterLvl == 0 ? @" Piece" : [NSString stringWithFormat:@" LVL %d", reward.monsterLvl]];
      break;
    }
      
    case RewardTypePvpLeague:
    case RewardTypeReward:
      break;
  }
  
  return name;
}

- (NSString *) shortName {
  
  GameState *gs = [GameState sharedGameState];
  
  Reward *reward = self.type != RewardTypeReward ? self : self.innerReward;
  NSString* name  = nil;
  
  switch (reward.type)
  {
    case RewardTypeItem:
    {
      ItemProto* item = [gs itemForId:reward.itemId];
      name  = item.hasShortName ? item.shortName : item.name;
      break;
    }
      
    case RewardTypeMonster:
    {
      MonsterProto* monster = [gs monsterWithId:reward.monsterId];
      name  = [NSString stringWithFormat:@"%@ %@", monster.monsterName, reward.monsterLvl > 0 ? [NSString stringWithFormat:@"L%d", reward.monsterLvl] : @"Piece"];
      break;
    }
      
    case RewardTypeGems:
    case RewardTypeCash:
    case RewardTypeOil:
    case RewardTypeGachaToken:
    case RewardTypePvpLeague:
    case RewardTypeReward:
      name = [self name];
      break;
  }
  
  return name;
}

- (NSString *) shorterName {
  
  Reward *reward = self.type != RewardTypeReward ? self : self.innerReward;
  NSString* name  = nil;
  
  switch (reward.type)
  {
    case RewardTypeGems:
      name = reward.gemAmount < 100000 ? [Globals commafyNumber:reward.gemAmount] : [Globals shortenNumber:reward.gemAmount];
      break;
    case RewardTypeCash:
      name = reward.cashAmount < 100000 ? [Globals commafyNumber:reward.cashAmount] : [Globals shortenNumber:reward.cashAmount];
      break;
    case RewardTypeOil:
      name = reward.oilAmount < 100000 ? [Globals commafyNumber:reward.oilAmount] : [Globals shortenNumber:reward.oilAmount];
      break;
    case RewardTypeGachaToken:
      name = reward.tokenAmount < 100000 ? [Globals commafyNumber:reward.tokenAmount] : [Globals shortenNumber:reward.tokenAmount];
      break;
      
    case RewardTypeItem:
    {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = reward.itemId;
      
      name = ui.iconText;
    }
    case RewardTypeMonster:
    case RewardTypePvpLeague:
    case RewardTypeReward:
      break;
  }
  
  return name;
}

- (int) quantity {
  
  Reward *reward = self;
  int quantity  = 1;
  
  switch (reward.type)
  {
    case RewardTypeItem:
      quantity  = reward.itemQuantity;
      break;
      
    case RewardTypeReward:
      quantity = reward.rewardQuantity;
      break;
      
    case RewardTypeGems:
    case RewardTypeCash:
    case RewardTypeOil:
    case RewardTypeGachaToken:
    case RewardTypePvpLeague:
    case RewardTypeMonster:
      break;
  }
  
  return quantity;
}

@end