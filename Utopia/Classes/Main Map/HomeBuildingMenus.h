//
//  HomeBuildingMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "UserData.h"

#define PROGRESS_BAR_SPEED 2.f

@interface PurchaseConfirmMenu : CCNode

- (id) initWithCheckTarget:(id)cTarget checkSelector:(SEL)cSelector cancelTarget:(id)xTarget cancelSelector:(SEL)xSelector;

@end

@interface UpgradeProgressBar : CCSprite {
  CCLabelTTF *_timeLabel;
}

@property (nonatomic, assign) CCProgressTimer *progressBar;

- (id) initBar;
- (void) updateForSecsLeft:(int)secs totalSecs:(int)totalSecs;

@end

@interface UpgradeBuildingMenu : UIView

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *currentIncomeLabel;
@property (nonatomic, assign) IBOutlet UILabel *currentTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradedIncomeLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradedTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradeTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradePriceLabel;
@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UIImageView *structIcon;

@property (nonatomic, assign) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIView *bgdView;

- (void) displayForUserStruct:(UserStruct *)us;

- (IBAction)closeClicked:(id)sender;

@end

@interface ExpansionView : UIView

@property (nonatomic, assign) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel *costLabel;

@property (nonatomic, assign) IBOutlet UIView *bgdView;
@property (nonatomic, assign) IBOutlet UIView *mainView;

- (void) display;
- (IBAction)closeClicked:(id)sender;

@end
