//
//  MiniEventViewController.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@class MiniEventDetailsView;
@class MiniEventPointsView;
@class UserMiniEvent;

@interface MiniEventViewController : UIViewController <TabBarDelegate>
{
  UIImageView* _tabLeftShadow;
  UIImageView* _tabRightShadow;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet ButtonTabBar* buttonTabBar;
@property (nonatomic, retain) IBOutlet UIButton* tab1Button;
@property (nonatomic, retain) IBOutlet UIButton* tab2Button;

@property (nonatomic, retain) MiniEventDetailsView* detailsView;
@property (nonatomic, retain) MiniEventPointsView* pointsView;

@property (nonatomic, retain) NSTimer* eventUpdateTimeLeftTimer;

- (IBAction) closeClicked:(id)sender;

- (void) miniEventUpdated:(UserMiniEvent*)userMiniEvent;

@end
