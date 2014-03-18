//
//  RequestsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "RequestsViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "UserData.h"
#import "OutgoingEventController.h"
#import "FacebookDelegate.h"
#import "RequestsFacebookTableController.h"

@implementation RequestsViewController

- (void) viewDidLoad {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.facebookController = [[RequestsFacebookTableController alloc] init];
  
  [self changeTableController:self.facebookController];
}

- (void) changeTableController:(id<RequestsTableController>)newController {
  [_curTableController resignDelegate];
  self.requestsTable.delegate = newController;
  self.requestsTable.dataSource = newController;
  [newController becameDelegate:self.requestsTable noRequestsLabel:self.noRequestsLabel spinner:self.spinner];
  _curTableController = newController;
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
