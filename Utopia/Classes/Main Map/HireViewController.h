//
//  HireViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/17/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBChooserView.h"
#import "DBFBProfilePictureView.h"

@interface FriendAcceptView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet DBFBProfilePictureView *profPicView;

@end

@interface UpgradeBonusCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *occupationLabel;
@property (nonatomic, retain) IBOutlet UILabel *slotsLabel;
@property (nonatomic, retain) IBOutlet UIImageView *occupationIcon;
@property (nonatomic, retain) IBOutlet UIImageView *claimedIcon;
@property (nonatomic, retain) IBOutlet UIImageView *arrowIcon;
@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;

@end

@interface UpgradeBonusView : UIView <UITableViewDataSource, TabBarDelegate> {
  BOOL _canClick;
}

@property (nonatomic, retain) IBOutlet UITableView *hireTable;
@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *numSlotsLabel;
@property (nonatomic, retain) IBOutlet FBChooserView *chooserView;

@property (nonatomic, retain) IBOutlet UIView *gemView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *gemSpinner;

@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *acceptViews;

// These ones are for the jobs that already succeeded
@property (nonatomic, retain) IBOutlet UILabel *alreadyHiredLabel;
@property (nonatomic, retain) IBOutlet UIView *alreadyHiredBottomView;
@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *hiredFriendViews;

@property (nonatomic, retain) IBOutlet UIView *hireView;
@property (nonatomic, retain) IBOutlet UIView *addSlotsView;
@property (nonatomic, retain) IBOutlet UIView *alreadyHiredView;
@property (nonatomic, retain) IBOutlet UIView *friendFinderView;

@property (nonatomic, retain) IBOutlet UIView *sendLabel;
@property (nonatomic, retain) IBOutlet UIView *sendSpinner;

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

@interface HireViewController : UIViewController <UITableViewDelegate> {
  BOOL _canClick;
  BOOL _isOnFriendFinder;
  
  BOOL _sendingFbInvites;
}

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet ButtonTabBar *bonusTopBar;
@property (nonatomic, retain) IBOutlet UIView *backView;

@property (nonatomic, retain) IBOutlet UIView *menuContainer;
@property (nonatomic, retain) IBOutlet UpgradeBonusView *bonusView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) UserStruct *userStruct;

- (id) initWithUserStruct:(UserStruct *)us;

- (void) closeClicked:(id)sender;

@end
