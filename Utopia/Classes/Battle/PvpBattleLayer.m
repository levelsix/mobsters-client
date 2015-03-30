//
//  PvpBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PvpBattleLayer.h"
#import "FullEvent.h"
#import "GameViewController.h"
#import <Kamcord/Kamcord.h>
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "GameState.h"
#import "Globals.h"
#import <cocos2d-ui.h>
#import "SoundEngine.h"
#import "AchievementUtil.h"
#import "ChartboostDelegate.h"

@implementation PvpBattleLayer

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize {
  if ((self = [super initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize])) {
    self.shouldShowChatLine = YES;
  }
  return self;
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize pvpHistoryForRevenge:(PvpHistoryProto *)hist {
  if ((self = [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize])) {
    _isRevenge = YES;
    _prevBattleStartTime = hist.battleEndTime;
  }
  return self;
}

- (void) setClanAvenging:(PvpClanAvenging *)ca {
  _clanAvenging = ca;
}

- (CCSprite *) getCurrentEnemyLoot {
  GameState *gs = [GameState sharedGameState];
  PvpProto *pvp = self.defendersList[_curQueueNum];
  NSArray *monsterList = pvp.defenderMonstersList;
  
  if (pvp.hasCmtd) {
    PvpMonsterProto *pmp = [[[PvpMonsterProto builder] setMonsterIdDropped:pvp.monsterIdDropped] build];
    monsterList = [monsterList arrayByAddingObject:pmp];
  }
  
  PvpMonsterProto *pm = monsterList[_curStage];
  
  CCSprite *ed = nil;
  if (pm.hasMonsterIdDropped && pm.monsterIdDropped > 0) {
    BOOL isComplete = NO;
    
    MonsterProto *mp = [gs monsterWithId:pm.monsterIdDropped];
    NSString *fileName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:(isComplete ? @"ball.png" : @"piece.png")]];
    ed = [CCSprite spriteWithImageNamed:fileName];
  }
  return ed;
}

- (void) moveBegan {
  [super moveBegan];
  _userAttacked = YES;
}

- (void) beginEnemyTurn:(float)delay {
  [super beginEnemyTurn:delay];
  _userAttacked = YES;
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
  [self removeCloseButton];
}

#pragma mark - Close Button

