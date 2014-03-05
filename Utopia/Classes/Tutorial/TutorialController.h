//
//  TutorialController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "TutorialMissionMap.h"
#import "DialogueViewController.h"
#import "TutorialBattleLayer.h"

@class GameViewController;

typedef enum {
  TutorialDialogueSpeakerFriend,
  TutorialDialogueSpeakerMark,
  TutorialDialogueSpeakerEnemy,
  TutorialDialogueSpeakerEnemyBoss,
} TutorialDialogueSpeaker;

typedef enum {
  TutorialStepBlackedOutDialogue = 1,
  TutorialStepInitialChase,
  TutorialStepFirstDialogue,
  TutorialStepFirstEnemyTaunt,
  TutorialStepFriendEnterBuilding,
  
  TutorialStepEnteredFirstBattle,
  TutorialStepFirstBattleFirstMove,
  TutorialStepFirstBattleSecondMove,
  TutorialStepFirstBattleLastMove,
  
  TutorialStepPostFirstBattleConfrontation,
  TutorialStepEnemyRanOff,
  TutorialStepEnemyBroughtBackBoss,
  
  TutorialStepEnteredSecondBattle,
  TutorialStepSecondBattleFirstMove,
  TutorialStepSecondBattleSecondMove,
  TutorialStepSecondBattleThirdMove,
  TutorialStepSecondBattleSwap,
  TutorialStepSecondBattleKillEnemy,
  
  TutorialStepPostSecondBattleConfrontation,
  TutorialStepBoardYacht,
} TutorialStep;

@interface TutorialController : NSObject <TutorialMissionMapDelegate, DialogueViewControllerDelegate, TutorialBattleLayerDelegate> {
  TutorialStep _currentStep;
}

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) TutorialMissionMap *missionMap;
@property (nonatomic, retain) TutorialBattleLayer *battleLayer;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc;
- (void) beginTutorial;

@end
