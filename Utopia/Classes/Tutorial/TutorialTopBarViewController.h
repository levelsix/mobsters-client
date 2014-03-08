//
//  TutorialTopBarViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TopBarViewController.h"

@protocol TutorialTopBarDelegate <NSObject>

- (void) menuClicked;
- (void) questsClicked;

@end

@interface TutorialTopBarViewController : TopBarViewController {
  BOOL _allowMenuClick;
}

@property (nonatomic, assign) id<TutorialTopBarDelegate> delegate;

- (void) displayCoinBars;
- (void) displayMenuButton;

- (void) allowMenuClick;

@end
