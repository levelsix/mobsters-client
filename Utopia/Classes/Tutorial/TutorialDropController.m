//
//  TutorialDropController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialDropController.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"
#import "MissionMap.h"

@implementation TutorialDropController

- (void) displayLootDialogue:(NSArray *)dialogue {
  DialogueProto_Builder *dp = [DialogueProto builder];
  
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i+1 < dialogue.count; i += 2) {
    BOOL isLootGuy = [dialogue[i] boolValue];
    MonsterProto *mp = [gs monsterWithId:isLootGuy ? self.lootMonsterId : self.speakerMonsterId];
    NSString *speakerText = dialogue[i+1];
    
    DialogueProto_SpeechSegmentProto_Builder *ss = [DialogueProto_SpeechSegmentProto builder];
    ss.speaker = mp.displayName;
    ss.speakerImage = mp.imagePrefix;
    ss.isLeftSide = !isLootGuy;
    ss.speakerText = speakerText;
    [dp addSpeechSegment:ss.build];
  }
  
  DialogueViewController *dvc = [[DialogueViewController alloc] initWithDialogueProto:dp.build useSmallBubble:NO];
  dvc.delegate = self;
  [self.gameViewController addChildViewController:dvc];
  [self.gameViewController.view insertSubview:dvc.view belowSubview:self.touchView];
  self.dialogueViewController = dvc;
  
  [self.touchView addResponder:self.dialogueViewController];
} 

- (void) initTopBar {
  self.topBarViewController = [[TutorialTopBarViewController alloc] init];
  self.topBarViewController.delegate = self;
  self.topBarViewController.view.frame = self.gameViewController.view.bounds;
  [self.gameViewController addChildViewController:self.topBarViewController];
  [self.gameViewController.view insertSubview:self.topBarViewController.view belowSubview:self.touchView];
}

- (void) initMyCronies {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [self.gameViewController presentViewController:m animated:YES completion:nil];
  self.myCroniesViewController = [[TutorialMyCroniesViewController alloc] init];
  self.myCroniesViewController.delegate = self;
  [m pushViewController:self.myCroniesViewController animated:YES];
}

