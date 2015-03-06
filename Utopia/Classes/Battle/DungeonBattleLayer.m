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
#import "SkillManager.h"
#import "ChartboostDelegate.h"

#import <zlib.h>

@implementation DungeonBattleLayer

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix layoutProto:(BoardLayoutProto *)layoutProto
{
  self = [super initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:bgdPrefix layoutProto:layoutProto];
  if (! self)
    return nil;
  
  self.shouldShowContinueButton = YES;
  
  return self;
}

- (CCSprite *) getCurrentEnemyLoot {
  GameState *gs = [GameState sharedGameState];
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  TaskStageMonsterProto *monster = [stage stageMonstersAtIndex:0];
  CCSprite *ed = nil;
  if (monster.puzzlePieceDropped) {
    BOOL isComplete = monster.puzzlePieceMonsterDropLvl > 0;
    
    MonsterProto *mp = [gs monsterWithId:monster.puzzlePieceMonsterId];
    NSString *fileName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:(isComplete ? @"ball.png" : @"piece.png")]];
    ed = [CCSprite spriteWithImageNamed:fileName];
  } else if (monster.hasItemId) {
    ItemProto *item = [gs itemForId:monster.itemId];
    ed = [CCSprite spriteWithImageNamed:item.imgName];
  }
  return ed;
}

- (void) youWon {
  [super youWon];
  [self.endView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo droplessStageNums:self.droplessStageNums] isWin:YES allowsContinue:NO continueCost:0];
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:YES droplessStageNums:self.droplessStageNums delegate:self];
  [self makeGoCarrotCalls];
  
  [self saveCurrentStateWithForceFlush:YES];
}

- (void) youLost {
  [super youLost];
  
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  [self.endView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo tillStage:_curStage-1 droplessStageNums:self.droplessStageNums] isWin:NO allowsContinue:YES continueCost:gemsAmount];
  
  [self saveCurrentStateWithForceFlush:YES];
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
  
  self.userMonstersGained = proto.updatedOrNewList;
  self.itemIdGained = proto.userItem.itemId;
  self.sectionName = proto.taskMapSectionName;
  
  [self sendAnalytics];
  
  if (_waitingForEndDungeonResponse) {
    [self exitFinal];
  }
}

- (NSDictionary *) battleCompleteValues {
  NSMutableDictionary *vals = [NSMutableDictionary dictionary];
  if (self.userMonstersGained.count) {
    vals[BATTLE_USER_MONSTERS_GAINED_KEY] = self.userMonstersGained;
  }
  
  if (self.itemIdGained) {
    vals[BATTLE_SECTION_COMPLETE_KEY] = @{BATTLE_SECTION_NAME_KEY: self.sectionName, BATTLE_SECTION_ITEM_KEY : @(self.itemIdGained)};
  }
  
  if (_wonBattle && _isFirstTime) {
    // Set the dialogue
    GameState *gs = [GameState sharedGameState];
    FullTaskProto *ftp = [gs taskWithId:self.dungeonInfo.taskId];
    if (ftp.hasInitialDefeatedDialogue) {
      vals[BATTLE_DEFEATED_DIALOGUE_KEY] = ftp.initialDefeatedDialogue;
    }
  }
  
  return vals;
}

- (void) checkQuests {
  if (!_checkedQuests) {
    _checkedQuests = YES;
    if (_wonBattle) {
      [QuestUtil checkQuestsForDungeon:self.dungeonInfo];
    }
    [AchievementUtil checkAchievementsForDungeonBattleWithOrbCounts:_totalOrbCounts powerupCounts:_powerupCounts comboCount:_totalComboCount damageTaken:_totalDamageTaken dungeonInfo:self.dungeonInfo wonBattle:_wonBattle];
  }
}

