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
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "TutorialDoublePowerupController.h"
#import "SoundEngine.h"

@implementation TutorialController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants gameViewController:(GameViewController *)gvc {
  if ((self = [super init])) {
    self.constants = constants;
    self.gameViewController = gvc;
    
    _damageDealtToFriend = 137;
    
    GameState *gs = [GameState sharedGameState];
    gs.silver = _cash = constants.cashInit;
    gs.oil = _oil = constants.oilInit;
    gs.gold = _gems = constants.gemsInit;
    
    _structs = [NSMutableDictionary dictionary];
    for (NSNumber *structId in constants.structureIdsToBeBuilltList) {
      [_structs setObject:[NSValue valueWithCGPoint:ccp(0, 0)] forKey:structId];
    }
    
    _name = @"NewUser";
  }
  return self;
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch useShortBubble:(BOOL)shortBubble toViewController:(UIViewController *)vc {
  GameState *gs = [GameState sharedGameState];
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    TutorialDialogueSpeaker speaker = [dialogue[i] intValue];
    NSString *speakerText = dialogue[i+1];
    
    int monsterId = 0;
    BOOL isLeftSide = NO;
    NSString *suffix = @"";
    switch (speaker) {
      case TutorialDialogueSpeakerEnemy1:
        monsterId = self.constants.enemyMonsterId;
        suffix = @"P1";
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemy2:
        monsterId = self.constants.enemyMonsterId;
        suffix = @"P2";
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemy3:
        monsterId = self.constants.enemyMonsterId;
        suffix = @"P3";
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyBoss:
        monsterId = self.constants.enemyBossMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerFriend1:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P1";
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend2:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P2";
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend3:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P3";
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend4:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P4";
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriendR3:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P3";
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerFriendR4:
        monsterId = self.constants.startingMonsterId;
        suffix = @"P4";
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
    ss.speaker = mp.displayName;
    ss.speakerImage = [mp.imagePrefix stringByAppendingString:suffix];
    ss.isLeftSide = isLeftSide;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:shortBubble];
  dvc.delegate = self;
  [vc addChildViewController:dvc];
  [vc.view insertSubview:dvc.view belowSubview:self.touchView];
  dvc.view.frame = vc.view.bounds;
  self.dialogueViewController = dvc;
  
  [self.touchView addResponder:self.dialogueViewController];
  self.touchView.userInteractionEnabled = !allowTouch;
  self.dialogueViewController.view.userInteractionEnabled = allowTouch;
  
  if (!allowTouch) {
    [dvc.bottomGradient removeFromSuperview];
  }
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch useShortBubble:(BOOL)shortBubble {
  [self displayDialogue:dialogue allowTouch:allowTouch useShortBubble:shortBubble toViewController:self.gameViewController];
}

- (void) beginTutorial {
  [self.gameViewController.topBarViewController.mainView setHidden:YES];
  [self.gameViewController.topBarViewController.chatViewController.view setHidden:YES];
  
  self.touchView = [[TutorialTouchView alloc] initWithFrame:self.gameViewController.view.bounds];
  [self.gameViewController.view addSubview:self.touchView];
  [self.touchView addResponder:[CCDirector sharedDirector].view];
  self.touchView.userInteractionEnabled = NO;
  
  //[self initMissionMapWithCenterOnThirdBuilding:NO];
  //[self beginBlackedOutDialogue];
  //[self beginPostFirstBattleConfrontationPhase];
  
  [self yachtWentOffScene];
  
  //[self initHomeMap];
  //[self initMissionMapWithCenterOnThirdBuilding:YES];
  //[self initTopBar];
  //[self sendUserCreate];
  //[self beginFacebookLoginPhase];
  
  [[SoundEngine sharedSoundEngine] playMissionMapMusic];
}

- (void) initMissionMapWithCenterOnThirdBuilding:(BOOL)thirdBuilding {
  CCScene *scene = [CCScene node];
  if (!self.missionMap) {
    TutorialMissionMap *missionMap = [[TutorialMissionMap alloc] initWithTutorialConstants:self.constants];
    missionMap.delegate = self;
    self.missionMap = missionMap;
  } else {
    if (self.missionMap.parent) {
      [self.missionMap removeFromParent];
    }
  }
  
  if (thirdBuilding) {
    [self.missionMap moveToThirdBuilding];
  }
  
  [scene addChild:self.missionMap];
  CCDirector *dir = [CCDirector sharedDirector];
  if (!dir.runningScene) {
    [dir replaceScene:scene];
  } else {
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.4f]];
  }
  self.gameViewController.currentMap = self.missionMap;
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
  
  GameState *gs = [GameState sharedGameState];
  gs.myStructs = homeMap.myStructs;
  
  CCDirector *dir = [CCDirector sharedDirector];
  if (!dir.runningScene) {
    [dir replaceScene:scene];
  } else {
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionCrossFadeWithDuration:0.4f]];
  }
}

