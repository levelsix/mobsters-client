//
//  BattlePlayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BattleEquip : NSObject

@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int enhancePercent;
@property (nonatomic, assign) int durability;

+ (id) equipWithEquipId:(int)equipId enhancePercent:(int)enhancePercent durability:(int)durability;
- (id) initWithEquipId:(int)equipId enhancePercent:(int)enhancePercent durability:(int)durability;

@end

@interface BattlePlayer : NSObject

@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int maxHealth;

@property (nonatomic, retain) BattleEquip *weapon;
@property (nonatomic, retain) BattleEquip *armor;
@property (nonatomic, retain) BattleEquip *amulet;

+ (id) playerWithHealth:(int)health weapon:(BattleEquip *)weapon armor:(BattleEquip *)armor amulet:(BattleEquip *)amulet;
- (id) initWithHealth:(int)health weapon:(BattleEquip *)weapon armor:(BattleEquip *)armor amulet:(BattleEquip *)amulet;

- (int) attackPower;

@end
