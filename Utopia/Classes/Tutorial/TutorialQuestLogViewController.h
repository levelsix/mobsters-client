//
//  TutorialQuestLogViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "QuestLogViewController.h"

@protocol TutorialQuestLogDelegate <NSObject>

- (void) questClickedInList;
- (void) questVisitClicked;
- (void) questCollectClicked;

@end

@interface TutorialQuestLogViewController : QuestLogViewController

@property (nonatomic, assign) id<TutorialQuestLogDelegate> delegate;

- (void) arrowOnFirstQuestInList;
- (void) arrowOnVisit;
- (void) arrowOnCollect;

@end
