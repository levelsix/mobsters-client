//
//  BattlePlayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"
#import "OrbLayer.h"
#import "Protocols.pb.h"

@interface BattlePlayer : NSObject

@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int maxHealth;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *spritePrefix;
@property (nonatomic, assign) MonsterProto_AnimationType animationType;
@property (nonatomic, assign) float verticalOffset;

@property (nonatomic, assign) MonsterProto_MonsterElement element;
@property (nonatomic, assign) MonsterProto_MonsterQuality rarity;

@property (nonatomic, assign) int fireDamage;
@property (nonatomic, assign) int waterDamage;
@property (nonatomic, assign) int earthDamage;
@property (nonatomic, assign) int lightDamage;
@property (nonatomic, assign) int nightDamage;
@property (nonatomic, assign) int rockDamage;

@property (nonatomic, assign) int minDamage;
@property (nonatomic, assign) int maxDamage;
@property (nonatomic, assign) float damageRandomnessFactor;

@property (nonatomic, assign) int monsterId;
@property (nonatomic, assign) uint64_t userMonsterId;
@property (nonatomic, assign) int slotNum;

+ (id) playerWithMonster:(UserMonster *)monster;
+ (id) playerWithClanRaidStageMonster:(ClanRaidStageMonsterProto *)monster curHealth:(int)curHealth;

- (int) damageForColor:(GemColorId)color;
- (int) totalAttackPower;
- (int) randomDamage;

@end