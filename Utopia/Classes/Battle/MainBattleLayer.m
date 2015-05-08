//
//  NewBattleLayer.m
//  PadClone
//
//  Created by Ashwin Kamath on 8/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainBattleLayer.h"
#import "GameMap.h"
#import "Globals.h"
#import "SoundEngine.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "CCAnimation.h"
#import "CCTextureCache.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import <Kamcord/Kamcord.h>
#import "DestroyedOrb.h"
#import "SkillManager.h"
#import "MonsterPopUpViewController.h"
#import "BattleItemSelectViewController.h"
#import "ClientProperties.h"
#import "ShopViewController.h"
#import "Replay.pb.h"

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define BALLIN_SCORE 400
#define CANTTOUCHTHIS_SCORE 540
#define HAMMERTIME_SCORE 720
#define MAKEITRAIN_SCORE 900

#define DELAY_KEY @"DELAY"
#define SWAP_TOON_KEY @"SWAP_TOON"

#define STRENGTH_FOR_MAX_SHOTS MAKEITRAIN_SCORE

#define PUZZLE_BGD_TAG 1456

@implementation MainBattleLayer

#pragma mark - Properties

- (float)orbLayerDistFromSide {
  return ORB_LAYER_DIST_FROM_SIDE;
}

- (CGPoint)centerOfBattle {
  return CENTER_OF_BATTLE;
}

- (float)playerXDistanceFromCenter {
  return PLAYER_X_DISTANCE_FROM_CENTER;
}

- (CGPoint) myPlayerLocation {
  return MY_PLAYER_LOCATION;
}

- (CGPoint)enemyLocation {
  return ENEMY_PLAYER_LOCATION;
}

- (CGPoint)bgdLayerInitPosition {
  return BGD_LAYER_INIT_POSITION;
}

- (float)bottomCenterX {
  return BOTTOM_CENTER_X;
}

- (float)deployCenterX {
  return DEPLOY_CENTER_X;
}

- (BOOL)displayedWaveNumber {
  return self.mainView.displayedWaveNumber;
}

#pragma mark - Setup

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize {
  return [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:@"1" layoutProto:nil];
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix {
  return [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:bgdPrefix layoutProto:nil];
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix layoutProto:(BoardLayoutProto *)layoutProto {
  if ((self = [super init])) {
    
    if (layoutProto) {
      _layoutProto = layoutProto;
      _gridSize = CGSizeMake(layoutProto.width, layoutProto.height);
    } else {
      _gridSize = gridSize.width ? gridSize : CGSizeMake(9, 9);
    }
    
    NSMutableArray *myTeam = [NSMutableArray array];
    NSMutableArray *myTeamSnapshots = [NSMutableArray array];
    for (UserMonster *um in monsters) {
      [myTeam addObject:[BattlePlayer playerWithMonster:um]];
      [myTeamSnapshots addObject:[self monsterSnapshot:um isOffensive:YES]];
    }
    self.myTeam = myTeam;
    self.playerTeamSnapshot = myTeamSnapshots;
    
    self.contentSize = [CCDirector sharedDirector].viewSize;
    
    [skillManager updateBattleLayer:self];
    
    [self initOrbLayer];
    
    OrbMainLayer *puzzleBg = self.orbLayer;
    // Need to make it equidistant on all sides
    float distFromSide = ORB_LAYER_DIST_FROM_SIDE;
    float puzzX = self.contentSize.width-puzzleBg.contentSize.width/2-distFromSide;
    puzzleBg.position = ccp(puzzX, puzzleBg.contentSize.height/2+distFromSide);
    
    self.mainView = [[BattleMainView alloc] initWithBgdPrefix:bgdPrefix battleLayer:self];
    [self addChild:self.mainView z:-10];
    
    _curStage = -1;
    
    _canPlayNextComboSound = YES;
    _canPlayNextGemPop = YES;
    
    self.shouldShowContinueButton = NO;
    self.shouldShowChatLine = NO;
    self.droplessStageNums = [NSMutableArray array];
    
    _enemyCounter = 0;
    
    [self.mainView loadHudView];
    [self removeOrbLayerAnimated:NO withBlock:nil];
    
    [self setupStateMachine];
  }
  return self;
}

- (CombatReplayMonsterSnapshot*) monsterSnapshot:(UserMonster*)um isOffensive:(BOOL)isOffensive {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSNumber *skillNumber = [NSNumber numberWithInteger:isOffensive ? um.offensiveSkillId : um.defensiveSkillId];
  return [[[[[[[CombatReplayMonsterSnapshot builder]
               setMonsterId:um.monsterId]
              setStartingHealth:um.curHealth]
             setMaxHealth:[gl calculateMaxHealthForMonster:um]]
            setSkillSnapshot:[gs.staticSkills objectForKey:skillNumber]]
           setLevel:um.level] build];
}

- (void) setupStateMachine {
  _battleStateMachine = [BattleStateMachine new];
  
  BattleState *initialState = [BattleState stateWithName:@"Initial Load" andType:CombatReplayStepTypeBattleInitialization];
  
  BattleState *spawnEnemyState = [BattleState stateWithName:@"Spawn Enemy" andType:CombatReplayStepTypeSpawnEnemy];
  [spawnEnemyState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self moveToNextEnemy];
  }];
  
  BattleState *playerSwapState = [BattleState stateWithName:@"Swap Player" andType:CombatReplayStepTypePlayerSwap];
  [playerSwapState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self deployBattleSprite:transition.userInfo[SWAP_TOON_KEY]];
  }];
  
  BattleState *playerTurn = [BattleState stateWithName:@"Player Turn" andType:CombatReplayStepTypePlayerTurn];
  [playerTurn setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self beginMyTurn];
  }];
  
  BattleState *playerMove = [BattleState stateWithName:@"Player Move" andType:CombatReplayStepTypePlayerMove];
  [playerMove setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self startMyMove];
  }];
  
  BattleState *playerAttack = [BattleState stateWithName:@"Player Attack" andType:CombatReplayStepTypePlayerAttack];
  [playerAttack setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self doMyAttackAnimation];
    [self.battleStateMachine.currentBattleState addDamage:_myDamageDealt unmodifiedDamage:_myDamageDealtUnmodified];
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
  
  [_battleStateMachine addStates:@[initialState, spawnEnemyState, playerSwapState, playerTurn, playerMove, playerAttack, enemyTurn, playerVictory, playerDeath, playerRevive]];
  
  loadingCompleteEvent = [TKEvent eventWithName:@"Loading complete" transitioningFromStates:@[initialState] toState:spawnEnemyState];
  nextEnemyEvent = [TKEvent eventWithName:@"Spawn Next Enemy" transitioningFromStates:@[enemyTurn, playerAttack, playerMove ] toState:spawnEnemyState];
  playerSwapEvent = [TKEvent eventWithName:@"Do Swap Players" transitioningFromStates:@[playerTurn, playerDeath, playerMove, playerRevive] toState:playerSwapState];
  playerTurnEvent = [TKEvent eventWithName:@"Player Turn Start" transitioningFromStates:@[initialState, playerSwapState, spawnEnemyState, playerAttack, enemyTurn] toState:playerTurn];
  playerMoveEvent = [TKEvent eventWithName:@"Player Move Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerMove];
  playerAttackEvent = [TKEvent eventWithName:@"Player Attack Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerAttack];
  enemyTurnEvent = [TKEvent eventWithName:@"Enemy Turn Start" transitioningFromStates:@[initialState, playerAttack, enemyTurn, spawnEnemyState, playerSwapState] toState:enemyTurn];
  playerVictoryEvent = [TKEvent eventWithName:@"Player Win Event" transitioningFromStates:@[spawnEnemyState, playerAttack, playerMove, enemyTurn] toState:playerVictory];
  playerDeathEvent = [TKEvent eventWithName:@"Player Death Event" transitioningFromStates:@[playerAttack, playerMove, enemyTurn] toState:playerDeath];
  playerReviveEvent = [TKEvent eventWithName:@"Player Revive Event" transitioningFromStates:@[playerDeath] toState:playerRevive];
  
  [_battleStateMachine addEvents:@[loadingCompleteEvent, nextEnemyEvent, playerSwapEvent, playerTurnEvent, playerMoveEvent, playerAttackEvent, enemyTurnEvent, playerVictoryEvent, playerDeathEvent, playerReviveEvent]];
  
  _battleStateMachine.initialState = initialState;
  
  [_battleStateMachine activate];
}

- (void) initOrbLayer {
  OrbMainLayer *ol;
  
  if (_layoutProto) {
    ol = [[OrbMainLayer alloc] initWithLayoutProto:_layoutProto];
  } else {
    ol = [[OrbMainLayer alloc] initWithGridSize:_gridSize numColors:6];
  }
  
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  [self begin];
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
}

- (BattlePlayer *) firstMyPlayer {
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    if (b.curHealth > 0 && (!bp || b.slotNum < bp.slotNum)) {
      bp = b;
    }
  }
  return bp;
}
- (void) createScheduleWithSwap:(BOOL)swap {
  [self createScheduleWithSwap:swap playerHitsFirst:NO];
}

