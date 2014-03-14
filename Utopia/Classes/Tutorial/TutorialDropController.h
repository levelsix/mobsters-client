//
//  TutorialDropController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"
#import "TutorialDropBattleLayer.h"
#import "MiniTutorialController.h"
#import "TutorialTopBarViewController.h"
#import "TutorialMyCroniesViewController.h"

@class GameViewController;

typedef enum {
  TutorialDropStepFirstMove,
  TutorialDropStepKillEnemy,
  TutorialDropStepLoot,
  TutorialDropStepClickTopBar,
  TutorialDropStepEquip,
  TutorialDropStepClose,
} TutorialDropStep;

@interface TutorialDropController : MiniTutorialController <TutorialTopBarDelegate, TutorialMyCroniesDelegate> {
  TutorialDropStep _currentStep;
}

@property (nonatomic, retain) TutorialDropBattleLayer *battleLayer;

@property (nonatomic, retain) TutorialTopBarViewController *topBarViewController;
@property (nonatomic, retain) TutorialMyCroniesViewController *myCroniesViewController;

@property (nonatomic, assign) int lootMonsterId;

@end
