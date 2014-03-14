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
#import <Kamcord/Kamcord.h>
#import "CCBReader.h"
#import "FacebookDelegate.h"

@implementation DungeonBattleLayer

- (int) getCurrentEnemyLoot {
  TaskStageProto *stage = [self.dungeonInfo.tspList objectAtIndex:_curStage];
  TaskStageMonsterProto *monster = [stage stageMonstersAtIndex:0];
  
  return monster.puzzlePieceDropped ? monster.monsterId : 0;
}

- (void) youWon {
  [super youWon];
  [self.wonView updateForRewards:[Reward createRewardsForDungeon:self.dungeonInfo]];
  [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:YES delegate:self];
  [self makeGoCarrotCalls];
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
      [self checkQuests];
    }
  }
  
  if (_waitingForEndDungeonResponse) {
    [self exitFinal];
  }
}

- (void) checkQuests {
  if (!_checkedQuests) {
    _checkedQuests = YES;
    [QuestUtil checkQuestsForDungeon:self.dungeonInfo];
  }
}

#pragma mark - Waiting for response

- (IBAction)winExitClicked:(id)sender {
  if (_waitingForEndDungeonResponse) {
    return;
  }
  
  if (!_wonBattle) {
    [[OutgoingEventController sharedOutgoingEventController] endDungeon:self.dungeonInfo userWon:_wonBattle delegate:self];
    [self exitFinal];
  } else if (!_receivedEndDungeonResponse) {
    _waitingForEndDungeonResponse = YES;
  } else {
    [self exitFinal];
  }
}

- (IBAction)manageClicked:(id)sender {
  if (_waitingForEndDungeonResponse) {
    return;
  }
  
  _manageWasClicked = YES;
  [self winExitClicked:nil];
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
    
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      self.dungeonInfo = proto;
    }];
  } else {
    [self performSelector:@selector(exitFinal) withObject:nil afterDelay:2.f];
  }
}

- (void) begin {
  [super begin];
  
  [self displayOrbLayer];
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    if (!self.enemyTeam.count) {
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

@end
