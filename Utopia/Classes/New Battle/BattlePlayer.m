//
//  BattlePlayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattlePlayer.h"
#import "GameState.h"
#import "Globals.h"

@implementation BattlePlayer

+ (id) playerWithMonster:(UserMonster *)monster {
  return [[self alloc] initWithMonster:monster];
}

- (id) initWithMonster:(UserMonster *)monster {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    self.maxHealth = [gl calculateMaxHealthForMonster:monster];
    self.curHealth = MIN(self.maxHealth, monster.curHealth);
    self.element = mp.monsterElement;
    self.fireDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementFire];
    self.waterDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementWater];
    self.earthDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementGrass];
    self.lightDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementLightning];
    self.nightDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementDarkness];
    self.name = [NSString stringWithFormat:@"%@ (lvl %d)", mp.displayName, monster.level];
    self.spritePrefix = mp.imagePrefix;
    self.userMonsterId = monster.userMonsterId;
    self.slotNum = monster.teamSlot;
  }
  return self;
}

- (int) damageForColor:(GemColorId)color {
  switch (color) {
    case color_red:
      return self.fireDamage;
      break;
      
    case color_blue:
      return self.waterDamage;
      break;
      
    case color_green:
      return self.earthDamage;
      break;
      
    case color_white:
      return self.lightDamage;
      break;
      
    case color_purple:
      return self.nightDamage;
      break;
      
    default:
      return 1;
      break;
  }
}

- (int) totalAttackPower {
  return self.fireDamage+self.waterDamage+self.earthDamage+self.lightDamage+self.nightDamage;
}

@end
