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
#import "MenuNavigationController.h"
#import "FacebookSpammer.h"
#import "GameCenterDelegate.h"
#import "FacebookDelegate.h"

@implementation TutorialController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc {
  if ((self = [super init])) {
    self.constants = constants;
    self.gameViewController = gvc;
    
    _damageDealtToFriend = 137;
    
    GameState *gs = [GameState sharedGameState];
    gs.silver = constants.cashInit;
    gs.oil = constants.oilInit;
    gs.gold = constants.gemsInit;
  }
  return self;
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch toViewController:(UIViewController *)vc {
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
      case TutorialDialogueSpeakerFriendR:
        monsterId = self.constants.startingMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerMarkL:
        monsterId = self.constants.markZmonsterId;
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerMarkR:
        monsterId = self.constants.markZmonsterId;
        isLeftSide = NO;
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
  [vc addChildViewController:dvc];
  [vc.view addSubview:dvc.view];
  self.dialogueViewController = dvc;
  
  if (!allowTouch) {
    [dvc.bottomGradient removeFromSuperview];
  }
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch {
  [self displayDialogue:dialogue allowTouch:allowTouch toViewController:self.gameViewController];
}

- (void) beginTutorial {
  [self.gameViewController.topBarViewController.mainView setHidden:YES];
  [self.gameViewController.topBarViewController.chatViewController.view setHidden:YES];
  
  [self initMissionMap];
  [self beginBlackedOutDialogue];
  //[self beginSecondBattlePhase];
  
  //[self yachtWentOffScene];
  
  //[self initHomeMap];
  //[self initTopBar];
  //[self beginBuildingThreePhase];
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

- (void) initHomeMap {
  CCScene *scene = [CCScene node];
  TutorialHomeMap *homeMap = [[TutorialHomeMap alloc] initWithTutorialConstants:self.constants];
  homeMap.delegate = self;
  [scene addChild:homeMap];
  [homeMap refresh];
  self.homeMap = homeMap;
  self.gameViewController.currentMap = homeMap;
  
  HospitalProto *hp = (HospitalProto *)homeMap.hospital.userStruct.staticStruct;
  _hospitalHealSpeed = hp.healthPerSecond;
  
  CCDirector *dir = [CCDirector sharedDirector];
  if (!dir.runningScene) {
    [dir replaceScene:scene];
  } else {
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.4f]];
  }
}

- (void) initTopBar {
  self.topBarViewController = [[TutorialTopBarViewController alloc] init];
  self.topBarViewController.delegate = self;
  [self.gameViewController addChildViewController:self.topBarViewController];
  [self.gameViewController.view addSubview:self.topBarViewController.view];
  [self.topBarViewController displayMenuButton];
  [self.topBarViewController displayCoinBars];
}

- (void) initMainMenuController {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [self.gameViewController presentViewController:m animated:YES completion:nil];
  self.mainMenuController = [[TutorialMainMenuController alloc] init];
  self.mainMenuController.delegate = self;
  [m pushViewController:self.mainMenuController animated:YES];
}

- (void) initCarpenterController:(int)structId {
  self.carpenterViewController = [[TutorialCarpenterViewController alloc] initWithTutorialConstants:self.constants curStructs:self.homeMap.myStructs];
  self.carpenterViewController.delegate = self;
  [self.carpenterViewController allowPurchaseOfStructId:structId];
  [self.mainMenuController.navigationController pushViewController:self.carpenterViewController animated:YES];
}

- (void) initFacebookViewController {
  self.facebookViewController = [[TutorialFacebookViewController alloc] init];
  self.facebookViewController.delegate = self;
  [self.gameViewController addChildViewController:self.facebookViewController];
  [self.gameViewController.view addSubview:self.facebookViewController.view];
}

- (void) initNameViewController {
  NSString *gcName = [GameCenterDelegate gameCenterName];
  if (gcName) {
    [self initNameViewController:gcName];
  } else {
    [FacebookDelegate getFacebookUsernameAndDoAction:^(NSString *facebookId) {
      if (facebookId) {
        [self initNameViewController:facebookId];
      } else {
        [self initNameViewController:nil];
      }
    }];
  }
}

- (void) initNameViewController:(NSString *)name {
  self.nameViewController = [[TutorialNameViewController alloc] initWithName:name];
  self.nameViewController.delegate = self;
  [self.gameViewController addChildViewController:self.nameViewController];
  [self.gameViewController.view addSubview:self.nameViewController.view];
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
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Did you see where that scumbag went?"];
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
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"This is Candy Crush on steroids. Match 3 orbs by swiping this one to the right."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepFirstBattleFirstMove;
}

- (void) beginFirstBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Nice! The more orbs you break, the stronger I get. Let’s try another."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepFirstBattleSecondMove;
}

- (void) beginFirstBattleFinalMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Good job! You have 1 move left before I attack. Make it count."];
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
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Thanks for helping me out back there. Hopefully we’re done with..."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnemyRanOff;
}

- (void) beginEnemyBroughtBackBossPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy), @"Prepare to..."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnemyBroughtBackBoss;
}

- (void) beginFriendJokePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"HURRY! SOMEONE GET THIS MAN SOME DUCT TAPE.",
                        @(TutorialDialogueSpeakerEnemy), @"...Why?",
                        @(TutorialDialogueSpeakerFriend), @"'CAUSE THIS MAN IS RIPPED!",
                        @(TutorialDialogueSpeakerEnemyBoss), @"Bad joke. You die now."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepFriendJoke;
}

- (void) beginSecondBattlePhase {
  self.battleLayer = [[TutorialBattleTwoLayer alloc] initWithConstants:self.constants enemyDamageDealt:_damageDealtToFriend];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  _currentStep = TutorialStepEnteredSecondBattle;
}

- (void) beginSecondBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You no run. You fight.",
                        @(TutorialDialogueSpeakerFriend), @"We’re dunzos if we don’t do something quick. Create a power-up by matching 4 orbs."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepSecondBattleFirstMove;
}

- (void) beginSecondBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"We’re not finished yet. Swipe the striped orb up to activate the power-up."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleSecondMove;
}

- (void) beginSecondBattleThirdMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Bada bing, bada boom. It all comes down to this last move."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSecondBattleThirdMove;
}

- (void) beginSecondBattleSwapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Looks like I won’t make...",
                        @(TutorialDialogueSpeakerMarkL), @"*Poke*",
                        @(TutorialDialogueSpeakerMarkL), @"Hey buddy, you don’t look so good. Would you “like” me to help you out?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepSecondBattleSwap;
}

- (void) beginSecondBattleKillPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Oops, let me update my Bookface status before we begin.",
                        @(TutorialDialogueSpeakerEnemyBoss), @"...",
                        @(TutorialDialogueSpeakerMarkL), @"\"Currently saving a stranger who got owned by a luchador. #LOL #GoodGuyZark\"",
                        @(TutorialDialogueSpeakerMarkL), @"Heh, 12 likes already. Alright, let’s do this."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepSecondBattleKillEnemy;
}

- (void) beginPostSecondBattleConfrontationPhase {
  [self.missionMap beginThirdConfrontation];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You win battle. Not war. We be back.",
                        @(TutorialDialogueSpeakerMarkL), @"So... is it cool if I still send you a friend request?",
                        @(TutorialDialogueSpeakerEnemyBoss), @"... No."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepPostSecondBattleConfrontation;
}

- (void) beginBoardYachtPhase {
  [self.missionMap markLooksAtYou];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"I don’t know if you noticed, but your buddy Joey is kinda bleeding everywhere.",
                        @(TutorialDialogueSpeakerMarkL), @"I have a private island nearby with a sweet hospital. We’ll take my BookFace yacht."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepBoardYacht;
}

- (void) beginHomeMapPhase {
  [self initHomeMap];
  [self.homeMap landBoatOnShore];
  
  _currentStep = TutorialStepLandAtHome;
}

