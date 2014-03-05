//
//  TutorialController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialController.h"
#import "TutorialMissionMap.h"
#import "GameViewController.h"
#import "GameState.h"

@implementation TutorialController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc {
  if ((self = [super init])) {
    self.constants = constants;
    self.gameViewController = gvc;
  }
  return self;
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch {
  GameState *gs = [GameState sharedGameState];
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    TutorialDialogueSpeaker speaker = [dialogue[i] intValue];
    NSString *speakerText = dialogue[i+1];
    
    int monsterId = 0, isLeftSide = NO;
    switch (speaker) {
      case TutorialDialogueSpeakerEnemy:
        monsterId = self.constants.enemyMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyBoss:
        monsterId = self.constants.enemyBossMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerFriend:
        monsterId = self.constants.startingMonsterId;
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerMark:
        monsterId = self.constants.markZmonsterId;
        isLeftSide = YES;
        break;
      default:
        break;
    }
    
    MonsterProto *mp = [gs monsterWithId:monsterId];
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = mp.imagePrefix;
    ss.isLeftSide = isLeftSide;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build];
  dvc.view.userInteractionEnabled = allowTouch;
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view addSubview:dvc.view];
  self.dialogueViewController = dvc;
}

- (void) beginTutorial {
  [self.gameViewController.topBarViewController.view.subviews[0] setHidden:YES];
  [self.gameViewController.topBarViewController.chatViewController.view setHidden:YES];
  
  [self initMissionMap];
  [self beginBlackedOutDialogue];
  //[self beginPostSecondBattleConfrontationPhase];
}

- (void) initMissionMap {
  CCScene *scene = [CCScene node];
  TutorialMissionMap *missionMap = [[TutorialMissionMap alloc] initWithTutorialConstants:self.constants];
  missionMap.delegate = self;
  [scene addChild:missionMap];
  [[CCDirector sharedDirector] replaceScene:scene];
  self.missionMap = missionMap;
  self.gameViewController.currentMap = missionMap;
}

#pragma mark - Tutorial Sequence

- (void) beginBlackedOutDialogue {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Help! Somebody stole my meatballs!"];
  [self displayDialogue:dialogue allowTouch:YES];
  self.dialogueViewController.blackOutSpeakers = YES;
  
  _currentStep = TutorialStepBlackedOutDialogue;
}

- (void) beginInitialChasePhase {
  [self.missionMap beginInitialChase];
  
  _currentStep = TutorialStepInitialChase;
}

- (void) beginFirstDialoguePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Somebody stop that guy. He stole my meatballs!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepFirstDialogue;
}

- (void) beginFirstEnemyTauntPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy), @"You'll never catch me!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepFirstEnemyTaunt;
}

- (void) beginFriendEnterBuildingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Where'd that scumbag go?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepFriendEnterBuilding;
}

- (void) beginFirstBattlePhase {
  self.battleLayer = [[TutorialBattleOneLayer alloc] initWithConstants:self.constants];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  _currentStep = TutorialStepEnteredFirstBattle;
}

- (void) beginFirstBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"I gain my power from making orb combinations! Match some now."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepFirstBattleFirstMove;
}

- (void) beginFirstBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Good job! Let's try another one."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepFirstBattleSecondMove;
}

- (void) beginFirstBattleFinalMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Alright! Make the last move on your own."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepFirstBattleLastMove;
}

- (void) beginPostFirstBattleConfrontationPhase {
  [self.missionMap beginSecondConfrontation];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy), @"Do you know who you’re messing with? Just wait till I call in back up!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepPostFirstBattleConfrontation;
}

- (void) beginEnemyRanOffPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Thanks for helping me back there. Hopefully we’re done with..."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnemyRanOff;
}

- (void) beginEnemyBroughtBackBossPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You weak. Me Strong. You die now.",
                        @(TutorialDialogueSpeakerFriend), @"Uh oh, let's hide in that candy shop down there!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnemyBroughtBackBoss;
}

- (void) beginSecondBattlePhase {
  self.battleLayer = [[TutorialBattleTwoLayer alloc] initWithConstants:self.constants];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  _currentStep = TutorialStepEnteredSecondBattle;
}

- (void) beginSecondBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Let's make some powerups and show this guy what we got!"];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleFirstMove;
}

- (void) beginSecondBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Great! Let's unleash the powerup now."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleSecondMove;
}

- (void) beginSecondBattleThirdMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Finish him off!"];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleThirdMove;
}

- (void) beginSecondBattleSwapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Oh man! I'm badly hurt..",
                        @(TutorialDialogueSpeakerMark), @"*Poke*",
                        @(TutorialDialogueSpeakerMark), @"Hey buddy, you don’t look so good. Would you “like” me to help you out?",
                        @(TutorialDialogueSpeakerFriend), @"Swap me out!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepSecondBattleSwap;
}

