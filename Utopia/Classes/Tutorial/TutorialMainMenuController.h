//
//  TutorialMainMenuViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MainMenuController.h"

@protocol TutorialMainMenuDelegate

- (void) buildingButtonClicked;

@end

@interface TutorialMainMenuController : MainMenuController

@property (nonatomic, assign) id<TutorialMainMenuDelegate> delegate;

@end
