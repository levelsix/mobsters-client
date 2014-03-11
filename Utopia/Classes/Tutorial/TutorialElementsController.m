//
//  TutorialElementsController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialElementsController.h"

#import "GameViewController.h"
#import "Protocols.pb.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "GameState.h"

@implementation TutorialElementsController

- (void) initBattleLayer {
  self.battleLayer = [[TutorialElementsBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:1 assetId:gl.miniTutorialConstants.elementTutorialAssetId];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId isEvent:NO eventId:0 useGems:NO withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"We mobsters draw our strength from the different elements on the board.",
                        @"Notice how the health bar above my head is red? It means I’m a fire-type mobster.",
                        @"Check this out. Swipe this orb down to match 3 water orbs."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[@"Weak. We only did 2 damage per orb. Now let’s see what happens when you match 3 fire orbs."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[@"Boom! You did 6 damage per orb! That’s much stronger because I’m a fire-type.",
                        @"You have one move left before I attack. Choose wisely!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepThirdMove;
}

- (void) beginShowHierarchy {
  NSArray *dialogue = @[@"Did you see that? Because I’m a fire-type, I also do extra damage versus an earth-type.",
                        @"Like \"Rock, Paper, Scissors\", each element has its own strength and weakness.",
                        @"Click here to see the elemental hierarchy, and check back if you ever forget."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepHierarchy;
}

- (void) beginKillEnemy {
  NSArray *dialogue = @[@"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  [self beginFirstMove];
}

- (void) moveMade {
  // Dismiss the dialogue
  [self.dialogueViewController animateNext];
}

- (void) moveFinished {
  if (_currentStep == TutorialElementsStepFirstMove) {
    [self beginSecondMove];
  } else if (_currentStep == TutorialElementsStepSecondMove) {
    [self beginThirdMove];
  } else if (_currentStep == TutorialElementsStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialElementsStepThirdMove) {
    [self beginShowHierarchy];
  } else if (_currentStep == TutorialElementsStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep != TutorialElementsStepHierarchy && index == dvc.dialogue.speechSegmentList.count-1) {
    [super dialogueViewController:dvc willDisplaySpeechAtIndex:index];
  }
}

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialElementsStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialElementsStepSecondMove) {
      [self.battleLayer beginSecondMove];
    } else if (_currentStep == TutorialElementsStepThirdMove) {
      [self.battleLayer allowMove];
    } else if (_currentStep == TutorialElementsStepHierarchy) {
      
    } else if (_currentStep == TutorialElementsStepKillEnemy) {
      [self.battleLayer allowMove];
    }
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  if (_currentStep == TutorialElementsStepHierarchy) {
    [self beginKillEnemy];
  }
  [super dialogueViewControllerFinished:dvc];
}

@end
