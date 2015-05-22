//
//  ReplayBattleLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ReplayBattleLayer.h"
#import "GameState.h"
#import "GenericPopupController.h"
#import "ReplayOrbMainLayer.h"
#import "CCDirector_Private.h"
#import "SkillManager.h"
#import "GameViewController.h"
#import "SoundEngine.h"
#import "Reward.h"

#define DELAY_KEY @"DELAY"
#define SWAP_TOON_KEY @"SWAP_TOON"

@implementation ReplayBattleLayer

#pragma mark - Setup

- (id) initWithReplay:(CombatReplayProto *)replay {
  _replay = replay;
  
  _battleSpeeds = @[ @1.f, @2.f, @4.f ];
  _battleSpeedIndex = 0;
  [self resetTimeScale];
  
  NSMutableArray *myteam = [NSMutableArray array];
  for (CombatReplayMonsterSnapshot *crms in replay.playerTeamList) {
    UserMonster *um = [UserMonster userMonsterWithReplayMonsterSnapshotProto:crms];
    um.userMonsterUuid = [NSString stringWithFormat:@"%lu", (unsigned long)myteam.count];
    [myteam addObject:um];
  }
  
  CGSize boardSize = [replay hasBoard] ? CGSizeMake(replay.board.width, replay.board.height) : CGSizeMake(replay.boardWidth, replay.boardHeight);
  
  if ((self = [super initWithMyUserMonsters:myteam puzzleIsOnLeft:NO gridSize:boardSize bgdPrefix:replay.groundImgPrefix layoutProto:([replay hasBoard] ? replay.board : nil)]))
  {
    _combatSteps = [NSMutableArray array];
    for (CombatReplayStepProto *crsp in replay.stepsList) {
      [_combatSteps addObject:crsp];
    }
  }
  
  [self buildEnemyTeam];
  [self downloadAllImages];
  
  [self.mainView.hudView activateReplayMode];
  
  return self;
}

- (void)initOrbLayer {
  ReplayOrbMainLayer *ol;
  
  if (_layoutProto)
    ol = [[ReplayOrbMainLayer alloc] initWithLayoutProto:_replay.board andHistory:_replay.orbsList];
  else if (_replay.pvpObstaclesList.count)
    ol = [[ReplayOrbMainLayer alloc] initWithGridSize:CGSizeMake(_replay.boardWidth, _replay.boardHeight) userBoardObstacles:_replay.pvpObstaclesList andHistory:_replay.orbsList];
  else
    ol = [[ReplayOrbMainLayer alloc] initWithGridSize:CGSizeMake(_replay.boardWidth, _replay.boardHeight) numColors:6 andHistory:_replay.orbsList];
  
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void)begin {
  [super begin];
  [self displayOrbLayer];
}

- (void) buildEnemyTeam {
  
  NSMutableArray *defendingTeam = [NSMutableArray array];
  for (CombatReplayMonsterSnapshot *crms in _replay.enemyTeamList) {
    UserMonster *um = [UserMonster userMonsterWithReplayMonsterSnapshotProto:crms];
    um.userMonsterUuid = [NSString stringWithFormat:@"%lu", (unsigned long)defendingTeam.count];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    [defendingTeam addObject:bp];
    bp.slotNum = (int)defendingTeam.count;
  }
  self.enemyTeam = defendingTeam;
  
}

- (void) downloadAllImages {
  NSMutableSet *imagePrefixes = [NSMutableSet set];
  NSMutableSet *sideEffects = [NSMutableSet set];
  
  for (BattlePlayer *bp in self.myTeam) {
    if (bp.spritePrefix)
      [imagePrefixes addObject:bp.spritePrefix];
    [sideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:NO]];
  }
  
  for (BattlePlayer *bp in self.enemyTeam) {
    if (bp.spritePrefix)
      [imagePrefixes addObject:bp.spritePrefix];
    [sideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:YES]];
  }
  
  _isDownloading = YES;
  [Globals downloadAllFilesForSpritePrefixes:imagePrefixes.allObjects completion:^{
    [Globals downloadAllAssetsForSkillSideEffects:sideEffects completion:^{
      _isDownloading = NO;
    }];
  }];
}