- (void) initTopBar {
  if (!self.topBarViewController) {
    self.topBarViewController = [[TutorialTopBarViewController alloc] init];
    self.topBarViewController.delegate = self;
    self.topBarViewController.view.frame = self.gameViewController.view.bounds;
    self.topBarViewController.mainView.hidden = YES;
    self.topBarViewController.chatViewController.view.hidden = YES;
    [self.gameViewController addChildViewController:self.topBarViewController];
    [self.gameViewController.view insertSubview:self.topBarViewController.view belowSubview:self.touchView];
    [self.topBarViewController displayMenuButton];
    [self.topBarViewController displayCoinBars];
    
    // Have to do this for some reason..
    [self.topBarViewController viewWillAppear:YES];
  }
}

- (void) initMyCroniesViewController {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [self.gameViewController presentViewController:m animated:YES completion:nil];
  self.myCroniesViewController = [[TutorialMyCroniesViewController alloc] initWithTutorialConstants:self.constants damageDealt:_damageDealtToFriend hospitalHealSpeed:_hospitalHealSpeed];
  self.myCroniesViewController.delegate = self;
  [m pushViewController:self.myCroniesViewController animated:YES];
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

- (void) initQuestLogControllerWithQuestId:(int)questId {
  self.questLogViewController = [[TutorialQuestLogViewController alloc] init];
  [self.gameViewController addChildViewController:self.questLogViewController];
  self.questLogViewController.view.frame = self.gameViewController.view.bounds;
  self.questLogViewController.delegate = self;
  [self.gameViewController.view insertSubview:self.questLogViewController.view belowSubview:self.touchView];
  
  if (questId) {
    GameState *gs = [GameState sharedGameState];
    FullQuestProto *fqp = [gs questForId:questId];
    UserQuest *uq = [gs myQuestWithId:questId];
    [self.questLogViewController loadDetailsViewForQuest:fqp userQuest:uq animated:NO];
  }
}

- (void) initFacebookViewController {
  self.facebookViewController = [[TutorialFacebookViewController alloc] init];
  self.facebookViewController.delegate = self;
  self.facebookViewController.view.frame = self.gameViewController.view.bounds;
  [self.gameViewController addChildViewController:self.facebookViewController];
  [self.gameViewController.view addSubview:self.facebookViewController.view];
}

- (void) initNameViewController {
  NSString *gcName = [GameCenterDelegate gameCenterName];
  if (gcName) {
    [self initNameViewController:gcName];
  } else {
    if (_facebookId) {
      [FacebookDelegate getFacebookUsernameAndDoAction:^(NSString *username) {
        if (username) {
          [self initNameViewController:username];
        } else {
          [self initNameViewController:nil];
        }
      }];
    } else {
      [self initNameViewController:nil];
    }
  }
}

- (void) initNameViewController:(NSString *)name {
  self.nameViewController = [[TutorialNameViewController alloc] initWithName:name];
  self.nameViewController.delegate = self;
  self.nameViewController.view.frame = self.gameViewController.view.bounds;
  [self.gameViewController addChildViewController:self.nameViewController];
  [self.gameViewController.view addSubview:self.nameViewController.view];
}

- (void) initAttackMapViewController {
  self.attackMapViewController = [[TutorialAttackMapViewController alloc] init];
  self.attackMapViewController.delegate = self;
  [self.attackMapViewController allowClickOnCityId:1];
  MenuNavigationController *nav = [[MenuNavigationController alloc] init];
  nav.navigationBarHidden = YES;
  [self.gameViewController presentViewController:nav animated:YES completion:nil];
  [nav pushViewController:self.attackMapViewController animated:YES];
}

- (void) cacheKeyboard {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0), dispatch_get_main_queue(), ^(void){
    UITextField *field = [UITextField new];
    [self.gameViewController.view addSubview:field];
    [field becomeFirstResponder];
    [field resignFirstResponder];
    [field removeFromSuperview];
  });
}

- (void) cleanup {
  [self.topBarViewController.view removeFromSuperview];
  [self.topBarViewController removeFromParentViewController];
  
  [self.gameViewController.topBarViewController.mainView setHidden:NO];
  [self.gameViewController.topBarViewController.chatViewController.view setHidden:NO];
  
  [self.touchView removeFromSuperview];
}

