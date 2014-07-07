//
//  DungeonBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "DungeonBattleLayer.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "QuestUtil.h"
#import "GenericPopupController.h"
#import "GameViewController.h"
#import "CCBReader.h"
#import "FacebookDelegate.h"
#import "AchievementUtil.h"

@implementation DungeonBattleLayer

- (CCSprite *) getCurrentEnemyLoot {
  GameState *gs = [GameState sharedGameState];
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  TaskStageMonsterProto *monster = [stage stageMonstersAtIndex:0];
  CCSprite *ed = nil;
  if (monster.puzzlePieceDropped) {
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    NSString *fileName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"piece.png"]];
    ed = [CCSprite spriteWithImageNamed:fileName];
  } else if (monster.hasItemId) {
    ItemProto *item = [gs itemForId:monster.itemId];
    ed = [CCSprite spriteWithImageNamed:item.imgName];
  }
  return ed;
}

- (void) youWon {
  [super youWon];
  [self.wonView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo]];
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:YES delegate:self];
  [self makeGoCarrotCalls];
}

- (void) youLost {
  [super youLost];
  [self.lostView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo tillStage:_curStage-1]];
}

- (void) makeGoCarrotCalls {
  //GameState *gs = [GameState sharedGameState];
  for (TaskStageProto *tsp in self.dungeonInfo.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      if (tsm.puzzlePieceDropped) {
        //MonsterProto *mp = [gs monsterWithId:tsm.monsterId];
        //[[Carrot sharedInstance] postAction:@"recruit" forObjectInstance:mp.carrotRecruited];
      }
    }
  }
}

- (void) handleEndDungeonResponseProto:(FullEvent *)fe {
  _receivedEndDungeonResponse = YES;
  EndDungeonResponseProto *proto = (EndDungeonResponseProto *)fe.event;
  if (proto.status == EndDungeonResponseProto_EndDungeonStatusSuccess) {
    [self checkQuests];
  }
  
  if (_waitingForEndDungeonResponse) {
    [self exitFinal];
  }
}

- (void) checkQuests {
  if (!_checkedQuests) {
    _checkedQuests = YES;
    if (_wonBattle) {
      [QuestUtil checkQuestsForDungeon:self.dungeonInfo];
    }
    [AchievementUtil checkAchievementsForDungeonBattleWithOrbCounts:_orbCounts powerupCounts:_powerupCounts comboCount:_totalComboCount damageTaken:_totalDamageTaken dungeonInfo:self.dungeonInfo wonBattle:_wonBattle];
  }
}

#pragma mark - Run away

- (IBAction)forfeitClicked:(id)sender {
  [GenericPopupController displayNegativeConfirmationWithDescription:@"Would you like to try to run away?"
                                                               title:@"Run Away?"
                                                          okayButton:@"Run Away"
                                                        cancelButton:@"Cancel"
                                                            okTarget:self
                                                          okSelector:@selector(attemptRunaway)
                                                        cancelTarget:nil
                                                      cancelSelector:nil];
}

- (void) attemptRunaway {
  BOOL success = arc4random()%2 == 0;
  success = 1;
  if (success) {
    [self runawaySuccess];
  } else {
    _movesLeft = 0;
    _myDamageDealt = 0;
    [self saveCurrentState];
    
    [self runawayFailed];
  }
  
  [self removeButtons];
  [self displayNoInputLayer];
  [self.orbLayer disallowInput];
}

- (void) runawaySuccess {
  [self animateImageLabel:@"runawaysuccess.png" completion:^{
    [self youLost];
  }];
  
  [self makeMyPlayerWalkOutWithBlock:nil];
  self.myPlayer = nil;
  self.myPlayerObject = nil;
}

- (void) runawayFailed {
  [self animateImageLabel:@"runawayfailed.png" completion:^{
    [self checkIfAnyMovesLeft];
  }];
}

- (void) animateImageLabel:(NSString *)imgName completion:(void (^)(void))completion {
  CCSprite *label = [CCSprite spriteWithImageNamed:imgName];
  [self addChild:label];
  label.position = ccp((self.orbBgdLayer.position.x-self.orbBgdLayer.contentSize.width/2)/2, self.contentSize.height/2);
  
  label.scale = 0.3f;
  [label runAction:[CCActionSequence actions:
                    [CCActionSpawn actions:
                     [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.4f scale:1]],
                     [CCActionSequence actions:
                      [CCActionDelay actionWithDuration:1.f],
                      [CCActionFadeOut actionWithDuration:1.f],
                      nil],
                     [CCActionMoveBy actionWithDuration:2.f position:ccp(0,70)],nil],
                    [CCActionRemove action], nil]];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:1.4f],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (completion) {
         completion();
       }
     }],nil]];
}