- (void) sendAnalytics {
  NSMutableArray *mobsterIdsUsed = [NSMutableArray array];
  for (BattlePlayer *bp in self.myTeam) {
    [mobsterIdsUsed addObject:@(bp.monsterId)];
  }
  
  NSMutableArray *mobsterIdsGained = [NSMutableArray array];
  int numPiecesGained = 0;
  if (_wonBattle) {
    for (TaskStageProto *stage in self.dungeonInfo.tspList) {
      for (TaskStageMonsterProto *tsm in stage.stageMonstersList) {
        if (tsm.puzzlePieceDropped) {
          numPiecesGained++;
          [mobsterIdsGained addObject:@(tsm.monsterId)];
        }
      }
    }
  }
  
  NSString *outcome = _wonBattle ? @"Win" : _didRunaway ? @"Flee" : @"Lose";
  [Analytics pveMatchEnd:_wonBattle numEnemiesDefeated:_curStage type:self.dungeonType mobsterIdsUsed:mobsterIdsUsed numPiecesGained:numPiecesGained mobsterIdsGained:mobsterIdsGained totalRounds:(int)self.enemyTeam.count dungeonId:self.dungeonInfo.taskId numContinues:_numContinues outcome:outcome];
}

#pragma mark - Run away

// REMOVING RUN AWAY
//- (IBAction)forfeitClicked:(id)sender {
//  // Make sure a move is allowed
//  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
//    [[NSBundle mainBundle] loadNibNamed:@"RunawayMiddleView" owner:self options:nil];
//    self.runawayPercentLabel.text = [NSString stringWithFormat:@"%d%%", (int)([self runAwayChance]*100)];
//    [GenericPopupController displayNegativeConfirmationWithMiddleView:self.runawayMiddleView
//                                                                title:@"Run Away?"
//                                                           okayButton:@"Run Away"
//                                                         cancelButton:@"Cancel"
//                                                             okTarget:self
//                                                           okSelector:@selector(attemptRunaway)
//                                                         cancelTarget:nil
//                                                       cancelSelector:nil];
//  }
//}

- (float) runAwayChance {
#ifdef DEBUG
  return 1.f;
#else
  Globals *gl = [Globals sharedGlobals];
  return gl.battleRunAwayBasePercent+_numAttemptedRunaways*gl.battleRunAwayIncrement;
#endif
}

- (void) attemptRunaway {
  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
    BOOL success = drand48() < [self runAwayChance];
    if (success) {
      [self runawaySuccess];
    } else {
      [self setMovesLeft:0 animated:NO];
      
      _myDamageDealt = 0;
      _numAttemptedRunaways++;
      [self saveCurrentStateWithForceFlush:YES];
      
      [self runawayFailed];
    }
    
    [self.hudView removeButtons];
    [self.orbLayer.bgdLayer turnTheLightsOff];
    [self.orbLayer disallowInput];
  }
}

- (void) runawaySuccess {
  _didRunaway = YES;
  [self animateImageLabel:@"runawaysuccess.png" completion:^{
    [self youLost];
  }];
  
  [self makeMyPlayerWalkOutWithBlock:nil];
  self.myPlayer = nil;
  self.myPlayerObject = nil;
}

- (void) runawayFailed {
  [self animateImageLabel:@"runawayfailed.png" completion:^{
    [self beginNextTurn];
  }];
}

- (void) animateImageLabel:(NSString *)imgName completion:(void (^)(void))completion {
  CCSprite *label = [CCSprite spriteWithImageNamed:imgName];
  [self addChild:label];
  label.position = ccp((self.orbLayer.position.x-self.orbLayer.contentSize.width/2)/2, self.contentSize.height/2);
  
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
      [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:_wonBattle droplessStageNums:self.droplessStageNums delegate:self];
    }
    
    if (!_receivedEndDungeonResponse) {
      _waitingForEndDungeonResponse = YES;
      
      [self.endView spinnerOnDone];
    } else {
      [self exitFinal];
    }
  }
}

- (void) exitFinal {
  [super exitFinal];
  
  if (!self.itemIdGained) {
    [ChartboostDelegate firePveMatch];
  }
}

- (void) continueConfirmed {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  
  if (gs.gems < gemsAmount) {
    [GenericPopupController displayNotificationViewWithText:@"You do not have enough gems to continue this dungeon." title:@"Not enough gems"];
  } else {
    if (gemsAmount > 0) {
      [[OutgoingEventController sharedOutgoingEventController] reviveInDungeon:self.dungeonInfo.userTaskUuid taskId:self.dungeonInfo.taskId myTeam:self.myTeam];
    }
    [super continueConfirmed];
    _numAttemptedRunaways = 0;
    _didRunaway = NO;
    _numContinues++;
  }
}

