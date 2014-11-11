//
//  BuySlotsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBChooserView.h"

@interface FriendAcceptView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet FBProfilePictureView *profPicView;

@end

@protocol BuySlotsViewControllerDelegate <NSObject>

- (void) slotsPurchased;

@end

@interface BuySlotsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *addSlotsView;
@property (nonatomic, retain) IBOutlet UIView *askFriendsView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIView *sendView;
@property (nonatomic, retain) IBOutlet UIView *closeView;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *numSlotsLabel;

@property (nonatomic, retain) IBOutlet FBChooserView *chooserView;

@property (nonatomic, retain) IBOutletCollection(FriendAcceptView) NSArray *acceptViews;

@property (nonatomic, assign) id<BuySlotsViewControllerDelegate> delegate;

- (IBAction)backClicked:(id)sender;

@end
