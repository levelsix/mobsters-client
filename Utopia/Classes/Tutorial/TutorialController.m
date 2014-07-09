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
    
    Globals *gl = [Globals sharedGlobals];
    GameState *gs = [GameState sharedGameState];
    UserMonster *um = [[UserMonster alloc] init];
    um.level = 1;
    um.monsterId = constants.startingMonsterId;
    _damageDealtToFriend = [gl calculateMaxHealthForMonster:um]*0.93;
    
    gs.silver = _cash = constants.cashInit;
    gs.oil = _oil = constants.oilInit;
    gs.gold = _gems = constants.gemsInit;
    [gs.myMonsters removeAllObjects];
    [gs.myMiniJobs removeAllObjects];
    [gs.monsterHealingQueue removeAllObjects];
    [gs.myStructs removeAllObjects];
    
    _structs = [NSMutableDictionary dictionary];
    for (NSNumber *structId in constants.structureIdsToBeBuilltList) {
      [_structs setObject:[NSValue valueWithCGPoint:ccp(0, 0)] forKey:structId];
    }
    
    _name = @"NewUser";
  }
  return self;
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch useShortBubble:(BOOL)shortBubble buttonText:(NSString *)buttonText toViewController:(UIViewController *)vc {
  GameState *gs = [GameState sharedGameState];
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    TutorialDialogueSpeaker speaker = [dialogue[i] intValue];
    NSString *speakerText = dialogue[i+1];
    
    int monsterId = 0;
    BOOL isLeftSide = NO;
    NSString *suffix = @"Tut";
    switch (speaker) {
      case TutorialDialogueSpeakerGuide:
        monsterId = self.constants.guideMonsterId;
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerGuide2:
        monsterId = self.constants.guideMonsterId;
        suffix = [@"P2" stringByAppendingString:suffix];
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerGuide3:
        monsterId = self.constants.guideMonsterId;
        suffix = [@"P3" stringByAppendingString:suffix];
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend:
        monsterId = self.constants.startingMonsterId;
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend2:
        monsterId = self.constants.startingMonsterId;
        suffix = [@"P2" stringByAppendingString:suffix];
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerFriend3:
        monsterId = self.constants.startingMonsterId;
        suffix = [@"P3" stringByAppendingString:suffix];
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerMark:
        monsterId = self.constants.markZmonsterId;
        isLeftSide = YES;
        break;
      case TutorialDialogueSpeakerEnemy:
        monsterId = self.constants.enemyMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemy2:
        monsterId = self.constants.enemyMonsterId;
        suffix = [@"P2" stringByAppendingString:suffix];
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyTwo:
        monsterId = self.constants.enemyMonsterIdTwo;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyBoss:
        monsterId = self.constants.enemyBossMonsterId;
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyBoss2:
        monsterId = self.constants.enemyBossMonsterId;
        suffix = [@"P2" stringByAppendingString:suffix];
        isLeftSide = NO;
        break;
      case TutorialDialogueSpeakerEnemyBoss3:
        monsterId = self.constants.enemyBossMonsterId;
        suffix = [@"P3" stringByAppendingString:suffix];
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
  
  DialogueViewController *dvc;
  if (!self.dialogueViewController) {
    dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:shortBubble buttonText:buttonText];
    dvc.delegate = self;
    [vc addChildViewController:dvc];
    [vc.view insertSubview:dvc.view belowSubview:self.touchView];
    dvc.view.frame = vc.view.bounds;
    self.dialogueViewController = dvc;
    
    [self.touchView addResponder:self.dialogueViewController];
  } else {
    dvc = self.dialogueViewController;
    [dvc extendDialogue:dp.build];
    [dvc animateNext];
  }
  
  self.touchView.userInteractionEnabled = !allowTouch;
  self.dialogueViewController.view.userInteractionEnabled = allowTouch;
  
  dvc.bottomGradient.hidden = !allowTouch;
}

- (void) displayDialogue:(NSArray *)dialogue allowTouch:(BOOL)allowTouch useShortBubble:(BOOL)shortBubble {
  [self displayDialogue:dialogue allowTouch:allowTouch useShortBubble:shortBubble buttonText:nil toViewController:self.gameViewController];
}

