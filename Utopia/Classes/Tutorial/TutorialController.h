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
#import "TutorialAttackMapViewController.h"
#import "TutorialRainbowController.h"
#import "TutorialTouchView.h"
#import "TutorialQuestLogViewController.h"

@class GameViewController;

@protocol TutorialControllerDelegate <NSObject>

- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialFinished;

@end

typedef enum {
  TutorialDialogueSpeakerFriend1,
  TutorialDialogueSpeakerFriend2,
  TutorialDialogueSpeakerFriend3,
  TutorialDialogueSpeakerFriend4,
  TutorialDialogueSpeakerFriendR3,
  TutorialDialogueSpeakerFriendR4,
  TutorialDialogueSpeakerMarkL,
  TutorialDialogueSpeakerMarkR,
  TutorialDialogueSpeakerEnemy1,
  TutorialDialogueSpeakerEnemy2,
  TutorialDialogueSpeakerEnemy3,
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
  TutorialStepEnemyLookBack,
  
  TutorialStepEnteredSecondBattle,
  TutorialStepSecondBattleFirstMove,
  TutorialStepSecondBattleSecondMove,
  TutorialStepSecondBattleThirdMove,
  TutorialStepSecondBattleSwap,
  TutorialStepSecondBattleKillEnemy,
  
  TutorialStepPostSecondBattleConfrontation,
  TutorialStepBoardYacht,
  
  TutorialStepLandAtHome,
  TutorialStepMarkLookBack,
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
  
  TutorialStepAttackMap,
  TutorialStepEnterBattleThree,
  TutorialStepRainbowMiniTutorial,
  
  TutorialStepClickQuests,
  TutorialStepQuestList,
  TutorialStepFirstQuest,
  TutorialStepEnterBattleFour,
  TutorialStepDoublePowerupMiniTutorial,
  TutorialStepFirstQuestComplete,
  
  TutorialStepSecondQuest,
  TutorialStepEnterBattleFive,
  TutorialStepDropMiniTutorial,
  TutorialStepSecondQuestComplete,
} TutorialStep;

@interface TutorialController : NSObject <TutorialMissionMapDelegate, DialogueViewControllerDelegate, TutorialBattleLayerDelegate, TutorialHomeMapDelegate, TutorialMyCroniesDelegate, TutorialTopBarDelegate, TutorialMainMenuDelegate, TutorialCarpenterDelegate, TutorialFacebookDelegate, TutorialNameDelegate, AttackMapDelegate, MiniTutorialDelegate, TutorialQuestLogDelegate> {
  TutorialStep _currentStep;
  
  int _damageDealtToFriend;
  float _hospitalHealSpeed;
  
  NSString *_name;
  NSString *_facebookId;
  NSMutableDictionary *_structs;
  
  int _cash;
  int _oil;
  int _gems;
  
  BOOL _sendingUserCreateStartup;
  BOOL _waitingOnUserCreate;
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
@property (nonatomic, retain) TutorialQuestLogViewController *questLogViewController;

@property (nonatomic, retain) TutorialFacebookViewController *facebookViewController;
@property (nonatomic, retain) TutorialNameViewController *nameViewController;
@property (nonatomic, retain) TutorialAttackMapViewController *attackMapViewController;

@property (nonatomic, retain) MiniTutorialController *miniTutController;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, retain) StartupResponseProto *facebookStartupResponse;

@property (nonatomic, retain) StartupResponseProto *userCreateStartupResponse;

@property (nonatomic, retain) TutorialTouchView *touchView;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc;
- (void) beginTutorial;

@end
