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

@implementation PvpBattleLayer

- (void) loadDeployView {
  GameViewController *gvc = [GameViewController baseController];
  UIView *view = gvc.view;
  
  [[NSBundle mainBundle] loadNibNamed:@"BattleDeployView" owner:self options:nil];
  [view addSubview:self.swapView];
  [view addSubview:self.deployView];
  [view addSubview:self.forfeitButton];
  self.swapView.hidden = YES;
  self.deployView.hidden = YES;
  self.forfeitButton.hidden = YES;
  
  self.forfeitButton.center = ccp(self.forfeitButton.frame.size.width/2+5, self.forfeitButton.frame.size.height/2+5);
  self.swapLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
}

- (void) beginMyTurn {
  [super beginMyTurn];
  [self displaySwapButton];
  self.forfeitButton.hidden = NO;
}

- (void) moveBegan {
  [super moveBegan];
  [self removeSwapButton];
}

- (void) myTurnEnded {
  [super myTurnEnded];
  self.forfeitButton.hidden = YES;
}

#pragma mark - Continue View Actions

- (void) youWon {
  [self endBattle:YES];
}

- (void) youLost {
  [self endBattle:NO];
}

- (void) endBattle:(BOOL)won {
  _receivedEndDungeonResponse = YES;
  _wonBattle = won;
  
  [self removeOrbLayerAnimated:YES withBlock:^{
    if (won) {
      [CCBReader load:@"BattleWonView" owner:self];
      PvpProto *pvp = self.queueInfo.defenderInfoListList[_curQueueNum];
      [self.wonView updateForRewards:[Reward createRewardsForPvpProto:pvp]];
      [self addChild:self.wonView z:10000];
      
      self.wonView.anchorPoint = ccp(0.5, 0.5);
      self.wonView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    } else {
      [self addChild:[CCBReader load:@"BattleLostView" owner:self] z:10000];
      self.lostView.anchorPoint = ccp(0.5, 0.5);
      self.lostView.continueButton.visible = NO;
      self.lostView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    }
  }];
}

- (IBAction)forfeitClicked:(id)sender {
  if (_hasChosenEnemy) {
    [GenericPopupController displayNegativeConfirmationWithDescription:@"You will lose everything - are you sure you want to forfeit?"
                                                                 title:@"Forfeit Battle"
                                                            okayButton:@"Forfeit"
                                                          cancelButton:@"Cancel"
                                                              okTarget:self
                                                            okSelector:@selector(forfeitConfirmed)
                                                          cancelTarget:nil
                                                        cancelSelector:nil];
  } else {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to leave?"
                                                         title:@"Leave?"
                                                    okayButton:@"Leave"
                                                  cancelButton:@"Cancel"
                                                      okTarget:self
                                                    okSelector:@selector(forfeitConfirmed)
                                                  cancelTarget:nil
                                                cancelSelector:nil];
  }
}

- (void) forfeitConfirmed {
  [self exitFinal];
}

- (IBAction)winExitClicked:(id)sender {
  if (!_wonBattle) {
    [self exitFinal];
  } else if (!_receivedEndDungeonResponse) {
    _waitingForEndDungeonResponse = YES;
    
    _manageWasClicked = NO;
  } else {
    [self exitFinal];
  }
}

- (IBAction)manageClicked:(id)sender {
  _manageWasClicked = YES;
  if (!_receivedEndDungeonResponse) {
    _waitingForEndDungeonResponse = YES;
  } else {
    [self exitFinal];
  }
}

- (void) exitFinal {
  self.swapView.hidden  = YES;
  self.forfeitButton.hidden = YES;
  
  [self.delegate battleComplete:[NSDictionary dictionaryWithObjectsAndKeys:@(_manageWasClicked), BATTLE_MANAGE_CLICKED_KEY, nil]];
  
  // in case it hasnt stopped yet
  [Kamcord stopRecording];
}

- (IBAction)shareClicked:(id)sender {
  [Kamcord stopRecording];
  [Kamcord showView];
}

- (IBAction)continueClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  NSString *desc = [NSString stringWithFormat:@"Would you like to heal your entire team for %d gems?", gemsAmount];
  [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Heal Team?" gemCost:gemsAmount target:self selector:@selector(continueConfirmed)];
}