- (void) beginTutorial {
  [self.gameViewController.topBarViewController.mainView setHidden:YES];
  [self.gameViewController.topBarViewController.chatBottomView setHidden:YES];
  
  self.touchView = [[TutorialTouchView alloc] initWithFrame:self.gameViewController.view.bounds];
  [self.gameViewController.view addSubview:self.touchView];
  [self.touchView addResponder:[CCDirector sharedDirector].view];
  self.touchView.userInteractionEnabled = NO;
  
  //[self createCloseButton];
  
#ifdef DEBUG
  [self initHomeMap];
  [self beginGuideGreetingPhase];
  //[self beginEnterBattlePhase];
  //[self beginPostBattleConfrontation];
  //[self initTopBar];
  //[self beginFacebookLoginPhase];
  //[self beginFacebookRejectedNamingPhase];
#else
  [self initHomeMap];
  [self beginGuideGreetingPhase];
#endif
  
  [[SoundEngine sharedSoundEngine] playMissionMapMusic];
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
  [dir replaceScene:scene];
}

- (void) initBattleLayer {
  self.battleLayer = [[TutorialBattleOneLayer alloc] initWithConstants:self.constants enemyDamageDealt:_damageDealtToFriend];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
}

- (void) initTopBar {
  if (!self.topBarViewController) {
    self.topBarViewController = [[TutorialTopBarViewController alloc] init];
    self.topBarViewController.delegate = self;
    self.topBarViewController.view.frame = self.gameViewController.view.bounds;
    self.topBarViewController.mainView.hidden = YES;
    [self.gameViewController addChildViewController:self.topBarViewController];
    [self.gameViewController.view insertSubview:self.topBarViewController.view belowSubview:self.touchView];
    [self.topBarViewController displayMenuButton];
    [self.topBarViewController displayCoinBars];
    
    // Have to do this for some reason..
    [self.topBarViewController viewWillAppear:YES];
  }
}

- (void) initHealViewController {
  self.healViewController = [[TutorialHealViewController alloc] initWithTutorialConstants:self.constants damageDealt:_damageDealtToFriend hospitalHealSpeed:_hospitalHealSpeed];
  self.healViewController.delegate = self;
  self.homeViewController = [[TutorialHomeViewController alloc] initWithSubViewController:self.healViewController];
  [self.homeViewController displayInParentViewController:self.gameViewController];
  [self.gameViewController.view bringSubviewToFront:self.dialogueViewController.view];
}

- (void) initBuildingViewController:(int)structId {
  self.buildingViewController = [[TutorialBuildingViewController alloc] initWithTutorialConstants:self.constants curStructs:self.homeMap.myStructs];
  [self.buildingViewController allowPurchaseOfStructId:structId];
  self.buildingViewController.delegate = self;
  ShopViewController *svc = [[TutorialShopViewController alloc] initWithBuildingViewController:self.buildingViewController];
  [svc displayInParentViewController:self.topBarViewController];
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
  GameViewController *gvc = self.gameViewController;
  TutorialAttackMapViewController *amvc = [[TutorialAttackMapViewController alloc] init];
  [amvc allowClickOnCityId:1];
  amvc.delegate = self;
  [gvc addChildViewController:amvc];
  amvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:amvc.view];
  self.attackMapViewController = amvc;
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
  [self.gameViewController.topBarViewController.chatBottomView setHidden:NO];
  
  [self.touchView removeFromSuperview];
}

- (void) tutorialFinished {
  [self cleanup];
  
  CCScene *scene = [CCScene node];
  HomeMap *hm = [HomeMap node];
  [scene addChild:hm];
  [hm moveToCenterAnimated:NO];
  self.gameViewController.currentMap = hm;
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
      [self enterDungeon:_taskIdToEnter isEvent:NO eventId:0 useGems:NO];
    }
  } else {
    [self facebookStartupReceived:proto];
  }
}

#pragma mark - Skipping Tutorial

- (void) createCloseButton {
  self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.closeButton setImage:[Globals imageNamed:@"close1.png"] forState:UIControlStateNormal];
  self.closeButton.frame = CGRectMake(4, 4, 30, 30);
  [self.gameViewController.view addSubview:self.closeButton];
  [self.closeButton addTarget:self action:@selector(skipToNamePhase) forControlEvents:UIControlEventTouchUpInside];
  
  [self performSelector:@selector(removeCloseButton) withObject:nil afterDelay:10.f];
}

- (void) removeCloseButton {
  [self.closeButton removeFromSuperview];
}