- (void) createCloseButton {
  if (!_isExiting) {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[Globals imageNamed:@"closebattle.png"] forState:UIControlStateNormal];
    [Globals displayUIView:self.closeButton];
    self.closeButton.frame = CGRectMake(4, 4, 30, 30);
    [self.closeButton addTarget:self action:@selector(forfeitClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void) removeCloseButton {
  [self.closeButton removeFromSuperview];
}

#pragma mark - Continue View Actions

- (void) youWon {
  [super youWon];
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [self.endView updateForRewards:[Reward createRewardsForPvpProto:pvp droplessStageNums:self.droplessStageNums isWin:YES] isWin:YES allowsContinue:NO continueCost:0];
  [[OutgoingEventController sharedOutgoingEventController] endPvpBattleMessage:pvp userAttacked:_userAttacked userWon:YES droplessStageNums:self.droplessStageNums delegate:self];
  
  // Send a private chat if avenge
  if (_clanAvenging) {
    NSString *msg = [NSString stringWithFormat:@"I have successfully avenged you and defeated %@.", _clanAvenging.attacker.minUserProto.name];
    [[OutgoingEventController sharedOutgoingEventController] privateChatPost:_clanAvenging.defender.userUuid content:msg];
  }
}

- (void) youLost {
  [super youLost];
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [self.endView updateForRewards:[Reward createRewardsForPvpProto:pvp droplessStageNums:self.droplessStageNums isWin:NO] isWin:NO allowsContinue:NO continueCost:0];
  [[OutgoingEventController sharedOutgoingEventController] endPvpBattleMessage:pvp userAttacked:_userAttacked userWon:NO droplessStageNums:self.droplessStageNums delegate:self];
  
  // Send a private chat if avenge
  if (_clanAvenging) {
    NSString *msg = [NSString stringWithFormat:@"I have attacked %@ but was unable to avenge you.", _clanAvenging.attacker.minUserProto.name];
    [[OutgoingEventController sharedOutgoingEventController] privateChatPost:_clanAvenging.defender.userUuid content:msg];
  }
}

- (IBAction)forfeitClicked:(id)sender {
  if (_hasChosenEnemy) {
    [super forfeitClicked:nil];
  } else {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to leave?"
                                                         title:@"Leave?"
                                                    okayButton:@"Leave"
                                                  cancelButton:@"Cancel"
                                                      okTarget:self
                                                    okSelector:@selector(leaveBattle)
                                                  cancelTarget:nil
                                                cancelSelector:nil];
  }
}

- (void) youForfeited {
  [super youForfeited];
  _didRunaway = YES;
}

- (void) leaveBattle {
  [self exitFinal];
  
  [self removeCloseButton];
  
  [Analytics foundMatch:@"closed"];
}

- (IBAction)winExitClicked:(id)sender {
  if (!_waitingForEndPvpResponse) {
    if (!_receivedEndPvpResponse) {
      _waitingForEndPvpResponse = YES;
      
      [self.endView spinnerOnDone];
    } else {
      [self exitFinal];
    }
  }
}

- (void) exitFinal {
  [super exitFinal];
  
  if (_hasChosenEnemy) {
    [ChartboostDelegate firePvpMatch];
  }
}

- (void) handleEndPvpBattleResponseProto:(FullEvent *)fe {
  _receivedEndPvpResponse = YES;
  
  EndPvpBattleResponseProto *response = (EndPvpBattleResponseProto *)fe.event;
  
  if (response.hasStatsBefore && response.hasStatsAfter) {
    PvpLeagueProto *newLeague = [[GameState sharedGameState] leagueForId:response.statsAfter.leagueId];
    
    if (response.statsBefore.leagueId == response.statsAfter.leagueId)
    {
      [self.endView updatePvpReward:newLeague leagueChange:NO change:(response.statsBefore.rank - response.statsAfter.rank)];
    } else {
      [self.endView updatePvpReward:newLeague leagueChange:YES change:(response.statsAfter.leagueId - response.statsBefore.leagueId)];
    }
  }
  
  [self checkQuests];
  [self sendAnalytics];
  
  if (_waitingForEndPvpResponse) {
    [self exitFinal];
  }
}

- (void) checkQuests {
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [AchievementUtil checkAchievementsForPvpBattleWithOrbCounts:_totalOrbCounts powerupCounts:_powerupCounts comboCount:_totalComboCount damageTaken:_totalDamageTaken pvpInfo:pvp wonBattle:_wonBattle];
}

- (void) sendAnalytics {
  
  GameState *gs = [GameState sharedGameState];
  PvpProto *pvp = self.defendersList[_curQueueNum];
  PvpLeagueProto *league = [gs leagueForId:gs.pvpLeague.leagueId];
  
  NSString *outcome = _wonBattle ? @"Win" : _didRunaway ? @"Flee" : @"Lose";
  [Analytics pvpMatchEnd:_wonBattle numEnemiesDefeated:_curStage mobstersUsed:self.myTeam totalRounds:(int)self.enemyTeam.count elo:gs.pvpLeague.elo oppElo:pvp.pvpLeagueStats.elo oppId:pvp.defender.minUserProto.userUuid outcome:outcome league:league.leagueName];
}

- (void) sendButtonClicked:(id)sender {
  UITextField *tf = self.endView.msgTextField;
  if (tf.text.length) {
    PvpProto *pvp = self.defendersList[_curQueueNum];
    
    if (pvp.defender.minUserProto.hasUserUuid && pvp.defender.minUserProto.userUuid.length > 0) {
      [[OutgoingEventController sharedOutgoingEventController] privateChatPost:pvp.defender.minUserProto.userUuid content:tf.text];
    }
    
    tf.text = nil;
    [tf resignFirstResponder];
    
    [self.endView replaceTextFieldWithMessageSentLabel];
  }
}

#pragma mark - Queue Node Methods

- (void) loadQueueNode {
  [CCBReader load:@"BattleQueueNode" owner:self];
  [self addChild:self.queueNode z:10000];
  self.queueNode.visible = NO;
}

- (void) displayQueueNode {
  if (self.defendersList.count > _curQueueNum && _curQueueNum >= 0) {
    if (!self.queueNode) {
      [self loadQueueNode];
    }
    
    PvpProto *pvp = self.defendersList[_curQueueNum];
    [self.queueNode updateForPvpProto:pvp];
    self.queueNode.visible = YES;
    self.queueNode.position = ccp(self.contentSize.width-self.queueNode.contentSize.width, self.contentSize.height/2-self.queueNode.contentSize.height/2);
    self.queueNode.gradientNode.scaleY = self.contentSize.height/self.queueNode.gradientNode.contentSize.height;
    [self.queueNode fadeInAnimationForIsRevenge:_isRevenge || _clanAvenging];
    
    [SoundEngine puzzlePvpQueueUISlideIn];
  }
}

- (void) removeQueueNode {
  [self.queueNode fadeOutAnimation];
  
  [SoundEngine puzzlePvpQueueUISlideOut];
}

- (void) nextMatchClicked {
  if (!self.queueNode.userInteractionEnabled) return;
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  if (gs.cash < thp.pvpQueueCashCost) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeCash requiredAmount:thp.pvpQueueCashCost shouldAccumulate:YES];
      rif.delegate = self;
      svc.delegate = rif;
      self.popoverViewController = svc;
      self.resourceItemsFiller = rif;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      CCNode* invokingButton = nil;
      for (CCNode* child in self.queueNode.nextButtonNode.children)
      {
        if ([child isKindOfClass:[CCButton class]])
        {
          invokingButton = child;
          break;
        }
      }
      
      if (invokingButton == nil)
      {
        [svc showCenteredOnScreen];
      }
      else
      {
        CGPoint worldSpacePosition = [invokingButton.parent convertToWorldSpace:invokingButton.boundingBox.origin];
        CGRect worldSpaceFrame = CGRectMake(worldSpacePosition.x, [Globals screenSize].height - (worldSpacePosition.y + invokingButton.boundingBox.size.height),
                                            invokingButton.boundingBox.size.width, invokingButton.boundingBox.size.height);
        UIView* floatingView = [[UIView alloc] initWithFrame:worldSpaceFrame];
        
        if (_nextMatchButtonMask == nil) _nextMatchButtonMask = [UIImage imageNamed:@"nextmatchmask.png"];
        [svc showAnchoredToInvokingView:floatingView withDirection:ViewAnchoringPreferLeftPlacement inkovingViewImage:_nextMatchButtonMask];
      }
    }
  } else {
    [self nextMatchWithItemsDict:nil useGems:NO];
  }
}