- (void) createScheduleWithSwap:(BOOL)swap playerHitsFirst:(BOOL)playerFirst {
#ifdef DEBUG_BATTLE_MODE
  playerFirst = YES;
#endif

  if (self.myPlayerObject && self.enemyPlayerObject) {
    ScheduleFirstTurn order;
    if(swap) {
      order = ScheduleFirstTurnEnemy;
    } else {
      order = playerFirst ? ScheduleFirstTurnPlayer : ScheduleFirstTurnRandom;
    }
    
    // Cake kid mechanics handling and creating schedule
    if ([skillManager cakeKidSchedule])
      order = ScheduleFirstTurnPlayer;
    if (! swap || ! [skillManager cakeKidSchedule]) { // update schedule for all cases except if swap && cakeKidSchedule (for that we just remove one turn)
      self.battleSchedule = [[BattleSchedule alloc] initWithPlayerA:self.myPlayerObject.speed playerB:self.enemyPlayerObject.speed andOrder:order andDelegate:self.battleStateMachine];
    }
    
    _shouldDisplayNewSchedule = YES;
  } else {
    [self.mainView.hudView removeBattleScheduleView];
    self.battleSchedule = nil;
  }
  
  [self.mainView.hudView.battleScheduleView setBattleSchedule:self.battleSchedule];
}

- (void) begin {
  if (!_isResumingState)
    [skillManager flushPersistentSkills];
  
  BattlePlayer *bp = [self firstMyPlayer];
  if (bp) {
    [self deployBattleSprite:bp];
  }
}

- (void) setMovesLeft:(int)movesLeft animated:(BOOL)animated
{
  [self.mainView setMovesLeft:movesLeft animated:animated];
  _movesLeft = movesLeft;
}

- (void) makePlayer:(BattleSprite *)player walkInFromEntranceWithSelector:(SEL)selector {
  CGPoint finalPos = player.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -player.contentSize.width-MY_PLAYER_LOCATION.x+finalPos.x;
  float xDelta = finalPos.x-startX;
  CGPoint newPos = ccp(startX, finalPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  [player beginWalking];
  player.position = newPos;
  [player runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, newPos)/MY_WALKING_SPEED position:finalPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (player == self.mainView.myPlayer) {
         float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
         if (perc < PULSE_CONT_THRESH) {
           [self.mainView pulseBloodContinuously];
           [self.mainView pulseHealthLabel:NO];
         } else {
           [self.mainView stopPulsing];
         }
         
         [self updateHealthBars];
       }
       
       [player stopWalking];
       
       if (selector) {
         [self performSelector:selector withObject:player];
       }
     }],
    nil]];
}

- (NSInteger) currentStageNum {
  return _curStage;
}

- (NSInteger) stagesLeft
{
  return self.enemyTeam.count - _curStage - 1;
}

- (void) moveToNextEnemy {
  [self moveToNextEnemyWithPlayerFirst:NO];
}

- (void) moveToNextEnemyWithPlayerFirst:(BOOL)playerHitsFirst {
  _dungeonPlayerHitsFirst = playerHitsFirst;
  [self.mainView removeButtons];
  
  if (_lootSprite) {
    [self pickUpLoot];
  }
  
  if ([self spawnNextEnemy]) {
    [self.mainView moveToNextEnemy];
    
    [self.mainView displayWaveNumber:_curStage+1 totalWaves:(int)self.enemyTeam.count andEnemy:self.enemyPlayerObject];
    
    _reachedNextScene = NO;
    self.mainView.displayedWaveNumber = NO;
  } else {
    if (_lootSprite) {
      [self.mainView moveToNextEnemy];
      
      [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallFunc actionWithTarget:self selector:@selector(fireVictoryEvent)], nil]];
    } else {
      [self fireEvent:playerVictoryEvent userInfo:nil error:nil];
    }
  }
}

- (BOOL) spawnNextEnemy {
  BOOL success = [self createNextEnemyObject];
  
  if (success) {
    
    CGPoint finalPos = ENEMY_PLAYER_LOCATION;
    CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
    CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
    
    [self.mainView createNextEnemySpriteWithBattlePlayer:self.enemyPlayerObject startPosition:newPos endPosition:finalPos];
    
    [self triggerSkillForEnemyCreatedWithBlock:^{
      [self createScheduleWithSwap:NO playerHitsFirst:_dungeonPlayerHitsFirst];
    }];
  }
  
  return success;
}

- (void) triggerSkillForEnemyCreatedWithBlock:(dispatch_block_t)block {
  SkillLogStart(@"TRIGGER STARTED: enemy initialized");
  [self triggerSkills:SkillTriggerPointEnemyInitialized withCompletion:^(BOOL triggered, id params) {
    SkillLogEnd(triggered, @"  Enemy initialized trigger ENDED");
    if (block) {
      block();
    }
  }];
}

- (BOOL) createNextEnemyObject {
  self.enemyPlayerObject = nil;
  
  while (_curStage+1 < (int)self.enemyTeam.count && !self.enemyPlayerObject) {
    _curStage++;
    
    self.enemyPlayerObject = [self.enemyTeam objectAtIndex:_curStage];
    
    if (self.enemyPlayerObject.curHealth <= 0) {
      self.enemyPlayerObject = nil;
    }
  }
  
  return self.enemyPlayerObject != nil;
}

#pragma mark - UI Updates

- (void) updateHealthBars {
  [self.mainView updateHealthBarsForPlayer:self.myPlayerObject andEnemy:self.enemyPlayerObject];
  //_comboLabel.string = [NSString stringWithFormat:@"%dx", _comboCount];

}

- (void) pulseLabel:(CCNode *)label {
  if (![label getActionByTag:924]) {
    CCActionScaleBy *a = [CCActionScaleBy actionWithDuration:0.4f scale:1.2];
    CCAction *b = [a reverse];
    CCActionSequence *seq = [CCActionEaseInOut actionWithAction:[CCActionSequence actions:a, b, nil]];
    seq.tag = 924;
    [label runAction:seq];
  }
}

#pragma mark - Turn Sequence

- (void) prepareScheduleView
{
  NSArray *bools = [self.battleSchedule getNextNMoves:self.mainView.hudView.battleScheduleView.numSlots];
  NSMutableArray *ids = [NSMutableArray array];
  NSMutableArray *enemyBands = [NSMutableArray array];
  NSMutableArray *playerTurns = [NSMutableArray array];
  for (NSNumber *num in bools) {
    BOOL val = num.boolValue;
    if (val) {
      [ids addObject:@(self.myPlayerObject.monsterId)];
      [enemyBands addObject:@NO];
      [playerTurns addObject:@YES];
    } else {
      [ids addObject:@(self.enemyPlayerObject.monsterId)];
      [enemyBands addObject:@(self.enemyPlayerObject.element == self.myPlayerObject.element)];
      [playerTurns addObject:@NO];
    }
  }
  self.mainView.hudView.battleScheduleView.delegate = self;
  [self.mainView.hudView.battleScheduleView setOrdering:ids showEnemyBands:enemyBands playerTurns:playerTurns];
}

- (void) beginNextTurn {
  
  // Enemy could be reset during Cake Drop explosion
//  if (! _currentEnemy)
//  {
//    [self moveToNextEnemy];
//    return;
//  }
#warning Rob is going to fix this with the state machine logics!
  
  
  // There are two methods calling this method in a race condition (reachedNextScene and displayWaveNumber)
  // These two flags are used to call beginNextTurn only once, upon the last call of the two
  if (self.mainView.displayedWaveNumber && _reachedNextScene) {
    float delay = 1.0;
    float delay2 = 0.0;
    
    if (_shouldDisplayNewSchedule) {
      
      [self prepareScheduleView];
      _shouldDisplayNewSchedule = NO;
      delay = 1.3;
      delay2 = 0.2;
      [self.mainView.hudView displayBattleScheduleView];
      
    } else {
      // If nth is YES, this is your move, otherwise enemy's move
      BOOL nth = [self.battleSchedule getNthMove:self.mainView.hudView.battleScheduleView.numSlots-1];
      int monsterId = nth ? self.myPlayerObject.monsterId : self.enemyPlayerObject.monsterId;
      BOOL showEnemyBand = nth ? NO : self.enemyPlayerObject.element == self.myPlayerObject.element;
      [self.mainView.hudView.battleScheduleView addMonster:monsterId showEnemyBand:showEnemyBand player:nth];
    }
    
    self.mainView.hudView.bottomView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
      self.mainView.hudView.waveNumLabel.alpha = 1.f;
    }];
    
    // To allow the schedule cards to refresh before the bump of the last
    [self performBlockAfterDelay:delay2 block:^{
      
      if (_firstTurn) {
        // Trigger skills when new enemy joins the battle
        SkillLogStart(@"TRIGGER STARTED: enemy appeared");
        ++_enemyCounter;
        [self triggerSkills:SkillTriggerPointEnemyAppeared withCompletion:^(BOOL triggered, id params) {
          SkillLogEnd(triggered, @"  Enemy appeared trigger ENDED");
          [self processNextTurn: triggered ? 0.3 : delay]; // Don't wait if we're in the middle of enemy turn (ie skill was triggered and now is his turn)
        }];
      } else {
        [self processNextTurn: delay];
      }

    }];
  }
}

- (void) processNextTurn:(float)delay
{
  _firstTurn = NO;
  BOOL nextMove = [self.battleSchedule dequeueNextMove];
  if (nextMove) {
    [self fireEvent:playerTurnEvent userInfo:nil error:nil];
  } else {
    NSNumber *delayN = [NSNumber numberWithFloat:delay];
    [self fireEvent:enemyTurnEvent userInfo:@{DELAY_KEY : delayN} error:nil];
  }
}

- (BOOL) isFirstEnemy
{
  return (_enemyCounter <= 1);
}