- (void) skipToNamePhase {
  [GenericPopupController displayConfirmationWithDescription:@"Would you like to skip the tutorial?" title:@"Skip Tutorial?" okayButton:@"Skip" cancelButton:@"Cancel" target:self selector:@selector(doSkip)];
}

- (void) doSkip {
  [self removeCloseButton];
  
  [self.dialogueViewController.view removeFromSuperview];
  [self.dialogueViewController removeFromParentViewController];
  self.dialogueViewController = nil;
  
  [self initTopBar];
  [self beginFacebookRejectedNamingPhase];
}

#pragma mark - Tutorial Sequence

- (void) beginGuideGreetingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerGuide2), @"Hey Boss! We’ve been expecting you!",
                        @(TutorialDialogueSpeakerGuide2), @"An evil dictator named Lil’ Kim has taken over the world and it’s up to you to stop him!",
                        @(TutorialDialogueSpeakerGuide2), @"Hopefully they don’t find..."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  [self.homeMap centerOnGuide];
  
  _currentStep = TutorialStepGuideGreeting;
}

- (void) beginEnemyTeamDisembarkPhase {
  [self.homeMap landBoatOnShore];
  
  _currentStep = TutorialStepEnemyTeamDisembark;
}

- (void) beginEnemyBossThreatPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss3), @"Well well well... you peasants think you can start a new squad, under my watch?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepEnemyBossThreat;
}

- (void) beginEnemyTwoThreatPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyTwo), @"Heh, did you really EGG-spect us not to find you here?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepEnemyTwoThreat;
}

- (void) beginGuideScaredPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerGuide3), @"Oh no. It’s Lil’ Kim! Send my nephew into battle, Boss! I don’t like him anyways."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepGuideScared;
}

- (void) beginFriendEnterFightPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend2), @"Yolo."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES buttonText:@"FIGHT" toViewController:self.gameViewController];
  
  _currentStep = TutorialStepFriendEnterFight;
}

- (void) beginEnterBattlePhase {
  [self.homeMap friendRunForBattleEnter];
  
  [self performSelector:@selector(initBattleLayer) withObject:nil afterDelay:0.3];
  
  _currentStep = TutorialStepEnteredBattle;
}

- (void) beginFriendTauntPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Who wants a piece of Swaggy?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  //[self.battleLayer enemyJumpAndShoot];
  
  _currentStep = TutorialStepBattleFriendTaunt;
}

- (void) beginEnemyTauntPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy), @"Lemme at 'em boss! I ain’t chicken.",
                        @(TutorialDialogueSpeakerEnemyTwo), @"......"];
  
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepBattleEnemyTaunt;
}

- (void) beginEnemyDefensePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemy2), @"OW! Can’t take a joke chicken? Don’t make me fry..."];
  
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  self.dialogueViewController.leftImageView.transform = CGAffineTransformMakeScale(-1, 1);
  
  _currentStep = TutorialStepBattleEnemyDefense;
}

- (void) beginEnemyBossAngryPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"Enough you two! Take care of this degenerate, Pépé."];
  
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepBattleEnemyBossAngry;
}

- (void) beginFirstBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend2), @"Yo dawg, movin’ orbs ain’t my style. Help a brotha out."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleFirstMove;
}

- (void) beginFirstBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Smooth move homie! The more orbs you break, the stronger I get."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleSecondMove;
}

- (void) beginFirstBattleFinalMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Dope! You got one last move before I make it rain. You got this!"];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepFirstBattleLastMove;
}

- (void) beginSecondBattleEnemyBossTauntPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss2), @"Sigh, never leave a man to do a chicken’s work. Take him out Drumstix."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleEnemyBossTaunt;
}

- (void) beginSecondBattleFirstMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend2), @"Yo, this chicken is savage. Create a power-up by matching 4 orbs."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleFirstMove;
}

- (void) beginSecondBattleSecondMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"Swipe the striped orb down to activate the power-up."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleSecondMove;
}

- (void) beginSecondBattleThirdMovePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend), @"BALLIN’! You got one last move homie."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleThirdMove;
}

- (void) beginSecondBattleSwapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerFriend3), @"Yolo... ain’t... the... motto.",
                        @(TutorialDialogueSpeakerMark), @"*Poke*",
                        @(TutorialDialogueSpeakerMark), @"Hey buddy, you don’t look so good. Would you “Like” me to help you out?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  [self.battleLayer friendKneel];
  
  _currentStep = TutorialStepSecondBattleSwap;
}

