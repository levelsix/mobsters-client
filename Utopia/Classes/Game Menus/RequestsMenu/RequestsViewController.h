//
//  RequestsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@class RequestsFacebookTableController;

@protocol RequestsTableController <UITableViewDataSource, UITableViewDelegate>

- (void) becameDelegate:(UITableView *)requestsTable noRequestsLabel:(UILabel *)noRequestsLabel spinner:(UIActivityIndicatorView *)spinner;
- (void) resignDelegate;

@end

@interface RequestsViewController : UIViewController {
  id<RequestsTableController> _curTableController;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UITableView *requestsTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *noRequestsLabel;

@property (nonatomic, retain) RequestsFacebookTableController *facebookController;

@end
