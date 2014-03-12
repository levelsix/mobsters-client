//
//  TutorialDoublePowerupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialDoublePowerupController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

@implementation TutorialDoublePowerupController

- (void) initBattleLayer {
  self.battleLayer = [[TutorialDoublePowerupBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:gl.miniTutorialConstants.cityId assetId:gl.miniTutorialConstants.powerUpComboTutorialAssetId];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"If you’re going to succeed, you’ll need to learn how to combine power-ups.",
                        @"First, let’s start by creating a rainbow orb by matching these 5 green orbs."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDoublePowerupStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[@"Good work! Now let’s match these 4 red orbs to create a rocket."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDoublePowerupStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[@"I almost feel bad for that little henchman. Combine the two power-ups now!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDoublePowerupStepThirdMove;
}

- (void) beginKillEnemy {
  NSArray *dialogue = @[@"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDoublePowerupStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  if (_currentStep == 0) {
    [self beginFirstMove];
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialDoublePowerupStepFirstMove) {
    [self beginSecondMove];
  } else if (_currentStep == TutorialDoublePowerupStepSecondMove) {
    [self beginThirdMove];
  } else if (_currentStep == TutorialDoublePowerupStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialDoublePowerupStepThirdMove) {
    [self beginKillEnemy];
  } if (_currentStep == TutorialDoublePowerupStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialDoublePowerupStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialDoublePowerupStepSecondMove) {
      [self.battleLayer beginSecondMove];
    } else if (_currentStep == TutorialDoublePowerupStepThirdMove) {
      [self.battleLayer beginThirdMove];
    } else {
      [self.battleLayer allowMove];
    }
  }
}

@end
