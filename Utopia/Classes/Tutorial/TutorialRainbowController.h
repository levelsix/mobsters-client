//
//  TutorialRainbowController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialRainbowBattleLayer.h"
#import "MiniTutorialController.h"

@class GameViewController;

typedef enum {
  TutorialRainbowStepFirstMove,
  TutorialRainbowStepSecondMove,
  TutorialRainbowStepThirdMove,
  TutorialRainbowStepKillEnemy
} TutorialRainbowStep;

@interface TutorialRainbowController : MiniTutorialController {
  TutorialRainbowStep _currentStep;
}

@property (nonatomic, retain) TutorialRainbowBattleLayer *battleLayer;


@end
