//
//  TutorialTeamController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"

#import "TutorialHomeViewController.h"
#import "TutorialTeamViewController.h"
#import "TutorialHomeMap.h"

typedef enum {
  TutorialTeamStepClickBuilding,
  TutorialTeamStepEquip,
  TutorialTeamStepClose,
} TutorialTeamStep;

@interface TutorialTeamController : MiniTutorialController <DialogueViewControllerDelegate, TutorialHomeMapDelegate, TutorialTeamDelegate> {
  TutorialTeamStep _currentStep;
}

@property (nonatomic, retain) TutorialHomeMap *homeMap;

@property (nonatomic, retain) TutorialHomeViewController *homeViewController;
@property (nonatomic, retain) TutorialTeamViewController *teamViewController;

@property (nonatomic, assign) int lootMonsterId;
@property (nonatomic, assign) uint64_t lootUserMonsterId;

@end
