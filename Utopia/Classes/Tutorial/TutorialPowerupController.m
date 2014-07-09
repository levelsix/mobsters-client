//
//  TutorialPowerupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialPowerupController.h"
#import "GameState.h"
#import "OutgoingEventController.h"

@implementation TutorialPowerupController

- (void) initBattleLayer {
  self.battleLayer = [[TutorialPowerupBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO gridSize:CGSizeMake(6, 6)];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:gl.miniTutorialConstants.cityId assetId:gl.miniTutorialConstants.matchThreeTutorialAssetId];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"Power-ups are key to making strong attacks. Combine 4 orbs in a line to make a striped orb."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialPowerupStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[@"We’re not finished yet. Swipe the striped orb up to activate the power-up."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialPowerupStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[@"Bada bing, bada boom. It all comes down to this last move."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialPowerupStepThirdMove;
}

- (void) beginKillEnemy {
  NSArray *dialogue = @[@"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialPowerupStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  if (_currentStep == 0) {
    [self beginFirstMove];
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialPowerupStepFirstMove) {
    [self beginSecondMove];
  } else if (_currentStep == TutorialPowerupStepSecondMove) {
    [self beginThirdMove];
  } else if (_currentStep == TutorialPowerupStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialPowerupStepThirdMove) {
    [self beginKillEnemy];
  } if (_currentStep == TutorialPowerupStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialPowerupStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialPowerupStepSecondMove) {
      [self.battleLayer beginSecondMove];
    } else {
      [self.battleLayer allowMove];
    }
  }
}

@end
