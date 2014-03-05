//
//  ClanRaidProto+EasyAccess.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidProto+EasyAccess.h"

@implementation ClanRaidProto (EasyAccess)

- (ClanRaidStageProto *) stageWithId:(int)stageId {
  for (ClanRaidStageProto *stage in self.raidStagesList) {
    if (stage.clanRaidStageId == stageId) {
      return stage;
    }
  }
  return nil;
}

@end

@implementation ClanRaidStageProto (EasyAccess)

- (ClanRaidStageMonsterProto *) monsterWithId:(int)crsmId {
  for (ClanRaidStageMonsterProto *mon in self.monstersList) {
    if (mon.crsmId == crsmId) {
      return mon;
    }
  }
  return nil;
}

- (int) totalHealth {
  int health = 0;
  for (ClanRaidStageMonsterProto *mon in self.monstersList) {
    health += mon.monsterHp;
  }
  return health;
}

@end
