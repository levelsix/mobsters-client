//
//  BattleSimulation.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattlePlayer.h"
#import "BattleSchedule.h"
#import "BattleOrbLayout.h"

@interface BattleSimulation : NSObject

@property (nonatomic, retain) NSArray *myTeam;
@property (nonatomic, retain) NSArray *enemyTeam;

@property (nonatomic, retain) BattlePlayer *currentMyPlayer;
@property (nonatomic, retain) BattlePlayer *currentEnemy;

@property (nonatomic, retain) BattleSchedule *battleSchedule;

@property (nonatomic, assign) int curStageNum;

- (id) initWithMyUserMonsters:(NSArray *)myUserMonsters;
- (BattlePlayer *) firstMyPlayer;
- (BattlePlayer *) nextEnemy;
- (void) setEnemyUserMonsters:(NSArray *)enemyUserMonsters;
- (BOOL) isReadyToBegin;

- (BOOL) swapToPlayerAtSlotNum:(int)slotNum isSwap:(BOOL)isSwap;
- (void) moveToNextEnemy;

- (void) beginGame;
- (BOOL) dequeuNextTurn;
- (int) myDamageForOrb:(BattleOrb *)orb;
- (int) dealMyDamageWithOrbCounts:(int[])orbCounts;
- (int) dealEnemyDamage;

@end