- (void) nextMatchWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = thp.pvpQueueCashCost;
  ResourceType resType = ResourceTypeCash;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self nextMatchWithItemsDict:itemIdsToQuantity useGems:allowGems];
  }
}

- (void) nextMatchWithItemsDict:(NSDictionary *)itemIdsToQuantity useGems:(BOOL)useGems {
  self.itemUsagesForQueue = itemIdsToQuantity;
  
  [self removeQueueNode];
  
  if (self.statueNode) {
    [self destroyEnemyStatueWithExplosion:YES];
  }
  
  for (BattleSprite *bs in self.enemyTeamSprites) {
    CGPoint startPos = bs.position;
    CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
    float startX = self.contentSize.width+self.myPlayer.contentSize.width;
    float xDelta = startPos.x-startX;
    CGPoint endPos = ccp(startX, startPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
    
    bs.isFacingNear = NO;
    [bs beginWalking];
    [bs runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED position:endPos],
      [CCActionCallFunc actionWithTarget:bs selector:@selector(removeFromParent)], nil]];
    
    _numTimesNotResponded = 0;
  }
  
  _spawnedNewTeam = NO;
  self.enemyTeam = nil;
  self.enemyTeamSprites = nil;
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallFunc actionWithTarget:self selector:@selector(reachedNextScene)], nil]];
  
  [Analytics foundMatch:@"skip"];
}

