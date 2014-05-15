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

- (NSString *) myType {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  return [[Globals stringForElement:mp.monsterElement] lowercaseString];
}

- (NSString *) weakType {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  return [[Globals stringForElement:[Globals elementForNotVeryEffective:mp.monsterElement]] lowercaseString];
}

- (NSString *) strongType {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  return [[Globals stringForElement:[Globals elementForSuperEffective:mp.monsterElement]] lowercaseString];
}

- (NSString *) myColor {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  switch (mp.monsterElement) {
    case ElementEarth:
      return @"green";
    case ElementWater:
      return @"blue";
    case ElementLight:
      return @"yellow";
    case ElementDark:
      return @"purple";
    case ElementFire:
      return @"red";
    default:
      return @"";
  }
}

- (int) weakDamage {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  return [self.battleLayer.myPlayerObject damageForColor:(GemColorId)[Globals elementForNotVeryEffective:mp.monsterElement]];
}

- (int) strongDamage {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:self.speakerMonsterId];
  return [self.battleLayer.myPlayerObject damageForColor:(GemColorId)mp.monsterElement];
}

- (void) initBattleLayer {
  self.battleLayer = [[TutorialElementsBattleLayer alloc] initWithMyUserMonsters:self.myTeam puzzleIsOnLeft:NO];
  self.battleLayer.delegate = self;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullTaskProto *ftp = [gs taskWithCityId:1 assetId:gl.miniTutorialConstants.elementTutorialAssetId];
  Element elem = [self.battleLayer firstMyPlayer].element;
  Element enemyElem = [Globals elementForSuperEffective:elem];
  [[OutgoingEventController sharedOutgoingEventController] beginDungeon:ftp.taskId enemyElement:enemyElem withDelegate:self.battleLayer];
}

- (void) beginFirstMove {
  NSString *n = [[self myType] characterAtIndex:0] == 'e' ? @"n" : @"";
  NSArray *dialogue = @[[NSString stringWithFormat:@"Notice how the health bar above my head is %@? It means I’m a%@ %@-type mobster.", [self myColor], n, [self myType]],
                        [NSString stringWithFormat:@"Because I'm a%@ %@-type, %@ orbs will give me more damage. Match 3 %@ orbs to check it out now!", n, [self myType], [self myType], [self myType]]];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepFirstMove;
}

- (void) beginSecondMove {
  NSArray *dialogue = @[[NSString stringWithFormat:@"Boom! You did %d damage per orb! Now let’s see what happens when you match 3 %@ orbs.", [self strongDamage], [self weakType]]];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepSecondMove;
}

- (void) beginThirdMove {
  NSArray *dialogue = @[[NSString stringWithFormat:@"Weak. You only did %d damage per orb. That’s because %@-types are weak against %@.", [self weakDamage], [self myType], [self weakType]],
                        @"You have one move left before I attack. Choose wisely!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepThirdMove;
}

- (void) beginShowHierarchy {
  NSString *n = [[self strongType] characterAtIndex:0] == 'e' ? @"n" : @"";
  NSArray *dialogue = @[[NSString stringWithFormat:@"Did you see that? Because I'm a%@ %@-type mobster, I also do extra damage to %@-type mobsters.", n, [self myType], [self strongType]],
                        @"Click here to see the elemental hierarchy, and check back if you ever forget.",
                        @"You have 3 moves before I attack again. Finish him off!"];
  [self displayDialogue:dialogue];
  
  _currentStep = TutorialElementsStepHierarchy;
}

- (void) beginKillEnemy {
  [self.dialogueViewController animateNext];
  
  _currentStep = TutorialElementsStepKillEnemy;
}

#pragma mark - Battle delegate

- (void) battleLayerReachedEnemy {
  [super battleLayerReachedEnemy];
  [self beginFirstMove];
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

- (void) elementButtonClicked {
  [self beginKillEnemy];
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
  if (_currentStep == TutorialElementsStepFirstMove) {
    if (index == 0) {
      [self.battleLayer arrowOnMyHealthBar];
    } else if (index == 1) {
      [self.battleLayer removeArrowOnMyHealthBar];
    }
  }
  
  if (_currentStep != TutorialElementsStepHierarchy) {
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
    } else if (_currentStep == TutorialElementsStepKillEnemy) {
      [self.battleLayer allowMove];
    }
  } else if (_currentStep == TutorialElementsStepHierarchy && index == 1) {
    self.dialogueViewController.view.userInteractionEnabled = NO;
    [self.battleLayer arrowOnElements];
  }
}

@end
