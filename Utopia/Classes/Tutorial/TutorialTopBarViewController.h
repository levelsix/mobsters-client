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
- (void) attackClicked;
- (void) questsClicked;

@end

@interface TutorialTopBarViewController : TopBarViewController {
  BOOL _allowMenuClick;
  BOOL _allowAttackClick;
  BOOL _allowQuestsClick;
}

@property (nonatomic, assign) id<TutorialTopBarDelegate> delegate;

- (void) displayCoinBars;
- (void) displayMenuButton;

- (void) allowMenuClick;
- (void) allowAttackClick;
- (void) allowQuestsClick;

@end
