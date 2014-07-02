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

@implementation PvpBattleLayer

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft pvpHistoryForRevenge:(PvpHistoryProto *)hist {
  if ((self = [super initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft])) {
    PvpProto_Builder *pvp = [PvpProto builder];
    MinimumUserProto *mup = [[[[[MinimumUserProto builder] setName:hist.attacker.name] setUserId:hist.attacker.userId] setClan:hist.attacker.clan] build];
    pvp.defender = [[[[MinimumUserProtoWithLevel builder] setLevel:hist.attacker.level] setMinUserProto:mup] build];
    pvp.prospectiveCashWinnings = hist.prospectiveCashWinnings;
    pvp.prospectiveOilWinnings = hist.prospectiveOilWinnings;
    pvp.pvpLeagueStats = hist.attackerAfter;
    [pvp addAllDefenderMonsters:hist.attackersMonstersList];
    
    self.defendersList = @[pvp.build];
    _curQueueNum = -1;
    
    _isRevenge = YES;
    _prevBattleStartTime = hist.battleEndTime;
  }
  return self;
}

- (void) moveBegan {
  [super moveBegan];
  _userAttacked = YES;
}

#pragma mark - Continue View Actions

- (void) youWon {
  [super youWon];
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [self.wonView updateForRewards:[Reward createRewardsForPvpProto:pvp]];
  [[OutgoingEventController sharedOutgoingEventController] endPvpBattleMessage:pvp userAttacked:_userAttacked userWon:YES delegate:self];
}

- (void) youLost {
  [super youLost];
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [self.wonView updateForRewards:[Reward createRewardsForPvpProto:pvp]];
  [[OutgoingEventController sharedOutgoingEventController] endPvpBattleMessage:pvp userAttacked:_userAttacked userWon:NO delegate:self];
}

- (IBAction)manageClicked:(id)sender {
  if (!_waitingForEndPvpResponse) {
    _manageWasClicked = YES;
    [self winExitClicked:nil];
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
                                                    okSelector:@selector(exitFinal)
                                                  cancelTarget:nil
                                                cancelSelector:nil];
  }
}

- (IBAction)winExitClicked:(id)sender {
  if (!_waitingForEndPvpResponse) {
    if (!_receivedEndPvpResponse) {
      _waitingForEndPvpResponse = YES;
      
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

- (void) handleEndPvpBattleResponseProto:(FullEvent *)fe {
  _receivedEndPvpResponse = YES;
  
  [self checkQuests];
  
  if (_waitingForEndPvpResponse) {
    [self exitFinal];
  }
}

- (void) checkQuests {
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [AchievementUtil checkAchievementsForPvpBattleWithOrbCounts:_orbCounts powerupCounts:_powerupCounts comboCount:_totalComboCount damageTaken:_totalDamageTaken pvpInfo:pvp wonBattle:_wonBattle];
}

#pragma mark - Queue Node Methods

- (void) loadQueueNode {
  [CCBReader load:@"BattleQueueNode" owner:self];
  [self addChild:self.queueNode z:10000];
  self.queueNode.position = ccp(self.contentSize.width, 0);
}

- (void) displayQueueNode {
  if (self.defendersList.count > _curQueueNum && _curQueueNum >= 0) {
    if (!self.queueNode) {
      [self loadQueueNode];
    }
    
    PvpProto *pvp = self.defendersList[_curQueueNum];
    [self.queueNode updateForPvpProto:pvp];
    self.queueNode.position = ccp(self.contentSize.width-self.queueNode.contentSize.width,0);
    [self.queueNode fadeInAnimationForIsRevenge:_isRevenge];
    
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
  if (gs.silver < thp.pvpQueueCashCost) {
    [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeCash amount:thp.pvpQueueCashCost-gs.silver target:self selector:@selector(nextMatchUseGems)];
  } else {
    [self nextMatch:NO];
  }
}

- (void) nextMatchUseGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  int cost = thp.pvpQueueCashCost;
  int curAmount = gs.silver;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self nextMatch:YES];
  }
}

- (void) nextMatch:(BOOL)useGems {
  _useGemsForQueue = useGems;
  
  [self removeQueueNode];
  
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
  }
  
  _spawnedNewTeam = NO;
  self.enemyTeam = nil;
  self.enemyTeamSprites = nil;
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallFunc actionWithTarget:self selector:@selector(reachedNextScene)], nil]];
}

- (void) startMatchClicked {
  if (!self.queueNode.userInteractionEnabled) return;
  
  PvpProto *pvp = self.defendersList[_curQueueNum];
  [[OutgoingEventController sharedOutgoingEventController] beginPvpBattle:pvp isRevenge:_isRevenge previousBattleTime:_prevBattleStartTime];
  
  [self removeQueueNode];
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallFunc actionWithTarget:self selector:@selector(displayOrbLayer)], nil]];
  
  self.currentEnemy = self.enemyTeamSprites[0];
  self.enemyPlayerObject = self.enemyTeam[0];
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
  
  [self beginMyTurn];
  
  _hasChosenEnemy = YES;
  _curStage = 0;
  _hasStarted = YES;
}

