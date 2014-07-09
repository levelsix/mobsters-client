//
//  TutorialTeamController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialTeamController.h"

#import "GameState.h"
#import "GameViewController.h"
#import "Globals.h"

@implementation TutorialTeamController

- (void) displayTeamDialogue:(NSArray *)dialogue {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    BOOL isLootGuy = [dialogue[i] boolValue];
    MonsterProto *mp = [gs monsterWithId:isLootGuy ? self.lootMonsterId : self.speakerMonsterId];
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

- (void) initTeamViewController {
  self.teamViewController = [[TutorialTeamViewController alloc] init];
  self.teamViewController.delegate = self;
  self.homeViewController = [[TutorialHomeViewController alloc] initWithSubViewController:self.teamViewController];
  [self.homeViewController displayInParentViewController:self.gameViewController];
  [self.gameViewController.view bringSubviewToFront:self.dialogueViewController.view];
}

- (void) beginClickBuildingPhase {
  NSArray *dialogue = @[@NO, @"Yippee! You caught your first Toon! Click here to equip him."];
  [self displayTeamDialogue:dialogue];
  
  [self.homeMap moveToTeamCenter];
  
  _currentStep = TutorialTeamStepClickBuilding;
}

- (void) beginEquipPhase {
  [self initTeamViewController];
  
  _currentStep = TutorialTeamStepEquip;
}

- (void) beginClosePhase {
  NSArray *dialogue = @[@YES, @"I'm ready Boss! Head to battle now and give me a spin!"];
  [self displayTeamDialogue:dialogue];
  
  [self.teamViewController allowClose];
  
  _currentStep = TutorialTeamStepEquip;
}

- (void) teamCenterClicked {
  [self.dialogueViewController animateNext];
}

- (void) teamOpened {
  [self.teamViewController allowEquip:self.lootUserMonsterId];
}

- (void) enterTeamCenterClicked {
  [self beginEquipPhase];
}

- (void) addedMobsterToTeam {
  [self beginClosePhase];
}

- (void) teamClosed {
  [self.dialogueViewController animateNext];
  [self stop];
}

@end
