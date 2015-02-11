//
//  TutorialEnhanceController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniTutorialController.h"

#import "TutorialHomeMap.h"
#import "TutorialHomeViewController.h"
#import "TutorialEnhanceChooserViewController.h"
#import "TutorialEnhanceQueueViewController.h"

#import "TutorialTopBarViewController.h"

#import "UserData.h"

typedef enum {
  TutorialEnhanceStepClickBuilding,
  TutorialEnhanceStepChooseBase,
  TutorialEnhanceStepChooseFeeder,
  TutorialEnhanceStepAttackMap,
  
} TutorialEnhanceStep;

@interface TutorialEnhanceController : MiniTutorialController <TutorialHomeMapDelegate, TutorialEnhanceChooserDelegate, TutorialEnhanceQueueDelegate, TutorialTopBarDelegate>

@property (nonatomic, assign) TutorialEnhanceStep currentStep;

@property (nonatomic, retain) TutorialHomeMap *homeMap;

@property (nonatomic, retain) TutorialHomeViewController *homeViewController;
@property (nonatomic, retain) TutorialEnhanceChooserViewController *chooserViewController;
@property (nonatomic, retain) TutorialEnhanceQueueViewController *queueViewController;

@property (nonatomic, retain) TutorialTopBarViewController *topBarViewController;

@property (nonatomic, retain) UserMonster *baseUserMonster;
@property (nonatomic, retain) UserMonster *feederUserMonster;

- (id) initWithBaseMonster:(UserMonster *)bm feeder:(UserMonster *)f gameViewController:(GameViewController *)gvc;

@end
