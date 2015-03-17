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
  [self prepareCharacterImage:monster.monsterId];
  if ((self = [super init])) {
    Globals *gl = [Globals sharedGlobals];
    self.minHealth = 0;
    self.maxHealth = [gl calculateMaxHealthForMonster:monster];
    self.curHealth = MAX(self.minHealth, MIN(self.maxHealth, monster.curHealth));
    self.level = monster.level;
    self.speed = [gl calculateSpeedForMonster:monster];
    self.fireDamage = [gl calculateElementalDamageForMonster:monster element:ElementFire];
    self.waterDamage = [gl calculateElementalDamageForMonster:monster element:ElementWater];
    self.earthDamage = [gl calculateElementalDamageForMonster:monster element:ElementEarth];
    self.lightDamage = [gl calculateElementalDamageForMonster:monster element:ElementLight];
    self.nightDamage = [gl calculateElementalDamageForMonster:monster element:ElementDark];
    self.rockDamage = [gl calculateElementalDamageForMonster:monster element:ElementRock];
    self.monsterId = monster.monsterId;
    self.userMonsterUuid = monster.userMonsterUuid;
    self.slotNum = monster.teamSlot;
    self.offensiveSkillId = monster.offensiveSkillId;
    self.defensiveSkillId = monster.defensiveSkillId;
    self.monsterType = monsterType;
    self.isConfused = NO;
    self.isStunned = NO;
    self.isCursed = NO;
    self.isClanMonster = monster.isClanMonster;
    
    self.lowerBound = 0.6*dmgMultiplier;
    self.upperBound = 1.*dmgMultiplier;
  }
  return self;
}

- (void) prepareCharacterImage:(int)monsterId
{
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  _characterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:_characterImage maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

+ (id) playerWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth {
  return [[self alloc] initWithClanRaidStageMonster:monster curHealth:curHealth];
}

- (id) initWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth {
  if ((self = [super init])) {
    self.minHealth = 0;
    self.maxHealth = monster.monsterHp;
    self.curHealth = MAX(self.minHealth, MIN(self.maxHealth, curHealth));
    self.minDamage = monster.minDmg;
    self.maxDamage = monster.maxDmg;
    self.monsterId = monster.monsterId;
    self.userMonsterUuid = [NSString stringWithFormat:@"%d", monster.crsmId];
    
    // Need to get a speed value for this guy
  }
  return self;
}

- (void) setMonsterId:(int)monsterId {
  _monsterId = monsterId;
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  self.element = mp.monsterElement;
  self.rarity = mp.quality;
  
  self.spritePrefix = mp.imagePrefix;
  self.animationType = mp.attackAnimationType;
  
  self.verticalOffset = mp.verticalPixelOffset;
  self.evoLevel = mp.evolutionLevel;
  
  if (mp) {
    NSString *p1 = ![Globals isSmallestiPhone] ? mp.displayName : mp.monsterName;
    NSString *p2 = [NSString stringWithFormat:@" L%d", self.level];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, p1.length)];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:202/255.f blue:1.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
    self.attrName = as;
  }
}

- (void) setLevel:(int)level {
  _level = level;
  
  if (self.monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:self.monsterId];
    
    if (mp) {
      NSString *p1 = ![Globals isSmallestiPhone] ? mp.displayName : mp.monsterName;
      NSString *p2 = [NSString stringWithFormat:@" L%d", self.level];
      NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, p1.length)];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:202/255.f blue:1.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
      self.attrName = as;
    }
  }
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
      return 0;
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

#pragma mark - Serialization

//@property (nonatomic, assign) int curHealth;
//@property (nonatomic, assign) int maxHealth;
//
//@property (nonatomic, retain) NSAttributedString *attrName;
//@property (nonatomic, retain) NSString *spritePrefix;
//@property (nonatomic, assign) MonsterProto_AnimationType animationType;
//@property (nonatomic, assign) float verticalOffset;
//
//@property (nonatomic, assign) Element element;
//@property (nonatomic, assign) Quality rarity;
//@property (nonatomic, assign) TaskStageMonsterProto_MonsterType monsterType;
//
//@property (nonatomic, assign) int level;
//@property (nonatomic, assign) int evoLevel;
//
//@property (nonatomic, assign) int speed;
//
//@property (nonatomic, assign) int fireDamage;
//@property (nonatomic, assign) int waterDamage;
//@property (nonatomic, assign) int earthDamage;
//@property (nonatomic, assign) int lightDamage;
//@property (nonatomic, assign) int nightDamage;
//@property (nonatomic, assign) int rockDamage;
//
//@property (nonatomic, assign) int minDamage;
//@property (nonatomic, assign) int maxDamage;
//@property (nonatomic, assign) float lowerBound;
//@property (nonatomic, assign) float upperBound;
//
//@property (nonatomic, assign) int monsterId;
//@property (nonatomic, retain) NSString *userMonsterUuid;
//@property (nonatomic, assign) int slotNum;
//
//@property (nonatomic, assign) int offensiveSkillId;
//@property (nonatomic, assign) int defensiveSkillId;
//
//@property (nonatomic, assign) BOOL isClanMonster;
//
//@property (nonatomic, assign) BOOL isConfused;
//@property (nonatomic, assign) BOOL isStunned;
//
//@property (nonatomic, retain) DialogueProto *dialogue;

#define CUR_HEALTH_KEY @"curHp"
#define MAX_HEALTH_KEY @"maxHp"