#pragma mark - Waiting for response

- (IBAction)winExitClicked:(id)sender {
  if (!_waitingForEndDungeonResponse) {
    if (!_wonBattle) {
      [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:_wonBattle delegate:self];
    }
    
    if (!_receivedEndDungeonResponse) {
      _waitingForEndDungeonResponse = YES;
      
      if (_manageWasClicked) {
        [self.wonView spinnerOnManage];
        [self.lostView spinnerOnManage];
      } else {
        [self.wonView spinnerOnDone];
        [self.lostView spinnerOnDone];
      }
    } else {
      [self exitFinal];
    }
  }
}

- (IBAction)manageClicked:(id)sender {
  if (!_waitingForEndDungeonResponse) {
    _manageWasClicked = YES;
    [self winExitClicked:nil];
  }
}

- (void) continueConfirmed {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  
  if (gs.gold < gemsAmount) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    if (gemsAmount > 0) {
      [[OutgoingEventController sharedOutgoingEventController] reviveInDungeon:self.dungeonInfo.userTaskId myTeam:self.myTeam];
    }
    [super continueConfirmed];
  }
}

#pragma mark - Waiting for server

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  
  if (proto.status == BeginDungeonResponseProto_BeginDungeonStatusSuccess) {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    for (TaskStageProto *tsp in proto.tspList) {
      TaskStageMonsterProto *tsm = [tsp.stageMonstersList objectAtIndex:0];
      UserMonster *um = [UserMonster userMonsterWithTaskStageMonsterProto:tsm];
      BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
      [enemyTeam addObject:bp];
      
      [set addObject:bp.spritePrefix];
    }
    self.enemyTeam = enemyTeam;
    
    for (BattlePlayer *bp in self.myTeam) {
      [set addObject:bp.spritePrefix];
    }
    
    self.dungeonInfo = proto;
    
    _isDownloading = YES;
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      _isDownloading = NO;
    }];
  } else {
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) resumeFromUserTask:(MinimumUserTaskProto *)task stages:(NSArray *)stages {
  BeginDungeonResponseProto_Builder *bldr = [BeginDungeonResponseProto builder];
  bldr.taskId = task.taskId;
  bldr.userTaskId = task.userTaskId;
  [bldr addAllTsp:stages];
  
  FullEvent *fe = [[FullEvent alloc] init];
  fe.event = bldr.build;
  [self handleBeginDungeonResponseProto:fe];
  
  for (int i = 0; i < stages.count; i++) {
    TaskStageProto *tsp = stages[i];
    if (tsp.stageId == task.curTaskStageId) {
      _curStage = i-1;
      break;
    } else {
      for (TaskStageMonsterProto *mon in tsp.stageMonstersList) {
        if (mon.puzzlePieceDropped) {
          _lootCount++;
        }
      }
    }
  }
  self.lootLabel.string = [Globals commafyNumber:_lootCount];
  
  [self attemptToResumeState];
}

- (void) moveToNextEnemy {
  [super moveToNextEnemy];
  [self sendServerDungeonProgress];
}

- (void) sendServerDungeonProgress {
  if (_hasStarted && _curStage < self.enemyTeam.count) {
    [[OutgoingEventController sharedOutgoingEventController] progressDungeon:self.myTeam dungeonInfo:self.dungeonInfo newStageNum:_curStage];
    [self saveCurrentState];
  }
}

- (void) moveComplete {
  [super moveComplete];
  [self saveCurrentState];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector {
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker withSelector:selector];
  
  if (enemyIsAttacker) {
    _damageWasDealt = YES;
    [self saveCurrentState];
  }
}

- (void) begin {
  [super begin];
  
  if (self.myPlayerObject) {
    [self displayOrbLayer];
  } else {
    [self youLost];
  }
}

- (void) beginMyTurn {
  if (_isResumingState && !_damageWasDealt) {
    int moves = _movesLeft;
    int damage = _myDamageDealt;
    
    if (_movesLeft <= 0) {
      [self myTurnEnded];
    } else {
      [super beginMyTurn];
    }
    
    _movesLeft = moves;
    _myDamageDealt = damage;
    
    _isResumingState = NO;
  } else {
    [super beginMyTurn];
  }
  
  _damageWasDealt = NO;
  [self saveCurrentState];
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    if (!self.enemyTeam.count || _isDownloading) {
      _numTimesNotResponded++;
      if (_numTimesNotResponded < 10) {
        [self.myPlayer beginWalking];
        [self.bgdLayer scrollToNewScene];
      } else {
        [self.myPlayer stopWalking];
        [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Tap okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
      }
    } else {
      [self moveToNextEnemy];
      _hasStarted = YES;
    }
  } else {
    [super reachedNextScene];
  }
}

