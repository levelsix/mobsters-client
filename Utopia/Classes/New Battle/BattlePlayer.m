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
#import "NewBattleLayer.h"

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
    self.rockDamage = [gl calculateElementalDamageForMonster:monster element:MonsterProto_MonsterElementRock];
    self.name = [NSString stringWithFormat:@"%@ (lvl %d)", mp.displayName, monster.level];
    self.spritePrefix = mp.imagePrefix;
    self.userMonsterId = monster.userMonsterId;
    self.slotNum = monster.teamSlot;
    self.animationType = mp.attackAnimationType;
    
    self.damageRandomnessFactor = 0.2;
  }
  return self;
}

+ (id) playerWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth {
  return [[self alloc] initWithClanRaidStageMonster:monster curHealth:curHealth];
}

- (id) initWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    self.maxHealth = monster.monsterHp;
    self.curHealth = MIN(self.maxHealth, curHealth);
    self.element = mp.monsterElement;
    self.minDamage = monster.minDmg;
    self.maxDamage = monster.maxDmg;
    self.spritePrefix = mp.imagePrefix;
    self.animationType = mp.attackAnimationType;
    self.userMonsterId = monster.crsmId;
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
      
    case color_filler:
      return self.rockDamage;
      break;
      
    default:
      return 1;
      break;
  }
}

- (int) totalAttackPower {
  if (self.minDamage && self.maxDamage) {
    return (self.minDamage+self.maxDamage)/2;
  }
  return self.fireDamage+self.waterDamage+self.earthDamage+self.lightDamage+self.nightDamage+self.rockDamage;
}

- (int) randomDamage {
  if (self.minDamage && self.maxDamage) {
    return self.minDamage+arc4random()%(self.maxDamage-self.minDamage);
  } else {
    float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
    float amt = 1+(rand*2-1)*self.damageRandomnessFactor;
    return amt*self.totalAttackPower*NUM_MOVES_PER_TURN;
  }
}

@end
