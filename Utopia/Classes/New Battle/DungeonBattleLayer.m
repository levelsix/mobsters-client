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

- (void) orbKilled:(GemColorId)color {
  [super orbKilled:color];
  [self removeSwapButton];
}

- (void) youWon {
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:YES delegate:self];
  [self.endView displayWithDungeon:self.dungeonInfo];
  _wonBattle = YES;
}

- (void) youLost {
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:NO delegate:self];
  [self.continueView display];
  _wonBattle = NO;
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
    [self displayDeployView];
  }
}

- (void) displayDeployView {
  [self.deployView updateWithBattlePlayers:self.myTeam];
  
  self.deployView.hidden = NO;
  self.deployView.center = ccp(self.deployView.superview.frame.size.width/2, -self.deployView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.deployView.center = ccp(self.deployView.center.x, (self.deployView.superview.frame.size.height-self.orbLayer.contentSize.height)/2);
  }];
  
  [self.orbLayer disallowInput];
}

- (void) removeDeployView {
  [UIView animateWithDuration:0.3f animations:^{
    self.deployView.center = ccp(self.deployView.center.x, -self.deployView.frame.size.height/2);
  } completion:^(BOOL finished) {
    self.deployView.hidden = YES;
  }];
}

- (IBAction)deployCardClicked:(id)sender {
  [self removeDeployView];
  
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
  if (bp && bp.userMonsterId != self.myPlayerObject.userMonsterId) {
    self.myPlayerObject = bp;
    
    BOOL isSwap = self.myPlayer != nil;
    if (isSwap) {
      [self makeMyPlayerWalkOut];
    }
    [self createNextMyPlayerSprite];
    
    // If it is swap, enemy should attack
    // If it is game start, wait till battle response has arrived
    // Otherwise, it is coming back from player just dying
    SEL selector = isSwap ? @selector(beginEnemyTurn) : _curStage < 0 ? @selector(reachedNextScene) : @selector(beginMyTurn);
    [self makeMyPlayerWalkInFromEntranceWithSelector:selector];
  } else {
    [self displaySwapButton];
    [self.orbLayer allowInput];
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
    [self displayDeployView];
  } else {
    [self youLost];
  }
}

- (void) reachedNextScene {
  if (_curStage < 0) {
    if (!self.dungeonInfo) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
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
}

@end