#define MONSTER_TYPE_KEY @"monsterType"

#define LEVEL_KEY @"level"
#define SPEED_KEY @"speed"

#define FIRE_DMG_KEY @"fireDmg"
#define WATER_DMG_KEY @"waterDmg"
#define EARTH_DMG_KEY @"earthDmg"
#define LIGHT_DMG_KEY @"lightDmg"
#define NIGHT_DMG_KEY @"nightDmg"
#define ROCK_DMG_KEY @"rockDmg"

#define MIN_DMG_KEY @"minDmg"
#define MAX_DMG_KEY @"maxDmg"
#define LOWER_BOUND_KEY @"lowerBound"
#define UPPER_BOUND_KEY @"upperBound"

#define MONSTER_ID_KEY @"monsterId"
#define USER_MONSTER_UUID_KEY @"userMonsterUuid"
#define SLOT_NUM_KEY @"slotNum"

#define OFF_SKILL_ID_KEY @"offSkill"
#define DEF_SKILL_ID_KEY @"defSkill"

#define IS_CLAN_MONSTER_KEY @"clanMonster"

#define IS_CONFUSED_KEY @"isConfused"
#define IS_STUNNED_KEY @"isStunned"

#define DIALOGUE_KEY @"dialogue"

- (NSDictionary *)serialize {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  dict[CUR_HEALTH_KEY] = @(self.curHealth);
  dict[MAX_HEALTH_KEY] = @(self.maxHealth);
  
  dict[MONSTER_TYPE_KEY] = @(self.monsterType);
  
  dict[LEVEL_KEY] = @(self.level);
  dict[SPEED_KEY] = @(self.speed);
  
  dict[FIRE_DMG_KEY] = @(self.fireDamage);
  dict[WATER_DMG_KEY] = @(self.waterDamage);
  dict[EARTH_DMG_KEY] = @(self.earthDamage);
  dict[LIGHT_DMG_KEY] = @(self.lightDamage);
  dict[NIGHT_DMG_KEY] = @(self.nightDamage);
  dict[ROCK_DMG_KEY] = @(self.rockDamage);
  
  dict[MIN_DMG_KEY] = @(self.minDamage);
  dict[MAX_DMG_KEY] = @(self.maxDamage);
  dict[LOWER_BOUND_KEY] = @(self.lowerBound);
  dict[UPPER_BOUND_KEY] = @(self.upperBound);
  
  dict[MONSTER_ID_KEY] = @(self.monsterId);
  if (self.userMonsterUuid) {
    dict[USER_MONSTER_UUID_KEY] = self.userMonsterUuid;
  }
  dict[SLOT_NUM_KEY] = @(self.slotNum);
  
  dict[OFF_SKILL_ID_KEY] = @(self.offensiveSkillId);
  dict[DEF_SKILL_ID_KEY] = @(self.defensiveSkillId);
  
  dict[IS_CLAN_MONSTER_KEY] = @(self.isClanMonster);
  
  dict[IS_CONFUSED_KEY] = @(self.isConfused);
  dict[IS_STUNNED_KEY] = @(self.isStunned);
  
  if (self.dialogue) {
    dict[DIALOGUE_KEY] = [[self.dialogue data] base64EncodedStringWithOptions:0];
  }
  
  return dict;
}

- (void) deserialize:(NSDictionary *)dict {
  self.curHealth = [dict[CUR_HEALTH_KEY] intValue];
  self.maxHealth = [dict[MAX_HEALTH_KEY] intValue];
  
  self.monsterType = [dict[MONSTER_ID_KEY] intValue];
  
  self.level = [dict[LEVEL_KEY] intValue];
  self.speed = [dict[SPEED_KEY] intValue];
  
  self.fireDamage = [dict[FIRE_DMG_KEY] intValue];
  self.waterDamage = [dict[WATER_DMG_KEY] intValue];
  self.earthDamage = [dict[EARTH_DMG_KEY] intValue];
  self.lightDamage = [dict[LIGHT_DMG_KEY] intValue];
  self.nightDamage = [dict[NIGHT_DMG_KEY] intValue];
  self.rockDamage = [dict[ROCK_DMG_KEY] intValue];
  
  self.minDamage = [dict[MIN_DMG_KEY] intValue];
  self.maxDamage = [dict[MAX_DMG_KEY] intValue];
  self.lowerBound = [dict[LOWER_BOUND_KEY] floatValue];
  self.upperBound = [dict[UPPER_BOUND_KEY] floatValue];
  
  self.monsterId = [dict[MONSTER_ID_KEY] intValue];
  self.userMonsterUuid = dict[USER_MONSTER_UUID_KEY];
  self.slotNum = [dict[SLOT_NUM_KEY] intValue];
  
  self.offensiveSkillId = [dict[OFF_SKILL_ID_KEY] intValue];
  self.defensiveSkillId = [dict[DEF_SKILL_ID_KEY] intValue];
  
  self.isClanMonster = [dict[IS_CLAN_MONSTER_KEY] boolValue];
  
  self.isConfused = [dict[IS_CONFUSED_KEY] boolValue];
  self.isStunned = [dict[IS_STUNNED_KEY] boolValue];
  
  NSString *str = dict[DIALOGUE_KEY];
  if (str) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:dict[DIALOGUE_KEY] options:0];
    self.dialogue = [DialogueProto parseFromData:data];
  }
  
  [self prepareCharacterImage:self.monsterId];
}

@end