- (void) tutorialFinished {
  [self cleanup];
  
  LoadCityResponseProto_Builder *bldr = [LoadCityResponseProto builder];
  [bldr addAllCityElements:self.constants.cityOneElementsList];
  bldr.cityId = self.constants.cityId;
  
  CCScene *scene = [CCScene node];
  MissionMap *mm = [[MissionMap alloc] initWithProto:bldr.build];
  [scene addChild:mm];
  mm.position = self.missionMap.position;
  mm.scale = self.missionMap.scale;
  self.gameViewController.currentMap = mm;
  [[CCDirector sharedDirector] replaceScene:scene];
  
  [self.gameViewController.topBarViewController showMyCityView];
  [self.gameViewController tutorialFinished];
}

- (void) sendUserCreate {
  NSMutableArray *str = [NSMutableArray array];
  for (NSNumber *num in _structs) {
    CGPoint coord = [_structs[num] CGPointValue];
    
    TutorialStructProto_Builder *bldr = [TutorialStructProto builder];
    bldr.structId = num.intValue;
    bldr.coordinate = [[[[CoordinateProto builder] setX:coord.x] setY:coord.y] build];
    [str addObject:bldr.build];
  }
  
  [[OutgoingEventController sharedOutgoingEventController] createUserWithName:_name facebookId:_facebookId structs:str cash:_cash oil:_oil gems:_gems delegate:self];
}

- (void) handleUserCreateResponseProto:(FullEvent *)fe {
  UserCreateResponseProto *proto = (UserCreateResponseProto *)fe.event;
  if (proto.status == UserCreateResponseProto_UserCreateStatusSuccess) {
    _sendingUserCreateStartup = YES;
    [[OutgoingEventController sharedOutgoingEventController] startupWithFacebookId:_facebookId isFreshRestart:YES delegate:self];
  } else {
    [Globals popupMessage:@"Something went wrong with creating your account. Please contact support about this issue."];
  }
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  StartupResponseProto *proto = (StartupResponseProto *)fe.event;
  if (_sendingUserCreateStartup) {
    self.userCreateStartupResponse = proto;
    [self.gameViewController tutorialReceivedStartupResponse:self.userCreateStartupResponse];
    
    if (_waitingOnUserCreate) {
      [self fadeToMissionMap];
    }
  } else {
    [self facebookStartupReceived:proto];
  }
}

#pragma mark - Tutorial Sequence

- (void) beginBlackedOutDialogue {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend3), @"Help! Somebody stop that guy!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  self.dialogueViewController.blackOutSpeakers = YES;
  
  _currentStep = TutorialStepBlackedOutDialogue;
}

- (void) beginInitialChasePhase {
  [self.missionMap beginInitialChase];
  
  _currentStep = TutorialStepInitialChase;
}

- (void) beginFirstDialoguePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend3), @"Come back! Just give me 15 minutes and you could be saving 15% or more on car insurance by switching to GuyCo!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFirstDialogue;
}

- (void) beginFirstEnemyTauntPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy3), @"Leave me alone! I don’t want your stupid insurance! Stop following me."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFirstEnemyTaunt;
}

- (void) beginFriendEnterBuildingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"Did you see where that... excited customer went?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFriendEnterBuilding;
}

- (void) beginFirstBattlePhase {
  self.battleLayer = [[TutorialBattleOneLayer alloc] initWithConstants:self.constants];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  _currentStep = TutorialStepEnteredFirstBattle;
}

- (void) beginFirstBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"My hands are too tiny to move the orbs on the right, so you’ll need to help me out.",
                        @(TutorialDialogueSpeakerFriend4), @"This is Candy Crush on steroids. Match 3 orbs by swiping this one to the right."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleFirstMove;
}

- (void) beginFirstBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend1), @"Nice! The more orbs you break, the stronger I get. Let’s try another."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleSecondMove;
}

- (void) beginFirstBattleFinalMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend1), @"Good job! You have 1 move left before I attack. Make it count."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleLastMove;
}

- (void) beginPostFirstBattleConfrontationPhase {
  [self.missionMap beginSecondConfrontation];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy3), @"Do you know who you’re messing with? Just wait till I call in the back up!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepPostFirstBattleConfrontation;
}

- (void) beginEnemyRanOffPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"Thanks for helping me out back there. Hopefully he'll reconsider..."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnemyRanOff;
}

- (void) beginEnemyBroughtBackBossPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy3), @"This is the guy, boss! Let's get..."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnemyBroughtBackBoss;
}

- (void) beginFriendJokePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend3), @"HURRY! SOMEONE GET THIS MAN SOME DUCT TAPE."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFriendJoke;
}

- (void) beginEnemyLookBackPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy3), @"What... Why?",
                        @(TutorialDialogueSpeakerFriend2), @"CAUSE THIS MAN IS RIPPED!",
                        @(TutorialDialogueSpeakerEnemyBoss), @"Me no laugh. You die now."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnemyLookBack;
}

- (void) beginSecondBattlePhase {
  self.battleLayer = [[TutorialBattleTwoLayer alloc] initWithConstants:self.constants enemyDamageDealt:_damageDealtToFriend];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  _currentStep = TutorialStepEnteredSecondBattle;
}