- (void)reachedNextScene {
  if (!_hasStarted) {
    if (!self.enemyTeam.count || _isDownloading) {
      _numTimesNotResponded++;
      if (_isDownloading || _numTimesNotResponded < 10) {
        if (_isDownloading && _numTimesNotResponded % 4 == 0) {
          [self.mainView.myPlayer initiateSpeechBubbleWithText:@"Hmm.. Enemies are calibrating."];
        }
        
        [self.mainView.myPlayer beginWalking];
        [self.mainView.bgdLayer scrollToNewScene];
      } else {
        [self.mainView.myPlayer stopWalking];
        [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Tap okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
      }
    } else {
      [self fireEvent:loadingCompleteEvent userInfo:nil error:nil];
      _hasStarted = YES;
    }
  } else {
    [super reachedNextScene];
  }
}

//Need to change some of the state machine behavior
- (void) setupStateMachine {
  self.battleStateMachine = [BattleStateMachine new];
  
  BattleState *initialState = [BattleState stateWithName:@"Initial Load" andType:CombatReplayStepTypeBattleInitialization];
  
  BattleState *spawnEnemyState = [BattleState stateWithName:@"Spawn Enemy" andType:CombatReplayStepTypeSpawnEnemy];
  [spawnEnemyState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self moveToNextEnemy];
  }];
  
  BattleState *playerSwapState = [BattleState stateWithName:@"Swap Player" andType:CombatReplayStepTypePlayerSwap];
  [playerSwapState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    BattlePlayer* bp;
    for (BattlePlayer *b in self.myTeam)
      if (b.slotNum == self.currStep.swapIndex)
        bp = b;
        
    if (bp)
      [self deployBattleSprite:bp];
  }];
  
  BattleState *playerTurn = [BattleState stateWithName:@"Player Turn" andType:CombatReplayStepTypePlayerTurn];
  [playerTurn setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self beginMyTurn];
  }];
  
  BattleState *playerMove = [BattleState stateWithName:@"Player Move" andType:CombatReplayStepTypePlayerMove];
  [playerMove setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self performBlockAfterDelay:.5 / self.battleSpeed block:^{
      [self startMyMove];
    }];
  }];
  
  BattleState *playerAttack = [BattleState stateWithName:@"Player Attack" andType:CombatReplayStepTypePlayerAttack];
  [playerAttack setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
      _myDamageDealtUnmodified = self.currStep.unmodifiedDamage;
      _myDamageDealt = self.currStep.modifiedDamage;
      [self doMyAttackAnimation];
  }];
  
  BattleState *enemyTurn = [BattleState stateWithName:@"Enemy Attack" andType:CombatReplayStepTypeEnemyTurn];
  [enemyTurn setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self beginEnemyTurn:[transition.userInfo[DELAY_KEY] floatValue]];
  }];
  
  BattleState *playerVictory = [BattleState stateWithName:@"Player Victory" andType:CombatReplayStepTypePlayerVictory];
  [playerVictory setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self youWon];
  }];
  
  BattleState *playerDeath = [BattleState stateWithName:@"Player Death" andType:CombatReplayStepTypePlayerDeath];
  [playerDeath setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self currentMyPlayerDied];
  }];
  
  BattleState *playerRevive = [BattleState stateWithName:@"Player Revive" andType:CombatReplayStepTypePlayerRevive];
  [playerRevive setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self continueConfirmed];
  }];
  
  BattleState *playerRun = [BattleState stateWithName:@"Player Run" andType:CombatReplayStepTypePlayerRun];
  [playerRun setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self youForfeited];
  }];
  
  BattleState *playerLose = [BattleState stateWithName:@"Player Lose" andType:CombatReplayStepTypePlayerLose];
  [playerLose setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self youLost];
  }];
  
  [self.battleStateMachine addStates:@[initialState, spawnEnemyState, playerSwapState, playerTurn, playerMove, playerAttack, enemyTurn, playerVictory, playerDeath, playerRevive, playerRun, playerLose]];
  
  loadingCompleteEvent = [TKEvent eventWithName:@"Loading complete" transitioningFromStates:@[initialState] toState:spawnEnemyState];
  nextEnemyEvent = [TKEvent eventWithName:@"Spawn Next Enemy" transitioningFromStates:@[ enemyTurn, playerAttack, playerMove ] toState:spawnEnemyState];
  playerSwapEvent = [TKEvent eventWithName:@"Do Swap Players" transitioningFromStates:@[playerTurn, playerDeath, playerMove, playerRevive] toState:playerSwapState];
  playerTurnEvent = [TKEvent eventWithName:@"Player Turn Start" transitioningFromStates:@[initialState, playerSwapState, spawnEnemyState, playerAttack, enemyTurn] toState:playerTurn];
  playerMoveEvent = [TKEvent eventWithName:@"Player Move Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerMove];
  playerAttackEvent = [TKEvent eventWithName:@"Player Attack Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerAttack];
  enemyTurnEvent = [TKEvent eventWithName:@"Enemy Turn Start" transitioningFromStates:@[initialState, playerAttack, enemyTurn, spawnEnemyState, playerSwapState] toState:enemyTurn];
  playerVictoryEvent = [TKEvent eventWithName:@"Player Win Event" transitioningFromStates:@[playerAttack, playerMove, enemyTurn] toState:playerVictory];
  playerDeathEvent = [TKEvent eventWithName:@"Player Death Event" transitioningFromStates:@[playerAttack, playerMove, enemyTurn] toState:playerDeath];
  playerReviveEvent = [TKEvent eventWithName:@"Player Revive Event" transitioningFromStates:@[playerDeath] toState:playerRevive];
  playerRunEvent = [TKEvent eventWithName:@"Player Run Event" transitioningFromStates:@[playerTurn, playerMove] toState:playerRun];
  playerLoseEvent = [TKEvent eventWithName:@"Player Lose Event" transitioningFromStates:@[playerRun, playerDeath] toState:playerLose];
  
  [self.battleStateMachine addEvents:@[loadingCompleteEvent, nextEnemyEvent, playerSwapEvent, playerTurnEvent, playerMoveEvent, playerAttackEvent, enemyTurnEvent, playerVictoryEvent, playerDeathEvent, playerReviveEvent, playerRunEvent, playerLoseEvent]];
  
  self.battleStateMachine.initialState = initialState;
  
  [self.battleStateMachine activate];
  
}

#pragma mark - Time Controls

- (float)getBattleSpeed {
  return [(NSNumber*)_battleSpeeds[_battleSpeedIndex] floatValue];
}

- (void)resetTimeScale {
  [[[CCDirector sharedDirector] scheduler] setTimeScale:self.battleSpeed];
  [self.mainView.hudView setReplaySpeedLabelValue:self.battleSpeed];
}

- (void)nextTimeScale {
  if (++_battleSpeedIndex >= [_battleSpeeds count])
    _battleSpeedIndex = 0;
  [self resetTimeScale];
}

#pragma mark - State Machine Stepping

- (void)fireEvent:(TKEvent *)event userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
  if ([self.battleStateMachine canFireEvent:event])
    [self startNextStep];
}