- (void) continueConfirmed {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  
  if (gs.gold < gemsAmount) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self.lostView removeFromParent];
    [self displayDeployViewAndIsCancellable:NO];
    [self.orbBgdLayer runAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(self.contentSize.width-self.orbBgdLayer.contentSize.width/2-14, self.orbBgdLayer.position.y)]];
  }
}

#pragma BattleDeployView methods

#define ANIMATION_TIME 0.4f
#define SWAP_CENTER_Y 268
#define DEPLOY_CENTER_Y self.contentSize.height-16-self.deployView.frame.size.height/2

- (void) displaySwapButton {
  self.swapView.hidden = NO;
  self.swapView.center = ccp(-self.swapView.frame.size.width/2, SWAP_CENTER_Y);
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    self.swapView.center = ccp(self.swapView.frame.size.width/2, SWAP_CENTER_Y);
  }];
}

- (void) removeSwapButton {
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    self.swapView.center = ccp(-self.swapView.frame.size.width/2, SWAP_CENTER_Y);
  } completion:^(BOOL finished) {
    self.swapView.hidden = YES;
  }];
}

- (IBAction)swapClicked:(id)sender {
  if (_orbCount == 0 && !self.orbLayer.isTrackingTouch) {
    [self removeSwapButton];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self displayNoInputLayer];
  
  [self.deployView updateWithBattlePlayers:self.myTeam];
  
  self.deployView.hidden = NO;
  self.deployView.center = ccp(-self.deployView.frame.size.width/2, DEPLOY_CENTER_Y);
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    float extra = [Globals isLongiPhone] ? self.movesBgd.contentSize.width : 0;
    self.deployView.center = ccp((self.contentSize.width-self.orbBgdLayer.contentSize.width-extra-14)/2, DEPLOY_CENTER_Y);
  } completion:^(BOOL finished) {
    if (finished && cancel) {
      self.deployCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
      [Globals displayUIView:self.deployCancelButton];
      [self.deployCancelButton addTarget:self action:@selector(cancelDeploy:) forControlEvents:UIControlEventTouchUpInside];
      [self.deployView.superview bringSubviewToFront:self.deployView];
    }
  }];
  
  [self.orbLayer disallowInput];
}

- (void) removeDeployView {
  [self.deployCancelButton removeFromSuperview];
  self.deployCancelButton = nil;
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    self.deployView.center = ccp(-self.deployView.frame.size.width/2, DEPLOY_CENTER_Y);
  } completion:^(BOOL finished) {
    self.deployView.hidden = YES;
  }];
}

- (IBAction)cancelDeploy:(id)sender {
  [self deployBattleSprite:nil];
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
    [self deployBattleSprite:bp];
  }
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  [self removeDeployView];
  BOOL isSwap = self.myPlayer != nil;
  if (bp && bp.userMonsterId != self.myPlayerObject.userMonsterId) {
    self.myPlayerObject = bp;
    
    if (isSwap) {
      [self makeMyPlayerWalkOut];
    }
    [self createNextMyPlayerSprite];
    
    // If it is swap, enemy should attack
    // If it is game start, wait till battle response has arrived
    // Otherwise, it is coming back from player just dying
    SEL selector = isSwap ? @selector(beginMyTurn) : _curStage < 0 ? @selector(reachedNextScene) : @selector(beginMyTurn);
    [self makeMyPlayerWalkInFromEntranceWithSelector:selector];
  } else if (isSwap) {
    [self displaySwapButton];
    [self.orbLayer allowInput];
    [self removeNoInputLayer];
  }
}

#pragma mark - Queue Node Methods

- (void) loadQueueNode {
  [CCBReader load:@"BattleQueueNode" owner:self];
  [self addChild:self.queueNode z:10000];
  self.queueNode.position = ccp(self.contentSize.width, 0);
}

