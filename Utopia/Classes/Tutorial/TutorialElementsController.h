//
//  TutorialElementsController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialElementsBattleLayer.h"
#import "DialogueViewController.h"
#import "TutorialTouchView.h"

@class GameViewController;

@protocol TutorialElementsDelegate <NSObject>

- (void) elementsTutorialComplete;

@end

typedef enum {
  TutorialElementsStepFirstMove,
  TutorialElementsStepSecondMove,
  TutorialElementsStepThirdMove,
  TutorialElementsStepHierarchy,
  TutorialElementsStepKillEnemy
} TutorialElementsStep;

@interface TutorialElementsController : NSObject <DialogueViewControllerDelegate, TutorialBattleLayerDelegate> {
  TutorialElementsStep _currentStep;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, retain) TutorialElementsBattleLayer *battleLayer;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, copy) NSString *dialogueSpeakerImage;

@property (nonatomic, assign) id<TutorialElementsDelegate> delegate;

@property (nonatomic, retain) TutorialTouchView *touchView;

- (id) initWithGameViewController:(GameViewController *)gvc dialogueSpeakerImage:(NSString *)dsi constants:(StartupResponseProto_TutorialConstants *)constants;
- (void) begin;

@end
