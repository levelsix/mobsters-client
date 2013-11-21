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
#import <Carrot/Carrot.h>
#import "GenericPopupController.h"

@implementation DungeonBattleLayer

- (void) loadDeployView {
  [[NSBundle mainBundle] loadNibNamed:@"BattleDeployView" owner:self options:nil];
  [Globals displayUIView:self.swapView];
  [Globals displayUIView:self.deployView];
  self.swapView.hidden = YES;
  self.deployView.hidden = YES;
}

- (void) receivedDungeonInfo:(BeginDungeonResponseProto *)di {
  self.dungeonInfo = di;
  _numStages = di.tspList.count;
}

- (BattleContinueView *) continueView {
  if (!_continueView) {
    [[NSBundle mainBundle] loadNibNamed:@"BattleContinueView" owner:self options:nil];
  }
  return _continueView;
}

- (BattleEndView *) endView {
  if (!_endView) {
    [[NSBundle mainBundle] loadNibNamed:@"BattleEndView" owner:self options:nil];
  }
  return _endView;
}

- (void) beginMyTurn {
  [super beginMyTurn];
  [self displaySwapButton];
}

- (int) getCurrentEnemyLoot {
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  TaskStageMonsterProto *monster = [stage stageMonstersAtIndex:0];
  
  return monster.puzzlePieceDropped ? monster.monsterId : 0;
}

- (void) turnBegan {
  [super turnBegan];
  [self removeSwapButton];
}

- (void) youWon {
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:YES delegate:self];
  [self.endView displayWithDungeon:self.dungeonInfo];
  _wonBattle = YES;
  
  [self makeGoCarrotCalls];
}

- (void) youLost {
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:NO delegate:self];
  [self.continueView display];
  _wonBattle = NO;
}

- (void) makeGoCarrotCalls {
  GameState *gs = [GameState sharedGameState];
  for (TaskStageProto *tsp in self.dungeonInfo.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      if (tsm.puzzlePieceDropped) {
        MonsterProto *mp = [gs monsterWithId:tsm.monsterId];
        [[Carrot sharedInstance] postAction:@"recruit" forObjectInstance:mp.carrotRecruited];
      }
    }
  }
}

- (void) handleEndDungeonResponseProto:(FullEvent *)fe {
  _receivedEndDungeonResponse = YES;
  if (_wonBattle) {
    EndDungeonResponseProto *proto = (EndDungeonResponseProto *)fe.event;
    if (proto.status == EndDungeonResponseProto_EndDungeonStatusSuccess) {
      [QuestUtil checkQuestsForDungeon:self.dungeonInfo];
    }
  }
  
  if (_waitingForEndDungeonResponse) {
    [self winExitFinal];
  }
}

#pragma mark - Continue View Actions

- (IBAction)loseExitClicked:(id)sender {
  [Globals popOutView:self.continueView.mainView fadeOutBgdView:self.continueView.bgdView completion:^{
    [self.continueView removeFromSuperview];
  }];
  
  [self.delegate battleComplete];
}

- (IBAction)winExitClicked:(id)sender {
  if (!_receivedEndDungeonResponse) {
    self.endView.spinner.hidden = NO;
    self.endView.doneLabel.hidden = YES;
    self.endView.userInteractionEnabled = NO;
    _waitingForEndDungeonResponse = YES;
  } else {
    [self winExitFinal];
  }
}

- (void) winExitFinal {
  [Globals popOutView:self.endView.mainView fadeOutBgdView:self.endView.bgdView completion:^{
    [self.endView removeFromSuperview];
  }];
  
  [self.delegate battleComplete];
}

//- (IBAction)refillClicked:(id)sender {
//  [Globals popOutView:self.continueView.mainView fadeOutBgdView:self.continueView.bgdView completion:^{
//    [self.continueView removeFromSuperview];
//  }];
//  
//  [self dealDamageWithPercent:-1000000 enemyIsAttacker:YES withSelector:@selector(beginMyTurn)];
//  [self.bloodSplatter stopAllActions];
//  self.bloodSplatter.opacity = 0;
//  [self.leftHealthLabel stopActionByTag:RED_TINT_TAG];
//  self.leftHealthLabel.color = ccc3(255, 255, 255);
//}

#pragma BattleDeployView methods

- (void) displaySwapButton {
  self.swapView.hidden = NO;
  self.swapView.center = ccp(self.swapView.superview.frame.size.width/2, -self.swapView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.swapView.center = ccp(self.swapView.center.x, self.swapView.frame.size.height/2);
  }];
}

- (void) removeSwapButton {
  [UIView animateWithDuration:0.3f animations:^{
    self.swapView.center = ccp(self.swapView.center.x, -self.swapView.frame.size.height/2);
  } completion:^(BOOL finished) {
    self.swapView.hidden = YES;
  }];
}

- (IBAction)swapClicked:(id)sender {
  if (_orbCount == 0) {
    [self removeSwapButton];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self displayNoInputLayer];
  
  [self.deployView updateWithBattlePlayers:self.myTeam];
  
  self.deployView.hidden = NO;
  self.deployView.center = ccp(self.deployView.superview.frame.size.width/2, -self.deployView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.deployView.center = ccp(self.deployView.center.x, (self.deployView.superview.frame.size.height-self.orbLayer.contentSize.height)/2);
  } completion:^(BOOL finished) {
    if (finished && cancel) {
      self.deployButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
      [Globals displayUIView:self.deployButton];
      [self.deployButton addTarget:self action:@selector(cancelDeploy:) forControlEvents:UIControlEventTouchUpInside];
      [self.deployView.superview bringSubviewToFront:self.deployView];
    }
  }];
  
  [self.orbLayer disallowInput];
}

- (void) removeDeployView {
  [self.deployButton removeFromSuperview];
  self.deployButton = nil;
  [UIView animateWithDuration:0.3f animations:^{
    self.deployView.center = ccp(self.deployView.center.x, -self.deployView.frame.size.height/2);
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
    if (b.slotNum == card.tag) {
      bp = b;
    }
  }
  
  [self deployBattleSprite:bp];
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  [self removeDeployView];
  BOOL isSwap = self.myPlayer != nil;
  if (bp && ![bp.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
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
    
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      [self receivedDungeonInfo:proto];
    }];
  } else {
    [self performSelector:@selector(winExitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) begin {
  [self loadDeployView];
  
  // This will spawn the deploy view assuming someone is alive
  [self currentMyPlayerDied];
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

- (void) reachedNextScene {
  if (_curStage < 0) {
    if (!self.dungeonInfo) {
      _numTimesNotResponded++;
      if (_numTimesNotResponded < 5) {
        [self.myPlayer beginWalking];
        [self.bgdLayer scrollToNewScene];
      } else {
        [self.myPlayer stopWalking];
        [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Click okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(winExitFinal)];
      }
    } else {
      [self moveToNextEnemy];
    }
  } else {
    [super reachedNextScene];
  }
}

- (void) dealloc {
  [self.swapView removeFromSuperview];
  [self.deployView removeFromSuperview];
  [self.deployButton removeFromSuperview];
}

@end
