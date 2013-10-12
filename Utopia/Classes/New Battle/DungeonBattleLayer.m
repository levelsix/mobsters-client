//
//  DungeonBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "DungeonBattleLayer.h"
#import "GameState.h"

@implementation DungeonBattleLayer

+ (CCScene *) sceneWithBeginDungeonResponseProto:(BeginDungeonResponseProto *)dungeonInfo {
	CCScene *scene = [CCScene node];
	
	NewBattleLayer *layer = [[DungeonBattleLayer alloc] initWithBeginDungeonResponseProto:dungeonInfo];
	[scene addChild: layer];
  
	return scene;
}

- (id) initWithBeginDungeonResponseProto:(BeginDungeonResponseProto *)dungeonInfo {
  if ((self = [super init])) {
    self.dungeonInfo = dungeonInfo;
    _numStages = dungeonInfo.tspList.count;
  }
  return self;
}

- (void) createNextEnemyObject {
//  GameState *gs = [GameState sharedGameState];
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  MonsterProto *monster = [stage mpAtIndex:0];
  
  if (monster) {
//    FullEquipProto *fep;
//    BattleEquip *weapon = nil, *armor = nil, *amulet = nil;
//    if (monster.weaponId) {
//      fep = [gs equipWithId:monster.weaponId];
//      weapon = [BattleEquip equipWithEquipId:monster.weaponId enhancePercent:monster.weaponLvl durability:fep.maxDurability];
//    }
//    if (monster.armorId) {
//      fep = [gs equipWithId:monster.armorId];
//      armor = [BattleEquip equipWithEquipId:monster.armorId enhancePercent:monster.armorLvl durability:fep.maxDurability];
//    }
//    if (monster.amuletId) {
//      fep = [gs equipWithId:monster.amuletId];
//      amulet = [BattleEquip equipWithEquipId:monster.amuletId enhancePercent:monster.amuletLvl durability:fep.maxDurability];
//    }
//    self.enemyPlayerObject = [BattlePlayer playerWithHealth:monster.maxHp weapon:weapon armor:armor amulet:amulet];
  }
}

- (int) getCurrentEnemyLoot {
//  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
//  MonsterProto *monster = [stage mpAtIndex:0];
  
  return 0;//monster.equipId;
}

@end