- (void) beginSecondBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You no run. You fight.",
                        @(TutorialDialogueSpeakerFriend4), @"We’re toast if we don’t do something quick. Create a power-up by matching 4 orbs."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleFirstMove;
}

- (void) beginSecondBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"We’re not finished yet. Swipe the striped orb up to activate the power-up."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleSecondMove;
}

- (void) beginSecondBattleThirdMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"Bada bing, bada boom. It all comes down to this last move."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleThirdMove;
}

- (void) beginSecondBattleSwapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend3), @"Looks like I won’t make...",
                        @(TutorialDialogueSpeakerMarkL), @"*Poke*",
                        @(TutorialDialogueSpeakerMarkL), @"Hey buddy, you don’t look so good. Would you “like” me to help you out?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleSwap;
}

- (void) beginSecondBattleKillPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Oops, let me update my BookFace status before we begin.",
                        @(TutorialDialogueSpeakerEnemyBoss), @"...",
                        @(TutorialDialogueSpeakerMarkL), @"\"Currently saving a stranger who got owned by a luchador. #LOL #GoodGuyZark\"",
                        @(TutorialDialogueSpeakerMarkL), @"Heh, 12 likes already. Alright, let’s do this."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleKillEnemy;
}

- (void) beginPostSecondBattleConfrontationPhase {
  [self.missionMap beginThirdConfrontation];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"You win battle. Not war. We be back.",
                        @(TutorialDialogueSpeakerMarkL), @"So... is it cool if I still send you a friend request?",
                        @(TutorialDialogueSpeakerEnemyBoss), @"...No."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepPostSecondBattleConfrontation;
}

- (void) beginBoardYachtPhase {
  [self.missionMap markLooksAtYou];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"I don’t know if you noticed, but your buddy Joey is kinda bleeding everywhere.",
                        @(TutorialDialogueSpeakerMarkL), @"I have a private island nearby with a sweet hospital. We’ll take my BookFace yacht."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepBoardYacht;
}

- (void) beginHomeMapPhase {
  [self initHomeMap];
  [self.homeMap landBoatOnShore];
  [[SoundEngine sharedSoundEngine] playHomeMapMusic];
  
  _currentStep = TutorialStepLandAtHome;
}

- (void) beginMarkLookBackPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Welcome to one of my many private islands. You seem like a cool dude, so you can have this one.",
                        @(TutorialDialogueSpeakerMarkL), @"Your destiny is to turn this island into your secret base and to recruit the meanest mobsters around.",
                        @(TutorialDialogueSpeakerFriendR3), @"In case you didn’t notice, I’m still bleeding and..."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepMarkLookBack;
}

- (void) beginEnterHospitalPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"First, let’s learn how to heal Joey so he can stop whining. Follow the magical floating arrows to begin."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterHospital;
}

- (void) beginHealQueueingPhase {
  [self initMyCroniesViewController];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkR), @"Click on Joey to insert him into the healing queue.",
                        @(TutorialDialogueSpeakerMarkL), @"Mom always said, “health over wealth.” Use your gems to auto-magically heal Joey.",
                        @(TutorialDialogueSpeakerMarkL), @"Fantastic. Exit the hospital and I’ll show you the rest of the island."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:NO toViewController:self.myCroniesViewController];
  
  _currentStep = TutorialStepBeginHealQueue;
}

- (void) beginSpeedupHealQueuePhase {
  //NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Mom always said, “health over wealth.” Use your gems to auto-magically heal Joey."];
  //[self displayDialogue:dialogue allowTouch:NO toViewController:self.myCroniesViewController];
  
  _currentStep = TutorialStepSpeedupHealQueue;
}

- (void) beginHospitalExitPhase {
  //NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Fantastic. Exit the hospital and I’ll show you the rest of the island."];
  //[self displayDialogue:dialogue allowTouch:NO toViewController:self.myCroniesViewController];
  
  _currentStep = TutorialStepExitHospital;
}

- (void) beginBuildingOnePhase {
  [self initTopBar];
  [self.homeMap zoomOutMap];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"On your path to power, you’ll need cash to... do anything really.",
                        @(TutorialDialogueSpeakerMarkL), @"What better way to make money than to print it? Build a Cash Printer now!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepBeginBuildingOne;
}

- (void) beginSpeedupBuildingOnePhase {
  [self.homeMap speedupPurchasedBuilding];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Patience is a virtue, but not when you're building a Cash Printer."];
  BOOL allowTouch = ![Globals isLongiPhone];
  [self displayDialogue:dialogue allowTouch:allowTouch useShortBubble:YES];
  self.touchView.userInteractionEnabled = NO;
  
  _currentStep = TutorialStepSpeedupBuildingOne;
}