- (void) beginMyTurn {
  _comboCount = 0;
  _orbCount = 0;
  _soundComboCount = 0;
  _enemyShouldAttack = NO;
  
  [self setMovesLeft:NUM_MOVES_PER_TURN animated:NO];
  
  _myDamageDealt = 0;
  _myDamageForThisTurn = 0;
  _enemyDamageDealt = 0;
  _myDamageDealtUnmodified = 0;
  _enemyDamageDealtUnmodified = 0;
  
  for (int i = 0; i < OrbColorNone; i++) {
    _orbCounts[i] = 0;
  }
  
  [self updateHealthBars];
  
  // Skills trigger for enemy turn started
  SkillLogStart(@"TRIGGER STARTED: beginning of player turn");
  [self triggerSkills:SkillTriggerPointStartOfPlayerTurn withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Beginning of player turn ENDED");
    
    if (self.myPlayerObject.isStunned)
    {
      [[skillManager enemySkillControler] showSkillPopupAilmentOverlay:@"STUNNED" bottomText:@"TURN LOST"];
      [self endMyTurnAfterDelay:1.5f];
      return;
    }
    
    [self fireEvent:playerMoveEvent userInfo:nil error:nil];
    
    [self.mainView.hudView prepareForMyTurn];
    [self updateItemsBadge];
    
    [self performBlockAfterDelay:0.5 block:^{
      [self.mainView.hudView.battleScheduleView bounceLastView];
    }];
  }];
}

- (void) endMyTurnAfterDelay:(NSTimeInterval)delay
{
  [self performBlockAfterDelay:delay block:^{
    _enemyShouldAttack = YES;
    [self checkEnemyHealthAndStartNewTurn];
  }];
}

- (int) calculateUnmodifiedEnemyDamage {
  int enemyDamage = [self.enemyPlayerObject randomDamage];
  return enemyDamage*[self damageMultiplierIsEnemyAttacker:YES];
}

- (int) calculateModifiedEnemyDamage:(int)unmodifiedDamage {
  return (int)[skillManager modifyDamage:unmodifiedDamage forPlayer:NO];
}

- (void) beginEnemyTurn:(float)delay {
  [self.mainView removeButtons];
  
  // Bounce if needed
  BOOL needToBounce = YES;
  if (! [skillManager willEnemySkillTrigger:SkillTriggerPointStartOfEnemyTurn])
  {
    [self performBlockAfterDelay:0.5 block:^{
      [self.mainView.hudView.battleScheduleView bounceLastView];
    }];
    needToBounce = NO;
  }
  
  // Skills trigger for enemy turn started
  [self performBlockAfterDelay:delay block:^{
    
    SkillLogStart(@"TRIGGER STARTED: beginning of enemy turn");
    [self triggerSkills:SkillTriggerPointStartOfEnemyTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  Beginning of enemy turn ENDED");
      if (_enemyPlayerObject) // can be set to nil during the skill execution - Cake Drop does that and starts different sequence
      {
        BOOL enemyIsKilled = [self checkEnemyHealth];
        if (! enemyIsKilled)
        {
          if (needToBounce)
            [self.mainView.hudView.battleScheduleView bounceLastView];
          [self performBlockAfterDelay:0.5 block:^{
            _enemyDamageDealtUnmodified = [self calculateUnmodifiedEnemyDamage];
            _enemyDamageDealt = [self calculateModifiedEnemyDamage:_enemyDamageDealtUnmodified];
            
            [self.battleStateMachine.currentBattleState addDamage:_enemyDamageDealt unmodifiedDamage:_enemyDamageDealtUnmodified];
            
            // If the enemy's stunned, short the attack function
            if (self.enemyPlayerObject.isStunned)
            {
              [[skillManager playerSkillControler] showSkillPopupAilmentOverlay:@"STUNNED" bottomText:@"TURN LOST"];
              [self performBlockAfterDelay:1.5 block:^{
                [self endEnemyTurn];
              }];
              return;
            }
            
            // If the enemy's confused, they will deal damage to themself. Instead of the usual flow, show
            // the popup above their head, followed by flinch animation and showing the damage label
            if (self.enemyPlayerObject.isConfused)
            {
              self.enemyPlayerObject.isConfused = NO;
              
              [[skillManager playerSkillControler] enqueueSkillPopupAilmentOverlay:@"CONFUSED" bottomText:[NSString stringWithFormat:@"%i DMG TO SELF", _enemyDamageDealt]];
              
              [self.mainView showConfusedPopup:YES withTarget:self andSelector:@selector(enemyDealsDamageToSelf)];
            }
            else
            {
              [self.mainView.currentEnemy performNearAttackAnimationWithEnemy:self.mainView.myPlayer
                                                        shouldReturn:YES
                                                         shouldEvade:[skillManager playerWillEvade:YES]
                                                          shouldMiss:[skillManager playerWillMiss:NO]
                                                        shouldFlinch:(_enemyDamageDealt>0)
                                                              target:self
                                                            selector:@selector(dealEnemyDamage)
                                                      animCompletion:nil];
            }
            
            
            [skillManager playDamageLogos];
          }];
        }
      }
    }];
  }];
}

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy {
  Globals *gl = [Globals sharedGlobals];
  Element attackerElement = isEnemy ? self.enemyPlayerObject.element : self.myPlayerObject.element;
  Element defenderElement = !isEnemy ? self.enemyPlayerObject.element : self.myPlayerObject.element;
  return [gl calculateDamageMultiplierForAttackElement:attackerElement defenseElement:defenderElement];
}

- (void) checkIfAnyMovesLeft {
  if (_movesLeft <= 0) {
    [self myTurnEnded];
  } else {
    _myDamageForThisTurn = 0;
    [self fireEvent:playerMoveEvent userInfo:nil error:nil];
  }
}

- (void) startMyMove {
  if ([self.orbLayer.layout detectPossibleSwaps].count)
    [self.orbLayer.bgdLayer turnTheLightsOn];
  else
    [self checkNoPossibleMoves];
  
  [skillManager enableSkillButton:YES];
  [self.orbLayer allowInput];
}

- (void) myTurnEnded {
  
  _myDamageDealt = _myDamageDealt*[self damageMultiplierIsEnemyAttacker:NO];
  _myDamageDealtUnmodified = _myDamageDealt;
  _myDamageDealt = (int)[skillManager modifyDamage:_myDamageDealt forPlayer:YES];
  
  [self showHighScoreWord];
  [self.orbLayer disallowInput];
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self.mainView removeButtons];
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(firePlayerAttackEvent)];
}

- (void) doMyAttackAnimation {
  
  
  // Changing damage with a skill
  NSInteger scoreModifier = _myDamageDealtUnmodified > 0 ? 1 : 0; // used to make current score not 0 if damage was modified to 0 by skillManager
  if (_myDamageDealt > 0)
    scoreModifier = 0;
  
  int currentScore = (float)(_myDamageDealtUnmodified + scoreModifier)/(float)[self.myPlayerObject totalAttackPower]*100.f;
  
  if (currentScore > 0) {
  
    // If the player's confused, he will deal damage to himself. Instead of the usual flow, show
    // the popup above his head, followed by flinch animation and showing the damage label
    if (self.myPlayerObject.isConfused)
    {
      self.myPlayerObject.isConfused = NO;
      
      [[skillManager enemySkillControler] enqueueSkillPopupAilmentOverlay:@"CONFUSED" bottomText:[NSString stringWithFormat:@"%i DMG TO SELF", _myDamageDealt]];
      
      [self.mainView showConfusedPopup:NO withTarget:self andSelector:@selector(playerDealsDamageToSelf)];
    }
    else
    {
//#if !TARGET_IPHONE_SIMULATOR
      if (currentScore > MAKEITRAIN_SCORE) {
        [self.mainView.myPlayer restoreStandingFrame];
        [self.mainView spawnPlaneWithTarget:nil selector:nil];
      }
//#endif
      float strength = MIN(1, currentScore/(float)STRENGTH_FOR_MAX_SHOTS);
      [self.mainView.myPlayer performFarAttackAnimationWithStrength:strength
                                               shouldEvade:[skillManager playerWillEvade:NO]
                                                shouldMiss:[skillManager playerWillMiss:YES]
                                                     enemy:self.mainView.currentEnemy
                                                    target:self
                                                  selector:@selector(dealMyDamage)
                                            animCompletion:nil];
    }
  } else {
    [self beginNextTurn];
  }
  
  [skillManager playDamageLogos];
}

- (void) dealMyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by player");
  [self triggerSkills:SkillTriggerPointPlayerDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by player trigger ENDED");
    
    _enemyShouldAttack = YES;
    
    [self.mainView animateDamageLabel:NO initialDamage:_myDamageDealtUnmodified modifiedDamage:_myDamageDealt withCompletion:^{
      [self dealDamage:_myDamageDealt enemyIsAttacker:NO usingAbility:NO showDamageLabel:NO withTarget:self withSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    }];
  }];
}

- (void) dealEnemyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [self triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    _totalDamageTaken += _enemyDamageDealt;
    
    [self.mainView animateDamageLabel:YES initialDamage:_enemyDamageDealtUnmodified modifiedDamage:_enemyDamageDealt withCompletion:^{
      [self dealDamage:_enemyDamageDealt enemyIsAttacker:YES usingAbility:NO showDamageLabel:NO withTarget:self withSelector:@selector(endEnemyTurn)];
    }];
  }];
}

- (void) endEnemyTurn {
  BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
  if (!playerIsKilled){
    SkillLogStart(@"TRIGGER STARTED: enemy turn end");
    [self triggerSkills:SkillTriggerPointEndOfEnemyTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  end of enemy turn trigger ENDED");
      if (![self checkEnemyHealth]){
        [self checkMyHealth];
      }
    }];
  } else {
    [self checkMyHealth];
  }
}

