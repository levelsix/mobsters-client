//
//  TutorialPowerupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "TutorialPowerupBattleLayer.h"
#import "MiniTutorialController.h"

@class GameViewController;

typedef enum {
  TutorialPowerupStepFirstMove,
  TutorialPowerupStepSecondMove,
  TutorialPowerupStepThirdMove,
  TutorialPowerupStepKillEnemy
} TutorialPowerupStep;

@interface TutorialPowerupController : MiniTutorialController {
  TutorialPowerupStep _currentStep;
}

@property (nonatomic, retain) TutorialPowerupBattleLayer *battleLayer;

@end