#pragma mark - Waiting for server

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  GameState *gs = [GameState sharedGameState];
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  
  if (proto.status == BeginDungeonResponseProto_BeginDungeonStatusSuccess) {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableSet *skillSideEffects = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    _isFirstTime = ![gs isTaskCompleted:proto.taskId];
    for (TaskStageProto *tsp in proto.tspList) {
      TaskStageMonsterProto *tsm = [tsp.stageMonstersList objectAtIndex:0];
      UserMonster *um = [UserMonster userMonsterWithTaskStageMonsterProto:tsm];
      BattlePlayer *bp = [BattlePlayer playerWithMonster:um dmgMultiplier:tsm.dmgMultiplier monsterType:tsm.monsterType];
      [enemyTeam addObject:bp];
      
      if (_isFirstTime) {
        bp.dialogue = !tsm.hasInitialD ? nil : tsm.initialD;
      } else {
        bp.dialogue = !tsm.hasDefaultD ? nil : tsm.defaultD;
      }
      
      if (bp.spritePrefix) {
        [set addObject:bp.spritePrefix];
      }
      [skillSideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:YES]];
    }
    self.enemyTeam = enemyTeam;
    
    for (BattlePlayer *bp in self.myTeam) {
      if (bp.spritePrefix) {
        [set addObject:bp.spritePrefix];
      }
      [skillSideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:NO]];
    }
    
    self.dungeonInfo = proto;
    
    _isDownloading = YES;
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      [Globals downloadAllAssetsForSkillSideEffects:skillSideEffects completion:^{
        _isDownloading = NO;
      }];
    }];
  } else {
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) resumeFromUserTask:(MinimumUserTaskProto *)task stages:(NSArray *)stages {
  BeginDungeonResponseProto_Builder *bldr = [BeginDungeonResponseProto builder];
  bldr.taskId = task.taskId;
  bldr.userTaskUuid = task.userTaskUuid;
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
  
  @try {
    NSError *error = nil;
    
    NSData *jsonDataUnzipped = [self gzipInflate:task.clientState];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonDataUnzipped options:NSJSONReadingMutableContainers error:&error];
    
    if (!error) {
      [self attemptToResumeState:dict];
    } else {
      LNLog(@"Unable to deserialize JSON. error: %@", error);
    }
  } @catch (NSException *e) {
    LNLog(@"Exception in de-serialize battle state. %@", e);
  }
}

- (void) moveToNextEnemy {
  BOOL playerFirst = NO;
  if(_curStage+1 < self.dungeonInfo.tspList.count) {
    TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage+1];
    playerFirst = stage.attackerAlwaysHitsFirst;
  }
  [super moveToNextEnemyWithPlayerFirst:playerFirst];
  [self sendServerDungeonProgress];
  
  // Reset on each enemy
  if (!_isResumingState) {
    _numAttemptedRunaways = 0;
  }
}

- (BOOL) createNextEnemyObject {
  int stage = _curStage;
  
  BOOL success = [super createNextEnemyObject];
  
  // We must check if we're skipping over the current stage (i.e. cake kid blew up when we resumed
  if (stage+1 < _curStage) {
    _isResumingState = NO;
  }
  
  return success;
}

- (void) sendServerDungeonProgress {
  if (_hasStarted && _curStage < self.enemyTeam.count) {
    [[OutgoingEventController sharedOutgoingEventController] progressDungeon:self.myTeam dungeonInfo:self.dungeonInfo newStageNum:_curStage dropless:([self.droplessStageNums containsObject:@(_curStage-1)])];
    [self saveCurrentStateWithForceFlush:YES];
  }
}

// checkEnemyHealth is a better place for saving because it's called after both move and skill trigger for that move finish
/*- (void) moveComplete {
 [super moveComplete];
 [self saveCurrentState];
 }*/

- (BOOL) checkEnemyHealth {
  [self saveCurrentStateWithForceFlush:NO];
  return [super checkEnemyHealth];
}