- (void) beginSecondBattleKillPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"This will be an easy fight!"];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleKillEnemy;
}

- (void) beginPostSecondBattleConfrontationPhase {
  [self.missionMap beginThirdConfrontation];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You win battle. Not war. We be back.",
                        @(TutorialDialogueSpeakerMark), @"Heh, we'll see."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepPostSecondBattleConfrontation;
}

- (void) beginBoardYachtPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"You’re hurt pretty badly. I have a private island to get you all healed up. Let’s take the BookFace yacht."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepBoardYacht;
}

#pragma mark - MissionMap delegate

- (void) initialChaseComplete {
  [self beginFirstDialoguePhase];
}

- (void) enemyJumped {
  [self beginFirstEnemyTauntPhase];
}

- (void) enemyRanIntoFirstBuilding {
  [self beginFriendEnterBuildingPhase];
}

- (void) friendEnteredFirstBuilding {
  [self beginFirstBattlePhase];
}

- (void) enemyRanOffMap {
  [self beginEnemyRanOffPhase];
}

- (void) enemyArrivedWithBoss {
  [self beginEnemyBroughtBackBossPhase];
}

- (void) everyoneEnteredSecondBuilding {
  [self beginSecondBattlePhase];
}

- (void) enemyBossRanOffMap {
  [self beginBoardYachtPhase];
}

- (void) yachtWentOffScene {
  NSLog(@"Reached here");
}

#pragma mark - BattleLayer delegate

- (void) moveMade {
  // Dismiss the dialogue
  [self.dialogueViewController animateNext];
}

- (void) battleLayerReachedEnemy {
  if (_currentStep == TutorialStepEnteredFirstBattle) {
    [self beginFirstBattleFirstMovePhase];
  } else if (_currentStep == TutorialStepEnteredSecondBattle) {
    [self beginSecondBattleFirstMovePhase];
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialStepFirstBattleFirstMove) {
    [self beginFirstBattleSecondMovePhase];
  } else if (_currentStep == TutorialStepFirstBattleSecondMove) {
    [self beginFirstBattleFinalMovePhase];
  } else if (_currentStep == TutorialStepSecondBattleFirstMove) {
    [self beginSecondBattleSecondMovePhase];
  } else if (_currentStep == TutorialStepSecondBattleSecondMove) {
    [self beginSecondBattleThirdMovePhase];
  } else if (_currentStep == TutorialStepSecondBattleThirdMove) {
    [self beginSecondBattleSwapPhase];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialStepSecondBattleThirdMove) {
    [self beginSecondBattleSwapPhase];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) swappedToMark {
  if (_currentStep == TutorialStepSecondBattleSwap) {
    [self beginSecondBattleKillPhase];
  }
}

- (void) battleComplete:(NSDictionary *)params {
  if (_currentStep == TutorialStepFirstBattleLastMove) {
    [self beginPostFirstBattleConfrontationPhase];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy) {
    [self beginPostSecondBattleConfrontationPhase];
  }
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:0.6f]];
}

#pragma mark DialogueViewController

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialStepFirstBattleFirstMove || _currentStep == TutorialStepSecondBattleFirstMove) {
    [self.battleLayer beginFirstMove];
  } else if (_currentStep == TutorialStepFirstBattleSecondMove || _currentStep == TutorialStepSecondBattleSecondMove) {
    [self.battleLayer beginSecondMove];
  } else if (_currentStep == TutorialStepFirstBattleLastMove || _currentStep == TutorialStepSecondBattleThirdMove) {
    [self.battleLayer beginThirdMove];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  if (_currentStep == TutorialStepBlackedOutDialogue) {
    [self beginInitialChasePhase];
  } else if (_currentStep == TutorialStepFirstDialogue) {
    [self.missionMap enemyJump];
  } else if (_currentStep == TutorialStepFirstEnemyTaunt) {
    [self.missionMap enemyRunIntoFirstBuilding];
  } else if (_currentStep == TutorialStepFriendEnterBuilding) {
    [self.missionMap displayArrowOverFirstBuilding];
  } else if (_currentStep == TutorialStepPostFirstBattleConfrontation) {
    [self.missionMap runOutEnemy];
  } else if (_currentStep == TutorialStepEnemyRanOff) {
    [self.missionMap enemyComeInWithBoss];
  } else if (_currentStep == TutorialStepEnemyBroughtBackBoss) {
    [self.missionMap beginChaseIntoSecondBuilding];
  } else if (_currentStep == TutorialStepSecondBattleSwap) {
    TutorialBattleTwoLayer *two = (TutorialBattleTwoLayer *)self.battleLayer;
    [two swapToMark];
  } else if (_currentStep == TutorialStepPostSecondBattleConfrontation) {
    [self.missionMap runOutEnemyBoss];
  } else if (_currentStep == TutorialStepBoardYacht) {
    [self.missionMap moveToYacht];
  }
}

@end