- (void) beginEnterHospitalPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Welcome to one of my many private islands. You seem like a cool dude, so you can have this one.",
                        @(TutorialDialogueSpeakerMarkL), @"Your destiny is to turn this island into your secret base and to recruit the meanest mobsters around.",
                        @(TutorialDialogueSpeakerFriendR), @"In case you didn’t notice, I’m still bleeding and...",
                        @(TutorialDialogueSpeakerMarkL), @"First, let’s learn how to heal Joey so he can stop whining. Follow the magical floating arrows to begin."];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnterHospital;
}

- (void) beginHealQueueingPhase {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [self.gameViewController presentViewController:m animated:YES completion:nil];
  self.myCroniesViewController = [[TutorialMyCroniesViewController alloc] initWithTutorialConstants:self.constants damageDealt:_damageDealtToFriend hospitalHealSpeed:_hospitalHealSpeed];
  self.myCroniesViewController.delegate = self;
  [m pushViewController:self.myCroniesViewController animated:YES];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkR), @"Click on Joey to insert him into the healing queue.",
                        @(TutorialDialogueSpeakerMarkL), @"Mom always said, “health over wealth.” Use your gems to auto-magically heal Joey.",
                        @(TutorialDialogueSpeakerMarkL), @"Fantastic. Exit the hospital and I’ll show you the rest of the island."];
  [self displayDialogue:dialogue allowTouch:NO toViewController:self.myCroniesViewController];
  
  _currentStep = TutorialStepBeginHealQueue;
}

- (void) beginSpeedupHealQueuePhase {
  [self.dialogueViewController animateNext];
  
  _currentStep = TutorialStepSpeedupHealQueue;
}

- (void) beginHospitalExitPhase {
  [self.dialogueViewController animateNext];
  
  _currentStep = TutorialStepExitHospital;
}

- (void) beginBuildingOnePhase {
  [self initTopBar];
  [self.homeMap zoomOutMap];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"On your path to power, you’ll need cash to... do anything really.",
                        @(TutorialDialogueSpeakerMarkL), @"What better way to make money than to print it? Build a Cash Printer now!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepBeginBuildingOne;
}

- (void) beginSpeedupBuildingOnePhase {
  [self.homeMap speedupPurchasedBuilding];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Patience is a virtue, but not when you're building a Cash Printer."];
  [self displayDialogue:dialogue allowTouch:NO];
  
  _currentStep = TutorialStepSpeedupBuildingOne;
}

- (void) beginBuildingTwoPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Nice job! The Printer can only store a small amount of cash, so we’ll need a Vault to stash it.",
                        @(TutorialDialogueSpeakerMarkL), @"Hmm... I tried to buy one on Amazon, but they don't seem to ship to secret islands yet.",
                        @(TutorialDialogueSpeakerMarkL),@"Let's build one in the meantime!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepBeginBuildingTwo;
}

- (void) beginSpeedupBuildingTwoPhase {
  [self.homeMap speedupPurchasedBuilding];
  
  _currentStep = TutorialStepSpeedupBuildingTwo;
}

- (void) beginBuildingThreePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Good work! The Vault will protect your money from being stolen, so remember to upgrade it!",
                        @(TutorialDialogueSpeakerMarkL), @"Another important resource is Oil, which is used to upgrade your mobsters and buildings.",
                        @(TutorialDialogueSpeakerMarkL), @"A Saudi Prince once donated this Oil Drill to me, but you'll probably need it more than I.",
                        @(TutorialDialogueSpeakerMarkL), @"Construct an Oil Silo now to protect what your liquid gold!"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepBeginBuildingThree;
}

- (void) beginSpeedupBuildingThreePhase {
  [self.homeMap speedupPurchasedBuilding];
  
  _currentStep = TutorialStepSpeedupBuildingThree;
}

