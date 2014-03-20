//
//  RequestsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "NibUtils.h"

@class RequestsFacebookTableController;
@class RequestsBattleTableController;

@protocol RequestsTableController <UITableViewDataSource, UITableViewDelegate>

- (void) becameDelegate:(UITableView *)requestsTable noRequestsLabel:(UILabel *)noRequestsLabel spinner:(UIActivityIndicatorView *)spinner;
- (void) resignDelegate;

@end

@interface RequestsTopBar : UIView

@property (nonatomic, retain) IBOutlet UIImageView *selectedView;

@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;

@property (nonatomic, assign) IBOutlet id<TabBarDelegate> delegate;

- (void) clickButton:(int)button;
- (IBAction) buttonClicked:(id)sender;

@end

@interface RequestsViewController : UIViewController <TabBarDelegate> {
  id<RequestsTableController> _curTableController;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet RequestsTopBar *topBar;

@property (nonatomic, retain) IBOutlet UITableView *requestsTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *noRequestsLabel;

@property (nonatomic, retain) RequestsFacebookTableController *facebookController;
@property (nonatomic, retain) RequestsBattleTableController *battleController;

@end