- (void) playerDealsDamageToSelf {
  SkillLogStart(@"TRIGGER STARTED: deal damage by player");
  [self triggerSkills:SkillTriggerPointPlayerDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by player trigger ENDED");
    
    _enemyShouldAttack = YES;
    _totalDamageTaken += _myDamageDealt;
    
    [self.mainView animateDamageLabel:YES initialDamage:_myDamageDealtUnmodified modifiedDamage:_myDamageDealt withCompletion:^{
      [self dealDamageToSelf:_myDamageDealt enemyIsAttacker:NO showDamageLabel:NO withTarget:self andSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    }];
    
    [self.mainView.myPlayer performFarFlinchAnimationWithDelay:0.f];
  }];
}

- (void) enemyDealsDamageToSelf {
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [self triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    [self.mainView animateDamageLabel:NO initialDamage:_enemyDamageDealtUnmodified modifiedDamage:_enemyDamageDealt withCompletion:^{
      [self dealDamageToSelf:_enemyDamageDealt enemyIsAttacker:YES showDamageLabel:NO withTarget:self andSelector:@selector(endEnemyTurn)];
    }];
    
    [self.mainView.currentEnemy performNearFlinchAnimationWithStrength:0 delay:0.f];
  }];
}

- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withTarget:(id)target andSelector:(SEL)selector
{
  [self dealDamageToSelf:damageDone enemyIsAttacker:enemyIsAttacker showDamageLabel:YES withTarget:target andSelector:selector];
}

- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker showDamageLabel:(BOOL)showLabel withTarget:(id)target andSelector:(SEL)selector
{
  BattlePlayer *bp = enemyIsAttacker ? self.enemyPlayerObject : self.myPlayerObject;
  BattleSprite *bs = enemyIsAttacker ? self.mainView.currentEnemy : self.mainView.myPlayer;
  CCLabelTTF *healthLabel = enemyIsAttacker ? self.mainView.currentEnemy.healthLabel : self.mainView.myPlayer.healthLabel;
  CCProgressNode *healthBar = enemyIsAttacker ? self.mainView.currentEnemy.healthBar : self.mainView.myPlayer.healthBar;
  
  int curHealth = bp.curHealth;
  int newHealth = MIN(bp.maxHealth, MAX(bp.minHealth, curHealth - damageDone));
  float newPercent = (float)newHealth / bp.maxHealth * 100.f;
  float percChange = ABS(healthBar.percentage - newPercent);
  float duration = percChange / HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           [self updateHealthBars];
                           [SoundEngine stopRepeatingEffect];
                           
                           if (newHealth <= 0) {
                             if (!enemyIsAttacker) {
                               [self.mainView.movesLeftContainer removeFromParent];
                               self.mainView.movesLeftContainer = nil;
                             }
                             
                             [self.mainView blowupBattleSprite:bs withBlock:^{
                               [target performSelector:selector];
                             }];
                             
                             if (enemyIsAttacker) {
                               // Drop loot
                               _lootSprite = [self getCurrentEnemyLoot];
                               
                               if (_lootSprite)
                                 [self.mainView dropLoot:_lootSprite];
                             }
                           } else {
                             [target performSelector:selector];
                           }
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@",
                                                 [Globals commafyNumber:(int)(healthBar.percentage / 100.f * bp.maxHealth)],
                                                 [Globals commafyNumber:bp.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:.02f],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  [self.mainView pulseHealthLabelIfRequired:enemyIsAttacker forBattlePlayer:bp];
  
  if (showLabel)
    [self.mainView animateDamageLabel:!enemyIsAttacker initialDamage:damageDone modifiedDamage:damageDone withCompletion:nil];
  
  bp.curHealth = newHealth;
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector {
  [self dealDamage:damageDone enemyIsAttacker:enemyIsAttacker usingAbility:usingAbility showDamageLabel:YES withTarget:target withSelector:selector];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility showDamageLabel:(BOOL)showLabel withTarget:(id)target withSelector:(SEL)selector {
  BattlePlayer *att, *def;
  BattleSprite *attSpr, *defSpr;
  CCLabelTTF *healthLabel;
  CCProgressNode *healthBar;
  if (enemyIsAttacker) {
    att = self.enemyPlayerObject; def = self.myPlayerObject;
    attSpr = self.mainView.currentEnemy; defSpr = self.mainView.myPlayer;
    healthLabel = self.mainView.myPlayer.healthLabel; healthBar = self.mainView.myPlayer.healthBar;
  } else {
    def = self.enemyPlayerObject; att = self.myPlayerObject;
    defSpr = self.mainView.currentEnemy; attSpr = self.mainView.myPlayer;
    healthLabel = self.mainView.currentEnemy.healthLabel; healthBar = self.mainView.currentEnemy.healthBar;
  }
  
  int curHealth = def.curHealth;
  int newHealth = MIN(def.maxHealth, MAX(def.minHealth, curHealth-damageDone));
  float newPercent = ((float)newHealth)/def.maxHealth*100;
  float percChange = ABS(healthBar.percentage-newPercent);
  float duration = percChange/HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           [self updateHealthBars];
                           [SoundEngine stopRepeatingEffect];
                           
                           if (newHealth <= 0) {
                             if (enemyIsAttacker) {
                               [self.mainView.movesLeftContainer removeFromParent];
                               self.mainView.movesLeftContainer = nil;
                             }
                             
                             [self.mainView blowupBattleSprite:defSpr withBlock:^{
                               [target performSelector:selector];
                             }];
                             
                             if (!enemyIsAttacker) {
                               // Drop loot
                               _lootSprite = [self getCurrentEnemyLoot];
                               
                               if (_lootSprite)
                                 [self.mainView dropLoot:_lootSprite];
                             }
                           } else {
                             [target performSelector:selector];
                           }
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:(int)(healthBar.percentage/100.f*def.maxHealth)], [Globals commafyNumber:def.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:0.02],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  [self.mainView pulseHealthLabelIfRequired:!enemyIsAttacker forBattlePlayer:def];
  
  if (showLabel)
    [self.mainView animateDamageLabel:YES initialDamage:damageDone modifiedDamage:damageDone withCompletion:nil];
  
  def.curHealth = newHealth;
}

- (void) healForAmount:(int)heal enemyIsHealed:(BOOL)enemyIsHealed withTarget:(id)target andSelector:(SEL)selector {
  BattlePlayer *bp;
  BattleSprite *sprite;
  CCLabelTTF *healthLabel;
  CCProgressNode *healthBar;
  if (enemyIsHealed) {
    bp = self.enemyPlayerObject;
    sprite = self.mainView.currentEnemy;
    healthLabel = self.mainView.currentEnemy.healthLabel;
    healthBar = self.mainView.currentEnemy.healthBar;
  } else {
    bp = self.myPlayerObject;
    sprite = self.mainView.myPlayer;
    healthLabel = self.mainView.myPlayer.healthLabel;
    healthBar = self.mainView.myPlayer.healthBar;
  }
  
  int curHealth = bp.curHealth;
  int newHealth = MIN(bp.maxHealth, MAX(bp.minHealth, curHealth + heal));
  float newPercent = ((float)newHealth) / bp.maxHealth * 100.f;
  float percChange = ABS(healthBar.percentage - newPercent);
  float duration = percChange / HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1827];
                           [self updateHealthBars];
                           [SoundEngine stopRepeatingEffect];
                           [target performSelector:selector];
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@",
                                                 [Globals commafyNumber:(int)(healthBar.percentage / 100.f * bp.maxHealth)],
                                                 [Globals commafyNumber:bp.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:.02f],
                        nil]];
  [f setTag:1827];
  [healthLabel runAction:f];
  
  [self.mainView pulseHealthLabelIfRequired:enemyIsHealed forBattlePlayer:bp];
  
  NSString *str = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:heal]];
  CCLabelBMFont *healLabel = [CCLabelBMFont labelWithString:str fntFile:@"earthpointsfont.fnt"];
  [self.mainView.bgdContainer addChild:healLabel z:sprite.zOrder];
  [healLabel setPosition:ccpAdd(sprite.position, ccp(0.f, sprite.contentSize.height - 15.f))];
  [healLabel setScale:.01f];
  [healLabel runAction:[CCActionSequence actions:
                        [CCActionSpawn actions:
                         [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1.1f]],
                         [CCActionFadeOut actionWithDuration:1.5f],
                         [CCActionMoveBy actionWithDuration:1.5f position:ccp(0.f, 25.f)], nil],
                        [CCActionCallFunc actionWithTarget:healLabel selector:@selector(removeFromParent)], nil]];
  
  bp.curHealth = newHealth;
}