- (void) checkMyHealth {
  [super checkMyHealth];
  [self saveCurrentStateWithForceFlush:NO];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector
{
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker usingAbility:usingAbility withTarget:target withSelector:selector];
  
  if (enemyIsAttacker && ! usingAbility) {
    if (! usingAbility) {
      _damageWasDealt = YES;
    }
    [self saveCurrentStateWithForceFlush:NO];
  }
  
  // Record analytics
  BattlePlayer *attkr = enemyIsAttacker ? self.enemyPlayerObject : self.myPlayerObject;
  BattlePlayer *defndr = enemyIsAttacker ? self.myPlayerObject : self.enemyPlayerObject;
  BOOL isKill = defndr.curHealth <= 0;
  BOOL isFinalBlow = isKill && [self checkIfTeamDead:enemyIsAttacker];
  int skillId = usingAbility ? (enemyIsAttacker ? attkr.defensiveSkillId : attkr.offensiveSkillId) : 0;
  
  [Analytics pveHit:self.dungeonInfo.taskId isEnemyAttack:enemyIsAttacker attackerMonsterId:attkr.monsterId attackerLevel:attkr.level attackerHp:attkr.curHealth defenderMonsterId:defndr.monsterId defenderLevel:defndr.level defenderHp:defndr.curHealth damageDealt:damageDone hitOrder:self.battleSchedule.numDequeued isKill:isKill isFinalBlow:isFinalBlow skillId:skillId numContinues:_numContinues];
}

- (BOOL) checkIfTeamDead:(BOOL)myTeam {
  if (myTeam) {
    BOOL isDead = YES;
    for (BattlePlayer *bp in self.myTeam) {
      if (bp.curHealth > 0) {
        isDead = NO;
      }
    }
    return isDead;
  } else {
    // Just check last mobster
    BattlePlayer *last = [self.enemyTeam lastObject];
    return last.curHealth <= 0;
  }
}

- (BattlePlayer *) firstMyPlayer {
  // If we are resuming state, check that the member is viable. If not, recalculate the schedule.
  BattlePlayer *bp = nil;
  if (_isResumingState) {
    for (BattlePlayer *b in self.myTeam) {
      if ([b.userMonsterUuid isEqualToString:_resumedUserMonsterUuid]) {
        bp = b;
      }
    }
    
    if (bp.curHealth <= 0) {
      bp = nil;
      self.battleSchedule = nil;
      [self.hudView.battleScheduleView setBattleSchedule:nil];
    }
  }
  
  if (!bp) {
    bp = [super firstMyPlayer];
  }
  return bp;
}

- (void) begin {
  [super begin];
  
  if (self.myPlayerObject) {
    [self displayOrbLayer];
  } else {
    [self youLost];
  }
}

- (void) createScheduleWithSwap:(BOOL)swap {
  if(_curStage >= 0) {
    TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
    [self createScheduleWithSwap:swap playerHitsFirst:stage.attackerAlwaysHitsFirst];
  }
}


- (void) createScheduleWithSwap:(BOOL)swap playerHitsFirst:(BOOL)playerFirst {
  if (!_isResumingState || !self.battleSchedule.schedule) {
    [super createScheduleWithSwap:swap playerHitsFirst:playerFirst];
  }
}

- (void) processNextTurn:(float)delay{
  [super processNextTurn:delay];
  _isResumingState = NO;
}

