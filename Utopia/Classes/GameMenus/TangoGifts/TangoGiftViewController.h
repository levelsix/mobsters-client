//
//  TangoGiftViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 5/8/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TangoDelegate.h"
#import "HudNotificationController.h"
#import <UIKit/UIKit.h>

@interface TangoFriendViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *tangoPic;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkmark;

- (void) loadForTangoProfile:(id)tangoProfile;

@end

@interface TangoGiftViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TopBarNotification> {
  dispatch_block_t _completion;
}

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIImageView *selectAllCheckmark;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *friendListActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *rewardLabel;

@property (nonatomic, retain) NSMutableArray *tangoFriends;
@property (nonatomic, retain) NSMutableArray *selectedFriends;

- (void) updateForTangoFriends:(NSArray *)friends;

@end