- (void) beginBuildingTwoPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Nice job! The Printer can only store a small amount of cash, so we’ll need a Vault to stash the rest of it.",
                        @(TutorialDialogueSpeakerMarkL), @"Hmm... I tried to buy one on Amazon, but they don't seem to ship to secret islands yet.",
                        @(TutorialDialogueSpeakerMarkL),@"Let's build one in the meantime!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
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
                        @(TutorialDialogueSpeakerMarkL), @"We'll need a place to store the oil you drill, so construct an Oil Silo now!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
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
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFacebookLogin;
}

- (void) beginFacebookRejectedNamingPhase {
  [self cacheKeyboard];
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Playing hard to get huh? I can play that game too. What was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterName;
}

- (void) beginFacebookAcceptedNamingPhase {
  [self cacheKeyboard];
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Hurray! I know that we’re besties now, but what was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterName;
}

- (void) beginAttackMapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkL), @"Is that really on your birth certificate? Seems legit I guess.",
                        @(TutorialDialogueSpeakerFriendR4), @"Enough chit chat. There’s a world to conquer, and it’s yours for the taking.",
                        @(TutorialDialogueSpeakerFriendR4), @"Let’s head to the training grounds now so I can teach you more about battling."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepAttackMap;
}

- (void) beginEnterBattleThreePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"Unlike your world, we mobsters like to take the fight inside. Click on the Tea Lounge to start a fight."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterBattleThree;
}

- (void) beginRainbowMiniTutorialPhase {
  GameState *gs = [GameState sharedGameState];
  self.miniTutController = [[TutorialRainbowController alloc] initWithMyTeam:gs.allMonstersOnMyTeam gameViewController:self.gameViewController];
  self.miniTutController.delegate = self;
  [self.miniTutController begin];
  [self.miniTutController.battleLayer.forfeitButton removeFromSuperview];
  
  [UIView animateWithDuration:0.4f animations:^{
    self.topBarViewController.view.alpha = 0.f;
  }];
  
  _currentStep = TutorialStepRainbowMiniTutorial;
}

- (void) beginClickQuestsPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"On your path to power, you’re going to run into mobsters stronger than you.",
                        @(TutorialDialogueSpeakerMarkR), @"Are you guys talking about me again?",
                        @(TutorialDialogueSpeakerFriend4), @"No... Anyway, to defeat a stronger enemy, you’ll need to learn how to create a Rainbow Orb.",
                        @(TutorialDialogueSpeakerFriend4), @"Meet me at the Tea Lounge and I’ll show you how it’s done.",
                        @(TutorialDialogueSpeakerMarkR), @"Hey buddy, before you go, I got you something!",
                        @(TutorialDialogueSpeakerMarkR), @"I made you this mission log to guide you to success. Tap here now to check it out!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepClickQuests;
}

- (void) beginQuestListPhase {
  [self initQuestLogControllerWithQuestId:0];
  [self.questLogViewController arrowOnFirstQuestInList];
  
  //  NSArray *dialogue = @[@(TutorialDialogueSpeakerMarkR), @"New missions will appear on this list as you complete them, so be sure to check back often.",
  //                        @(TutorialDialogueSpeakerMarkR), @"You can view the progress and rewards of quests by clicking on them."];
  //  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepQuestList;
}

- (void) beginFirstQuestPhase {
  [self.questLogViewController performSelector:@selector(arrowOnVisit) withObject:nil afterDelay:1.f];
  
  _currentStep = TutorialStepFirstQuest;
}

- (void) beginEnterBattleFourPhase {
  [self.missionMap moveToFourthBuildingAndDisplayArrow];
  
  _currentStep = TutorialStepEnterBattleFour;
}

- (void) beginDoublePowerupMiniTutorialPhase {
  GameState *gs = [GameState sharedGameState];
  self.miniTutController = [[TutorialDoublePowerupController alloc] initWithMyTeam:gs.allMonstersOnMyTeam gameViewController:self.gameViewController];
  self.miniTutController.delegate = self;
  [self.miniTutController begin];
  [self.miniTutController.battleLayer.forfeitButton removeFromSuperview];
  
  [UIView animateWithDuration:0.4f animations:^{
    self.topBarViewController.view.alpha = 0.f;
  }];
  
  _currentStep = TutorialStepDoublePowerupMiniTutorial;
}

- (void) beginFirstQuestCompletePhase {
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *fqp = nil;
  if (gs.inProgressCompleteQuests.count > 0) {
    fqp = gs.inProgressCompleteQuests.allValues[0];
  }
  [self initQuestLogControllerWithQuestId:fqp.questId];
  
  [self.questLogViewController performSelector:@selector(arrowOnCollect) withObject:nil afterDelay:1.f];
  
  _currentStep = TutorialStepFirstQuestComplete;
}

