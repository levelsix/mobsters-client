//
//  RequestsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import <FacebookSDK/FacebookSDK.h>

@interface RequestTableCell : UITableViewCell

@property (nonatomic, retain) IBOutlet FBProfilePictureView *pfPic;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkmark;


@property (nonatomic, retain) IBOutlet RequestFromFriend *request;

@end

@interface RequestsViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UITableView *requestsTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIButton *unselectButton;

@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) NSMutableSet *unselectedRequests;
@property (nonatomic, retain) NSDictionary *fbInfo;

@property (nonatomic, retain) IBOutlet RequestTableCell *requestCell;

- (IBAction)acceptClicked:(id)sender;

@end
