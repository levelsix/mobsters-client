//
//  MiniTutorialController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "GameState.h"
#import "GameViewController.h"

@implementation MiniTutorialController

+ (id) miniTutorialForCityId:(int)cityId assetId:(int)assetId gameViewController:(GameViewController *)gvc {
//  GameState *gs = [GameState sharedGameState];
//  Globals *gl = [Globals sharedGlobals];
//  StartupResponseProto_StartupConstants_MiniTutorialConstants *miniTuts = gl.miniTutorialConstants;
//  
//  NSArray *myTeam = gs.allMonstersOnMyTeam;
  MiniTutorialController *mtc = nil;
//  if (cityId == miniTuts.cityId) {
//    if (assetId == miniTuts.matchThreeTutorialAssetId) {
//      mtc = [[TutorialBasicComboController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    } else if (assetId == miniTuts.firstPowerUpAssetId) {
//      mtc = [[TutorialPowerupController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    } else if (assetId == miniTuts.elementTutorialAssetId) {
//      mtc = [[TutorialElementsController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    } else if (assetId == miniTuts.rainbowTutorialAssetId) {
//      mtc = [[TutorialRainbowController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    } else if (assetId == miniTuts.powerUpComboTutorialAssetId) {
//      mtc = [[TutorialDoublePowerupController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    } else if (assetId == miniTuts.monsterDropTutorialAssetId) {
//      mtc = [[TutorialDropController alloc] initWithMyTeam:myTeam gameViewController:gvc];
//    }
//  }
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
  
  if (self.battleLayer) {
    [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  }
}

- (void) moveMade {
  // Dismiss the dialogue
  [self.dialogueViewController animateNext];
}

- (void) displayDialogue:(NSArray *)dialogue {
  [self displayDialogue:dialogue isLeftSide:YES];
}

- (void) displayDialogue:(NSArray *)dialogue isLeftSide:(BOOL)isLeftSide {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  for (NSString *speakerText in dialogue) {
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = mp.displayName;
    ss.speakerImage = mp.imagePrefix;
    ss.isLeftSide = isLeftSide;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:YES];
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view addSubview:dvc.view];
  dvc.view.frame = self.gameViewController.view.bounds;
  self.dialogueViewController = dvc;
}

- (void) battleComplete:(NSDictionary *)params {
  [self.gameViewController battleComplete:params];
  [self.delegate miniTutorialComplete:self];
}

- (void) battleLayerReachedEnemy {
  self.speakerMonsterId = self.battleLayer.myPlayerObject.monsterId;
}

- (void) stop {
  [self.dialogueViewController removeFromParentViewController];
  [self.dialogueViewController.view removeFromSuperview];
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    [dvc allowClickThrough];
  }
}

@end