- (void) instantSetHealthForEnemy:(BOOL)enemy to:(int)health withTarget:(id)target andSelector:(SEL)selector
{
  // TODO - Right now only used to instakill a BattlePlayer. Not sure
  // why we would wanna set the health to any value other than zero
  // and not go through the usual dealDamage: flow
  
  BattlePlayer* bp = enemy ? self.enemyPlayerObject : self.myPlayerObject;
  BattleSprite* bs = enemy ? self.mainView.currentEnemy : self.mainView.myPlayer;
  
  bp.curHealth = MIN(bp.maxHealth, MAX(bp.minHealth, health));
  [self updateHealthBars];
  
  if (health <= 0) {
    if (!enemy) {
      [self.mainView.movesLeftContainer removeFromParent];
      self.mainView.movesLeftContainer = nil;
    }
    
    [self.mainView blowupBattleSprite:bs withBlock:^{
      [target performSelector:selector];
    }];
    
    if (enemy) {
      // Drop loot
      _lootSprite = [self getCurrentEnemyLoot];
      
      if (_lootSprite)
        [self.mainView dropLoot:_lootSprite];
    }
  } else {
    [target performSelector:selector];
  }
  
  if (!enemy) {
    [self sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify {
  if (_enemyDamageDealt || !verify) {
    if (!self.myPlayerObject.isClanMonster) {
      [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:self.myPlayerObject.userMonsterUuid curHealth:self.myPlayerObject.curHealth];
    }
  }
}

- (BOOL) checkEnemyHealth {
  
  if (self.enemyPlayerObject.curHealth <= 0) {
    
    // Trigger skills for move made by the player
    SkillLogStart(@"TRIGGER STARTED: enemy defeated");
    [self triggerSkills:SkillTriggerPointEnemyDefeated withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  Enemy defeated trigger ENDED");
      
      self.mainView.currentEnemy = nil;
      
      [self.mainView.hudView removeBattleScheduleView];
      [self.mainView.hudView hideSkillPopup:nil];
      
      // Send server updated values here because monster just died
      // But make sure that I actually did damage..
      [self sendServerUpdatedValuesVerifyDamageDealt:YES];
      
      self.enemyPlayerObject = nil;
      [self updateHealthBars];
      [self moveToNextEnemy];
      
    }];
    
    return YES;
  }
  
  return NO;
}

- (void) checkEnemyHealthAndStartNewTurn {
  BOOL enemyIsDead = [self checkEnemyHealth];
  if (! enemyIsDead)
  {
    SkillLogStart(@"TRIGGER STARTED: player turn ended");
    [self triggerSkills:SkillTriggerPointEndOfPlayerTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  player turn ended trigger ENDED");
      
      BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
      if (playerIsKilled){
        [self checkMyHealth];
      } else if (_enemyShouldAttack) {
        [self beginNextTurn];
      }
    }];
  }
}

- (CCSprite *) getCurrentEnemyLoot {
  // Should be implemented
  return nil;
}

- (void) checkMyHealth {
  [self sendServerUpdatedValuesVerifyDamageDealt:YES];
  if (self.myPlayerObject.curHealth <= 0) {
    [self fireEvent:playerDeathEvent userInfo:nil error:nil];
  } else {
    [self beginNextTurn];
  }
}

- (NSInteger) playerMobstersLeft
{
  NSInteger result = 0;
  for (BattlePlayer *bp in self.myTeam)
    if (bp.curHealth > 0)
      result++;
  return result;
}

- (void) currentMyPlayerDied {
  SkillLogStart(@"TRIGGER STARTED: mob defeated");
  [self triggerSkills:SkillTriggerPointPlayerMobDefeated withCompletion:^(BOOL triggered, id params) {
    SkillLogEnd(triggered, @"  Mob defeated trigger ENDED");
    
    [self setMovesLeft:0 animated:NO];
    [self.mainView stopPulsing];
    self.mainView.myPlayer = nil;
    self.myPlayerObject = nil;
    [self updateHealthBars];
    
    if ([self playerMobstersLeft] > 0) {
      [self displayDeployViewAndIsCancellable:NO];
    }
    else
    {
      [self youLost];
    }
  }];
}

- (void) pickUpLoot {
  [self.mainView pickUpLoot:++_lootCount];
}

- (void) showHighScoreWordWithTarget:(id)target selector:(SEL)selector {
  int currentScore = _myDamageDealtUnmodified*[self damageMultiplierIsEnemyAttacker:NO]/(float)[self.myPlayerObject totalAttackPower]*100.f;
  [self.mainView showHighScoreWordWithScore:currentScore target:target selector:selector];
}

- (void) firePlayerAttackEvent {
  [self fireEvent:playerAttackEvent userInfo:nil error:nil];
}

- (void) fireVictoryEvent {
  [self fireEvent:playerVictoryEvent userInfo:nil error:nil];
}

- (void) spawnRibbonForOrb:(BattleOrb *)orb target:(CGPoint)endPosition baseDuration:(CGFloat)dur skill:(BOOL)skill {
  
  BOOL cake = (orb.specialOrbType == SpecialOrbTypeCake);
  
  // Create random bezier
  if (orb.orbColor != OrbColorNone || cake) {
    ccBezierConfig bez;
    bez.endPosition = endPosition;
    CGPoint initPoint = [self.orbLayer convertToNodeSpace:[self.orbLayer.swipeLayer convertToWorldSpace:[self.orbLayer.swipeLayer pointForColumn:orb.column row:orb.row]]];
    
    // basePt1 is chosen with any y and x is between some neg num and approx .5
    // basePt2 is chosen with any y and x is anywhere between basePt1's x and .85
    BOOL chooseRight = arc4random()%2;
    CGPoint basePt1 = ccp(drand48()-0.8, drand48());
    CGPoint basePt2 = ccp(basePt1.x+drand48()*(0.7-basePt1.x), drand48());
    
    // outward potential increases based on distance between orbs
    float xScale = ccpDistance(initPoint, bez.endPosition);
    float yScale = (50+xScale/5)*(chooseRight?-1:1);
    float angle = ccpToAngle(ccpSub(bez.endPosition, initPoint));
    if (cake)
    {
      xScale = 1.0;
      yScale = 1.0;
      angle = 0.0;
      basePt1 = ccp(-10.0, -50.0);
      basePt2 = ccp(-100.0, -20.0);
    }
    
    // Transforms are applied in reverse order!! So rotate, then scale
    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
    bez.controlPoint_1 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt1, t));
    bez.controlPoint_2 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt2, t));
    
    CCActionBezierTo *move = [CCActionBezierTo actionWithDuration:(cake?1.5f:(dur+xScale/800.f)) bezier:bez];
    CCNode *dg;
    float stayDelay = 0.7f;
    if (skill)
    {
      // Tail for an orb flying to skill indicator
//    dg = [[SparklingTail alloc] initWithColor:orb.orbColor];
      
      CCSprite *orbSprite = [self.orbLayer.swipeLayer spriteForOrb:orb].orbSprite;
      dg = [CCSprite spriteWithTexture:orbSprite.texture rect:orbSprite.textureRect];
      move = [CCActionSpawn actions:move, [CCActionScaleTo actionWithDuration:move.duration scale:.3f], nil];

      stayDelay = 0.0;
    }
    else
    {
      // Cake or sparkle
      if (cake)
        dg = [[DestroyedOrb alloc] initWithCake];
      else
        dg = [[DestroyedOrb alloc] initWithColor:[self.orbLayer.swipeLayer colorForSparkle:orb.orbColor]];
    }
    
    [self.orbLayer addChild:dg z:10];
    dg.position = initPoint;
    [dg runAction:[CCActionSequence actions:move,
                   [CCActionSpawn actions:
                    [CCActionScaleTo actionWithDuration:.5f scale:.1f],
                    [CCActionFadeOut actionWithDuration:.5f],
                    nil],
                   [CCActionDelay actionWithDuration:stayDelay],
                   [CCActionCallFunc actionWithTarget:dg selector:@selector(removeFromParent)], nil]];
  }
}

- (void) youWon {
  [self endBattle:YES];
}

- (void) youLost {
  [self endBattle:NO];
}

- (void) youForfeited {
  // Make sure you can actually make a move
  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.mainView makeMyPlayerWalkOutWithBlock:^{
      [self youLost];
    }];
    self.mainView.myPlayer = nil;
    self.myPlayerObject = nil;
    [self.orbLayer disallowInput];
    [self.mainView removeButtons];
  }
}

- (void) endBattle:(BOOL)won {
  [CCBReader load:@"BattleEndView" owner:self];
  
  NSLog(self.battleStateMachine.description);
  
  [self buildReplay];
  
  // Set endView's parent so that the position normalization doesn't get screwed up
  // since we're only adding it to the parent once orb layer gets removed
  self.endView.parent = self;
  
  _wonBattle = won;
  
  [self.mainView removeButtons];
  [self.mainView.hudView removeBattleScheduleView];
  [self.mainView.hudView hideSkillPopup:nil];
  self.mainView.hudView.bottomView.hidden = YES;
  
  [self setMovesLeft:0 animated:NO];
  [self.mainView.movesLeftContainer removeFromParent];
  self.mainView.movesLeftContainer = nil;
  _movesLeftHidden = YES;
  
  [self removeOrbLayerAnimated:YES withBlock:^{
    [SoundEngine puzzleWinLoseUI];
    
    if ([self shouldShowChatLine]) {
      [self.endView showTextFieldWithTarget:self selector:@selector(sendButtonClicked:)];
    }
    
    self.endView.parent = nil;
    [self addChild:self.endView z:10000];
    
    if (won) {
      [self.endView.continueButton removeFromParent];
      
      [SoundEngine puzzleYouWon];
    } else {
      if ([self shouldShowContinueButton]) {
         [self.endView.shareButton removeFromParent];
      } else {
        [self.endView.continueButton removeFromParent];
      }
      
      [SoundEngine puzzleYouLose];
    }
  }];
}

- (void) buildReplay {
  [self.battleStateMachine addFinalState];
  
  CombatReplayProto *replay = [self createReplayWithBuilder:[CombatReplayProto builder]];
  
  [Globals sharedGlobals].lastReplay = replay;
}

- (CombatReplayProto*) createReplayWithBuilder:(CombatReplayProto_Builder*)builder {
  
  [builder setGroundImgPrefix:@"1"];
  
  if (_layoutProto)
    [builder setBoard:_layoutProto];
  else {
    [builder setBoardWidth:_gridSize.width];
    [builder setBoardHeight:_gridSize.height];
  }
  
  return [[[[[builder addAllOrbs:self.orbLayer.layout.orbRecords.allValues]
                                  addAllSteps:self.battleStateMachine.pastStates]
                                 addAllPlayerTeam:self.playerTeamSnapshot]
                                addAllEnemyTeam:self.enemyTeamSnapshot]
                               build];
}

