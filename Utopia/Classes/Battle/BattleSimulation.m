//
//  BattleSimulation.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleSimulation.h"

#import "Globals.h"

@implementation BattleSimulation

#pragma mark - Initialization

- (id) initWithMyUserMonsters:(NSArray *)myUserMonsters {
  if ((self = [super init])) {
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonster *um in myUserMonsters) {
      [arr addObject:[BattlePlayer playerWithMonster:um]];
    }
    self.myTeam = arr;
    
    self.currentMyPlayer = [self firstMyPlayer];
    
    self.curStageNum = -1;
  }
  return self;
}

- (BattlePlayer *) firstMyPlayer {
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    // Get the lowest slot member that is not dead
    if (b.curHealth > 0 && (!bp || b.slotNum < bp.slotNum)) {
      bp = b;
    }
  }
  return bp;
}

- (BattlePlayer *) nextEnemy {
  self.curStageNum++;
  return self.enemyTeam[self.curStageNum];;
}

- (void) setEnemyUserMonsters:(NSArray *)enemyUserMonsters {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonster *um in enemyUserMonsters) {
    [arr addObject:[BattlePlayer playerWithMonster:um]];
  }
  self.enemyTeam = arr;
}

- (BOOL) isReadyToBegin {
  return self.enemyTeam != nil;
}

- (void) createScheduleWithSwap:(BOOL)swap {
  if (self.currentMyPlayer && self.currentEnemy) {
    ScheduleFirstTurn order = swap ? ScheduleFirstTurnEnemy : ScheduleFirstTurnRandom;
    BattleSchedule *sched = [[BattleSchedule alloc] initWithPlayerA:self.currentMyPlayer.speed playerB:self.currentEnemy.speed andOrder:order];
    self.battleSchedule = sched;
  } else {
    self.battleSchedule = nil;
  }
}

#pragma mark - Switching Players

- (BOOL) swapToPlayerAtSlotNum:(int)slotNum isSwap:(BOOL)isSwap {
  for (BattlePlayer *b in self.myTeam) {
    // Get the lowest slot member that is not dead
    if (b.curHealth > 0 && b.slotNum == slotNum) {
      self.currentMyPlayer = b;
      
      [self createScheduleWithSwap:isSwap];
      return YES;
    }
  }
  
  return NO;
}

- (void) moveToNextEnemy {
  if (self.curStageNum < self.enemyTeam.count) {
    self.currentEnemy = [self nextEnemy];
    
    [self createScheduleWithSwap:NO];
  } else {
    self.currentEnemy = nil;
  }
}

#pragma mark - Turn Sequence

- (void) beginGame {
  [self moveToNextEnemy];
}

- (BOOL) dequeuNextTurn {
  return [self.battleSchedule dequeueNextMove];
}

- (float) damageMultiplierForAttacker:(BattlePlayer *)attacker defender:(BattlePlayer *)defender {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateDamageMultiplierForAttackElement:attacker.element defenseElement:defender.element];
}

#pragma mark MyPlayer

- (int) myDamageForOrb:(BattleOrb *)orb {
  return [self.currentMyPlayer damageForColor:orb.orbColor];
}

- (int) dealMyDamageWithOrbCounts:(int[])orbCounts {
  int totalDamage = 0;
  
  for (int i = 0; i < OrbColorNone; i++) {
    totalDamage += [self.currentMyPlayer damageForColor:i]*orbCounts[i];
  }
  
  totalDamage = totalDamage*[self damageMultiplierForAttacker:self.currentMyPlayer defender:self.currentEnemy];
  
  self.currentEnemy.curHealth = MAX(self.currentEnemy.minHealth, MIN(self.currentEnemy.maxHealth, self.currentEnemy.curHealth-totalDamage));
  
  return totalDamage;
}

#pragma mark Enemy

- (int) dealEnemyDamage {
  int randDamage = [self.currentEnemy randomDamage];
  randDamage = randDamage*[self damageMultiplierForAttacker:self.currentEnemy defender:self.currentMyPlayer];
  
  self.currentMyPlayer.curHealth = MAX(self.currentEnemy.minHealth, MIN(self.currentEnemy.maxHealth, self.currentEnemy.curHealth-randDamage));
  
  return randDamage;
}

@end
