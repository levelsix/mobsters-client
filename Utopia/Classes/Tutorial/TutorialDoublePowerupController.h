//
//  TutorialDoublePowerupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "TutorialDoublePowerupBattleLayer.h"
#import "MiniTutorialController.h"

@class GameViewController;

typedef enum {
  TutorialDoublePowerupStepFirstMove,
  TutorialDoublePowerupStepSecondMove,
  TutorialDoublePowerupStepThirdMove,
  TutorialDoublePowerupStepKillEnemy
} TutorialDoublePowerupStep;

@interface TutorialDoublePowerupController : MiniTutorialController {
  TutorialDoublePowerupStep _currentStep;
}

@property (nonatomic, retain) TutorialDoublePowerupBattleLayer *battleLayer;

@end

