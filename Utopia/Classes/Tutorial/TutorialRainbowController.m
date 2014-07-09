//
//  TutorialRainbowController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialRainbowController.h"
#import "GameState.h"
#import "OutgoingEventController.h"

@implementation TutorialRainbowController

- (void) initBattleLayer {
  self.battleLayer = [[TutorialRainbowBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO gridSize:CGSizeMake(6, 6)];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:gl.miniTutorialConstants.cityId assetId:gl.miniTutorialConstants.rainbowTutorialAssetId];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"When you’re weaker than your opponent, you can still beat him with power-ups.",
                        @"A rainbow orb is the best power-up you can create, so match 5 orbs to make one now!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialRainbowStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[@"Good work. A rainbow orb will completely destroy one element off the board. Activate it now!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialRainbowStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[@"Boom baby! This last move is up to you!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialRainbowStepThirdMove;
}

- (void) beginKillEnemy {
  NSArray *dialogue = @[@"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialRainbowStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  if (_currentStep == 0) {
    [self beginFirstMove];
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialRainbowStepFirstMove) {
    [self beginSecondMove];
  } else if (_currentStep == TutorialRainbowStepSecondMove) {
    [self beginThirdMove];
  } else if (_currentStep == TutorialRainbowStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialRainbowStepThirdMove) {
    [self beginKillEnemy];
  } if (_currentStep == TutorialRainbowStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialRainbowStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialRainbowStepSecondMove) {
      [self.battleLayer beginSecondMove];
    } else {
      [self.battleLayer allowMove];
    }
  }
}

@end