- (void) sendReplay {
  //Temp stubishly stuff
}

#pragma mark - Skill Methods

/*
 Wrapping this in a centralized call so that it can be overwritten in replay mode
 in order to have better control over certain skill things
*/
- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion {
  [skillManager triggerSkills:trigger withCompletion:completion];
}

#pragma mark - Delegate Methods

- (void) moveBegan {
  [self setMovesLeft:_movesLeft - 1 animated:YES];
  [self updateHealthBars];
  [self.mainView.hudView removeSwapButtonAnimated:YES];
  [skillManager enableSkillButton:NO];
  
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  if ((self.orbLayer.allowFreeMove && bip.battleItemType == BattleItemTypeHandSwap) ||
      (self.orbLayer.allowOrbHammer && bip.battleItemType == BattleItemTypeOrbHammer) ||
      (self.orbLayer.allowPutty && bip.battleItemType == BattleItemTypePutty)) {
    [self deductBattleItem:bip];
    _selectedBattleItem = nil;
  }
}

- (void) newComboFound {
  
  [self.mainView updateComboCount:++_comboCount];
  _totalComboCount++;
  
  if (_canPlayNextComboSound) {
    _soundComboCount++;
    [SoundEngine puzzleComboCreated];
    [SoundEngine puzzleFirework];
    _canPlayNextComboSound = NO;
    [self scheduleOnce:@selector(allowComboSound) delay:0.02];
  }
}

- (void) allowComboSound {
  _canPlayNextComboSound = YES;
}

- (void) orbKilled:(BattleOrb *)orb {
  OrbColor color = orb.orbColor;
  
  _orbCount++;
  _orbCounts[color]++;
  _totalOrbCounts[color]++;
  
  [skillManager orbDestroyed:orb.orbColor special:orb.specialOrbType];
  
  // Update tile
  BattleTile* tile = [self.orbLayer.layout tileAtColumn:orb.column row:orb.row];
  
  BOOL mudOnBoard = [SkillController specialTilesOnBoardCount:TileTypeMud layout:self.orbLayer.layout] > 0; // All mud tiles have to be removed before any damage can be done
  if (tile.allowsDamage && !mudOnBoard) // Certain tiles (e.g. jelly) do not allow damage
  {
    // Increment damage, create label and ribbon
    int dmg = [self.myPlayerObject damageForColor:color] * (int)orb.damageMultiplier;
    _myDamageDealt += dmg;
    _myDamageForThisTurn += dmg;
  
    if (color != OrbColorNone && ElementIsValidValue((Element)color)) {
      NSString *dmgStr = [NSString stringWithFormat:@"%@", [Globals commafyNumber:dmg]];
      NSString *fntFile = [Globals imageNameForElement:(Element)color suffix:@"pointsfont.fnt"];
      fntFile = color != OrbColorRock ? fntFile : @"nightpointsfont.fnt";
      if (fntFile) {
        CCLabelBMFont *dmgLabel = [CCLabelBMFont labelWithString:dmgStr fntFile:fntFile];
        dmgLabel.position = [self.orbLayer convertToNodeSpace:
                             [self.orbLayer.swipeLayer convertToWorldSpace:
                              [self.orbLayer.swipeLayer pointForColumn:orb.column row:orb.row]]];
        [self.orbLayer addChild:dmgLabel z:101];
        
        dmgLabel.scale = 0.25;
        [dmgLabel runAction:[CCActionSequence actions:
                             [CCActionScaleTo actionWithDuration:0.2f scale:1],
                             [CCActionSpawn actions:
                              [CCActionFadeOut actionWithDuration:0.5f],
                              [CCActionMoveBy actionWithDuration:0.5f position:ccp(0,10)],nil],
                             [CCActionCallFunc actionWithTarget:dmgLabel selector:@selector(removeFromParent)], nil]];
      }
      
      CGPoint endPoint = [self.orbLayer convertToNodeSpace:[self.mainView.bgdContainer convertToWorldSpace:ccpAdd(self.mainView.myPlayer.position, ccp(0, self.mainView.myPlayer.contentSize.height/2))]];
      [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.15f skill:NO];

      // 2/24/15 - BN - Special orbs no longer count towards skill activation
      if (orb.specialOrbType == SpecialOrbTypeNone)
      {
        // Skill ribbons
        if ([skillManager shouldSpawnRibbonForPlayerSkill:orb.orbColor])
        {
          endPoint = [skillManager playerSkillIndicatorPosition];
          [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:YES];
        }
        if ([skillManager shouldSpawnRibbonForEnemySkill:orb.orbColor])
        {
          endPoint = [skillManager enemySkillIndicatorPosition];
          [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:YES];
        }
      }
    }
    else if (orb.specialOrbType == SpecialOrbTypeCake)
    {
      CGPoint endPoint = [self.orbLayer convertToNodeSpace:[self.mainView.bgdContainer convertToWorldSpace:ccpAdd(self.mainView.currentEnemy.position, ccp(0, self.mainView.currentEnemy.contentSize.height/2))]];
      [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:NO];
    }
  }
  
  // Update all tiles
  [tile orbRemoved];
  [self.orbLayer.bgdLayer updateTile:tile];
  
  if (_canPlayNextGemPop) {
    [SoundEngine puzzleDestroyPiece];
    _canPlayNextGemPop = NO;
    [self scheduleOnce:@selector(allowGemPop) delay:0.02];
  }
}

- (void) allowGemPop {
  _canPlayNextGemPop = YES;
}

- (void) powerupCreated:(BattleOrb *)orb {
  _powerupCounts[orb.powerupType]++;
}

- (void)reportSwap:(BattleSwap *)swap {
  [self.battleStateMachine.currentBattleState addOrbSwap:swap];
}

- (void)reportTap:(CGPoint)point {
  [self.battleStateMachine.currentBattleState addTapAtX:point.x andY:point.y];
}

- (void)reportVine:(CGPoint)position {
  [self.battleStateMachine.currentBattleState addVineAtX:position.x andY:position.y];
}

- (BOOL)hasVinePos {
  return NO;
}

- (CGPoint)getVinePos {
  return CGPointZero;
}

- (void) moveComplete {
  /*
   * 12/16/14 - BN - This check means if a turn results in no damage (e.g. because of
   * jelly or mud), it will not count as a turn. It can lead to unlimited turns and
   * combos. Why is it here? Whyeeeeeeeee?
   *
  if (_myDamageForThisTurn == 0) {
    [self.orbLayer allowInput];
    return;
  }
   */
  
  _soundComboCount = 0;
  
  [self.mainView moveOutComboCounter];
  
  [self updateHealthBars];
  
  // Trigger skills for move made by the player
  SkillLogStart(@"TRIGGER STARTED: end of player move");
  [self triggerSkills:SkillTriggerPointEndOfPlayerMove withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  End of player move ENDED");
    BOOL enemyIsKilled = [self checkEnemyHealth];
    if (! enemyIsKilled)
    {
      BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
      if (playerIsKilled)
        [self checkMyHealth];
      else
        [self checkIfAnyMovesLeft];
    }
  }];
  
  
  
  _comboCount = 0;
}

- (void) reshuffleWithPrompt:(NSString*)prompt {
  CCLabelTTF *label = [CCLabelTTF labelWithString:prompt fontName:@"GothamBlack" fontSize:15];
  label.horizontalAlignment = CCTextAlignmentCenter;
  label.verticalAlignment = CCVerticalTextAlignmentCenter;
  label.position = ccp(self.orbLayer.contentSize.width/2, self.orbLayer.contentSize.height/2);
  label.opacity = 0.0;
  [self.orbLayer addChild:label];
  
  [label runAction:[CCActionSequence actions:
                                [CCActionCallBlock actionWithBlock:^{
                                  [self.orbLayer.bgdLayer turnTheLightsOff]; }],
                                [CCActionFadeIn actionWithDuration:0.3],
                                [CCActionDelay actionWithDuration:0.7f],
                                [CCActionCallBlock actionWithBlock:^{
                                  [self.orbLayer.bgdLayer turnTheLightsOn]; }],
                                [CCActionFadeOut actionWithDuration:0.3],
                                [CCActionRemove action], nil]];
}

- (void)checkNoPossibleMoves {
  if (![self.orbLayer.layout detectPossibleSwaps].count) {
    [self noPossibleMoves];
  }
}

- (void)noPossibleMoves {
  if (!_noMovesLabel) {
    NSString* prompt = @"No possible moves!\nUse an item to continue";
    _noMovesLabel = [CCLabelTTF labelWithString:prompt fontName:@"GothamBlack" fontSize:15];
    _noMovesLabel.horizontalAlignment = CCTextAlignmentCenter;
    _noMovesLabel.verticalAlignment = CCVerticalTextAlignmentCenter;
    _noMovesLabel.position = ccp(self.orbLayer.contentSize.width/2, self.orbLayer.contentSize.height/2);
    _noMovesLabel.opacity = 0.0;
    [self.orbLayer addChild:_noMovesLabel];
  }
  
  [_noMovesLabel runAction:[CCActionSequence actions:
                    [CCActionCallBlock actionWithBlock:^{
    [self.orbLayer.bgdLayer turnTheLightsOff]; }],
                    [CCActionFadeIn actionWithDuration:0.3],
                    nil]];
}

- (void) hideNoMovesOverlay {
  if (_noMovesLabel) {
    [_noMovesLabel runAction:[CCActionSequence actions:
                              [CCActionCallBlock actionWithBlock:^{
      [self.orbLayer.bgdLayer turnTheLightsOn]; }],
                              [CCActionFadeOut actionWithDuration:0.3],
                              nil]];
  }
}