- (void) startMatchClicked {
  if (!self.queueNode.userInteractionEnabled) return;
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [[OutgoingEventController sharedOutgoingEventController] beginPvpBattle:pvp isRevenge:_isRevenge previousBattleTime:_prevBattleStartTime];
  
  [self removeQueueNode];
  
  if (self.statueNode) {
    // Explode if the clan statue is first enemy because then enemy can appear from behind the explosion
    [self destroyEnemyStatueWithExplosion:self.enemyTeamSprites.count == 0];
  }
  
  if (self.enemyTeamSprites.count) {
    self.currentEnemy = [self.enemyTeamSprites firstObject];
    self.enemyPlayerObject = [self.enemyTeam firstObject];
    for (BattleSprite *bs in self.enemyTeamSprites) {
      if (bs == self.currentEnemy) {
        continue;
      }
      CGPoint startPos = bs.position;
      CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
      float startX = self.contentSize.width+self.myPlayer.contentSize.width;
      float xDelta = startPos.x-startX;
      CGPoint endPos = ccp(startX, startPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
      
      bs.isFacingNear = NO;
      [bs beginWalking];
      [bs runAction:
       [CCActionSequence actions:
        [CCActionMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED position:endPos],
        [CCActionCallFunc actionWithTarget:bs selector:@selector(removeFromParent)], nil]];
    }
    self.enemyTeamSprites = nil;
  } else {
    [self spawnNextEnemy];
    [self.currentEnemy stopAllActions];
    self.currentEnemy.position = self.statueNode.position;
    self.currentEnemy.zOrder = self.statueNode.zOrder;
  }
  
  self.myPlayerObject = [self.myTeam firstObject];
  BattleSprite *myPlayer = [self.myTeamSprites firstObject];
  self.myTeamSprites = [self.myTeamSprites subarrayWithRange:NSMakeRange(1, self.myTeamSprites.count-1)];
  for (BattleSprite *bs in self.myTeamSprites) {
    self.myPlayer = bs;
    [self makeMyPlayerWalkOutWithBlock:nil];
  }
  self.myPlayer = myPlayer;
  self.myTeamSprites = nil;
  
  // Have to fake this
  //  _reachedNextScene = YES;
  //  [self createScheduleWithSwap:NO];
  //  [self beginNextTurn];
  [self removeCloseButton];
  
  _hasChosenEnemy = YES;
  _curStage = 0;
  _hasStarted = YES;
  _firstTurn = YES;
  
  _displayedWaveNumber = YES;
  _reachedNextScene = YES;
  self.hudView.waveNumLabel.text = [NSString stringWithFormat:@"ENEMY %d/%d", _curStage+1, (int)self.enemyTeam.count];
  
  // At this point data for the potential custom PvP board of
  // the enemy is at hand, so we need to recreate the board
  [self recreateOrbLayer];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.7f],
    [CCActionCallFunc actionWithTarget:self selector:@selector(displayOrbLayer)],
    
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self triggerSkillForPlayerCreatedWithBlock:^{
         [self triggerSkillForEnemyCreatedWithBlock:^{
           [self createScheduleWithSwap:NO playerHitsFirst:NO];
           [self beginNextTurn];
         }];
       }];
     }], nil]];
  
  [Analytics foundMatch:@"attack"];
}

- (BOOL) spawnNextEnemy {
  BOOL success = [super spawnNextEnemy];
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  if (success && pvp.hasCmtd && _curStage == pvp.defenderMonstersList.count) {
    [[OutgoingEventController sharedOutgoingEventController] invalidateSolicitation:pvp.cmtd];
  }
  
  return success;
}

- (void) recreateOrbLayer {
  CGPoint pos = CGPointZero;
  if (self.orbLayer) {
    pos = self.orbLayer.position;
    [self.orbLayer removeFromParent];
    self.orbLayer = nil;
  }
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  NSArray *userBoardObstacles = pvp.userBoardObstaclesList;
  OrbMainLayer *ol = [[OrbMainLayer alloc] initWithGridSize:_gridSize userBoardObstacles:userBoardObstacles];
  ol.position = pos;
  ol.delegate = self;
  self.orbLayer = ol;
  
  [self addChild:ol z:2];
}

#pragma mark - Waiting for server

- (void) handleQueueUpResponseProto:(FullEvent *)fe {
  QueueUpResponseProto *proto = (QueueUpResponseProto *)fe.event;
  
  if (proto.status == QueueUpResponseProto_QueueUpStatusSuccess && proto.defenderInfoListList.count > 0) {
    _curQueueNum = -1;
    self.defendersList = proto.defenderInfoListList;
  } else if (!_isExiting) {
    _numTimesAttemptedQueueUp++;
    
    if (_numTimesAttemptedQueueUp < 10) {
      // Try firing another queue up in 2 seconds
      [self scheduleOnce:@selector(fireQueueUp) delay:2.f];
      
      _numTimesNotResponded = 0;
    } else {
      _numTimesNotResponded = 100;
    }
  }
}