- (BOOL) shouldShowContinueButton {
  return YES;
}

#pragma mark - Saving State

#define DUNGEON_DEFAULT_KEY @"DungeonStateKey"
#define USER_TASK_KEY @"UserTaskKey"
#define CUR_STAGE_KEY @"CurStageKey"
#define MOVES_LEFT_KEY @"MovesLeftKey"
#define ENEMY_HEALTH_KEY @"EnemyHealthKey"
#define BOARD_CONFIG_KEY @"BoardConfigKey"
#define DAMAGE_STORED_KEY @"DamageStoredKey"
#define DAMAGE_DEALT_KEY @"DamageDealtKey"
#define TOTAL_DAMAGE_TAKEN_KEY @"TotalDamageTakenKey"
#define TOTAL_COMBO_COUNT_KEY @"TotalComboCountKey"
#define ORB_COUNTS_KEY @"OrbCountsKey"
#define POWERUP_COUNTS_KEY @"PowerupCountsKey"

- (void) saveCurrentState {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[self serializeState] forKey:DUNGEON_DEFAULT_KEY];
}

- (void) attemptToResumeState {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *dict = [defaults objectForKey:DUNGEON_DEFAULT_KEY];
  
  if (dict) {
    NSInteger userTaskId = [[dict objectForKey:USER_TASK_KEY] integerValue];
    NSInteger curStage = [[dict objectForKey:CUR_STAGE_KEY] integerValue];
    if (self.dungeonInfo.userTaskId == userTaskId && curStage == _curStage+1) {
      [self deserializeAndResumeState:dict];
      _isResumingState = YES;
    } else {
      [defaults removeObjectForKey:DUNGEON_DEFAULT_KEY];
    }
  }
}

- (NSDictionary *) serializeState {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:@(_movesLeft) forKey:MOVES_LEFT_KEY];
  [dict setObject:@(_myDamageDealt) forKey:DAMAGE_STORED_KEY];
  [dict setObject:@(_damageWasDealt) forKey:DAMAGE_DEALT_KEY];
  [dict setObject:@(self.enemyPlayerObject.curHealth) forKey:ENEMY_HEALTH_KEY];
  [dict setObject:[self.orbLayer serialize] forKey:BOARD_CONFIG_KEY];
  [dict setObject:@(_curStage) forKey:CUR_STAGE_KEY];
  [dict setObject:@(self.dungeonInfo.userTaskId) forKey:USER_TASK_KEY];
  
  // Achievement info
  [dict setObject:@(_totalDamageTaken) forKey:TOTAL_DAMAGE_TAKEN_KEY];
  [dict setObject:@(_totalComboCount) forKey:TOTAL_COMBO_COUNT_KEY];
  
  NSData *orbCounts = [NSData dataWithBytes:_orbCounts length:sizeof(_orbCounts)];
  [dict setObject:orbCounts forKey:ORB_COUNTS_KEY];
  
  NSData *powerupCounts = [NSData dataWithBytes:_powerupCounts length:sizeof(_powerupCounts)];
  [dict setObject:powerupCounts forKey:POWERUP_COUNTS_KEY];
  
  return dict;
}

- (void) deserializeAndResumeState:(NSDictionary *)stateDict {
  _movesLeft = (int)[[stateDict objectForKey:MOVES_LEFT_KEY] integerValue];
  _myDamageDealt = (int)[[stateDict objectForKey:DAMAGE_STORED_KEY] integerValue];
  _damageWasDealt = [[stateDict objectForKey:DAMAGE_DEALT_KEY] boolValue];
  [self.orbLayer deserialize:[stateDict objectForKey:BOARD_CONFIG_KEY]];
  
  int curStage = (int)[[stateDict objectForKey:CUR_STAGE_KEY] integerValue];
  int enemyHealth = (int)[[stateDict objectForKey:ENEMY_HEALTH_KEY] integerValue];
  if (curStage < self.enemyTeam.count) {
    BattlePlayer *bp = self.enemyTeam[curStage];
    bp.curHealth = enemyHealth;
  }
  
  _totalDamageTaken = (int)[[stateDict objectForKey:TOTAL_DAMAGE_TAKEN_KEY] integerValue];
  _totalComboCount = (int)[[stateDict objectForKey:TOTAL_COMBO_COUNT_KEY] integerValue];
  
  // Use the c array's length as opposed to the NSData's in case the c array is shorter
  NSData *orbCounts = [stateDict objectForKey:ORB_COUNTS_KEY];
  [orbCounts getBytes:_orbCounts length:sizeof(_orbCounts)];
  
  NSData *powerupCounts = [stateDict objectForKey:POWERUP_COUNTS_KEY];
  [powerupCounts getBytes:_powerupCounts length:sizeof(_powerupCounts)];
}

@end
