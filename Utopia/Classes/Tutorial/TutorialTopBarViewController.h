//
//  TutorialTopBarViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TopBarViewController.h"

@protocol TutorialTopBarDelegate <NSObject>

@optional
- (void) menuClicked;
- (void) attackClicked;
- (void) questsClicked;
- (void) mobstersClicked;

@end

@interface TutorialTopBarViewController : TopBarViewController {
  BOOL _allowMenuClick;
  BOOL _allowAttackClick;
  BOOL _allowQuestsClick;
  BOOL _allowMobstersClick;
}

@property (nonatomic, weak) id<TutorialTopBarDelegate> delegate;

- (void) displayCoinBars;
- (void) displayMenuButton;

- (void) allowMenuClick;
- (void) allowAttackClick;
- (void) allowQuestsClick;
- (void) allowMobstersClick;

@end
