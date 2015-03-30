//
//  BattlePlayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"
#import "OrbMainLayer.h"
#import "Protocols.pb.h"

@interface BattlePlayer : NSObject

@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int minHealth; // Used only for certain skills. Defaults to 0
@property (nonatomic, assign) int maxHealth;

@property (nonatomic, retain) NSAttributedString *attrName;
@property (nonatomic, retain) NSString *spritePrefix;
@property (nonatomic, assign) MonsterProto_AnimationType animationType;
@property (nonatomic, assign) float verticalOffset;

@property (nonatomic, assign) Element element;
@property (nonatomic, assign) Quality rarity;
@property (nonatomic, assign) TaskStageMonsterProto_MonsterType monsterType;

@property (nonatomic, assign) int level;
@property (nonatomic, assign) int evoLevel;

@property (nonatomic, assign) int speed;

@property (nonatomic, assign) int fireDamage;
@property (nonatomic, assign) int waterDamage;
@property (nonatomic, assign) int earthDamage;
@property (nonatomic, assign) int lightDamage;
@property (nonatomic, assign) int nightDamage;
@property (nonatomic, assign) int rockDamage;

@property (nonatomic, assign) int minDamage;
@property (nonatomic, assign) int maxDamage;
@property (nonatomic, assign) float lowerBound;
@property (nonatomic, assign) float upperBound;

@property (nonatomic, assign) int monsterId;
@property (nonatomic, retain) NSString *userMonsterUuid;
@property (nonatomic, assign) int slotNum;

@property (nonatomic, assign) int offensiveSkillId;
@property (nonatomic, assign) int defensiveSkillId;

@property (nonatomic, assign) BOOL isClanMonster;

@property (nonatomic, assign) BOOL isConfused;
@property (nonatomic, assign) BOOL isStunned;
@property (nonatomic, assign) BOOL isCursed;

@property (nonatomic, retain) DialogueProto *dialogue;

@property (nonatomic, retain) ResearchUtil *researchUtil;

+ (id) playerWithMonster:(UserMonster *)monster;
+ (id) playerWithMonster:(UserMonster *)monster dmgMultiplier:(float)dmgMultiplier monsterType:(TaskStageMonsterProto_MonsterType)monsterType;
+ (id) playerWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth;

- (int) damageForColor:(OrbColor)color;
- (int) totalAttackPower;
- (int) randomDamage;

- (UserMonster*) getIncompleteUserMonster;

- (NSDictionary *)serialize;
- (void) deserialize:(NSDictionary *)dict;

@end