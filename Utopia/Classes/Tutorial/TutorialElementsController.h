//
//  TutorialElementsController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiniTutorialController.h"
#import "TutorialElementsBattleLayer.h"

@class GameViewController;

typedef enum {
  TutorialElementsStepFirstMove,
  TutorialElementsStepSecondMove,
  TutorialElementsStepThirdMove,
  TutorialElementsStepHierarchy,
  TutorialElementsStepKillEnemy
} TutorialElementsStep;

@interface TutorialElementsController : MiniTutorialController {
  TutorialElementsStep _currentStep;
}

@property (nonatomic, retain) TutorialElementsBattleLayer *battleLayer;

@end
