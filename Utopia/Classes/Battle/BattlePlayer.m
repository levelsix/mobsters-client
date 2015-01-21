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
  return [[self alloc] initWithMonster:monster dmgMultiplier:1 monsterType:TaskStageMonsterProto_MonsterTypeRegular];
}

+ (id) playerWithMonster:(UserMonster *)monster dmgMultiplier:(float)dmgMultiplier monsterType:(TaskStageMonsterProto_MonsterType)monsterType {
  return [[self alloc] initWithMonster:monster dmgMultiplier:dmgMultiplier monsterType:monsterType];
}

- (id) initWithMonster:(UserMonster *)monster dmgMultiplier:(float)dmgMultiplier monsterType:(TaskStageMonsterProto_MonsterType)monsterType {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    self.maxHealth = [gl calculateMaxHealthForMonster:monster];
    self.curHealth = MIN(self.maxHealth, monster.curHealth);
    self.element = mp.monsterElement;
    self.level = monster.level;
    self.evoLevel = mp.evolutionLevel;
    self.rarity = mp.quality;
    self.speed = [gl calculateSpeedForMonster:monster];
    self.fireDamage = [gl calculateElementalDamageForMonster:monster element:ElementFire];
    self.waterDamage = [gl calculateElementalDamageForMonster:monster element:ElementWater];
    self.earthDamage = [gl calculateElementalDamageForMonster:monster element:ElementEarth];
    self.lightDamage = [gl calculateElementalDamageForMonster:monster element:ElementLight];
    self.nightDamage = [gl calculateElementalDamageForMonster:monster element:ElementDark];
    self.rockDamage = [gl calculateElementalDamageForMonster:monster element:ElementRock];
    self.spritePrefix = mp.imagePrefix;
    self.monsterId = monster.monsterId;
    self.userMonsterUuid = monster.userMonsterUuid;
    self.slotNum = monster.teamSlot;
    self.animationType = mp.attackAnimationType;
    self.verticalOffset = mp.verticalPixelOffset;
    self.offensiveSkillId = monster.offensiveSkillId;
    self.defensiveSkillId = monster.defensiveSkillId;
    self.monsterType = monsterType;
    
    self.lowerBound = 0.6*dmgMultiplier;
    self.upperBound = 1.*dmgMultiplier;
    
    if (mp) {
      NSString *p1 = ![Globals isSmallestiPhone] ? mp.displayName : mp.monsterName;
      NSString *p2 = [NSString stringWithFormat:@" L%d", monster.level];
      NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, p1.length)];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:202/255.f blue:1.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
      self.attrName = as;
    }
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
    self.userMonsterUuid = [NSString stringWithFormat:@"%d", monster.crsmId];
    self.verticalOffset = mp.verticalPixelOffset;
    self.evoLevel = mp.evolutionLevel;
    
    // Need to get a speed value for this guy
  }
  return self;
}

- (int) damageForColor:(OrbColor)color {
  switch (color) {
    case OrbColorFire:
      return self.fireDamage;
      break;
      
    case OrbColorWater:
      return self.waterDamage;
      break;
      
    case OrbColorEarth:
      return self.earthDamage;
      break;
      
    case OrbColorLight:
      return self.lightDamage;
      break;
      
    case OrbColorDark:
      return self.nightDamage;
      break;
      
    case OrbColorRock:
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

- (UserMonster*) getIncompleteUserMonster
{
  UserMonster* monster = [[UserMonster alloc] init];
  
  monster.monsterId = self.monsterId;
  monster.curHealth = self.curHealth;
  monster.level = self.level;
  monster.offensiveSkillId = self.offensiveSkillId;
  monster.defensiveSkillId = self.defensiveSkillId;
  return monster;
}

@end
