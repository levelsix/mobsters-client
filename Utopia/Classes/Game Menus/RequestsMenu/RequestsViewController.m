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
#import "RequestsBattleTableController.h"

@implementation RequestsTopBar

- (void) clickButton:(int)button {
  UIColor *inactiveText = [UIColor colorWithRed:228/255.f green:243/255.f blue:248/255.f alpha:1.f];
  UIColor *inactiveShadow = [UIColor colorWithRed:21/255.f green:96/255.f blue:150/255.f alpha:0.75f];
  self.label1.highlighted = NO;
  self.label1.textColor = inactiveText;
  self.label1.shadowColor = inactiveShadow;
  self.label2.highlighted = NO;
  self.label2.textColor = inactiveText;
  self.label2.shadowColor = inactiveShadow;
  self.label3.highlighted = NO;
  self.label3.textColor = inactiveText;
  self.label3.shadowColor = inactiveShadow;
  
  UILabel *label = nil;
  if (button == 1) {
    label = self.label1;
  } else if (button == 2) {
    label = self.label2;
  } else if (button == 3) {
    label = self.label3;
  }
  self.selectedView.center = ccp(label.center.x, self.selectedView.center.y);
  label.textColor = [UIColor colorWithRed:71/255.f green:81/255.f blue:87/255.f alpha:1.f];
  label.shadowColor = [UIColor colorWithWhite:1.f alpha:0.75f];
}

- (IBAction) buttonClicked:(id)sender {
  NSInteger tag = [(UIView *)sender tag];
  if (tag == 1) {
    [self.delegate button1Clicked:sender];
    [self clickButton:1];
  } else if (tag == 2) {
    [self.delegate button2Clicked:sender];
    [self clickButton:2];
  } else if (tag == 3) {
    [self.delegate button3Clicked:sender];
    [self clickButton:3];
  }
}

@end

@implementation RequestsViewController

- (void) viewDidLoad {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.facebookController = [[RequestsFacebookTableController alloc] init];
  self.battleController = [[RequestsBattleTableController alloc] init];
  
  [self.topBar clickButton:1];
  [self button1Clicked:nil];
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
    [self changeTableController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Tab bar delegate

- (void) button1Clicked:(id)sender {
  [self changeTableController:self.battleController];
}

- (void) button2Clicked:(id)sender {
  
}

- (void) button3Clicked:(id)sender {
  [self changeTableController:self.facebookController];
}

@end
