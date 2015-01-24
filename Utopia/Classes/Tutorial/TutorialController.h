//
//  TutorialController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "DialogueViewController.h"
#import "TutorialBattleLayer.h"
#import "TutorialHomeMap.h"
#import "TutorialHomeViewController.h"
#import "TutorialHealViewController.h"
#import "TutorialTopBarViewController.h"
#import "TutorialShopViewController.h"
#import "TutorialBuildingViewController.h"
#import "TutorialFacebookViewController.h"
#import "TutorialNameViewController.h"
#import "TutorialAttackMapViewController.h"
#import "TutorialTouchView.h"

@class GameViewController;

@protocol TutorialControllerDelegate <NSObject>

- (void) reloadAccountWithStartupResponse:(StartupResponseProto *)startupResponse;
- (void) tutorialFinished;

@end

typedef enum {
  TutorialDialogueSpeakerGuide,
  TutorialDialogueSpeakerGuide2,
  TutorialDialogueSpeakerGuide3,
  TutorialDialogueSpeakerGuide4,
  TutorialDialogueSpeakerFriend,
  TutorialDialogueSpeakerFriend2,
  TutorialDialogueSpeakerFriend3,
  TutorialDialogueSpeakerMark,
  
  TutorialDialogueSpeakerEnemy,
  TutorialDialogueSpeakerEnemy2,
  TutorialDialogueSpeakerEnemyTwo,
  TutorialDialogueSpeakerEnemyTwo2,
  TutorialDialogueSpeakerEnemyTwo3,
  TutorialDialogueSpeakerEnemyTwo4,
  TutorialDialogueSpeakerEnemyBoss,
  TutorialDialogueSpeakerEnemyBoss2,
  TutorialDialogueSpeakerEnemyBoss3,
} TutorialDialogueSpeaker;

typedef enum {
  // 1
  TutorialStepGuideGreeting = 1,
  TutorialStepEnemyTeamDisembark,
  TutorialStepEnemyBossThreat,
  TutorialStepEnemyTwoThreat,
  TutorialStepGuideScared,
  TutorialStepFriendEnterFight,
  
  // 7
  TutorialStepEnteredBattle,
  TutorialStepBattleFriendTaunt,
  TutorialStepBattleEnemyTaunt,
  TutorialStepBattleEnemyDefense,
  TutorialStepBattleEnemyBossAngry,
  
  // 12
  TutorialStepFirstBattleFirstMove,
  TutorialStepFirstBattleSecondMove,
  TutorialStepFirstBattleLastMove,
  
  // 15
  TutorialStepSecondBattleEnemyBossTaunt,
  TutorialStepSecondBattleFirstMove,
  TutorialStepSecondBattleSecondMove,
  TutorialStepSecondBattleThirdMove,
  TutorialStepSecondBattleSwap,
  TutorialStepSecondBattleKillEnemy,
  
  // 21
  TutorialStepPostBattleConfrontation,
  
  TutorialStepEnterHospital,
  
  // 23
  TutorialStepBeginHealQueue,
  TutorialStepSpeedupHealQueue,
  TutorialStepExitHospital,
  
  // 26
  TutorialStepBeginBuildingOne,
  TutorialStepSpeedupBuildingOne,
  
  TutorialStepBeginBuildingTwo,
  TutorialStepSpeedupBuildingTwo,
  
  // 30
  TutorialStepBeginBuildingThree,
  TutorialStepSpeedupBuildingThree,

  TutorialStepFacebookLogin,
  TutorialStepEnterName,
  
  // 34
  TutorialStepAttackMap,
  TutorialStepAttackMapOpened,
  
  TutorialStepComplete,
} TutorialStep;

@interface TutorialController : NSObject <DialogueViewControllerDelegate, TutorialBattleLayerDelegate, TutorialHomeMapDelegate, TutorialHealDelegate, TutorialTopBarDelegate, BuildingViewDelegate, TutorialFacebookDelegate, TutorialNameDelegate, AttackMapDelegate> {
  int _damageDealtToFriend;
  float _hospitalHealSpeed;
  
  NSString *_name;
  NSString *_facebookId;
  NSString *_email;
  NSDictionary *_otherFbInfo;
  NSMutableDictionary *_structs;
  
  int _cash;
  int _oil;
  int _gems;
  
  BOOL _sendingUserCreateStartup;
  BOOL _waitingOnUserCreate;
  int _taskIdToEnter;
  BOOL _waitingOnFacebook;
}

@property (nonatomic, assign) TutorialStep currentStep;

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) TutorialBattleOneLayer *battleLayer;
@property (nonatomic, retain) TutorialHomeMap *homeMap;

@property (nonatomic, retain) TutorialHomeViewController *homeViewController;
@property (nonatomic, retain) TutorialHealViewController *healViewController;

@property (nonatomic, retain) TutorialBuildingViewController *buildingViewController;

@property (nonatomic, retain) TutorialTopBarViewController *topBarViewController;

@property (nonatomic, retain) TutorialFacebookViewController *facebookViewController;
@property (nonatomic, retain) TutorialNameViewController *nameViewController;
@property (nonatomic, retain) TutorialAttackMapViewController *attackMapViewController;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, retain) StartupResponseProto *facebookStartupResponse;

@property (nonatomic, retain) StartupResponseProto *userCreateStartupResponse;

@property (nonatomic, retain) TutorialTouchView *touchView;

@property (nonatomic, retain) UIButton *closeButton;

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc;
- (void) beginTutorial;

@end