- (void) displayQueueNode {
  if (self.queueInfo.defenderInfoListList.count > _curQueueNum && _curQueueNum >= 0) {
    if (!self.queueNode) {
      [self loadQueueNode];
    }
    
    PvpProto *pvp = self.queueInfo.defenderInfoListList[_curQueueNum];
    [self.queueNode updateForPvpProto:pvp];
    self.queueNode.position = ccp(self.contentSize.width-self.queueNode.contentSize.width,0);
    [self.queueNode fadeInAnimation];
  }
}

- (void) removeQueueNode {
  [self.queueNode fadeOutAnimation];
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
  
  PvpProto *pvp = self.queueInfo.defenderInfoListList[_curQueueNum];
  [[OutgoingEventController sharedOutgoingEventController] beginPvpBattle:pvp];
  
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
  _numStages = self.enemyTeam.count;
}

#pragma mark - Waiting for server

- (void) handleQueueUpResponseProto:(FullEvent *)fe {
  QueueUpResponseProto *proto = (QueueUpResponseProto *)fe.event;
  
  if (proto.status == QueueUpResponseProto_QueueUpStatusSuccess && proto.defenderInfoListList.count > 0) {
    _curQueueNum = -1;
    self.queueInfo = proto;
  } else {
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) begin {
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    if (b.curHealth > 0) {
      bp = b;
    }
  }
  if (bp) {
    [self deployBattleSprite:bp];
  }
  
  [self loadQueueNode];
  [self loadDeployView];
  
  // This will spawn the deploy view assuming someone is alive
  [self currentMyPlayerDied];
  
  [Kamcord startRecording];
  
  self.forfeitButton.hidden = NO;
}

- (void) currentMyPlayerDied {
  BOOL someoneIsAlive = NO;
  for (BattlePlayer *bp in self.myTeam) {
    if (bp.curHealth > 0) {
      someoneIsAlive = YES;
    }
  }
  
  if (someoneIsAlive) {
    [self displayDeployViewAndIsCancellable:NO];
  } else {
    [self youLost];
  }
}

- (void) prepareNextEnemyTeam {
  _curQueueNum++;
  if (self.queueInfo.defenderInfoListList.count <= _curQueueNum) {
    if (!self.seenUserIds) self.seenUserIds = [NSMutableArray array];
    for (PvpProto *pvp in self.queueInfo.defenderInfoListList) {
      [self.seenUserIds addObject:@(pvp.defender.minUserProto.userId)];
    }
    [[OutgoingEventController sharedOutgoingEventController] queueUpEvent:self.seenUserIds withDelegate:self];
    self.queueInfo = nil;
    
    _numTimesNotResponded = 0;
  } else {
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    
    PvpProto *enemy = self.queueInfo.defenderInfoListList[_curQueueNum];
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
  int success = [[OutgoingEventController sharedOutgoingEventController] viewNextPvpGuy:_useGemsForQueue];
  _useGemsForQueue = NO;
  
  if (success) {
    NSMutableArray *mut = [NSMutableArray array];
    for (BattlePlayer *bp in self.enemyTeam) {
      int idx = [self.enemyTeam indexOfObject:bp];
      BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:bp.spritePrefix nameString:bp.name isMySprite:NO];
      bs.healthBar.color = [self.orbLayer colorForSparkle:bp.element];
      [self.bgdContainer addChild:bs z:-idx];
      bs.isFacingNear = YES;
      
      CGPoint finalPos = ENEMY_PLAYER_LOCATION;
      
      if (idx == 1) {
        finalPos = ccpAdd(finalPos, ccp(53, 6));
      } else if (idx == 2) {
        finalPos = ccpAdd(finalPos, ccp(-7, 40));
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
  if (_curStage < 0) {
    if (!self.queueInfo) {
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
          
          if (self.enemyTeam) {
            // Spawn the new team
            [self spawnNextEnemyTeam];
            _spawnedNewTeam = YES;
          } else if (!_waitingForDownload) {
            [self prepareNextEnemyTeam];
          }
        } else {
          [self.myPlayer stopWalking];
        }
      } else {
        [self moveToNextEnemy];
      }
    }
  } else {
    [super reachedNextScene];
  }
}

- (void) dealloc {
  [self.forfeitButton removeFromSuperview];
  [self.swapView removeFromSuperview];
  [self.deployView removeFromSuperview];
  [self.deployCancelButton removeFromSuperview];
}

@end
