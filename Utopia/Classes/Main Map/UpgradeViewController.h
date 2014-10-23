//
//  UpgradeViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "UserData.h"
#import "TopBarViewcontroller.h"

@interface UpgradeBuildingMenu : UIView <UITableViewDelegate>

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UIImageView *structIcon;
@property (nonatomic, assign) IBOutlet UILabel *upgradeTimeLabel;

@property (nonatomic, assign) IBOutlet UIView *buttonContainerView;
@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet UILabel *upgradeCashLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradeOilLabel;
@property (nonatomic, strong) UIImageView *greyscaleView;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBgdView;
@property (nonatomic, assign) IBOutlet UIImageView *checkIcon;
@property (nonatomic, assign) IBOutlet UILabel *readyLabel;
@property (nonatomic, assign) IBOutlet UILabel *readySubLabel;

@property (nonatomic, assign) IBOutlet UIView *statBarView1;
@property (nonatomic, assign) IBOutlet UILabel *statNameLabel1;
@property (nonatomic, assign) IBOutlet UILabel *statDescriptionLabel1;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *statNewBar1;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *statCurrentBar1;
@property (nonatomic, assign) IBOutlet UIView *statBarView2;
@property (nonatomic, assign) IBOutlet UILabel *statNameLabel2;
@property (nonatomic, assign) IBOutlet UILabel *statDescriptionLabel2;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *statNewBar2;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *statCurrentBar2;

@property (nonatomic, assign) IBOutlet UIView *cityHallUnlocksView;
@property (nonatomic, assign) IBOutlet UILabel *cityHallUnlocksLabel;
@property (nonatomic, assign) IBOutlet UIScrollView *cityHallUnlocksScrollView;
@property (nonatomic, retain) IBOutlet UIView *nibUnlocksView;
@property (nonatomic, assign) IBOutlet UIImageView *nibUnlocksLabelBgd;
@property (nonatomic, assign) IBOutlet UILabel *nibUnlocksLabel;
@property (nonatomic, assign) IBOutlet UIImageView *nibUnlocksStructIcon;

@end

@protocol UpgradeViewControllerDelegate <NSObject>

- (void) bigUpgradeClicked;

@end

@interface UpgradeViewController : UIViewController <TabBarDelegate>

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet UpgradeBuildingMenu *upgradeView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) UserStruct *userStruct;

@property (nonatomic, assign) id<UpgradeViewControllerDelegate> delegate;

- (id) initWithUserStruct:(UserStruct *)us;

- (void) closeClicked:(id)sender;

@end