- (void) fireQueueUp {
  [[OutgoingEventController sharedOutgoingEventController] queueUpEvent:self.seenUserUuids withDelegate:self];
}

- (void) handleRetrieveUserMonsterTeamResponseProto:(FullEvent *)fe {
  RetrieveUserMonsterTeamResponseProto *proto = (RetrieveUserMonsterTeamResponseProto *)fe.event;
  
  if (proto.status == RetrieveUserMonsterTeamResponseProto_RetrieveUserMonsterTeamStatusSuccess) {
    _curQueueNum = -1;
    self.defendersList = proto.userMonsterTeamList;
  } else {
    [GenericPopupController displayNotificationViewWithText:@"Sorry, we were unable to load this enemy." title:@"Enemy Not Found" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
  }
}

- (void) begin {
  [Kamcord startRecording];
  
  [self deployMyTeam];
  
  [self loadQueueNode];
  
  [self scheduleOnce:@selector(createCloseButton) delay:2.f];
}

- (void) deployMyTeam {
  // Move first my player to from
  if (self.myTeam.count > 1) {
    BattlePlayer *first = [self firstMyPlayer];
    NSMutableArray *team = [self.myTeam mutableCopy];
    [team removeObject:first];
    [team insertObject:first atIndex:0];
    self.myTeam = team;
  }
  
  NSMutableArray *mut = [NSMutableArray array];
  _numMyPlayersRanIn = 0;
  for (BattlePlayer *bp in self.myTeam) {
    NSInteger idx = [self.myTeam indexOfObject:bp];
    BattleSprite *bs = [[BattleSprite alloc]  initWithPrefix:bp.spritePrefix nameString:bp.attrName rarity:bp.rarity animationType:bp.animationType isMySprite:YES verticalOffset:bp.verticalOffset];
    bs.battleLayer = self;
    bs.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)bp.element];
    [self.bgdContainer addChild:bs z:idx];
    bs.isFacingNear = NO;
    
    CGPoint finalPos = MY_PLAYER_LOCATION;
    
    // Clan monster should always be in 4th slot unless it is the first monster
    if ((bp.isClanMonster && idx > 0) || idx == 3) {
      finalPos = ccpAdd(finalPos, ccpMult(POINT_OFFSET_PER_SCENE, -0.1));
    } else if (idx == 1) {
      finalPos = ccpAdd(finalPos, ccp(-46, -3));
    } else if (idx == 2) {
      finalPos = ccpAdd(finalPos, ccp(7, -35));
    }
    
    
    bs.position = finalPos;
    [self makePlayer:bs walkInFromEntranceWithSelector:@selector(checkRunningIn)];
    _numMyPlayersRanIn++;
    
    bs.healthBar.percentage = ((float)bp.curHealth)/bp.maxHealth*100;
    bs.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    [mut addObject:bs];
    
    if (idx == 0) {
      // Do this so the enemies calibrating message will pop up over someones head
      self.myPlayer = bs;
      self.myPlayerObject = bp;
    }
  }
  self.myTeamSprites = mut;
}

- (void) checkRunningIn {
  _numMyPlayersRanIn--;
  if (_numMyPlayersRanIn == 0) {
    [self reachedNextScene];
  }
}

- (void) myTeamBeginWalking {
  for (BattleSprite *bs in self.myTeamSprites) {
    [bs beginWalking];
  }
}

- (void) myTeamStopWalking {
  for (BattleSprite *bs in self.myTeamSprites) {
    [bs stopWalking];
  }
}