- (CombatReplayStepProto *)getCurrStep {
  if (_combatSteps.count)
    return _combatSteps[0];
  @throw [NSException exceptionWithName:@"Out of Steps Exception" reason:@"Attempting to grab info from the current step after the list has been exhausted" userInfo:nil];
  return nil;
}

- (void)startMyMove {
  [self.orbLayer.bgdLayer turnTheLightsOn];
  if (self.currStep.hasItemId) {
    [self useBattleItem];
  } else if (self.currStep.hasMovePos1 && self.currStep.hasMovePos2) {
    [(ReplayOrbMainLayer*)self.orbLayer moveHandBetweenOrbs:[self splitPosInt:self.currStep.movePos1] endPoint:[self splitPosInt:self.currStep.movePos2] withCompletion:^{
      [self doSwapFromCurrStep];
    }];
  } else {
    @throw [NSException exceptionWithName:@"Bad Move" reason:@"Not sufficient move data in current step to recreate move" userInfo:nil];
  }
}

- (void) doSwapFromCurrStep {
  CGPoint pointA = [self splitPosInt:self.getCurrStep.movePos1];
  CGPoint pointB = [self splitPosInt:self.getCurrStep.movePos2];
  BattleOrb *orbA = [self.orbLayer.layout orbAtColumn:pointA.x row:pointA.y];
  BattleOrb *orbB = [self.orbLayer.layout orbAtColumn:pointB.x row:pointB.y];
  BattleSwap *swap = [[BattleSwap alloc] init];
  swap.orbA = orbA;
  swap.orbB = orbB;
  [self.orbLayer checkSwap:swap];
}

