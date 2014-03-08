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
#import "ChatViewController.h"

@interface SplitImageProgressBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *leftCap;
@property (nonatomic, retain) IBOutlet UIImageView *rightCap;
@property (nonatomic, retain) IBOutlet UIImageView *middleBar;

@property (nonatomic, assign) float percentage;
@property (nonatomic, assign) BOOL isRightToLeft;

@end

@interface TopBarMonsterView : UIView

@property (nonatomic, retain) IBOutlet UIView *iconView;
@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UIView *healthBarView;

@end

@interface TopBarViewController : UIViewController <NumTransitionLabelDelegate>

@property (nonatomic, assign) IBOutlet SplitImageProgressBar *expBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *cashBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *oilBar;

@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *expLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *cashLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *oilLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *cashMaxLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *oilMaxLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *gemsLabel;

@property (nonatomic, assign) IBOutlet UIImageView *expBgd;
@property (nonatomic, assign) IBOutlet UIImageView *cashBgd;
@property (nonatomic, assign) IBOutlet UIImageView *oilBgd;

@property (nonatomic, retain) IBOutlet BadgeIcon *questBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *mailBadge;

@property (nonatomic, retain) IBOutlet UIView *myCityView;
@property (nonatomic, retain) IBOutlet UIView *menuView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *coinBarsView;
@property (nonatomic, retain) IBOutlet UIView *questView;

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *topBarMonsterViewContainers;
@property (nonatomic, retain) IBOutlet TopBarMonsterView *topBarMonsterView;

@property (nonatomic, retain) ChatViewController *chatViewController;

@property (nonatomic, assign) MapBotView *curViewOverChatView;

- (void) showMyCityView;
- (void) removeMyCityView;

- (IBAction)menuClicked:(id)sender;
- (IBAction)questsClicked:(id)sender;
- (void) replaceChatViewWithView:(MapBotView *)view;
- (void) removeViewOverChatView;

@end
