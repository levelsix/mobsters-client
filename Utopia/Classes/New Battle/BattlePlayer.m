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
  return [[self alloc] initWithMonster:monster dmgMultiplier:0];
}

+ (id) playerWithMonster:(UserMonster *)monster dmgMultiplier:(float)dmgMultiplier {
  return [[self alloc] initWithMonster:monster dmgMultiplier:dmgMultiplier];
}

- (id) initWithMonster:(UserMonster *)monster dmgMultiplier:(float)dmgMultiplier {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    self.maxHealth = [gl calculateMaxHealthForMonster:monster];
    self.curHealth = MIN(self.maxHealth, monster.curHealth);
    self.element = mp.monsterElement;
    self.rarity = mp.quality;
    self.fireDamage = [gl calculateElementalDamageForMonster:monster element:ElementFire];
    self.waterDamage = [gl calculateElementalDamageForMonster:monster element:ElementWater];
    self.earthDamage = [gl calculateElementalDamageForMonster:monster element:ElementEarth];
    self.lightDamage = [gl calculateElementalDamageForMonster:monster element:ElementLight];
    self.nightDamage = [gl calculateElementalDamageForMonster:monster element:ElementDark];
    self.rockDamage = [gl calculateElementalDamageForMonster:monster element:ElementRock];
    self.name = [NSString stringWithFormat:@"%@ (Lvl %d)", mp.displayName, monster.level];
    self.spritePrefix = mp.imagePrefix;
    self.monsterId = monster.monsterId;
    self.userMonsterId = monster.userMonsterId;
    self.slotNum = monster.teamSlot;
    self.animationType = mp.attackAnimationType;
    self.verticalOffset = mp.verticalPixelOffset;
    
    self.lowerBound = 0.6*dmgMultiplier;
    self.upperBound = 1.*dmgMultiplier;
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
    self.rarity = mp.quality;
    self.minDamage = monster.minDmg;
    self.maxDamage = monster.maxDmg;
    self.spritePrefix = mp.imagePrefix;
    self.animationType = mp.attackAnimationType;
    self.monsterId = monster.monsterId;
    self.userMonsterId = monster.crsmId;
    self.verticalOffset = mp.verticalPixelOffset;
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
    if (self.minDamage < self.maxDamage) {
      return self.minDamage+arc4random()%(self.maxDamage-self.minDamage);
    } else {
      return self.maxDamage;
    }
  } else {
    float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
    float amt = self.lowerBound+(rand*(self.upperBound-self.lowerBound));
    return amt*self.totalAttackPower*NUM_MOVES_PER_TURN;
  }
}

@end