- (void) beginNextTurn {
  if (self.currentEnemy && _displayedWaveNumber && _reachedNextScene && self.enemyPlayerObject.dialogue) {
    DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:self.enemyPlayerObject.dialogue];
    dvc.delegate = self;
    GameViewController *gvc = [GameViewController baseController];
    [gvc addChildViewController:dvc];
    dvc.view.frame = gvc.view.bounds;
    [gvc.view addSubview:dvc.view];
    
    self.enemyPlayerObject.dialogue = nil;
  } else {
    [super beginNextTurn];
  }
}

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  Globals *gl = [Globals sharedGlobals];
  if(index == SHOW_PLAYER_SKILL_BUTTON_DIALOGUE_INDEX && [self dungeonInfo].taskId == gl.taskIdOfFirstSkill) {
    dvc.paused = YES;
    [self forceSkillClickOver:dvc];
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self beginNextTurn];
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
    
    _myDamageDealt = damage;
    
    [self setMovesLeft:moves animated:NO];
    
    if (_movesLeft < NUM_MOVES_PER_TURN) {
      [self.hudView removeSwapButtonAnimated:NO];
    }
  } else {
    [super beginMyTurn];
    [self saveCurrentStateWithForceFlush:YES];
  }
  
  _damageWasDealt = NO;
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    if (!self.enemyTeam.count || _isDownloading) {
      _numTimesNotResponded++;
      if (_isDownloading || _numTimesNotResponded < 10) {
        if (_isDownloading && _numTimesNotResponded % 4 == 0) {
          [self.myPlayer initiateSpeechBubbleWithText:@"Hmm.. Enemies are calibrating."];
        }
        
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

#pragma mark - Skipping Stage

#ifndef APPSTORE
- (void) elementButtonClicked {
  // Skip the enemy if it is not an app store build
  [GenericPopupController displayConfirmationWithDescription:@"Would you like to skip this stage?" title:@"Skip Stage?" okayButton:@"Skip" cancelButton:@"Cancel" target:self selector:@selector(skipStage)];
}

- (void) skipStage {
  [self.orbLayer disallowInput];
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self.hudView removeButtons];
  self.currentEnemy.healthBar.percentage = 0.01f;
  [self dealDamage:self.enemyPlayerObject.curHealth enemyIsAttacker:NO usingAbility:NO withTarget:self withSelector:@selector(checkEnemyHealth)];
}
#endif

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
#define RUNAWAY_COUNT_KEY @"RunawayCountKey"
#define DROPLESS_STAGES_KEY @"DroplessStageNumsKey"

#define SCHEDULE_KEY @"BattleScheduleKey"
#define SCHEDULE_INDEX_KEY @"BattleScheduleIndexKey"
#define MY_USER_MONSTER_ID_KEY @"MyUserIdMonsterKey"
#define MY_TEAM_KEY @"MyTeamKey"
#define ENEMY_TEAM_KEY @"EnemyTeamKey"

#define SKILL_MANAGER_KEY @"BattleSkillManager"

- (void) saveCurrentStateWithForceFlush:(BOOL)forceFlush {
  NSDictionary *state = [self serializeState];
  
  //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  //[defaults setObject:state forKey:DUNGEON_DEFAULT_KEY];
  
  NSError *error = nil;
  
  @try {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:state options:0 error:&error];
    NSData *jsonDataZipped = [self gzipDeflate:jsonData];
    
    if (!error) {
      [[OutgoingEventController sharedOutgoingEventController] updateClientState:jsonDataZipped shouldFlush:forceFlush];
    } else {
      LNLog(@"Unable to save client state. Error: %@", error);
    }
  } @catch (NSException *e) {
    LNLog(@"Exception in serialize battle state. %@", e);
  }
}