- (void) beginSecondQuestPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend4), @"Now that you have a decent handle on combat, you’ll need to assemble your squad.",
                        @(TutorialDialogueSpeakerFriend4), @"The key to taking over the world is by recruiting powerful allies to your team.",
                        @(TutorialDialogueSpeakerFriend4), @"Use your guns of persuasion and “recruit” a goonie to your team."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepSecondQuest;
}

- (void) beginEnterBattleFivePhase {
  [self.missionMap moveToFifthBuildingAndDisplayArrow];
  
  _currentStep = TutorialStepEnterBattleFive;
}

- (void) beginDropMiniTutorialPhase {
  GameState *gs = [GameState sharedGameState];
  self.miniTutController = [[TutorialDoublePowerupController alloc] initWithMyTeam:gs.allMonstersOnMyTeam gameViewController:self.gameViewController];
  self.miniTutController.delegate = self;
  [self.miniTutController begin];
  [self.miniTutController.battleLayer.forfeitButton removeFromSuperview];
  
  [UIView animateWithDuration:0.4f animations:^{
    self.topBarViewController.view.alpha = 0.f;
  }];
  
  _currentStep = TutorialStepDropMiniTutorial;
}

- (void) beginSecondQuestCompletePhase {
  GameState *gs = [GameState sharedGameState];
  FullQuestProto *fqp = nil;
  if (gs.inProgressCompleteQuests.count > 0) {
    fqp = gs.inProgressCompleteQuests.allValues[0];
  }
  [self initQuestLogControllerWithQuestId:fqp.questId];
  
  [self.questLogViewController performSelector:@selector(arrowOnCollect) withObject:nil afterDelay:1.f];
  
  _currentStep = TutorialStepSecondQuestComplete;
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

- (void) enemyTurnedToBossAndBack {
  [self beginEnemyLookBackPhase];
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

- (void) enteredMiniTutBuilding {
  if (_currentStep == TutorialStepEnterBattleThree) {
    [self beginRainbowMiniTutorialPhase];
  } else if (_currentStep == TutorialStepEnterBattleFour) {
    [self beginDoublePowerupMiniTutorialPhase];
  }
}

#pragma mark - BattleLayer delegate

- (void) battleLayerReachedEnemy {
  if (_currentStep == TutorialStepEnteredFirstBattle) {
    [self beginFirstBattleFirstMovePhase];
  } else if (_currentStep == TutorialStepEnteredSecondBattle) {
    [self beginSecondBattleFirstMovePhase];
  }
}

- (void) moveMade {
  // Dismiss the dialogue
  [self.dialogueViewController animateNext];
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
  [self.gameViewController showTopBarDuration:0.f completion:nil];
  
  [[SoundEngine sharedSoundEngine] playMissionMapMusic];
}

#pragma mark - HomeMap delegate

- (void) boatLanded {
  [self beginMarkLookBackPhase];
}

- (void) markFacedFriendAndBack {
  [self beginEnterHospitalPhase];
}

- (void) enterHospitalClicked {
  [self beginHealQueueingPhase];
}

- (void) purchasedBuildingWasSetDown:(int)structId coordinate:(CGPoint)coordinate cashCost:(int)cashCost oilCost:(int)oilCost {
  if (_currentStep == TutorialStepBeginBuildingOne) {
    [self beginSpeedupBuildingOnePhase];
  } else if (_currentStep == TutorialStepBeginBuildingTwo) {
    [self beginSpeedupBuildingTwoPhase];
  } else if (_currentStep == TutorialStepBeginBuildingThree) {
    [self beginSpeedupBuildingThreePhase];
  }
  
  [_structs setObject:[NSValue valueWithCGPoint:coordinate] forKey:@(structId)];
  
  GameState *gs = [GameState sharedGameState];
  _cash -= cashCost;
  _oil -= oilCost;
  gs.silver = _cash;
  gs.oil = _oil;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) buildingWasSpedUp:(int)gemsSpent {
  [self.dialogueViewController animateNext];
  
  GameState *gs = [GameState sharedGameState];
  _gems -= gemsSpent;
  gs.gold = _gems;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) buildingWasCompleted {
  if (_currentStep == TutorialStepSpeedupBuildingOne) {
    [self beginBuildingTwoPhase];
  } else if (_currentStep == TutorialStepSpeedupBuildingTwo) {
    [self beginBuildingThreePhase];
  } else if (_currentStep == TutorialStepSpeedupBuildingThree) {
    [self beginFacebookLoginPhase];
  }
}

#pragma mark - MyCroniesViewController delegate

- (void) queuedUpMonster:(int)cashSpent {
  [self.dialogueViewController animateNext];
  [self beginSpeedupHealQueuePhase];
  
  GameState *gs = [GameState sharedGameState];
  _cash -= cashSpent;
  gs.silver = _cash;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) spedUpQueue:(int)gemsSpent {
  [self.dialogueViewController animateNext];
  [self beginHospitalExitPhase];
  
  GameState *gs = [GameState sharedGameState];
  _gems -= gemsSpent;
  gs.gold = _gems;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) exitedMyCronies {
  [self.dialogueViewController animateNext];
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

- (void) attackClicked {
  [self initAttackMapViewController];
}

- (void) questsClicked {
  [self.dialogueViewController animateNext];
  
  //[self.gameViewController.topBarViewController questsClicked:nil];
  //[self tutorialFinished];
  [self beginQuestListPhase];
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

- (void) facebookConnectRejected {
  [self.facebookViewController close];
  [self beginFacebookRejectedNamingPhase];
}

- (void) facebookConnectAccepted {
  [FacebookDelegate getFacebookIdAndDoAction:^(NSString *facebookId) {
    if (facebookId) {
      _facebookId = facebookId;
      [[OutgoingEventController sharedOutgoingEventController] startupWithFacebookId:facebookId isFreshRestart:YES delegate:self];
    } else {
      [Globals popupMessage:@"Something went wrong. Your facebook account could not be retrieved! Please try again."];
    }
  }];
}

- (void) facebookStartupReceived:(StartupResponseProto *)proto {
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserNotInDb) {
    [self.facebookViewController close];
    [self beginFacebookAcceptedNamingPhase];
    
    Globals *gl = [Globals sharedGlobals];
    if (gl.addAllFbFriends) {
      [FacebookSpammer spamAllFriendsWithRequest];
    }
  } else {
    _facebookId = nil;
    self.facebookStartupResponse = proto;
    NSString *desc = [NSString stringWithFormat:@"Oops! This Facebook account is already linked to another player (%@). Would you like to load that account now?", proto.sender.name];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Account Already Used" okayButton:@"Load" cancelButton:@"Cancel" okTarget:self okSelector:@selector(swapAccounts) cancelTarget:self cancelSelector:@selector(swapRejected)];
  }
}

- (void) swapAccounts {
  [self.facebookViewController close];
  [self cleanup];
  [self.gameViewController reloadAccountWithStartupResponse:self.facebookStartupResponse];
}

- (void) swapRejected {
  [FacebookDelegate logout];
  [self.facebookViewController allowClick];
}

#pragma mark - Name delegate

- (void) nameChosen:(NSString *)name {
  _name = name;
  [self beginAttackMapPhase];
  
  [self sendUserCreate];
}

#pragma mark - AttackMap delegate

- (void) visitCityClicked:(int)cityId {
  if (_currentStep == TutorialStepAttackMap) {
    GameState *gs = [GameState sharedGameState];
    FullCityProto *fcp = [gs cityWithId:self.constants.cityId];
    self.gameViewController.loadingView.label.text = [NSString stringWithFormat:@"Traveling to\n%@", fcp.name];
    [self.gameViewController.loadingView display:self.gameViewController.view];
    
    [self performSelector:@selector(fadeToMissionMap) withObject:nil afterDelay:0.5f];
  }
}

- (void) fadeToMissionMap {
  if (self.userCreateStartupResponse) {
    [self.gameViewController.loadingView stop];
    
    // Go back to the mission map
    [self initMissionMapWithCenterOnThirdBuilding:YES];
    //[self beginEnterBattleThreePhase];
    [self beginClickQuestsPhase];
  } else {
    _waitingOnUserCreate = YES;
  }
}

#pragma mark - MiniTutorial delegate

- (void) miniTutorialComplete:(MiniTutorialController *)tut {
  if (_currentStep == TutorialStepRainbowMiniTutorial) {
    [self beginClickQuestsPhase];
  } else if (_currentStep == TutorialStepDoublePowerupMiniTutorial) {
    [self beginFirstQuestCompletePhase];
  } else if (_currentStep == TutorialStepDropMiniTutorial) {
    
  }
  
  [UIView animateWithDuration:0.4f animations:^{
    self.topBarViewController.view.alpha = 1.f;
  }];
}

#pragma mark - QuestLog delegate

- (void) questClickedInList {
  if (_currentStep == TutorialStepQuestList) {
    [self.dialogueViewController animateNext];
    [self beginFirstQuestPhase];
  }
}

- (void) questVisitClicked {
  if (_currentStep == TutorialStepFirstQuest) {
    //[self beginEnterBattleFourPhase];
    [self tutorialFinished];
  } else if (_currentStep == TutorialStepSecondQuest) {
    [self beginEnterBattleFivePhase];
  }
}

- (void) questCollectClicked {
  if (_currentStep == TutorialStepFirstQuestComplete) {
    [self beginSecondQuestPhase];
  } else if (_currentStep == TutorialStepSecondQuestComplete) {
    NSLog(@"Reached here");
  }
}

#pragma mark - DialogueViewController delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialStepFirstBattleFirstMove && index == 1) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepSecondBattleFirstMove && index == 1) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepSecondBattleKillEnemy && index == 3) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    [dvc fadeOutBottomGradient];
  }  else if ((_currentStep == TutorialStepBeginBuildingOne && index == 1) ||
              (_currentStep == TutorialStepBeginBuildingTwo && index == 2) ||
              (_currentStep == TutorialStepBeginBuildingThree && index == 3)) {
    dvc.view.userInteractionEnabled = NO;
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepMarkLookBack && index == 2) {
    [self.homeMap friendFaceMark];
  } else if (_currentStep == TutorialStepBeginBuildingThree && index == 1) {
    [self.homeMap moveToOilDrill];
  } else if (_currentStep == TutorialStepAttackMap && index == 1) {
    [self.homeMap friendFaceForward];
  } else if (_currentStep == TutorialStepFacebookLogin && index == 1) {
    [self.homeMap panToMark];
  }
}

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialStepFirstBattleFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialStepFirstBattleSecondMove ||
               _currentStep == TutorialStepSecondBattleSecondMove) {
      [self.battleLayer beginSecondMove];
    } else if (_currentStep == TutorialStepFirstBattleLastMove ||
               _currentStep == TutorialStepSecondBattleThirdMove) {
      [self.battleLayer allowMove];
    } else if (_currentStep == TutorialStepSecondBattleFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialStepSecondBattleKillEnemy) {
      [self.battleLayer allowMove];
    } else if ((_currentStep == TutorialStepBeginBuildingOne) ||
               (_currentStep == TutorialStepBeginBuildingTwo) ||
               (_currentStep == TutorialStepBeginBuildingThree)) {
      [self.topBarViewController allowMenuClick];
    } else if (_currentStep == TutorialStepClickQuests) {
      self.dialogueViewController.view.userInteractionEnabled = NO;
      [self.topBarViewController allowQuestsClick];
    } else if (_currentStep == TutorialStepQuestList) {
      self.dialogueViewController.view.userInteractionEnabled = NO;
      [self.questLogViewController arrowOnFirstQuestInList];
    } else if (_currentStep == TutorialStepFirstQuestComplete) {
      self.dialogueViewController.view.userInteractionEnabled = NO;
      [self.questLogViewController arrowOnCollect];
    }
  }
  
  if (_currentStep == TutorialStepBeginHealQueue) {
    [self.myCroniesViewController allowCardClick];
  } else if (_currentStep == TutorialStepSpeedupHealQueue) {
    [self.myCroniesViewController allowSpeedup];
  } else if (_currentStep == TutorialStepExitHospital) {
    [self.myCroniesViewController allowClose];
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
      [self.missionMap enemyTurnToBoss];
    } else if (_currentStep == TutorialStepEnemyLookBack) {
      [self.missionMap beginChaseIntoSecondBuilding];
    } else if (_currentStep == TutorialStepSecondBattleSwap) {
      TutorialBattleTwoLayer *two = (TutorialBattleTwoLayer *)self.battleLayer;
      [two swapToMark];
    } else if (_currentStep == TutorialStepPostSecondBattleConfrontation) {
      [self.missionMap runOutEnemyBoss];
    } else if (_currentStep == TutorialStepBoardYacht) {
      [self.missionMap moveToYacht];
      [SoundEngine tutorialBoatScene];
    } else if (_currentStep == TutorialStepMarkLookBack) {
      [self.homeMap markFaceFriendAndBack];
    } else if (_currentStep == TutorialStepEnterHospital) {
      [self.homeMap walkToHospitalAndEnter];
    } else if (_currentStep == TutorialStepFacebookLogin) {
      [self initFacebookViewController];
    } else if (_currentStep == TutorialStepEnterName) {
      [self initNameViewController];
    } else if (_currentStep == TutorialStepAttackMap) {
      [self.topBarViewController allowAttackClick];
    } else if (_currentStep == TutorialStepEnterBattleThree) {
      [self.missionMap displayArrowOverThirdBuilding];
    } else if (_currentStep == TutorialStepSecondQuest) {
      GameState *gs = [GameState sharedGameState];
      FullQuestProto *fqp = gs.availableQuests.allValues[0];
      [self initQuestLogControllerWithQuestId:fqp.questId];
    }
    
    [self.touchView removeResponder:self.dialogueViewController];
    self.touchView.userInteractionEnabled = NO;
  }
}

- (void) dealloc {
  self.dialogueViewController.delegate = nil;
}

@end
