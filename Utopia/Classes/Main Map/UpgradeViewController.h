//
//  UpgradeViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "FBChooserView.h"
#import "UserData.h"

@interface FriendAcceptView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet FBProfilePictureView *profPicView;

@end

@interface UpgradeBonusCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *occupationLabel;
@property (nonatomic, retain) IBOutlet UILabel *slotsLabel;
@property (nonatomic, retain) IBOutlet UILabel *requiresLabel;
@property (nonatomic, retain) IBOutlet UIImageView *claimedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *arrowIcon;
@property (nonatomic, retain) IBOutlet UIView *acceptViewsContainer;

@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *acceptViews;

@end

@interface UpgradeBonusView : UIView <UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *hireTable;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *numSlotsLabel;
@property (nonatomic, retain) IBOutlet FBChooserView *chooserView;

@property (nonatomic, retain) IBOutlet UIView *acceptViewsContainer;
@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *acceptViews;

@property (nonatomic, retain) IBOutlet UIView *hireView;
@property (nonatomic, retain) IBOutlet UIView *addSlotsView;
@property (nonatomic, retain) IBOutlet UIView *friendFinderView;

@property (nonatomic, retain) IBOutlet UpgradeBonusCell *bonusCell;

@property (nonatomic, retain) NSArray *staticStructs;
@property (nonatomic, assign) UserStruct *userStruct;

- (void) moveToHireView;
- (void) moveToAddSlotsView;
- (void) moveToFriendFinderView;

@end

@interface UpgradeBuildingMenu : UIView <UITableViewDelegate>

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UIImageView *structIcon;
@property (nonatomic, assign) IBOutlet UILabel *upgradeTimeLabel;

@property (nonatomic, assign) IBOutlet UIView *buttonContainerView;
@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet UILabel *upgradeCashLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradeOilLabel;
@property (nonatomic, assign) IBOutlet UILabel *cityHallTooLowLabel;
@property (nonatomic, strong) UIImageView *greyscaleView;

@property (nonatomic, assign) IBOutlet UIView *rightDescriptionView;
@property (nonatomic, assign) IBOutlet UIView *timeView;
@property (nonatomic, assign) IBOutlet UIView *statContainerView;
@property (nonatomic, assign) IBOutlet UIView *statBarView1;
@property (nonatomic, assign) IBOutlet UILabel *statNameLabel1;
@property (nonatomic, assign) IBOutlet UILabel *statIncreaseLabel1;
@property (nonatomic, assign) IBOutlet ProgressBar *statNewBar1;
@property (nonatomic, assign) IBOutlet ProgressBar *statCurrentBar1;
@property (nonatomic, assign) IBOutlet UIView *statBarView2;
@property (nonatomic, assign) IBOutlet UILabel *statNameLabel2;
@property (nonatomic, assign) IBOutlet UILabel *statIncreaseLabel2;
@property (nonatomic, assign) IBOutlet ProgressBar *statNewBar2;
@property (nonatomic, assign) IBOutlet ProgressBar *statCurrentBar2;

@end

@protocol UpgradeViewControllerDelegate <NSObject>

- (void) bigUpgradeClicked;

@end

@interface UpgradeViewController : UIViewController <TabBarDelegate> {
  BOOL _isOnFriendFinder;
  
  BOOL _sendingFbInvites;
}

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet FlipTabBar *bonusTopBar;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIView *sendView;
@property (nonatomic, retain) IBOutlet UIView *closeView;

@property (nonatomic, retain) IBOutlet UIView *sendLabel;
@property (nonatomic, retain) IBOutlet UIView *sendSpinner;

@property (nonatomic, retain) IBOutlet UIView *menuContainer;
@property (nonatomic, retain) IBOutlet UpgradeBuildingMenu *upgradeView;
@property (nonatomic, retain) IBOutlet UpgradeBonusView *bonusView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) UserStruct *userStruct;

@property (nonatomic, assign) id<UpgradeViewControllerDelegate> delegate;

- (id) initWithUserStruct:(UserStruct *)us;

- (IBAction) hireWithGemsClicked:(id)sender;
- (IBAction) viewFriendsClicked:(id)sender;
- (IBAction) sendClicked:(id)sender;
- (IBAction) backClicked:(id)sender;
- (void) button1Clicked:(id)sender;
- (void) button2Clicked:(id)sender;
- (IBAction) closeClicked:(id)sender;

@end
