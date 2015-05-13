//
//  TangoGiftViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 5/8/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TangoGiftViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgView;

@property (nonatomic, retain) IBOutlet UIImageView *selectAllCheckmark;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *friendListActivityIndicator;

@property (nonatomic, retain) NSMutableArray *tangoFriends;
@property (nonatomic, retain) NSMutableArray *selectedFriends;

- (void) updateForTangoFriends:(NSArray *)friends;

@end