- (void) initBattleLayer {
  self.battleLayer = [[TutorialDropBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO gridSize:CGSizeMake(6, 6)];
  self.battleLayer.delegate = self;
  
//  GameState *gs = [GameState sharedGameState];
//  Globals *gl = [Globals sharedGlobals];
//  FullTaskProto *ftp = nil;//[gs taskWithCityId:gl.miniTutorialConstants.cityId assetId:gl.miniTutorialConstants.monsterDropTutorialAssetId];
//  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId withDelegate:self.battleLayer];
}

- (void) stop {
  [super stop];
  [self.topBarViewController removeFromParentViewController];
  [self.topBarViewController.view removeFromSuperview];
  [self.myCroniesViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
  [CCDirector sharedDirector].view.userInteractionEnabled = YES;
}

- (void) beginFirstMove {
  NSArray *dialogue = @[@"Unlike your world, we mobsters find violence more civil than words when resolving issues.",
                        @"Earn the respect of this Goonie and recruit him to your squad by defeating him now!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDropStepFirstMove;
}

- (void) beginKillEnemy {
  [self.battleLayer allowMove];
  
  _currentStep = TutorialDropStepKillEnemy;
}

- (void) beginLootPhase {
  NSArray *dialogue = @[@"Check it out! This goonie dropped an orb, which shows you’ve earned his loyalty.",
                        @"Let’s get outta here so I can show you how to put him on your team."];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialDropStepLoot;
}

- (void) beginClickTopBarPhase {
  [self initTopBar];
  [CCDirector sharedDirector].view.userInteractionEnabled = NO;
  
  self.topBarViewController.view.alpha = 0.f;
  [UIView animateWithDuration:0.6f animations:^{
    self.topBarViewController.view.alpha = 1.f;
  }];
  
  NSArray *dialogue = @[@YES , @"It’s your lucky day guys -- You’ve just recruited a star to your team without even knowing it.",
                        @NO, @"Wow... this is coming from the guy that didn’t even shoot back?",
                        @YES , @"Typical noob. Any real mobster would’ve known I was acting. Can you believe this guy?",
                        @NO, @"I cannot wait to use you as a meat shield. Let’s just assign this guy to your team and get it over with.",
                        @NO , @"Click on the top bar now to manage your squad."];
  [self displayLootDialogue:dialogue];
  
  _currentStep = TutorialDropStepClickTopBar;
}

- (void) beginEquipPhase {
  [self initMyCronies];
  
  NSArray *dialogue = @[@"The mobsters at the top are the ones currently assigned to your team.",
                        @"Click here now to assign this Goonie to your squad."];
  [self displayDialogue:dialogue];
  [self.myCroniesViewController addChildViewController:self.dialogueViewController];
  [self.myCroniesViewController.view addSubview:self.dialogueViewController.view];
  
  _currentStep = TutorialDropStepEquip;
}

- (void) beginClosePhase {
  NSArray *dialogue = @[@"Good work. Exit this screen so we can throw this Goonie into battle."];
  [self displayDialogue:dialogue];
  [self.myCroniesViewController addChildViewController:self.dialogueViewController];
  [self.myCroniesViewController.view addSubview:self.dialogueViewController.view];
  self.dialogueViewController.view.userInteractionEnabled = NO;
  
  _currentStep = TutorialDropStepClose;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  if (_currentStep == 0) {
    [self beginFirstMove];
    
    // Grab the loot id
    NSArray *tsps = self.battleLayer.dungeonInfo.tspList;
    if (tsps.count > 0) {
      TaskStageProto *tsp = tsps[0];
      if (tsp.stageMonstersList.count > 0) {
        TaskStageMonsterProto *tsm = tsp.stageMonstersList[0];
        self.lootMonsterId = tsm.monsterId;
      }
    }
  }
}

- (void) moveFinished {
  if (_currentStep == TutorialDropStepFirstMove) {
    [self beginKillEnemy];
  } else if (_currentStep == TutorialDropStepKillEnemy) {
    [self.battleLayer allowMove];
  }
}

- (void) turnFinished {
  if (_currentStep == TutorialDropStepKillEnemy) {
    if (self.battleLayer.enemyPlayerObject.curHealth <= 0) {
      [self beginLootPhase];
    } else {
      [self.battleLayer allowMove];
    }
  }
}

- (void) battleComplete:(NSDictionary *)params {
  [self.gameViewController battleComplete:params];
  [self.touchView removeFromSuperview];
  
  if (self.battleLayer.newUserMonsterId > 0) {
    self.gameViewController.topBarViewController.view.hidden = YES;
    
    for (CCNode *n in self.gameViewController.currentMap.children) {
      if ([n isKindOfClass:[SelectableSprite class]]) {
        SelectableSprite *ss = (SelectableSprite *)n;
        [ss removeArrowAnimated:YES];
      }
    }
    
    [self beginClickTopBarPhase];
  } else {
    [self.delegate miniTutorialComplete:self];
  }
}

#pragma mark - Top bar delegate

- (void) mobstersClicked {
  [self.dialogueViewController animateNext];
  [self beginEquipPhase];
}

#pragma mark - MyCronies delegate

- (void) addedMobsterToTeam {
  [self.dialogueViewController animateNext];
  [self beginClosePhase];
}

- (void) exitedMyCronies {
  [CCDirector sharedDirector].view.userInteractionEnabled = YES;
  self.gameViewController.topBarViewController.view.hidden = NO;
  [self.topBarViewController.view removeFromSuperview];
  [self.topBarViewController removeFromParentViewController];
  
  [self.dialogueViewController animateNext];
  self.dialogueViewController.delegate = nil;
  
  if ([self.gameViewController.currentMap isKindOfClass:[MissionMap class]]) {
    [(MissionMap *)self.gameViewController.currentMap setAllLocksAndArrowsForBuildings];
  }
  
  [self.delegate miniTutorialComplete:self];
}

#pragma mark - Dialogue delegate

- (void) dialogueViewController:(DialogueViewController *)dvc willDisplaySpeechAtIndex:(int)index {
  if (_currentStep == TutorialDropStepFirstMove) {
    [super dialogueViewController:dvc willDisplaySpeechAtIndex:index];
  } else if (_currentStep == TutorialDropStepEquip && index == 0) {
    [self.myCroniesViewController unequipSlotThree];
    [self.myCroniesViewController highlightTeamView];
    [self.myCroniesViewController.view bringSubviewToFront:self.dialogueViewController.view];
  }
}

- (void) dialogueViewController:(DialogueViewController *)dvc didDisplaySpeechAtIndex:(int)index {
  if (index == dvc.dialogue.speechSegmentList.count-1) {
    if (_currentStep == TutorialDropStepFirstMove) {
      [self.battleLayer beginFirstMove];
    } else if (_currentStep == TutorialDropStepClickTopBar) {
      self.dialogueViewController.view.userInteractionEnabled = NO;
      [self.topBarViewController allowMobstersClick];
    } else if (_currentStep == TutorialDropStepEquip) {
      self.dialogueViewController.view.userInteractionEnabled = NO;
      [self.myCroniesViewController moveToMonster:self.battleLayer.newUserMonsterId];
      [self.myCroniesViewController allowEquip:self.battleLayer.newUserMonsterId];
    } else if (_currentStep == TutorialDropStepClose) {
      [self.myCroniesViewController allowClose];
    }
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  if (_currentStep == TutorialDropStepLoot) {
    [self.battleLayer finishBattle];
  }
  [super dialogueViewControllerFinished:dvc];
}

@end