- (CGPoint) splitPosInt:(uint32_t)pos {
  return CGPointMake((pos<<24)>>24, pos>>16);
}

- (void) startNextStep {
  [_combatSteps removeObjectAtIndex:0];
  [self.battleStateMachine forceStateWithType:self.currStep.type];
}

- (NSArray*) getCurrStepSchedule {
  NSMutableArray* arr = [NSMutableArray array];
  for (int i = 0; i < self.currStep.schedule.totalTurns; i++) {
    [arr addObject:@(NO)];
  }
  
  for (int i = 0; i < self.currStep.schedule.playerTurnsList.count; i++) {
    int index = [self.currStep.schedule.playerTurnsList[i] intValue];
    [arr setObject:@(YES) atIndexedSubscript:index];
  }
  
  return arr;
}

- (void)createScheduleWithSwap:(BOOL)swap playerHitsFirst:(BOOL)playerFirst {
  if (self.myPlayerObject && self.enemyPlayerObject) {
    self.battleSchedule = [[BattleSchedule alloc] initWithSequence:[self getCurrStepSchedule] currentIndex:self.currStep.schedule.startingTurn];
    _shouldDisplayNewSchedule = YES;
  } else {
    [self.mainView.hudView removeBattleScheduleView];
    self.battleSchedule = nil;
  }
  
  [self.mainView.hudView.battleScheduleView setBattleSchedule:self.battleSchedule];
}

#pragma mark - Vines

- (BOOL)hasVinePos {
  return self.currStep.hasVinePos;
}

- (CGPoint)getVinePos {
  return [self splitPosInt:self.currStep.vinePos];
}

#pragma mark - Items

- (void) useBattleItem {
  BattleItemProto *bip = [[GameState sharedGameState] battleItemWithId:self.currStep.itemId];
  
  switch (bip.battleItemType) {
    case BattleItemTypeHealingPotion:
      [self useHealthPotion:bip];
      break;
      
    case BattleItemTypeBoardShuffle:
      [self useBoardShuffle:bip];
      break;
      
    case BattleItemTypeHandSwap:
      [self useHandSwap:bip];
      break;
      
    case BattleItemTypeOrbHammer:
      [self useOrbHammer:bip];
      break;
      
    case BattleItemTypePutty:
      [self usePutty:bip];
      break;
      
    case BattleItemTypeChillAntidote:
    case BattleItemTypePoisonAntidote:
      [self useSkillAntidote:bip];
      break;
      
    case BattleItemTypeNone:
      break;
  }
}

