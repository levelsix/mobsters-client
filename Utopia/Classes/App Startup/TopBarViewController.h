//
//  TopBarViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "GameMap.h"

@interface SplitImageProgressBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *leftCap;
@property (nonatomic, retain) IBOutlet UIImageView *rightCap;
@property (nonatomic, retain) IBOutlet UIImageView *middleBar;

@property (nonatomic, assign) float percentage;

@end

@interface TopBarMonsterView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@property (nonatomic, retain) IBOutlet UIView *monsterView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;

@end

@interface TopBarView : UIView

@end

@interface TopBarViewController : UIViewController <NumTransitionLabelDelegate>

@property (nonatomic, assign) IBOutlet ProgressBar *expBar;
@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *expLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *silverLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *goldLabel;

@property (nonatomic, retain) IBOutlet UIView *myCityView;
@property (nonatomic, retain) IBOutlet UIView *menuView;

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *topBarMonsterViewContainers;
@property (nonatomic, retain) IBOutlet TopBarMonsterView *topBarMonsterView;

@property (nonatomic, assign) MapBotView *curViewOverChatView;

- (void) showMyCityView;
- (void) showMenuView;

- (IBAction)menuClicked:(id)sender;
- (void) replaceChatViewWithView:(MapBotView *)view;
- (void) removeViewOverChatView;

@end
