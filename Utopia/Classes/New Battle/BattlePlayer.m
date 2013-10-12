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

@implementation BattleEquip

+ (id) equipWithEquipId:(int)equipId enhancePercent:(int)enhancePercent durability:(int)durability {
  return [[self alloc] initWithEquipId:equipId enhancePercent:enhancePercent durability:durability];
}

- (id) initWithEquipId:(int)equipId enhancePercent:(int)enhancePercent durability:(int)durability {
  if ((self = [super init])) {
    self.equipId = equipId;
    self.enhancePercent = enhancePercent;
    self.durability = durability;
  }
  return self;
}

@end

@implementation BattlePlayer

+ (id) playerWithHealth:(int)health weapon:(BattleEquip *)weapon armor:(BattleEquip *)armor amulet:(BattleEquip *)amulet {
  return [[self alloc] initWithHealth:health weapon:weapon armor:armor amulet:amulet];
}

- (id) initWithHealth:(int)health weapon:(BattleEquip *)weapon armor:(BattleEquip *)armor amulet:(BattleEquip *)amulet {
  if ((self = [super init])) {
    self.curHealth = health;
    self.maxHealth = health;
    self.weapon = weapon;
    self.armor = armor;
    self.amulet = amulet;
  }
  return self;
}

- (int) attackPower {
  return 50;
}

@end
