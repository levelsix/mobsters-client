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
#import "TutorialTouchView.h"

@class GameViewController;
@class MiniTutorialController;

@protocol MiniTutorialDelegate <NSObject>

- (void) miniTutorialComplete:(MiniTutorialController *)tut;

@end

@interface MiniTutorialController : NSObject <DialogueViewControllerDelegate, MiniTutorialBattleLayerDelegate>

@property (nonatomic, retain) MiniTutorialBattleLayer *battleLayer;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, assign) GameViewController *gameViewController;
@property (nonatomic, assign) int speakerMonsterId;

@property (nonatomic, retain) NSArray *myTeam;

@property (nonatomic, weak) id<MiniTutorialDelegate> delegate;

+ (id) miniTutorialForCityId:(int)cityId assetId:(int)assetId gameViewController:(GameViewController *)gvc;

- (id) initWithMyTeam:(NSArray *)myTeam gameViewController:(GameViewController *)gvc;

- (void) initBattleLayer;
- (void) begin;

- (void) stop;

- (void) displayDialogue:(NSArray *)dialogue;
- (void) displayDialogue:(NSArray *)dialogue isLeftSide:(BOOL)isLeftSide;

@end