- (void) attemptToResumeState:(NSDictionary *)dict {
  //  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  //  NSDictionary *dict = [defaults objectForKey:DUNGEON_DEFAULT_KEY];
  
  if (dict) {
    NSString *userTaskUuid = [dict objectForKey:USER_TASK_KEY];
    NSInteger curStage = [[dict objectForKey:CUR_STAGE_KEY] integerValue];
    if ([self.dungeonInfo.userTaskUuid isEqualToString:userTaskUuid] && curStage == _curStage+1) {
      [self deserializeAndResumeState:dict];
      _isResumingState = YES;
    } else {
      //[defaults removeObjectForKey:DUNGEON_DEFAULT_KEY];
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
  
  if (self.dungeonInfo.userTaskUuid) {
    [dict setObject:self.dungeonInfo.userTaskUuid forKey:USER_TASK_KEY];
  }
  
  [dict setObject:@(_numAttemptedRunaways) forKey:RUNAWAY_COUNT_KEY];
  
  if (self.myPlayerObject.userMonsterUuid) {
    [dict setObject:self.myPlayerObject.userMonsterUuid forKey:MY_USER_MONSTER_ID_KEY];
  }
  
  NSMutableArray *myTeam = [NSMutableArray array];
  for (BattlePlayer *bp in self.myTeam) {
    [myTeam addObject:bp.serialize];
  }
  [dict setObject:myTeam forKey:MY_TEAM_KEY];
  
  NSMutableArray *enemyTeam = [NSMutableArray array];
  for (BattlePlayer *bp in self.enemyTeam) {
    [enemyTeam addObject:bp.serialize];
  }
  [dict setObject:enemyTeam forKey:ENEMY_TEAM_KEY];
  
  if (self.battleSchedule.schedule) {
    [dict setObject:self.battleSchedule.schedule forKey:SCHEDULE_KEY];
    [dict setObject:@(self.battleSchedule.currentIndex + (_firstTurn ? 1 : 0)) forKey:SCHEDULE_INDEX_KEY];
    // For the situation when user leaves before the first move has been dequeued
  }
  
  [dict setObject:self.droplessStageNums forKey:DROPLESS_STAGES_KEY];
  
  // Achievement info
  [dict setObject:@(_totalDamageTaken) forKey:TOTAL_DAMAGE_TAKEN_KEY];
  [dict setObject:@(_totalComboCount) forKey:TOTAL_COMBO_COUNT_KEY];
  
  NSData *orbCounts = [NSData dataWithBytes:_totalOrbCounts length:sizeof(_totalOrbCounts)];
  NSString *orbCountsStr = [orbCounts base64EncodedStringWithOptions:0];
  [dict setObject:orbCountsStr forKey:ORB_COUNTS_KEY];
  
  NSData *powerupCounts = [NSData dataWithBytes:_powerupCounts length:sizeof(_powerupCounts)];
  NSString *powerupCountsStr = [powerupCounts base64EncodedStringWithOptions:0];
  [dict setObject:powerupCountsStr forKey:POWERUP_COUNTS_KEY];
  
  [dict setObject:skillManager.serialize forKey:SKILL_MANAGER_KEY];
  
  return dict;
}

- (void) deserializeAndResumeState:(NSDictionary *)stateDict {
  [self setMovesLeft:(int)[[stateDict objectForKey:MOVES_LEFT_KEY] integerValue] animated:NO];
  
  _myDamageDealt = (int)[[stateDict objectForKey:DAMAGE_STORED_KEY] integerValue];
  _damageWasDealt = [[stateDict objectForKey:DAMAGE_DEALT_KEY] boolValue];
  _numAttemptedRunaways = (int)[[stateDict objectForKey:RUNAWAY_COUNT_KEY] integerValue];
  [self.orbLayer deserialize:[stateDict objectForKey:BOARD_CONFIG_KEY]];
  
  int curStage = (int)[[stateDict objectForKey:CUR_STAGE_KEY] integerValue];
  int enemyHealth = (int)[[stateDict objectForKey:ENEMY_HEALTH_KEY] integerValue];
  
  if (curStage < self.enemyTeam.count) {
    BattlePlayer *bp = self.enemyTeam[curStage];
    bp.curHealth = enemyHealth;
    bp.dialogue = nil;
  }
  
  _totalDamageTaken = (int)[[stateDict objectForKey:TOTAL_DAMAGE_TAKEN_KEY] integerValue];
  _totalComboCount = (int)[[stateDict objectForKey:TOTAL_COMBO_COUNT_KEY] integerValue];
  
  [self.droplessStageNums addObjectsFromArray:[stateDict objectForKey:DROPLESS_STAGES_KEY]];
  
  // Use the c array's length as opposed to the NSData's in case the c array is shorter
  // Check that we are not using the legacy nsdata vs nsstring.
  id orbCountsStr = [stateDict objectForKey:ORB_COUNTS_KEY];
  NSData *orbCounts = [orbCountsStr isKindOfClass:[NSData class]] ? orbCountsStr : [[NSData alloc] initWithBase64EncodedString:orbCountsStr options:0];
  [orbCounts getBytes:_totalOrbCounts length:sizeof(_totalOrbCounts)];
  
  id powerupCountsStr = [stateDict objectForKey:POWERUP_COUNTS_KEY];
  NSData *powerupCounts = [powerupCountsStr isKindOfClass:[NSData class]] ? powerupCountsStr : [[NSData alloc] initWithBase64EncodedString:powerupCountsStr options:0];
  [powerupCounts getBytes:_powerupCounts length:sizeof(_powerupCounts)];
  
  NSArray *schedule = [stateDict objectForKey:SCHEDULE_KEY];
  int curIdx = (int)[[stateDict objectForKey:SCHEDULE_INDEX_KEY] integerValue];
  self.battleSchedule = [[BattleSchedule alloc] initWithSequence:schedule currentIndex:curIdx-1];
  _shouldDisplayNewSchedule = YES;
  
  [self.hudView.battleScheduleView setBattleSchedule:self.battleSchedule];
  
  _resumedUserMonsterUuid = [stateDict objectForKey:MY_USER_MONSTER_ID_KEY];
  
  // Need to do this in case a monster came out of healing while user was in the middle of a dungeon
  NSArray *savedMyTeam = [stateDict objectForKey:MY_TEAM_KEY];
  if (savedMyTeam.count) {
    NSMutableArray *newTeam = [NSMutableArray array];
    for (NSDictionary *dict in savedMyTeam) {
      BattlePlayer *bp = [[BattlePlayer alloc] init];
      [bp deserialize:dict];
      [newTeam addObject:bp];
    }
    self.myTeam = newTeam;
  }
  
  NSArray *savedEnemyTeam = [stateDict objectForKey:ENEMY_TEAM_KEY];
  if (savedEnemyTeam.count) {
    NSMutableArray *newTeam = [NSMutableArray array];
    for (NSDictionary *dict in savedEnemyTeam) {
      BattlePlayer *bp = [[BattlePlayer alloc] init];
      [bp deserialize:dict];
      [newTeam addObject:bp];
    }
    self.enemyTeam = newTeam;
  }
  
  [skillManager deserialize:[stateDict objectForKey:SKILL_MANAGER_KEY]];
}

#pragma mark - Gzip

- (NSData *)gzipInflate:(NSData*)data
{
  if ([data length] == 0) return data;
  
  unsigned full_length = (uInt)[data length];
  unsigned half_length = (uInt)[data length] / 2;
  
  NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
  BOOL done = NO;
  int status;
  
  z_stream strm;
  strm.next_in = (Bytef *)[data bytes];
  strm.avail_in = (uInt)[data length];
  strm.total_out = 0;
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  
  if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
  while (!done)
  {
    // Make sure we have enough room and reset the lengths.
    if (strm.total_out >= [decompressed length])
      [decompressed increaseLengthBy: half_length];
    strm.next_out = [decompressed mutableBytes] + strm.total_out;
    strm.avail_out = (uInt)([decompressed length] - strm.total_out);
    
    // Inflate another chunk.
    status = inflate (&strm, Z_SYNC_FLUSH);
    if (status == Z_STREAM_END) done = YES;
    else if (status != Z_OK) break;
  }
  if (inflateEnd (&strm) != Z_OK) return nil;
  
  // Set real length.
  if (done)
  {
    [decompressed setLength: strm.total_out];
    return [NSData dataWithData: decompressed];
  }
  else return nil;
}

- (NSData *)gzipDeflate:(NSData*)data
{
  if ([data length] == 0) return data;
  
  z_stream strm;
  
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  strm.opaque = Z_NULL;
  strm.total_out = 0;
  strm.next_in=(Bytef *)[data bytes];
  strm.avail_in = (uInt)[data length];
  
  // Compresssion Levels:
  //   Z_NO_COMPRESSION
  //   Z_BEST_SPEED
  //   Z_BEST_COMPRESSION
  //   Z_DEFAULT_COMPRESSION
  
  if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
  
  NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
  
  do {
    
    if (strm.total_out >= [compressed length])
      [compressed increaseLengthBy: 16384];
    
    strm.next_out = [compressed mutableBytes] + strm.total_out;
    strm.avail_out = (uInt)([compressed length] - strm.total_out);
    
    deflate(&strm, Z_FINISH);
    
  } while (strm.avail_out == 0);
  
  deflateEnd(&strm);
  
  [compressed setLength: strm.total_out];
  return [NSData dataWithData:compressed];
}

@end
