//
//  RequestsFacebookTableController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UserData.h"
#import "RequestsViewController.h"

@interface RequestsFacebookCell : UITableViewCell

@property (nonatomic, retain) IBOutlet FBProfilePictureView *pfPic;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkmark;

@property (nonatomic, retain) RequestFromFriend *request;

@end

@interface RequestsFacebookTableController : NSObject <RequestsTableController>

@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *noRequestsLabel;

@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, retain) NSDictionary *fbInfo;

@property (nonatomic, retain) NSMutableArray *acceptedRequestUuids;
@property (nonatomic, retain) NSMutableArray *rejectedRequestUuids;

@property (nonatomic, retain) IBOutlet RequestsFacebookCell *requestCell;
@property (nonatomic, retain) IBOutlet UIView *headerView;

- (IBAction)acceptClicked:(id)sender;
- (IBAction)rejectClicked:(id)sender;

@end
