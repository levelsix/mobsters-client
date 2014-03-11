//
//  MiniTutorialController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "GameState.h"

@implementation MiniTutorialController

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

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
    self.touchView.userInteractionEnabled = YES;
    [self.touchView addResponder:dvc];
    
    if (index == 0) {
      [dvc.bottomGradient removeFromSuperview];
    } else {
      [dvc fadeOutBottomGradient];
    }
}


- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self.touchView removeResponder:self.dialogueViewController];
  self.touchView.userInteractionEnabled = NO;
}

@end
