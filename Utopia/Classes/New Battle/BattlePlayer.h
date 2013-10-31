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

@interface BattlePlayer : NSObject

@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int maxHealth;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *spritePrefix;

@property (nonatomic, assign) MonsterProto_MonsterElement element;

@property (nonatomic, assign) int fireDamage;
@property (nonatomic, assign) int waterDamage;
@property (nonatomic, assign) int earthDamage;
@property (nonatomic, assign) int lightDamage;
@property (nonatomic, assign) int nightDamage;

@property (nonatomic, assign) int userMonsterId;
@property (nonatomic, assign) int slotNum;

+ (id) playerWithMonster:(UserMonster *)monster;
- (id) initWithMonster:(UserMonster *)monster;

- (int) damageForColor:(GemColorId)color;
- (int) totalAttackPower;

@end