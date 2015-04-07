//
//  TutorialBuildingUpgrade.h
//  Utopia
//
//  Created by Rob Giusti on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"

#import "TutorialHomeViewController.h"
#import "TutorialUpgradeViewController.h"
#import "TutorialHomeMap.h"

typedef enum {
  TutorialBuildingUpgradeStepClickBuilding,
  TutorialBuildingUpgradeStepUpgrade,
  TutorialBuildingUpgradeStepFinish
} TutorialBuildingUpgradeStep;

@interface TutorialBuildingUpgradeController : MiniTutorialController <DialogueViewControllerDelegate, TutorialHomeMapDelegate, UpgradeViewControllerDelegate, HomeViewControllerDelegate>

@property (nonatomic, assign) TutorialBuildingUpgradeStep currentStep;

@property (nonatomic, retain) TutorialHomeMap *homeMap;

@property (nonatomic, retain) TutorialHomeViewController *homeViewController;
@property (nonatomic, retain) TutorialUpgradeViewController *upgradeViewController;

@property (nonatomic, assign) UserStruct *userStruct;

@end