- (void) beginFacebookLoginPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Great job! The Silo will now protect your oil from being stolen in battle.",
                        @(TutorialDialogueSpeakerMarkL), @"Your island is starting to look like a real secret base! There’s just one last thing...",
                        @(TutorialDialogueSpeakerMarkL), @"I know I just met you, and this is crazy, but here’s my friend request, so add me maybe?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepFacebookLogin;
}

- (void) beginFacebookRejectedNamingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Playing hard to get huh? I can play that game too. What was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnterName;
}

- (void) beginFacebookAcceptedNamingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Hurray! I know we’re besties now, but what was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepEnterName;
}

- (void) begin {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Is that really on your birth certificate? Seems legit I guess.",
                        @(TutorialDialogueSpeakerFriendR), @"Enough chit chat. There’s a world to conquer, and it’s yours for the taking.",
                        @(TutorialDialogueSpeakerFriendR), @"Let’s head to the training grounds so I can teach you more about battling.",
                        @(TutorialDialogueSpeakerMarkL), @"Just keep following the floating orange arrows! Aren’t they pretty?"];
  [self displayDialogue:dialogue allowTouch:YES];
  
  _currentStep = TutorialStepClickQuests;
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

- (void) friendWalkedUpToBoss {
  [self beginFriendJokePhase];
}

- (void) everyoneEnteredSecondBuilding {
  [self beginSecondBattlePhase];
}

- (void) enemyBossRanOffMap {
  [self beginBoardYachtPhase];
}

- (void) yachtWentOffScene {
  [self beginHomeMapPhase];
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
  [self.gameViewController showTopBarDuration:0.f completion:nil] ;
}

#pragma mark - HomeMap delegate

- (void) boatLanded {
  [self beginEnterHospitalPhase];
}

- (void) enterHospitalClicked {
  [self beginHealQueueingPhase];
}

- (void) purchasedBuildingWasSetDown {
  if (_currentStep == TutorialStepBeginBuildingOne) {
    [self beginSpeedupBuildingOnePhase];
  } else if (_currentStep == TutorialStepBeginBuildingTwo) {
    [self beginSpeedupBuildingTwoPhase];
  } else if (_currentStep == TutorialStepBeginBuildingThree) {
    [self beginSpeedupBuildingThreePhase];
  }
}

- (void) buildingWasCompleted {
  [self.dialogueViewController animateNext];
  if (_currentStep == TutorialStepSpeedupBuildingOne) {
    [self beginBuildingTwoPhase];
  } else if (_currentStep == TutorialStepSpeedupBuildingTwo) {
    [self beginBuildingThreePhase];
  } else if (_currentStep == TutorialStepSpeedupBuildingThree) {
    [self beginFacebookLoginPhase];
  }
}

#pragma mark - MyCroniesViewController delegate

- (void) queuedUpMonster {
  [self beginSpeedupHealQueuePhase];
}

- (void) spedUpQueue {
  [self beginHospitalExitPhase];
}

- (void) exitedMyCronies {
  [self beginBuildingOnePhase];
}

#pragma mark - TopBar delegate

- (void) menuClicked {
  if (_currentStep == TutorialStepBeginBuildingOne ||
      _currentStep == TutorialStepBeginBuildingTwo ||
      _currentStep == TutorialStepBeginBuildingThree) {
    [self initMainMenuController];
    
    [self.dialogueViewController animateNext];
  }
}

#pragma mark - MainMenu delegate

- (void) buildingButtonClicked {
  int structId = 0;
  if (_currentStep == TutorialStepBeginBuildingOne) {
    structId = [self.constants.structureIdsToBeBuilltList[0] intValue];
  } else if (_currentStep == TutorialStepBeginBuildingTwo) {
    structId = [self.constants.structureIdsToBeBuilltList[1] intValue];
  } else if (_currentStep == TutorialStepBeginBuildingThree) {
    structId = [self.constants.structureIdsToBeBuilltList[2] intValue];
  }
  [self initCarpenterController:structId];
}

#pragma mark - Carpenter delegate

