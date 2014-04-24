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
#import "TopBarViewcontroller.h"
#import "RequestsViewController.h"

@interface FriendAcceptView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet FBProfilePictureView *profPicView;

@end

@interface UpgradeBonusCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *occupationLabel;
@property (nonatomic, retain) IBOutlet UILabel *slotsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *claimedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *arrowIcon;
@property (nonatomic, retain) IBOutlet UIView *acceptViewsContainer;
@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;

@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *acceptViews;

@end

@interface UpgradeBonusView : UIView <UITableViewDataSource> {
  BOOL _canClick;
}

@property (nonatomic, retain) IBOutlet UITableView *hireTable;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *numSlotsLabel;
@property (nonatomic, retain) IBOutlet FBChooserView *chooserView;

@property (nonatomic, retain) IBOutlet UIView *gemView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *gemSpinner;

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

- (void) spinnerOnGems;
- (void) removeSpinner;

- (IBAction) rowSelected:(UITableViewCell *)sender;

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
@property (nonatomic, strong) UIImageView *greyscaleView;
@property (nonatomic, assign) IBOutlet UIView *tooLowLevelView;
@property (nonatomic, assign) IBOutlet UILabel *tooLowLevelLabel;

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

@interface UpgradeViewController : UIViewController <TabBarDelegate> {
  BOOL _isHire;
  BOOL _canClick;
  BOOL _isOnFriendFinder;
  
  BOOL _sendingFbInvites;
}

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet ButtonTopBar *bonusTopBar;
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
- (id) initHireViewWithUserStruct:(UserStruct *)us;

- (IBAction) hireWithGemsClicked:(id)sender;
- (IBAction) viewFriendsClicked:(id)sender;
- (IBAction) sendClicked:(id)sender;
- (IBAction) backClicked:(id)sender;
- (void) button1Clicked:(id)sender;
- (void) button2Clicked:(id)sender;
- (IBAction) closeClicked:(id)sender;

@end