- (void) prepareNextEnemyTeam {
  _curQueueNum++;
  if (self.defendersList.count <= _curQueueNum) {
    if (!self.seenUserUuids) self.seenUserUuids = [NSMutableArray array];
    for (PvpProto *pvp in self.defendersList) {
      if (pvp.defender.minUserProto.hasUserUuid &&
          pvp.defender.minUserProto.userUuid.length > 0) {
        [self.seenUserUuids addObject:pvp.defender.minUserProto.userUuid];
      }
    }
    [self fireQueueUp];
    _numTimesAttemptedQueueUp = 0;
    self.defendersList = nil;
    
    _isRevenge = NO;
  } else {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableSet *skillSideEffects = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    
    
    PvpProto *enemy = self.defendersList[_curQueueNum];
    ResearchUtil *ru = [[ResearchUtil alloc] initWithResearches:enemy.userResearchList];
    int num = 0;
    for (PvpMonsterProto *mon in enemy.defenderMonstersList) {
      UserMonster *um = [UserMonster userMonsterWithMinProto:mon.defenderMonster researchUtil:ru];
      um.userUuid = [NSString stringWithFormat:@"%i",num++];
      BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
      [enemyTeam addObject:bp];
      
      if (bp.spritePrefix) {
        [set addObject:bp.spritePrefix];
      }
      [skillSideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:YES]];
    }
    
    [enemyTeam sortUsingComparator:^NSComparisonResult(BattlePlayer *obj1, BattlePlayer *obj2) {
      return [@(obj1.slotNum) compare:@(obj2.slotNum)];
    }];
    
    if (enemy.hasCmtd) {
      UserMonster *um = enemy.cmtd.donatedMonster;
      if (um) {
        BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
        bp.isClanMonster = YES;
        [enemyTeam addObject:bp];
        
        if (bp.spritePrefix) {
          [set addObject:bp.spritePrefix];
        }
        [skillSideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:YES]];
      }
    }
    
    for (BattlePlayer *bp in self.myTeam) {
      if (bp.spritePrefix) {
        [set addObject:bp.spritePrefix];
      }
      [skillSideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:NO]];
    }
    
    _waitingForDownload = YES;
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      self.enemyTeam = enemyTeam;
      [Globals downloadAllAssetsForSkillSideEffects:skillSideEffects completion:^{
        _waitingForDownload = NO;
      }];
    }];
  }
}

- (void) spawnNextEnemyTeam {
  int success = YES;
  if (!_isRevenge) {
    BOOL allowGems = [self.itemUsagesForQueue[@0] boolValue];
    [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:self.itemUsagesForQueue];
    success = [[OutgoingEventController sharedOutgoingEventController] viewNextPvpGuy:allowGems];
    self.itemUsagesForQueue = nil;
  }
  
  if (success) {
    NSMutableArray *mut = [NSMutableArray array];
    float longestDuration = TIME_TO_SCROLL_PER_SCENE;
    for (BattlePlayer *bp in self.enemyTeam) {
      
      NSInteger idx = [self.enemyTeam indexOfObject:bp];
      
      CGPoint finalPos = ccpAdd(ENEMY_PLAYER_LOCATION, ccp(-9, -11));
      
      if (!bp.isClanMonster) {
        if (idx == 1) {
          finalPos = ccpAdd(finalPos, ccp(46, 3));
        } else if (idx == 2) {
          finalPos = ccpAdd(finalPos, ccp(-7, 35));
        }
        
        if (_puzzleIsOnLeft) finalPos = ccpAdd(finalPos, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
        
        BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:bp.spritePrefix nameString:bp.attrName rarity:bp.rarity animationType:bp.animationType isMySprite:NO verticalOffset:bp.verticalOffset];
        bs.battleLayer = self;
        bs.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)bp.element];
        [self.bgdContainer addChild:bs z:-idx];
        bs.isFacingNear = YES;
        
        CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
        CGPoint newPos = ccpAdd(finalPos, ccp(2*Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, 2*Y_MOVEMENT_FOR_NEW_SCENE));
        
        bs.position = newPos;
        [bs beginWalking];
        CCActionSequence *seq = [CCActionSequence actions:
                                 [CCActionDelay actionWithDuration:0.12*idx],
                                 [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos],
                                 [CCActionCallFunc actionWithTarget:bs selector:@selector(stopWalking)], nil];
        [bs runAction:seq];
        
        longestDuration = seq.duration;
        
        bs.healthBar.percentage = ((float)bp.curHealth)/bp.maxHealth*100;
        bs.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
        
        [mut addObject:bs];
        
        if (idx == self.enemyTeam.count-1) {
          // Spawn the queue node
          [self runAction:
           [CCActionSequence actions:
            [CCActionDelay actionWithDuration:seq.duration-0.3f],
            [CCActionCallFunc actionWithTarget:self selector:@selector(displayQueueNode)], nil]];
        }
      } else {
        finalPos = ccpAdd(finalPos, ccpMult(POINT_OFFSET_PER_SCENE, 0.15));
        
        if (self.enemyTeam.count == 1) {
          // So that when it blows up it displays the enemy sprite from under
          finalPos = ENEMY_PLAYER_LOCATION;
        }
        
        [self runAction:
         [CCActionSequence actions:
          [CCActionDelay actionWithDuration:longestDuration],
          [CCActionCallBlock actionWithBlock:
           ^{
             [self spawnEnemyStatueWithElement:bp.element position:finalPos completionSelector:@selector(displayQueueNode)];
           }], nil]];
      }
    }
    self.enemyTeamSprites = mut;
  }
}