- (void) buildingPurchased:(int)structId {
  [self.homeMap preparePurchaseOfStruct:structId];
  [self.gameViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Facebook delegate

- (void) facebookConnectAccepted {
  Globals *gl = [Globals sharedGlobals];
  if (gl.addAllFbFriends) {
    [FacebookSpammer spamAllFriendsWithRequest];
  }
  [self beginFacebookAcceptedNamingPhase];
}

- (void) facebookConnectRejected {
  [self beginFacebookRejectedNamingPhase];
}

#pragma mark - Name delegate

- (void) nameChosen:(NSString *)name {
  NSLog(@"%@", name);
}

#pragma mark - DialogueViewController delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialStepSecondBattleFirstMove && index == 1) {
    dvc.view.userInteractionEnabled = NO;
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepFriendJoke && index == 1) {
    [self.missionMap enemyTurnToBoss];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy && index == 3) {
    dvc.view.userInteractionEnabled = NO;
    [dvc fadeOutBottomGradient];
  }  else if ((_currentStep == TutorialStepBeginBuildingOne && index == 1) ||
              (_currentStep == TutorialStepBeginBuildingTwo && index == 2) ||
              (_currentStep == TutorialStepBeginBuildingThree && index == 3)) {
    dvc.view.userInteractionEnabled = NO;
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepEnterHospital && index == 2) {
    [self.homeMap friendFaceMark];
  } else if (_currentStep == TutorialStepBeginBuildingThree && index == 1) {
    [self.homeMap moveToOilDrill];
  }
}

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialStepFirstBattleFirstMove) {
    [self.battleLayer beginFirstMove];
  } else if (_currentStep == TutorialStepFirstBattleSecondMove ||
             _currentStep == TutorialStepSecondBattleSecondMove) {
    [self.battleLayer beginSecondMove];
  } else if (_currentStep == TutorialStepFirstBattleLastMove ||
             _currentStep == TutorialStepSecondBattleThirdMove) {
    [self.battleLayer beginThirdMove];
  } else if (_currentStep == TutorialStepSecondBattleFirstMove && index == 1) {
    [self.battleLayer beginFirstMove];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy && index == 3) {
    [self.battleLayer allowMove];
  } else if (_currentStep == TutorialStepBeginHealQueue) {
    [self.myCroniesViewController allowCardClick];
  } else if (_currentStep == TutorialStepSpeedupHealQueue) {
    [self.myCroniesViewController allowSpeedup];
  } else if (_currentStep == TutorialStepExitHospital) {
    [self.myCroniesViewController allowClose];
  } else if ((_currentStep == TutorialStepBeginBuildingOne && index == 1) ||
             (_currentStep == TutorialStepBeginBuildingTwo && index == 2) ||
             (_currentStep == TutorialStepBeginBuildingThree && index == 3)) {
    [self.topBarViewController allowMenuClick];
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  // Make sure we haven't moved to the next step yet
  if (self.dialogueViewController == dvc) {
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
      [self.missionMap friendWalkUpToBoss];
    } else if (_currentStep == TutorialStepFriendJoke) {
      [self.missionMap beginChaseIntoSecondBuilding];
    } else if (_currentStep == TutorialStepSecondBattleSwap) {
      TutorialBattleTwoLayer *two = (TutorialBattleTwoLayer *)self.battleLayer;
      [two swapToMark];
    } else if (_currentStep == TutorialStepPostSecondBattleConfrontation) {
      [self.missionMap runOutEnemyBoss];
    } else if (_currentStep == TutorialStepBoardYacht) {
      [self.missionMap moveToYacht];
    } else if (_currentStep == TutorialStepEnterHospital) {
      [self.homeMap walkToHospitalAndEnter];
    } else if (_currentStep == TutorialStepFacebookLogin) {
      [self initFacebookViewController];
    } else if (_currentStep == TutorialStepEnterName ) {
      [self initNameViewController];
    } else if (_currentStep == TutorialStepClickQuests) {
      
    }
  }
}

@end
