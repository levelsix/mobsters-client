//
//  TutorialEnhanceController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TutorialEnhanceController.h"

#import "GameState.h"
#import "Globals.h"
#import "GameViewController.h"

#import "SocketCommunication.h"
#import "OutgoingEventController.h"

@implementation TutorialEnhanceController

- (id) initWithBaseMonster:(UserMonster *)bm feeder:(UserMonster *)f gameViewController:(GameViewController *)gvc {
  if ((self = [super init])) {
    self.baseUserMonster = bm;
    self.feederUserMonster = f;
    self.gameViewController = gvc;
  }
  return self;
}

- (void) begin {
  [super begin];
  
  [self upgradeLaboratory];
  [self healMyTeam];
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [self initHomeMap];
  
  Globals *gl = [Globals sharedGlobals];
  self.speakerMonsterId = gl.miniTutorialConstants.enhanceGuideMonsterId;
  
  self.gameViewController.topBarViewController.mainView.hidden = YES;
  self.gameViewController.topBarViewController.chatBottomView.hidden = YES;
  
  [self beginClickBuildingPhase];
}

- (void) upgradeLaboratory {
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = [gs myLaboratory];
  
  if ([us satisfiesAllPrerequisites] && us.staticStructForNextLevel.structInfo.buildCost <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] upgradeAndCompleteFreeBuilding:us];
  }
}

- (void) healMyTeam {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *myTeam = [gs allBattleAvailableMonstersOnTeamWithClanSlot:NO];
  
  for (UserMonster *um in myTeam) {
    [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:um.userMonsterUuid curHealth:[gl calculateMaxHealthForMonster:um]];
  }
}

- (void) stop {
  [self.topBarViewController.view removeFromSuperview];
  [self.topBarViewController removeFromParentViewController];
  
  [self.gameViewController visitCityClicked:0];
  self.gameViewController.topBarViewController.mainView.hidden = NO;
  self.gameViewController.topBarViewController.chatBottomView.hidden = NO;
  [self.delegate miniTutorialComplete:self];
}

- (void) initHomeMap {
  GameState *gs = [GameState sharedGameState];
  CCScene *scene = [CCScene node];
  TutorialHomeMap *homeMap = [[TutorialHomeMap alloc] init];
  homeMap.delegate = self;
  homeMap.myStructs = gs.myStructs;
  homeMap.cityId = -1;
  [scene addChild:homeMap];
  [homeMap refresh];
  [homeMap moveToCenterAnimated:NO];
  self.homeMap = homeMap;
  self.gameViewController.currentMap = homeMap;
  
  CCDirector *dir = [CCDirector sharedDirector];
  [dir popToRootScene];
  [dir replaceScene:scene];
}

- (void) initChooserViewController {
  self.chooserViewController = [[TutorialEnhanceChooserViewController alloc] init];
  self.chooserViewController.delegate = self;
  self.homeViewController = [[TutorialHomeViewController alloc] initWithSubViewController:self.chooserViewController];
  [self.homeViewController displayInParentViewController:self.gameViewController];
  self.homeViewController.mainView.centerY = self.homeViewController.view.height/2;
  [self.gameViewController.view bringSubviewToFront:self.dialogueViewController.view];
}

- (void) initQueueViewController {
  self.queueViewController = [[TutorialEnhanceQueueViewController alloc] initWithBaseMonster:self.baseUserMonster];
  self.queueViewController.delegate = self;
  [self.homeViewController pushViewController:self.queueViewController animated:YES];
}

- (void) initTopBar {
  self.topBarViewController = [[TutorialTopBarViewController alloc] init];
  self.topBarViewController.delegate = self;
  self.topBarViewController.view.frame = self.gameViewController.view.bounds;
  self.topBarViewController.mainView.hidden = YES;
  [self.gameViewController addChildViewController:self.topBarViewController];
  [self.gameViewController.view addSubview:self.topBarViewController.view];
  
  // Have to do this for some reason..
  [self.topBarViewController viewWillAppear:YES];
}

#pragma mark - Sequence

- (void) beginClickBuildingPhase {
  [self.homeMap moveToLab];
  
  NSArray *dialogue = @[@"Greetings simpleton! My laboratory is now open for business.",
                        @"The lab is the only place where you can level up your toons. Care to take a tour?"];
  [self displayDialogue:dialogue];
  
  self.currentStep = TutorialEnhanceStepClickBuilding;
}

- (void) beginChooseBasePhase {
  [self.chooserViewController allowChoose:self.baseUserMonster.userMonsterUuid];
  
  NSArray *dialogue = @[[NSString stringWithFormat:@"So which of your weaklings could use a few levels? How about %@?", self.baseUserMonster.staticMonster.displayName]];
  [self displayDialogue:dialogue];
  
  self.currentStep = TutorialEnhanceStepChooseBase;
}

- (void) beginChooseFeederPhase {
  
  NSArray *dialogue = @[[NSString stringWithFormat:@"Excellent! Now we need to sacrifice a %@ and fuse its power into %@.", MONSTER_NAME, self.baseUserMonster.staticMonster.displayName]];
  [self displayDialogue:dialogue isLeftSide:YES];
  
  self.currentStep = TutorialEnhanceStepChooseFeeder;
}

- (void) beginAttackMapPhase {
  NSArray *dialogue = @[[NSString stringWithFormat:@"Splendid! Now let’s take your improved %@ out for a spin.", MONSTER_NAME],
                        [NSString stringWithFormat:@"I've healed your %@s for you — off to battle you go now!", MONSTER_NAME]];
  [self displayDialogue:dialogue isLeftSide:NO];
  
  self.currentStep = TutorialEnhanceStepAttackMap;
}

#pragma mark - Home Map Delegate

- (void) enterLabClicked {
  [self initChooserViewController];
}

- (void) chooserOpened {
  [self beginChooseBasePhase];
}

- (void) choseMonster {
  [self initQueueViewController];
  [self.queueViewController allowChoose:self.feederUserMonster.userMonsterUuid];
}

- (void) queueOpened {
  if (self.currentStep == TutorialEnhanceStepChooseBase) {
    [self beginChooseFeederPhase];
  }
}

- (void) choseFeeder {
  [self.queueViewController allowEnhance];
}

- (void) beganEnhance {
  [self.queueViewController allowFinish];
}

- (void) finishedEnhance {
  [self.queueViewController allowClose];
}

- (void) queueClosed {
  [self beginAttackMapPhase];
}

- (void) attackClicked {
  self.dialogueViewController.delegate = nil;
  [self.dialogueViewController animateNext];
  [self.gameViewController.topBarViewController attackClicked:nil];
  [self performSelector:@selector(stop) withObject:nil afterDelay:1.f];
}

#pragma mark - Dialogue Delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  [super dialogueViewController:dvc willDisplaySpeechAtIndex:index];
  
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    
    if (self.currentStep == TutorialEnhanceStepClickBuilding) {
      [self.homeMap arrowOnLab];
    } else if (self.currentStep == TutorialEnhanceStepAttackMap) {
      [self initTopBar];
      [self.topBarViewController allowAttackClick];
    }
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
}

@end