- (void) reachedNextScene {
  
  [self.mainView.myPlayer stopWalking];
  
  if (self.enemyPlayerObject) {
    
    _hasStarted = YES;
    _reachedNextScene = YES;
    
    // Mark first turn as true only if not loaded from a save
    _firstTurn = YES;
    
    [self beginNextTurn]; // One of the two racing calls for beginNextTurn, _reachedNextScene used as a flag
    [self updateHealthBars];
    [self.mainView.currentEnemy doRarityTagShine];
  }
}

- (void) mobsterViewTapped:(id)sender
{
  UIButton* senderButton = sender;
  UserMonster* monster;
  if (senderButton.tag)
    monster = [self.myPlayerObject getIncompleteUserMonster];
  else
    monster = [self.enemyPlayerObject getIncompleteUserMonster];
  
  if (! monster)
    return;
  
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:monster allowSell:YES];
  UIViewController *parent = [GameViewController baseController];
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

-(void) skillPopupClosed {
  if(_forcedSkillDialogueViewController) {
    [_forcedSkillDialogueViewController continueAndRevealSpeakers];
  }
}

#pragma mark - No Input Layer Methods

- (void) displayOrbLayer {
  const CGPoint orbLayerPosition = ccp(self.contentSize.width-self.orbLayer.contentSize.width/2-ORB_LAYER_DIST_FROM_SIDE, self.orbLayer.position.y);
  [self.orbLayer runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.4f position:orbLayerPosition] rate:3]];

  self.mainView.lootBgd.position = ccp(self.mainView.lootBgd.contentSize.width/2 + 10,
                              self.mainView.lootBgd.contentSize.height/2+ORB_LAYER_DIST_FROM_SIDE+self.mainView.hudView.swapView.height+7);
  [self.mainView displayLootCounter:YES];
  
  [SoundEngine puzzleOrbsSlideIn];
}

- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block {
  if (!block) {
    block = ^{};
  }
  
  CGPoint pos = ccp(self.contentSize.width+self.orbLayer.contentSize.width,
                    self.orbLayer.position.y);
  
  if (animated) {
    [self.orbLayer runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:0.3f position:pos],
      [CCActionCallBlock actionWithBlock:block], nil]];

    [self.mainView displayLootCounter:NO];
  } else {
    self.orbLayer.position = pos;
    self.mainView.lootBgd.opacity = 0.f;
    self.mainView.lootLabel.opacity = 0.f;
    block();
  }
}


#pragma mark - Hud views

- (void) itemsClicked:(id)sender {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    return;
  }
  
  BOOL showFooter = !self.allowBattleItemPurchase;
  BattleItemSelectViewController *svc = [[BattleItemSelectViewController alloc] initWithShowUseButton:YES showFooterView:showFooter showItemFactory:YES];
  if (svc) {
    svc.delegate = self;
    self.mainView.popoverViewController = svc;
    
    GameViewController *gvc = [GameViewController baseController];
    svc.view.frame = gvc.view.bounds;
    [gvc addChildViewController:svc];
    [gvc.view addSubview:svc.view];
    
    if (sender == nil)
    {
      [svc showCenteredOnScreen];
    }
    else
    {
      if ([sender isKindOfClass:[UIButton class]])
      {
        [svc showAnchoredToInvokingView:self.mainView.hudView.itemsButton.superview
                          withDirection:ViewAnchoringPreferTopPlacement
                      inkovingViewImage:[Globals maskImage:[Globals snapShotView:self.mainView.hudView.itemsButton.superview] withColor:[UIColor whiteColor]]];
      }
    }
  }
}

- (BOOL) canSwap {
  return _orbCount == 0 && !self.orbLayer.swipeLayer.isTrackingTouch;
}

- (IBAction)swapClicked:(id)sender {
  if (_orbCount == 0 && !self.orbLayer.swipeLayer.isTrackingTouch) {
    [self.mainView.hudView removeSwapButtonAnimated:YES];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self.orbLayer disallowInput];
  
  [self.mainView displayLootCounter:NO];
  
  [self.mainView.hudView.deployView updateWithBattlePlayers:self.myTeam];
  
  [self.mainView.hudView displayDeployViewToCenterX:DEPLOY_CENTER_X cancelTarget:cancel ? self : nil selector:@selector(cancelDeploy:)];
  
  [SoundEngine puzzleSwapWindow];
}

- (IBAction)cancelDeploy:(id)sender {
  [self deployBattleSprite:nil];
  [SoundEngine puzzleSwapWindow];
}

- (IBAction)deployCardClicked:(id)sender {
  while (![sender isKindOfClass:[BattleDeployCardView class]]) {
    sender = [sender superview];
  }
  BattleDeployCardView *card = (BattleDeployCardView *)sender;
  
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    if (b.slotNum == card.tag && b.curHealth > 0) {
      bp = b;
    }
  }
  
  if (bp) {
    [self fireEvent:playerSwapEvent userInfo:@{SWAP_TOON_KEY : bp} error:nil];
    //[self deployBattleSprite:bp];
  }
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  [self.mainView.hudView removeDeployView];
  [self.mainView displayLootCounter:YES];
  BOOL isSwap = self.mainView.myPlayer != nil;
  if (bp && ![bp.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
    
    [self.mainView.myPlayer removeAllSkillSideEffects];
    self.myPlayerObject = bp;
    
    if (bp.isClanMonster) {
      GameState *gs = [GameState sharedGameState];
      ClanMemberTeamDonationProto *donation = [gs.clanTeamDonateUtil myTeamDonation];
      UserMonster *um = [donation donatedMonsterWithResearchUtil:gs.researchUtil];
      if ([um.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
        [[OutgoingEventController sharedOutgoingEventController] invalidateSolicitation:donation];
      }
    }
    
    
    if (isSwap) {
      [self.mainView makeMyPlayerWalkOutWithBlock:nil];
      [self.mainView removeButtons];
    }
    
    [self createScheduleWithSwap:isSwap];
    
    [self.mainView createNextMyPlayerSpriteWithBattlePlayer:bp];
    
    [self triggerSkillForPlayerCreatedWithBlock:^{
      
      // If it is swap, enemy should attack
      // If it is game start, wait till battle response has arrived
      // Otherwise, it is coming back from player just dying
      SEL selector = isSwap ? @selector(beginNextTurn) : !_hasStarted ? @selector(reachedNextScene) : @selector(beginNextTurn);
      [self makePlayer:self.mainView.myPlayer walkInFromEntranceWithSelector:selector];
    }];
    
  } else if (isSwap) {
    [self.mainView.hudView displaySwapButton];
    [self.orbLayer allowInput];
    [self.orbLayer.bgdLayer turnTheLightsOn];
  }
}

- (void) triggerSkillForPlayerCreatedWithBlock:(dispatch_block_t)block {
  
  // Skills trigger for player appeared
  SkillLogStart(@"TRIGGER STARTED: player initialized");
  [self triggerSkills:SkillTriggerPointPlayerInitialized withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Player initialized trigger ENDED");
    
    if (block) {
      block();
    }
    
  }];
}

#pragma mark - Continue View Actions

- (IBAction)forfeitClicked:(id)sender {
  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
    [GenericPopupController displayNegativeConfirmationWithDescription:@"You will lose everything - are you sure you want to forfeit?"
                                                                 title:@"Forfeit Battle"
                                                            okayButton:@"Forfeit"
                                                          cancelButton:@"Cancel"
                                                              okTarget:self
                                                            okSelector:@selector(youForfeited)
                                                          cancelTarget:nil
                                                        cancelSelector:nil];
  }
}

- (IBAction)winExitClicked:(id)sender {
  [self exitFinal];
  
  [SoundEngine generalButtonClick];
}

- (void) exitFinal {
  if (!_isExiting) {
    _isExiting = YES;
    
    [self.mainView removeButtons];
    
    [self.mainView.popoverViewController closeClicked:nil];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[self battleCompleteValues]];
    [self.delegate battleComplete:dict];
  }
}

- (NSDictionary *) battleCompleteValues {
  return nil;
}

- (IBAction)shareClicked:(id)sender {
  [self buildReplay];
  [self exitFinal];
  
  [SoundEngine generalButtonClick];
}

- (IBAction)continueClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  
  if (gemsAmount > 0) {
    NSString *desc = [NSString stringWithFormat:@"Would you like to heal your entire team for %d gems?", gemsAmount];
    [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Heal Team?" gemCost:gemsAmount target:self selector:@selector(firePlayerReviveEvent)];
  } else {
    [self firePlayerReviveEvent];
  }
  
  [SoundEngine generalButtonClick];
}

- (void) firePlayerReviveEvent {
  [self fireEvent:playerReviveEvent userInfo:nil error:nil];
}

- (void)fireEvent:(TKEvent *)event userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error{
  [self.battleStateMachine fireEvent:event userInfo:userInfo error:nil];
}

- (void) continueConfirmed {
  [self.endView removeFromParent];
  
  [self displayDeployViewAndIsCancellable:NO];
  [self displayOrbLayer];
}

- (void) forceSkillClickOver:(DialogueViewController *)dvc {
  _forcedSkillDialogueViewController = dvc;
  
  [self.mainView forceSkillClickOver];
}

- (IBAction)skillClicked:(id)sender {
  [_forcedSkillDialogueViewController pauseAndHideSpeakers];
}

- (IBAction)sendButtonClicked:(id)sender {
  // Do nothing
}

#pragma mark - Battle Item Select Delegate

