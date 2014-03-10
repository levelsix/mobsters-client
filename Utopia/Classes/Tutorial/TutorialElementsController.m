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

@implementation TutorialElementsController

- (id) initWithGameViewController:(GameViewController *)gvc dialogueSpeakerImage:(NSString *)dsi constants:(StartupResponseProto_TutorialConstants *)constants {
  if ((self = [super init])) {
    self.gameViewController = gvc;
    self.dialogueSpeakerImage = dsi;
    self.constants = constants;
  }
  return self;
}

- (void) displayDialogue:(NSArray *)dialogue {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  for (NSString *speakerText in dialogue) {
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = self.dialogueSpeakerImage;
    ss.isLeftSide = YES;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build];
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view insertSubview:dvc.view belowSubview:self.touchView];
  self.dialogueViewController = dvc;
  
  [self.touchView addResponder:self.dialogueViewController];
  self.touchView.userInteractionEnabled = YES;
}

- (void) begin {
  self.battleLayer = [[TutorialElementsBattleLayer alloc] initWithConstants:self.constants];
  self.battleLayer.delegate = self;
  [self.gameViewController crossFadeIntoBattleLayer:self.battleLayer];
  
  self.touchView = [[TutorialTouchView alloc] initWithFrame:self.gameViewController.view.bounds];
  [self.gameViewController.view addSubview:self.touchView];
  [self.touchView addResponder:[CCDirector sharedDirector].view];
  self.touchView.userInteractionEnabled = NO;
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

- (void) battleComplete:(NSDictionary *)params {
  [self.delegate elementsTutorialComplete];
  [[CCDirector sharedDirector] popSceneWithTransition:[CCTransition transitionCrossFadeWithDuration:0.6f]];
  [self.gameViewController showTopBarDuration:0.f completion:nil];
  
  [self.touchView removeFromSuperview];
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep != TutorialElementsStepHierarchy && index == dvc.dialogue.speechSegmentList.count-1) {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    
    if (index == 0) {
      [dvc.bottomGradient removeFromSuperview];
    } else {
      [dvc fadeOutBottomGradient];
    }
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
  
  [self.touchView removeResponder:self.dialogueViewController];
}

@end
