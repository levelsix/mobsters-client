//
//  MiniTutorialController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "GameState.h"
#import "TutorialElementsController.h"
#import "TutorialRainbowController.h"
#import "TutorialBasicComboController.h"
#import "TutorialDoublePowerupController.h"
#import "TutorialPowerupController.h"
#import "TutorialDropController.h"
#import "GameViewController.h"

@implementation MiniTutorialController

+ (id) miniTutorialForCityId:(int)cityId assetId:(int)assetId gameViewController:(GameViewController *)gvc {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StartupResponseProto_StartupConstants_MiniTutorialConstants *miniTuts = gl.miniTutorialConstants;
  
  NSArray *myTeam = gs.allMonstersOnMyTeam;
  MiniTutorialController *mtc = nil;
  if (cityId == miniTuts.cityId) {
    if (assetId == miniTuts.matchThreeTutorialAssetId) {
      mtc = [[TutorialBasicComboController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    } else if (assetId == miniTuts.firstPowerUpAssetId) {
      mtc = [[TutorialPowerupController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    } else if (assetId == miniTuts.elementTutorialAssetId) {
      mtc = [[TutorialElementsController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    } else if (assetId == miniTuts.rainbowTutorialAssetId) {
      mtc = [[TutorialRainbowController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    } else if (assetId == miniTuts.powerUpComboTutorialAssetId) {
      mtc = [[TutorialDoublePowerupController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    } else if (assetId == miniTuts.monsterDropTutorialAssetId) {
      mtc = [[TutorialDropController alloc] initWithMyTeam:myTeam gameViewController:gvc];
    }
  }
  return mtc;
}

- (id) initWithMyTeam:(NSArray *)myTeam gameViewController:(GameViewController *)gvc {
  if ((self = [super init])) {
    self.myTeam = myTeam;
    self.gameViewController = gvc;
  }
  return self;
}

- (void) initBattleLayer {
  // Overwrite this..
}

- (void) begin {
  [self initBattleLayer];
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  self.touchView = [[TutorialTouchView alloc] initWithFrame:self.gameViewController.view.bounds];
  [self.gameViewController.view addSubview:self.touchView];
  [self.touchView addResponder:[CCDirector sharedDirector].view];
  self.touchView.userInteractionEnabled = NO;
}

- (void) moveMade {
  // Dismiss the dialogue
  [self.dialogueViewController animateNext];
}

- (void) displayDialogue:(NSArray *)dialogue {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  for (NSString *speakerText in dialogue) {
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = mp.displayName;
    ss.speakerImage = mp.imagePrefix;
    ss.isLeftSide = YES;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:YES];
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view insertSubview:dvc.view belowSubview:self.touchView];
  self.dialogueViewController = dvc;
  
  [self.touchView addResponder:self.dialogueViewController];
}

- (void) battleComplete:(NSDictionary *)params {
  [self.gameViewController battleComplete:params];
  [self.delegate miniTutorialComplete:self];
  
  [self.touchView removeFromSuperview];
}

- (void) battleLayerReachedEnemy {
  self.speakerMonsterId = self.battleLayer.myPlayerObject.monsterId;
}

- (void) stop {
  [self.dialogueViewController removeFromParentViewController];
  [self.dialogueViewController.view removeFromSuperview];
  [self.touchView removeFromSuperview];
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    
    if (index == 0) {
      [dvc.bottomGradient removeFromSuperview];
    } else {
      [dvc fadeOutBottomGradient];
    }
  }
}


- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self.touchView removeResponder:self.dialogueViewController];
  self.touchView.userInteractionEnabled = NO;
}

@end