#pragma mark - Waiting for server

- (void) handleQueueUpResponseProto:(FullEvent *)fe {
  QueueUpResponseProto *proto = (QueueUpResponseProto *)fe.event;
  
  if (proto.status == QueueUpResponseProto_QueueUpStatusSuccess && proto.defenderInfoListList.count > 0) {
    _curQueueNum = -1;
    self.defendersList = proto.defenderInfoListList;
  } else {
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) begin {
  [super begin];
  
  [self loadQueueNode];
  
  [self scheduleOnce:@selector(showForfeitButton) delay:2.f];
}

- (void) showForfeitButton {
  self.forfeitButton.hidden = NO;
}

- (void) prepareNextEnemyTeam {
  _curQueueNum++;
  if (self.defendersList.count <= _curQueueNum) {
    if (!self.seenUserIds) self.seenUserIds = [NSMutableArray array];
    for (PvpProto *pvp in self.defendersList) {
      [self.seenUserIds addObject:@(pvp.defender.minUserProto.userId)];
    }
    [[OutgoingEventController sharedOutgoingEventController] queueUpEvent:self.seenUserIds withDelegate:self];
    self.defendersList = nil;
    
    _isRevenge = NO;
    
    _numTimesNotResponded = 0;
  } else {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    
    PvpProto *enemy = self.defendersList[_curQueueNum];
    for (MinimumUserMonsterProto *mon in enemy.defenderMonstersList) {
      UserMonster *um = [UserMonster userMonsterWithMinProto:mon];
      BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
      [enemyTeam addObject:bp];
      
      [set addObject:bp.spritePrefix];
    }
    
    for (BattlePlayer *bp in self.myTeam) {
      [set addObject:bp.spritePrefix];
    }
    
    _waitingForDownload = YES;
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      self.enemyTeam = enemyTeam;
      _waitingForDownload = NO;
    }];
  }
}

- (void) spawnNextEnemyTeam {
  int success = YES;
  if (!_isRevenge) {
    success = [[OutgoingEventController sharedOutgoingEventController] viewNextPvpGuy:_useGemsForQueue];
    _useGemsForQueue = NO;
  }
  
  if (success) {
    NSMutableArray *mut = [NSMutableArray array];
    for (BattlePlayer *bp in self.enemyTeam) {
      NSInteger idx = [self.enemyTeam indexOfObject:bp];
      BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:bp.spritePrefix nameString:bp.name rarity:bp.rarity animationType:bp.animationType isMySprite:NO verticalOffset:bp.verticalOffset];
      bs.healthBar.color = [self.orbLayer colorForSparkle:(GemColorId)bp.element];
      [self.bgdContainer addChild:bs z:-idx];
      bs.isFacingNear = YES;
      
      CGPoint finalPos = ccpAdd(ENEMY_PLAYER_LOCATION, ccp(-9, -11));
      
      if (idx == 1) {
        finalPos = ccpAdd(finalPos, ccp(46, 3));
      } else if (idx == 2) {
        finalPos = ccpAdd(finalPos, ccp(-7, 35));
      }
      
      if (_puzzleIsOnLeft) finalPos = ccpAdd(finalPos, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
      CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
      CGPoint newPos = ccpAdd(finalPos, ccp(2*Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, 2*Y_MOVEMENT_FOR_NEW_SCENE));
      
      bs.position = newPos;
      [bs beginWalking];
      CCActionSequence *seq = [CCActionSequence actions:
                               [CCActionDelay actionWithDuration:0.12*idx],
                               [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos],
                               [CCActionCallFunc actionWithTarget:bs selector:@selector(stopWalking)], nil];
      [bs runAction:seq];
      
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
    }
    self.enemyTeamSprites = mut;
  }
}

- (void) reachedNextScene {
  if (!self.defendersList) {
    _numTimesNotResponded++;
    if (_numTimesNotResponded < 5) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
    } else {
      [self.myPlayer stopWalking];
      [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Tap okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
    }
  } else {
    if (!_hasChosenEnemy) {
      if (!_spawnedNewTeam) {
        [self.myPlayer beginWalking];
        [self.bgdLayer scrollToNewScene];
        
        if (!self.enemyTeam && !_waitingForDownload) {
          [self prepareNextEnemyTeam];
        }
        if (self.enemyTeam) {
          // Spawn the new team
          [self spawnNextEnemyTeam];
          _spawnedNewTeam = YES;
        }
      } else {
        [self.myPlayer stopWalking];
      }
    } else {
      [super reachedNextScene];
    }
  }
}

@end
