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
#import "GameViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Kamcord/Kamcord.h>
#import "CCBReader.h"

@implementation DungeonBattleLayer

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

- (void) receivedDungeonInfo:(BeginDungeonResponseProto *)di {
  self.dungeonInfo = di;
  _numStages = di.tspList.count;
}

- (void) beginMyTurn {
  [super beginMyTurn];
  [self displaySwapButton];
  self.forfeitButton.hidden = NO;
}

- (int) getCurrentEnemyLoot {
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  TaskStageMonsterProto *monster = [stage stageMonstersAtIndex:0];
  
  return monster.puzzlePieceDropped ? monster.monsterId : 0;
}

- (void) moveBegan {
  [super moveBegan];
  [self removeSwapButton];
}

- (void) myTurnEnded {
  [super myTurnEnded];
  self.forfeitButton.hidden = YES;
}

- (void) youWon {
  [self endBattle:YES];
}

- (void) youLost {
  [self endBattle:NO];
}

- (void) endBattle:(BOOL)won {
  _wonBattle = won;
  
  [self removeOrbLayerAnimated:YES withBlock:^{
     if (won) {
       [CCBReader load:@"BattleWonView" owner:self];
       [self.wonView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo]];
       self.wonView.anchorPoint = ccp(0.5, 0.5);
       self.wonView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
       [self addChild:self.wonView z:10000];
       [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:won delegate:self];
       
       [self makeGoCarrotCalls];
     } else {
       [self addChild:[CCBReader load:@"BattleLostView" owner:self] z:10000];
       self.lostView.anchorPoint = ccp(0.5, 0.5);
       self.lostView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
     }
   }];
}

- (void) makeGoCarrotCalls {
  [FBSession openActiveSessionWithPublishPermissions:nil defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:nil];
  
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
    [self exitFinal];
  }
}

#pragma mark - Continue View Actions

- (IBAction)forfeitClicked:(id)sender {
  [GenericPopupController displayNegativeConfirmationWithDescription:@"You will lose everything - are you sure you want to forfeit?"
                                                               title:@"Forfeit Battle"
                                                          okayButton:@"Forfeit"
                                                        cancelButton:@"Cancel"
                                                            okTarget:self
                                                          okSelector:@selector(forfeitConfirmed)
                                                        cancelTarget:nil
                                                      cancelSelector:nil];
}

- (void) forfeitConfirmed {
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:NO delegate:nil];
  [self exitFinal];
}

- (IBAction)winExitClicked:(id)sender {
  if (!_wonBattle) {
    [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:_wonBattle delegate:nil];
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
  [self winExitClicked:sender];
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
    [[OutgoingEventController sharedOutgoingEventController] reviveInDungeon:self.dungeonInfo.userTaskId myTeam:self.myTeam];
    [self.lostView removeFromParent];
    [self displayDeployViewAndIsCancellable:NO];
    [self displayOrbLayer];
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
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) begin {
  [self displayOrbLayer];
  [self loadDeployView];
  
  // This will spawn the deploy view assuming someone is alive
  [self currentMyPlayerDied];
  
  [Kamcord startRecording];
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
      if (_numTimesNotResponded < 10) {
        [self.myPlayer beginWalking];
        [self.bgdLayer scrollToNewScene];
      } else {
        [self.myPlayer stopWalking];
        [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Tap okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
      }
    } else {
      [self moveToNextEnemy];
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
