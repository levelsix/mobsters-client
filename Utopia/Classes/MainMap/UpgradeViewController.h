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
#import "EmbeddedScrollingUpgradeView.h"
#import "PopupNavViewController.h"

@class EmbeddedScrollingUpgradeView;
@class UpgradePrereqView;

//@protocol UpgradePrereqDelegate <NSObject>
//
//- (void) goClicked:(UpgradePrereqView *)pre;
//
//@end

@interface UpgradePrereqView : EmbeddedNibView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete;

@property (nonatomic, retain) IBOutlet UIImageView *checkIcon;
@property (nonatomic, retain) IBOutlet UILabel *prereqLabel;
@property (nonatomic, retain) IBOutlet UIView *goButtonView;

@property (nonatomic, assign) IBOutlet id<EmbeddedDelegate> delegate;

@end

@interface UpgradeBuildingMenu : UIView <UITableViewDelegate>

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UIImageView *structIcon;
@property (nonatomic, assign) IBOutlet UILabel *upgradeTimeLabel;

@property (nonatomic, assign) IBOutlet UIView *buttonContainerView;
@property (nonatomic, assign) IBOutlet UIButton *oilButton;
@property (nonatomic, assign) IBOutlet UIButton *cashButton;
@property (nonatomic, assign) IBOutlet UIImageView *oilIcon;
@property (nonatomic, assign) IBOutlet UIImageView *cashIcon;
@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet UILabel *upgradeCashLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradeOilLabel;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBgdView;
@property (nonatomic, assign) IBOutlet UIImageView *checkIcon;
@property (nonatomic, assign) IBOutlet UILabel *readyLabel;
@property (nonatomic, assign) IBOutlet UILabel *readySubLabel;

@property (nonatomic, assign) IBOutlet UIView *cityHallUnlocksView;
@property (nonatomic, retain) IBOutlet UIView *nibUnlocksView;
@property (nonatomic, assign) IBOutlet UIImageView *nibUnlocksLabelBgd;
@property (nonatomic, assign) IBOutlet UILabel *nibUnlocksLabel;
@property (nonatomic, assign) IBOutlet UIImageView *nibUnlocksStructIcon;

@property (nonatomic, assign) IBOutlet EmbeddedScrollingUpgradeView *embeddedScrollView;

//@property (nonatomic, retain) IBOutletCollection(UpgradePrereqView) NSArray *prereqViews;

@end

@protocol UpgradeViewControllerDelegate <NSObject>

- (void) bigUpgradeClicked:(id)sender;

@end

@interface UpgradeViewController : PopupSubViewController <TabBarDelegate, EmbeddedDelegate>

@property (nonatomic, retain) IBOutlet UpgradeBuildingMenu *upgradeView;

@property (nonatomic, retain) UserStruct *userStruct;

@property (nonatomic, assign) id<UpgradeViewControllerDelegate> delegate;

- (id) initWithUserStruct:(UserStruct *)us;

@end