- (void) spawnEnemyStatueWithElement:(Element)element position:(CGPoint)position completionSelector:(SEL)selector {
  CCSprite *statue = [CCSprite spriteWithImageNamed:[Globals imageNameForElement:element suffix:@"statue.png"]];
  statue.anchorPoint = ccp(0.6, 0.25);
  
  CCSprite *shadow = [CCSprite spriteWithImageNamed:@"statueshadow.png"];
  shadow.position = ccp(-5, -1);
  
  CCNode *node = [CCNode node];
  [node addChild:shadow];
  [node addChild:statue];
  self.statueNode = node;
  
  // Do this so that blowing up the sprite doesn't do anything bad
  node.contentSize = CGSizeMake(0, statue.contentSize.height*0.5);
  
  [self.bgdContainer addChild:node];
  node.position = position;
  node.zOrder = -4;
  
  statue.position = ccp(0, self.bgdContainer.contentSize.height-position.y+20);
  [statue runAction:[CCActionSequence actions:
                     [CCActionEaseSineIn actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(0,0)]],
                     [CCActionCallBlock actionWithBlock:
                      ^{
                        [self shakeScreenWithIntensity:1.f];
                      }],
                     [CCActionDelay actionWithDuration:0.2f],
                     [CCActionCallFunc actionWithTarget:self selector:selector], nil]];
  
  [shadow runAction:[CCActionFadeIn actionWithDuration:0.3f]];
}

- (void) destroyEnemyStatueWithExplosion:(BOOL)explosion {
  if (explosion) {
    [self blowupBattleSprite:(BattleSprite *)self.statueNode withBlock:nil];
  } else {
    [self.statueNode runAction:[CCActionSequence actions:
                                [RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                                [CCActionRemove action], nil]];
  }
  self.statueNode = nil;
}

- (void) reachedNextScene {
  _numTimesNotResponded++;
  if (!self.defendersList) {
    if (_numTimesNotResponded < 5) {
      [self myTeamBeginWalking];
      [self.bgdLayer scrollToNewScene];
    } else {
      [self myTeamStopWalking];
      [GenericPopupController displayNotificationViewWithText:@"Sorry, we were unable to find any enemies for you at the moment. Try again later." title:@"No Enemies Found!" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
    }
  } else {
    if (!_hasChosenEnemy) {
      if (!_spawnedNewTeam) {
        [self myTeamBeginWalking];
        [self.bgdLayer scrollToNewScene];
        
        if (!self.enemyTeam && !_waitingForDownload) {
          [self prepareNextEnemyTeam];
        }
        if (self.enemyTeam) {
          // Spawn the new team
          [self spawnNextEnemyTeam];
          _spawnedNewTeam = YES;
        }
        
        if (_waitingForDownload && _numTimesNotResponded % 4 == 0) {
          [self.myPlayer initiateSpeechBubbleWithText:@"Hmm.. Enemies are calibrating."];
        }
        
      } else {
        [self myTeamStopWalking];
      }
    } else {
      [super reachedNextScene];
    }
  }
}

- (BattleSprite *) myPlayer {
  return [super myPlayer];
}

#pragma mark - Resource Items Filler

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self nextMatchWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.popoverViewController = nil;
  self.resourceItemsFiller = nil;
}

@end
