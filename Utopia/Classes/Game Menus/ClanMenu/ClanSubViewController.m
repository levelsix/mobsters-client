//
//  ClanSubViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanSubViewController.h"
#import "ClanViewController.h"
#import "OutgoingEventController.h"

@interface ClanSubViewController ()

@end

@implementation ClanSubViewController

- (void) willMoveToParentViewController:(UIViewController *)parent {
  if (!parent) {
    [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
  }
}

- (BOOL) canGoBack {
  return YES;
}

- (BOOL) canClose {
  return YES;
}

@end
