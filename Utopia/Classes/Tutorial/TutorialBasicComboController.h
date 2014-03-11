//
//  TutorialBasicComboController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "TutorialBasicComboBattleLayer.h"
#import "MiniTutorialController.h"

@class GameViewController;

typedef enum {
  TutorialBasicComboStepFirstMove,
  TutorialBasicComboStepSecondMove,
  TutorialBasicComboStepThirdMove,
  TutorialBasicComboStepKillEnemy
} TutorialBasicComboStep;

@interface TutorialBasicComboController : MiniTutorialController {
  TutorialBasicComboStep _currentStep;
}

@property (nonatomic, retain) TutorialBasicComboBattleLayer *battleLayer;

@end