- (void) beginSecondBattleKillPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Oops, let me update my BookFace status before we begin.",
                        @(TutorialDialogueSpeakerEnemyTwo), @"......",
                        @(TutorialDialogueSpeakerMark), @"\"Currently saving a stranger who got owned by a chicken. #LOL #GoodGuyZark\"",
                        @(TutorialDialogueSpeakerMark), @"Heh, 12 likes already. Alright, let’s do this."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  _currentStep = TutorialStepSecondBattleKillEnemy;
}

- (void) beginPostBattleConfrontation {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerEnemyBoss), @"Ohhh, bet you feel like a big man beating a chicken. This isn’t over, I’ll be back!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:YES];
  
  [self.homeMap beginPostBattleConfrontation];
  
  _currentStep = TutorialStepPostBattleConfrontation;
}

- (void) beginEnterHospitalPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerGuide2), @"Whew! That was a close one. Thanks for the help Zark!",
                        @(TutorialDialogueSpeakerMark), @"No problem buddy, but in case you didn’t notice, your nephew is kinda... dying.",
                        @(TutorialDialogueSpeakerMark), @"Let’s head to the Hospital and get him healed right up. Follow the magical floating arrows to begin."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterHospital;
}

- (void) beginHealQueueingPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Tap on Swaggy Steve to insert him into the healing queue."];
  [self displayDialogue:dialogue allowTouch:NO useShortBubble:NO];
  
  [self.homeMap moveFriendsOffBuildableMap];
  
  [self.healViewController allowCardClick];
  
  _currentStep = TutorialStepBeginHealQueue;
}

- (void) beginSpeedupHealQueuePhase {
  [self.healViewController allowSpeedup];
  
  _currentStep = TutorialStepSpeedupHealQueue;
}

- (void) beginHospitalExitPhase {
  [self.healViewController allowClose];
  
  _currentStep = TutorialStepExitHospital;
}

- (void) beginBuildingOnePhase {
  [self initTopBar];
  [self.homeMap zoomOutMap];
  
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"If you’re going to try and fight Lil’ Kim and his men, you’ll need a war chest of cash.",
                        @(TutorialDialogueSpeakerMark), @"What better way to make money than to print it? Build a Cash Printer now!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepBeginBuildingOne;
}

- (void) beginSpeedupBuildingOnePhase {
  [self.homeMap speedupPurchasedBuilding];
  
  _currentStep = TutorialStepSpeedupBuildingOne;
}

- (void) beginBuildingTwoPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Nice job! The Printer can only store a small amount of cash, so we’ll need a Vault to stash the rest of it.",
                        @(TutorialDialogueSpeakerMark), @"Amazon doesn’t ship to secret islands, so let’s construct one ourselves now."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepBeginBuildingTwo;
}

- (void) beginSpeedupBuildingTwoPhase {
  [self.homeMap speedupPurchasedBuilding];
  
  _currentStep = TutorialStepSpeedupBuildingTwo;
}

- (void) beginBuildingThreePhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Good work! The Vault will protect your money from being stolen, so remember to upgrade it!",
                        @(TutorialDialogueSpeakerMark), @"Another important resource is Oil, which is used to upgrade your mobsters and buildings.",
                        @(TutorialDialogueSpeakerMark), @"We'll need a place to store the oil you drill, so construct an Oil Silo now!"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepBeginBuildingThree;
}

- (void) beginSpeedupBuildingThreePhase {
  [self.homeMap speedupPurchasedBuilding];
  
  _currentStep = TutorialStepSpeedupBuildingThree;
}

- (void) beginFacebookLoginPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Great job! The Silo will now protect your oil from being stolen in battle.",
                        @(TutorialDialogueSpeakerMark), @"Your island is starting to look like a real secret base! There’s just one last thing...",
                        @(TutorialDialogueSpeakerMark), @"I just met you, and this is crazy, but here’s my friend request, so add me maybe?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepFacebookLogin;
}

- (void) beginFacebookRejectedNamingPhase {
  [self cacheKeyboard];
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Playing hard to get huh? I can play that game too. What was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterName;
}

- (void) beginFacebookAcceptedNamingPhase {
  [self cacheKeyboard];
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Hurray! I know that we’re besties now, but what was your name again?"];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepEnterName;
}