- (void) updateItemsBadge {
  GameState *gs = [GameState sharedGameState];
  int quantity = 0;
  
  for (UserBattleItem *ubi in gs.battleItemUtil.battleItems) {
    if ([self battleItemIsValid:ubi]) {
      quantity += ubi.quantity;
    }
  }
  
  self.mainView.hudView.itemsBadge.badgeNum = quantity;
}

- (NSArray *) reloadBattleItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  BattleItemUtil *bi = gs.battleItemUtil;
  for (BattleItemProto *bip in gs.staticBattleItems.allValues) {
    UserBattleItem *ubi = [bi getUserBattleItemForBattleItemId:bip.battleItemId];
    
    if (!ubi) {
      ubi = [[UserBattleItem alloc] init];
      ubi.battleItemId = bip.battleItemId;
    }
    
    if (ubi.quantity > 0 || self.allowBattleItemPurchase) {
      [arr addObject:ubi];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserBattleItem *obj1, UserBattleItem *obj2) {
    BOOL isValid1 = [self battleItemIsValid:obj1];
    BOOL isValid2 = [self battleItemIsValid:obj2];
    BOOL hasQuant1 = obj1.quantity > 0;
    BOOL hasQuant2 = obj2.quantity > 0;
    
    if (isValid1 != isValid2) {
      return [@(isValid2) compare:@(isValid1)];
    } else if (hasQuant1 != hasQuant2) {
      return [@(hasQuant2) compare:@(hasQuant1)];
    } else {
      return [@(obj1.staticBattleItem.priority) compare:@(obj2.staticBattleItem.priority)];
    }
  }];
  
  return arr;
}

- (void) battleItemSelected:(UserBattleItem *)item viewController:(BattleItemSelectViewController *)viewController {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.mainView.popoverViewController closeClicked:nil];
    return;
  }
  
  BattleItemProto *bip = item.staticBattleItem;
  if ([self battleItemIsValid:item]) {
    _selectedBattleItem = item;
    if (item.quantity > 0) {
      [self useSelectedBattleItem];
    } else {
      NSString *desc = [NSString stringWithFormat:@"Would you like to purchase a %@ for %d Gems?", bip.name, bip.inBattleGemCost];
      NSString *title = [NSString stringWithFormat:@"Purchase %@?", bip.name];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:title gemCost:bip.inBattleGemCost target:self selector:@selector(checkUserHasGemsToPurchaseItem)];
    }
  } else {
    NSString *str = nil;
    switch (bip.battleItemType) {
      case BattleItemTypePoisonAntidote:
        str = [NSString stringWithFormat:@"Your %@ must be Poisoned to use this Antidote.", MONSTER_NAME];
        break;
        
      case BattleItemTypeChillAntidote:
        str = [NSString stringWithFormat:@"Your %@ must be Chilled to use this Antidote.", MONSTER_NAME];
        break;
        
      case BattleItemTypeHealingPotion:
        str = [NSString stringWithFormat:@"Your %@ is already at full health.", MONSTER_NAME];
        break;
        
      case BattleItemTypePutty:
        str = [NSString stringWithFormat:@"There are no holes to use %@ on.", bip.name];
        break;
        
      case BattleItemTypeBoardShuffle:
      case BattleItemTypeHandSwap:
      case BattleItemTypeOrbHammer:
      case BattleItemTypeNone:
        // Should always be valid
        break;
    }
    
    if (str) {
      [Globals addAlertNotification:str];
    }
  }
}

- (void) checkUserHasGemsToPurchaseItem {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.mainView.popoverViewController closeClicked:nil];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  
  if (bip.inBattleGemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsViewWithTarget:self selector:@selector(openGemShop)];
  } else {
    [self useSelectedBattleItem];
  }
}

- (void) useSelectedBattleItem {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.mainView.popoverViewController closeClicked:nil];
    return;
  }
  
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  
  NSString *instruction = nil;
  switch (bip.battleItemType) {
    case BattleItemTypeHealingPotion:
      [self useHealthPotion:bip];
      break;
      
    case BattleItemTypeBoardShuffle:
      [self useBoardShuffle:bip];
      break;
      
    case BattleItemTypeHandSwap:
      [self useHandSwap:bip];
      instruction = @"Swipe any two orbs to swap.";
      break;
      
    case BattleItemTypeOrbHammer:
      [self useOrbHammer:bip];
      instruction = @"Tap an orb to destroy it.";
      break;
      
    case BattleItemTypePutty:
      [self usePutty:bip];
      instruction = @"Tap a hole to fill it in.";
      break;
      
    case BattleItemTypeChillAntidote:
    case BattleItemTypePoisonAntidote:
      [self useSkillAntidote:bip];
      break;

	case BattleItemTypeNone:
      break;
  }
  
  // The ones that aren't done immediately get deducted in moveBegan
  if (!instruction) {
    [self deductBattleItem:bip];
    _selectedBattleItem = nil;
  } else {
    DialogueViewController *dvc = [[DialogueViewController alloc] initWithBattleItemName:bip instruction:instruction];
    dvc.delegate = self;
    GameViewController *gvc = [GameViewController baseController];
    [gvc addChildViewController:dvc];
    dvc.view.frame = gvc.view.bounds;
    
    // If the dialogue view controller gets finished, cancel the battle items.
    // Cover everything that's to the left of the board instead of whole screen
    dvc.view.width -= (self.orbLayer.contentSize.width+ORB_LAYER_DIST_FROM_SIDE);
    [gvc.view addSubview:dvc.view];
    
    self.mainView.dialogueViewController = dvc;
  }
  
  [self.mainView.popoverViewController closeClicked:nil];
}

- (void) deductBattleItem:(BattleItemProto *)bip {
  [self.battleStateMachine.currentBattleState addItemUse:bip.battleItemId];
  GameState *gs = [GameState sharedGameState];
  UserBattleItem *ubi = [gs.battleItemUtil getUserBattleItemForBattleItemId:bip.battleItemId];
  if (ubi.quantity > 0) {
    [[OutgoingEventController sharedOutgoingEventController] removeBattleItems:@[@(bip.battleItemId)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_REMOVED_NOTIFICATION object:nil];
    
    [self updateItemsBadge];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] updateUserCurrencyWithCashSpent:0 oilSpent:0 gemsSpent:bip.inBattleGemCost reason:[NSString stringWithFormat:@"Purchased %@ in battle.", bip.name]];
  }
  
  if (self.mainView.dialogueViewController) {
    [self.mainView.dialogueViewController animateNext];
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self cancelBattleItems];
}

- (void) cancelBattleItems {
  [self.orbLayer cancelFreeMove];
  [self.orbLayer cancelOrbHammer];
  [self.orbLayer cancelPutty];
  
  //A little hacky, but this quickly tells us whether the user actually used the item (animations would be playing if they used something)
  if (self.orbLayer.swipeLayer.userInteractionEnabled)
    [self checkNoPossibleMoves];
  
  self.mainView.dialogueViewController = nil;
}

- (BOOL) battleItemIsValid:(UserBattleItem *)item {
  BattleItemProto *bip = item.staticBattleItem;
  switch (bip.battleItemType) {
    case BattleItemTypeBoardShuffle:
    case BattleItemTypeHandSwap:
    case BattleItemTypeOrbHammer:
      return YES;
      
    case BattleItemTypePutty:
    {
      // Check all the tiles for holes
      for (int i = 0; i < self.orbLayer.layout.numColumns; i++) {
        for (int j = 0; j < self.orbLayer.layout.numRows; j++) {
          BattleTile *tile = [self.orbLayer.layout tileAtColumn:i row:j];
          if (tile.isHole) {
            return YES;
          }
        }
      }
      
      return NO;
    }
      
    case BattleItemTypeHealingPotion:
      return self.myPlayerObject.curHealth < self.myPlayerObject.maxHealth;
      
    case BattleItemTypeChillAntidote:
    case BattleItemTypePoisonAntidote:
      return [skillManager useAntidote:bip execute:NO];

    case BattleItemTypeNone:
      return NO;
  }
}

- (void) battleItemSelectClosed:(id)viewController {
  self.mainView.popoverViewController = nil;
}

#pragma mark Using Battle Items

- (void) useHealthPotion:(BattleItemProto *)bip {
  [self moveBegan];
  [self healForAmount:bip.amount enemyIsHealed:NO withTarget:self andSelector:@selector(moveComplete)];
  [self sendServerUpdatedValuesVerifyDamageDealt:NO];
  [skillManager showItemPopupOverlay:bip bottomText:[NSString stringWithFormat:@"+%i HP", bip.amount]];
  [self.mainView pulseHealthLabelIfRequired:NO forBattlePlayer:self.myPlayerObject ];
}

- (void) useBoardShuffle:(BattleItemProto *)bip {
  [self moveBegan];
  [self.orbLayer shuffleWithoutEnforcementAndCheckMatches];
}

- (void) useHandSwap:(BattleItemProto *)bip {
  [self.orbLayer allowFreeMoveForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) useOrbHammer:(BattleItemProto *)bip {
  [self.orbLayer allowOrbHammerForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) usePutty:(BattleItemProto *)bip {
  [self.orbLayer allowPuttyForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) useSkillAntidote:(BattleItemProto *)bip {
  [self moveBegan];
  [skillManager useAntidote:bip execute:YES];
}

#pragma mark - Open Shop

- (void) openGemShop {
  GameViewController *gvc = [GameViewController baseController];
  ShopViewController *svc = [[ShopViewController alloc] init];
  
  [svc displayInParentViewController:gvc];
  [svc openFundsShop];
  
  svc.mainView.originY += (svc.tabBar.superview.height-svc.tabBar.originY);
  
  [self.mainView.popoverViewController closeClicked:nil];
}

@end

#pragma clang diagnostic pop
