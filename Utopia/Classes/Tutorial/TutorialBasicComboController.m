//
//  TutorialBasicComboController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBasicComboController.h"
#import "GameState.h"
#import "OutgoingEventController.h"

@implementation TutorialBasicComboController

- (void) initBattleLayer {
  self.battleLayer = [[TutorialBasicComboBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO gridSize:CGSizeMake(6, 6)];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:gl.miniTutorialConstants.cityId assetId:gl.miniTutorialConstants.matchThreeTutorialAssetId];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"This is Candy Crush on steroids. Match 3 orbs by swiping this one to the right."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialBasicComboStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[@"Nice! The more orbs you break, the stronger I get. Let’s try another."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialBasicComboStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[@"Good job! You have 1 move left before I attack. Make it count."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialBasicComboStepThirdMove;
}

- (void) beginKillEnemy {
  NSArray *dialogue = @[@"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialBasicComboStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  if (_currentStep == 0) {
    [self beginFirstMove];
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialBasicComboStepFirstMove) {
    [self beginSecondMove];
  } else if (_currentStep == TutorialBasicComboStepSecondMove) {
    [self beginThirdMove];
  } else if (_currentStep == TutorialBasicComboStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialBasicComboStepThirdMove) {
    [self beginKillEnemy];
  } if (_currentStep == TutorialBasicComboStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialBasicComboStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialBasicComboStepSecondMove) {
      [self.battleLayer beginSecondMove];
    } else {
      [self.battleLayer allowMove];
    }
  }
}

@end