//
//  TutorialBuildingUpgrade.m
//  Utopia
//
//  Created by Rob Giusti on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TutorialBuildingUpgradeController.h"

#import "GameState.h"
#import "GameViewController.h"
#import "Globals.h"

#import "Analytics.h"

@implementation TutorialBuildingUpgradeController

- (void) setCurrentStep:(TutorialBuildingUpgradeStep)currentStep {
  _currentStep = currentStep;
}

- (void) displayUpgradeDialogue:(NSArray *)dialogue {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
    NSString *speakerText = dialogue[i+1];
    
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = mp.displayName;
    ss.speakerImage = [mp.imagePrefix stringByAppendingString:@"Tut"];
    ss.isLeftSide = !isLootGuy;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:NO];
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view addSubview:dvc.view];
  self.dialogueViewController.view.frame = self.gameViewController.view.bounds;
  self.dialogueViewController = dvc;
  self.dialogueViewController.view.userInteractionEnabled = NO;
  [dvc.bottomGradient removeFromSuperview];
}

- (void) begin {
  [self initHomeMap];
  
  Globals *gl = [Globals sharedGlobals];
  self.speakerMonsterId = gl.miniTutorialConstants.guideMonsterId;
  
  self.gameViewController.topBarViewController.mainView.hidden = YES;
  self.gameViewController.topBarViewController.chatBottomView.hidden = YES;
  
  [self beginClickBuildingPhase];
}

- (void) stop {
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

- (void) initBuildingUpgradeViewController {
  self.upgradeViewController = [[TutorialUpgradeViewController alloc] initWithUserStruct:self.userStruct];
  self.upgradeViewController.delegate = self;
  
  [self.gameViewController addChildViewController:self.upgradeViewController];
  self.upgradeViewController.view.frame = self.gameViewController.view.bounds;
  [self.gameViewController.view addSubview:self.upgradeViewController.view];
  
  [self.gameViewController.view bringSubviewToFront:self.dialogueViewController.view];
}

- (void) beginClickBuildingPhase {
  
  NSArray *dialogue = @[@NO,
                        [NSString stringWithFormat:@"Hey %@! Looks like you've got a nice stockpile of resources! Let's upgrade your Command Center!", [GameState sharedGameState].name]];
  [self displayUpgradeDialogue:dialogue];
  
  self.userStruct = [self.homeMap moveToTownHall];
  
  self.currentStep = TutorialBuildingUpgradeStepClickBuilding;
}

- (void) beginUpgradePhase {
  [self initBuildingUpgradeViewController];
  
  self.currentStep = TutorialBuildingUpgradeStepUpgrade;
}

- (void) beginFinishPhase {
  [self.upgradeViewController close];
  
  
  NSArray *dialogue = @[@NO,
                        [NSString stringWithFormat:@"Keep on building upgrading your buildings to get better, stronger, harder, and faster!"]];
  [self displayUpgradeDialogue:dialogue];
  
  self.currentStep = TutorialBuildingUpgradeStephFinish;
}

- (void) teamCenterClicked {
  [self.dialogueViewController animateNext];
}

- (void) upgradeClicked {
  [self beginUpgradePhase];
}

- (void) upgradeViewControllerClosed{
  //Do nothing
}

- (void) buildingWasSpedUp:(int)gemsSpent{
  //Nada
}

- (void) bigUpgradeClicked:(id)sender {
  [self.homeMap bigUpgradeClicked:sender];
  [self beginFinishPhase];
}

- (void) buildingWasCompleted {
  [self.dialogueViewController animateNext];
  [self stop];
}

@end