- (void)useHandSwap:(BattleItemProto *)bip {
  [skillManager showItemPopupOverlay:bip bottomText:@"Orbs Shifted"];
  [(ReplayOrbMainLayer*)self.orbLayer moveHandBetweenOrbs:[self splitPosInt:self.currStep.movePos1] endPoint:[self splitPosInt:self.currStep.movePos2] withCompletion:^{
    [self.orbLayer allowFreeMoveForSingleTurn];
    [self doSwapFromCurrStep];
  }];
}

- (void)useOrbHammer:(BattleItemProto *)bip {
  [skillManager showItemPopupOverlay:bip bottomText:@"Orb Destroyed"];
  CGPoint pointA = [self splitPosInt:self.getCurrStep.movePos1];
  
  [(ReplayOrbMainLayer*)self.orbLayer moveHandBetweenOrbs:pointA endPoint:pointA withCompletion:^{
    [self.orbLayer allowOrbHammerForSingleTurn];
    [(ReplayOrbMainLayer*)self.orbLayer tapDownOnSpace:pointA.x spaceY:pointA.y];
  }];
}

- (void)usePutty:(BattleItemProto *)bip {
  [skillManager showItemPopupOverlay:bip bottomText:@"Hole Covered"];
  CGPoint pointA = [self splitPosInt:self.getCurrStep.movePos1];
  [(ReplayOrbMainLayer*)self.orbLayer moveHandBetweenOrbs:pointA endPoint:pointA withCompletion:^{
    [self.orbLayer allowPuttyForSingleTurn];
    [(ReplayOrbMainLayer*)self.orbLayer tapDownOnSpace:pointA.x spaceY:pointA.y];
  }];
}

- (void)useBoardShuffle:(BattleItemProto *)bip {
  [skillManager showItemPopupOverlay:bip bottomText:@"Board Shuffled"];
  [super useBoardShuffle:bip];
}

#pragma mark - Overrides

- (void)itemsClicked:(id)sender{
  [self nextTimeScale];
}

//Override Share button to be a restart replay button
- (void)shareClicked:(id)sender{
//  [self exitFinal];
  
  [SoundEngine generalButtonClick];
  
  GameViewController *gvc = [GameViewController baseController];
  [gvc restartReplay:_replay];
}

- (int)calculateUnmodifiedEnemyDamage {
  return self.currStep.unmodifiedDamage;
}

- (int)calculateModifiedEnemyDamage:(int)unmodifiedDamage {
  [skillManager modifyDamage:unmodifiedDamage forPlayer:NO];
  return self.currStep.modifiedDamage;
}

- (void)forfeitClicked:(id)sender {
  [GenericPopupController displayNegativeConfirmationWithDescription:@"Exit viewing this replay?"
                                                               title:@"Exit Replay"
                                                          okayButton:@"Exit"
                                                        cancelButton:@"Cancel"
                                                            okTarget:self
                                                          okSelector:@selector(exitFinal)
                                                        cancelTarget:nil
                                                      cancelSelector:nil];
}

- (void)youForfeited {
  [self forfeit];
}

- (void) youWon {
  _battleSpeedIndex = 0;
  [self resetTimeScale];
  [self.mainView.hudView disableItemsView];
  [super youWon];
  [self.endView updateForReplay:[Reward createRewardsForReplay:_replay tillStage:(int)_replay.enemyTeamList.count droplessStageNums:self.droplessStageNums attackerVictory:YES] isWin:YES attackerPerspective:YES];
}

- (void) youLost {
  _battleSpeedIndex = 0;
  [self resetTimeScale];
  [self.mainView.hudView disableItemsView];
  [super youLost];
  [self.endView updateForReplay:[Reward createRewardsForReplay:_replay tillStage:self.enemyPlayerObject.slotNum droplessStageNums:self.droplessStageNums attackerVictory:NO] isWin:NO attackerPerspective:YES];
}

- (void)displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self fireEvent:playerSwapEvent userInfo:nil error:nil];
}

- (CombatReplayProto*)buildReplay {
  return nil;
}

- (void)sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify {
  //Do nothing
}

@end