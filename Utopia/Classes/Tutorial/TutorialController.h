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
#import "TutorialHomeMap.h"
#import "TutorialMyCroniesViewController.h"
#import "TutorialTopBarViewController.h"
#import "TutorialCarpenterViewController.h"
#import "TutorialMainMenuController.h"
#import "TutorialFacebookViewController.h"
#import "TutorialNameViewController.h"

@class GameViewController;

typedef enum {
  TutorialDialogueSpeakerFriend,
  TutorialDialogueSpeakerFriendR,
  TutorialDialogueSpeakerMarkL,
  TutorialDialogueSpeakerMarkR,
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
  TutorialStepFriendJoke,
  
  TutorialStepEnteredSecondBattle,
  TutorialStepSecondBattleFirstMove,
  TutorialStepSecondBattleSecondMove,
  TutorialStepSecondBattleThirdMove,
  TutorialStepSecondBattleSwap,
  TutorialStepSecondBattleKillEnemy,
  
  TutorialStepPostSecondBattleConfrontation,
  TutorialStepBoardYacht,
  
  TutorialStepLandAtHome,
  TutorialStepEnterHospital,
  
  TutorialStepBeginHealQueue,
  TutorialStepSpeedupHealQueue,
  TutorialStepExitHospital,
  
  TutorialStepBeginBuildingOne,
  TutorialStepSpeedupBuildingOne,
  
  TutorialStepBeginBuildingTwo,
  TutorialStepSpeedupBuildingTwo,
  
  TutorialStepBeginBuildingThree,
  TutorialStepSpeedupBuildingThree,
  
  TutorialStepFacebookLogin,
  TutorialStepEnterName,
  TutorialStepClickQuests,
} TutorialStep;

@interface TutorialController : NSObject <TutorialMissionMapDelegate, DialogueViewControllerDelegate, TutorialBattleLayerDelegate, TutorialHomeMapDelegate, TutorialMyCroniesDelegate, TutorialTopBarDelegate, TutorialMainMenuDelegate, TutorialCarpenterDelegate, TutorialFacebookDelegate, TutorialNameDelegate> {
  TutorialStep _currentStep;
  
  int _damageDealtToFriend;
  float _hospitalHealSpeed;
}

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) TutorialMissionMap *missionMap;
@property (nonatomic, retain) TutorialBattleLayer *battleLayer;
@property (nonatomic, retain) TutorialHomeMap *homeMap;

@property (nonatomic, retain) TutorialMyCroniesViewController *myCroniesViewController;

@property (nonatomic, retain) TutorialTopBarViewController *topBarViewController;
@property (nonatomic, retain) TutorialMainMenuController *mainMenuController;
@property (nonatomic, retain) TutorialCarpenterViewController *carpenterViewController;

@property (nonatomic, retain) TutorialFacebookViewController *facebookViewController;
@property (nonatomic, retain) TutorialNameViewController *nameViewController;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, retain) StartupResponseProto *facebookStartupResponse;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc;
- (void) beginTutorial;

@end
