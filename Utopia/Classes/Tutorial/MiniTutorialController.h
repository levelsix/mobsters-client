//
//  MiniTutorialController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogueViewController.h"
#import "MiniTutorialBattleLayer.h"
#import "GameViewController.h"
#import "TutorialTouchView.h"

@class MiniTutorialController;

@protocol MiniTutorialDelegate <NSObject>

- (void) miniTutorialComplete:(MiniTutorialController *)tut;

@end

@interface MiniTutorialController : NSObject <DialogueViewControllerDelegate, MiniTutorialBattleLayerDelegate>

@property (nonatomic, retain) MiniTutorialBattleLayer *battleLayer;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, assign) int speakerMonsterId;

@property (nonatomic, retain) TutorialTouchView *touchView;

@property (nonatomic, retain) NSArray *myTeam;

@property (nonatomic, assign) id<MiniTutorialDelegate> delegate;

- (id) initWithMyTeam:(NSArray *)myTeam gameViewController:(GameViewController *)gvc;

- (void) initBattleLayer;
- (void) begin;

- (void) displayDialogue:(NSArray *)dialogue;

@end