- (void) beginAttackMapPhase {
  NSArray *dialogue = @[@(TutorialDialogueSpeakerMark), @"Is that really on your birth certificate? Seems legit I guess.",
                        @(TutorialDialogueSpeakerGuide2), @"Yippee! Now let's go recruit some mobsters to join your team."];
  [self displayDialogue:dialogue allowTouch:YES useShortBubble:NO];
  
  _currentStep = TutorialStepAttackMap;
}

#pragma mark - BattleLayer delegate

- (void) battleLayerReachedEnemy {
  if (_currentStep == TutorialStepEnteredBattle) {
    [self beginFriendTauntPhase];
  } else if (_currentStep == TutorialStepFirstBattleLastMove) {
    [self beginSecondBattleEnemyBossTauntPhase];
  }
}

- (void) enemyJumpedAndShot {
  if (_currentStep == TutorialStepBattleFriendTaunt) {
    [self beginEnemyTauntPhase];
  }
}

- (void) enemyTwoHitEnemy {
  if (_currentStep == TutorialStepBattleEnemyTaunt) {
    [self beginEnemyDefensePhase];
  }
}

- (void) enemyBossStomped {
  if (_currentStep == TutorialStepBattleEnemyDefense) {
    [self beginEnemyBossAngryPhase];
  }
}

- (void) enemiesRanOut {
  if (_currentStep == TutorialStepBattleEnemyBossAngry) {
    [self beginFirstBattleFirstMovePhase];
  } else if (_currentStep == TutorialStepSecondBattleEnemyBossTaunt) {
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
  if (_currentStep == TutorialStepSecondBattleKillEnemy) {
    [self beginPostBattleConfrontation];
  }
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:0.6f]];
  [self.gameViewController showTopBarDuration:0.f completion:nil];
  
  [[SoundEngine sharedSoundEngine] playHomeMapMusic];
}

#pragma mark - HomeMap delegate

- (void) boatLanded {
  [self beginEnemyBossThreatPhase];
}

- (void) enemyTwoJumped {
  [self beginEnemyTwoThreatPhase];
}

- (void) guideReachedHideLocation {
  [self beginGuideScaredPhase];
}

- (void) friendEntered {
  [self beginFriendEnterFightPhase];
}

- (void) enemyTeamWalkedOut {
  [self.homeMap guideRunToMark];
}



- (void) guideRanToMark {
  [self beginEnterHospitalPhase];
}

- (void) enterHospitalClicked {
  // healOpened will be called when this completes
  [self initHealViewController];
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

#pragma mark - HealViewController delegate

- (void) healOpened {
  [self beginHealQueueingPhase];
}

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

- (void) healClosed {
  [self beginBuildingOnePhase];
}

#pragma mark - TopBar delegate

- (void) menuClicked {
  int structId = 0;
  if (_currentStep == TutorialStepBeginBuildingOne) {
    structId = [self.constants.structureIdsToBeBuilltList[0] intValue];
  } else if (_currentStep == TutorialStepBeginBuildingTwo) {
    structId = [self.constants.structureIdsToBeBuilltList[1] intValue];
  } else if (_currentStep == TutorialStepBeginBuildingThree) {
    structId = [self.constants.structureIdsToBeBuilltList[2] intValue];
  }
  [self initBuildingViewController:structId];
  
  [self.dialogueViewController animateNext];
}

- (void) attackClicked {
  [self initAttackMapViewController];
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
    [self.dialogueViewController animateNext];
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
  [self.dialogueViewController animateNext];
  [self cleanup];
  [self.gameViewController reloadAccountWithStartupResponse:self.facebookStartupResponse];
}

- (void) swapRejected {
  [FacebookDelegate logout];
  [self.dialogueViewController endFbSpinning];
  [self.facebookViewController allowClick];
  _waitingOnFacebook = NO;
}

#pragma mark - Name delegate

- (void) nameChosen:(NSString *)name {
  _name = name;
  [self beginAttackMapPhase];
  
  [self sendUserCreate];
}

#pragma mark - AttackMap delegate

- (void) enterDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems {
  if (_currentStep == TutorialStepAttackMap) {
    if (self.userCreateStartupResponse) {
      // Will be auto closed by game view controller
      //[self.attackMapViewController close];
      
      [self tutorialFinished];
      [self.gameViewController enterDungeon:taskId isEvent:isEvent eventId:eventId useGems:useGems];
    } else {
      [Globals addAlertNotification:@"Hold on, we're still creating your account!"];
      _waitingOnUserCreate = YES;
      _taskIdToEnter = taskId;
    }
  }
}

#pragma mark - DialogueViewController delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialStepSecondBattleKillEnemy && index == 3) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    [dvc fadeOutBottomGradient];
  }  else if ((_currentStep == TutorialStepBeginBuildingOne ||
               _currentStep == TutorialStepBeginBuildingTwo ||
               _currentStep == TutorialStepBeginBuildingThree) &&
              index == dvc.dialogue.speechSegmentList.count-1) {
    dvc.view.userInteractionEnabled = NO;
    [dvc fadeOutBottomGradient];
  } else if (_currentStep == TutorialStepBeginBuildingThree && index == 1) {
    [self.homeMap moveToOilDrill];
  } else if (_currentStep == TutorialStepFacebookLogin && index == 1) {
    [self.homeMap panToMark];
  } else if (_currentStep == TutorialStepBattleEnemyTaunt && index == 1) {
    [self.battleLayer enemyTwoLookAtEnemy];
  } else if (_currentStep == TutorialStepFacebookLogin && index == dvc.dialogue.speechSegmentList.count-1) {
    //[dvc showFbButtonView];
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
    }
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  // Make sure we haven't moved to the next step yet
  if (self.dialogueViewController == dvc) {
    if (_currentStep == TutorialStepGuideGreeting) {
      [self beginEnemyTeamDisembarkPhase];
    } else if (_currentStep == TutorialStepEnemyBossThreat) {
      [self.homeMap enemyTwoJump];
    } else if (_currentStep == TutorialStepEnemyTwoThreat) {
      [self.homeMap guideHideBehindObstacle];
    } else if (_currentStep == TutorialStepGuideScared) {
      [self.homeMap friendEnterScene];
    } else if (_currentStep == TutorialStepBattleFriendTaunt) {
      [self.battleLayer enemyJumpAndShoot];
    } else if (_currentStep == TutorialStepBattleEnemyTaunt) {
      [self.battleLayer enemyTwoAttackEnemy];
    } else if (_currentStep == TutorialStepBattleEnemyDefense) {
      [self.battleLayer enemyBossStomp];
    } else if (_currentStep == TutorialStepBattleEnemyBossAngry) {
      [self.battleLayer enemyTwoAndBossRunOut];
    } else if (_currentStep == TutorialStepSecondBattleEnemyBossTaunt) {
      [self.battleLayer enemyBossWalkOut];
    } else if (_currentStep == TutorialStepPostBattleConfrontation) {
      [self.homeMap walkOutEnemyTeam];
    } else if (_currentStep == TutorialStepSecondBattleSwap) {
      [self.battleLayer swapToMark];
    } else if (_currentStep == TutorialStepEnterHospital) {
      [self.homeMap walkToHospitalAndEnter];
    } else if (_currentStep == TutorialStepFacebookLogin) {
      if (!_waitingOnFacebook) {
        [self initFacebookViewController];
      }
    } else if (_currentStep == TutorialStepEnterName) {
      [self initNameViewController];
    } else if (_currentStep == TutorialStepAttackMap) {
      [self.topBarViewController allowAttackClick];
    }
    
    [self.touchView removeResponder:self.dialogueViewController];
    self.touchView.userInteractionEnabled = NO;
    
    self.dialogueViewController = nil;
  }
}

- (void) dialogueViewControllerButtonClicked:(DialogueViewController *)dvc {
  if (_currentStep == TutorialStepFriendEnterFight) {
    [self.dialogueViewController animateNext];
    [self beginEnterBattlePhase];
  } else if (_currentStep == TutorialStepFacebookLogin) {
    if (!_waitingOnFacebook) {
      _waitingOnFacebook = YES;
      [dvc beginFbSpinning];
      [FacebookDelegate openSessionWithLoginUI:YES completionHandler:^(BOOL success) {
        if (success) {
          [self facebookConnectAccepted];
        } else {
          [dvc endFbSpinning];
          _waitingOnFacebook = NO;
        }
      }];
    }
  }
}

- (void) dealloc {
  self.dialogueViewController.delegate = nil;
}

@end
