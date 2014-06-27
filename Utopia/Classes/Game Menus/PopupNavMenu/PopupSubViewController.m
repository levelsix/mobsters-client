//
//  PopupSubViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

@interface PopupSubViewController ()

@end

@implementation PopupSubViewController

//- (void) viewWillAppear:(BOOL)animated {
//  NSLog(@"%@: will appear", NSStringFromClass([self class]));
//}
//
//- (void) viewDidAppear:(BOOL)animated {
//  NSLog(@"%@: did appear", NSStringFromClass([self class]));
//}
//
//- (void) viewWillDisappear:(BOOL)animated {
//  NSLog(@"%@: will disappear", NSStringFromClass([self class]));
//}
//
//- (void) viewDidDisappear:(BOOL)animated {
//  NSLog(@"%@: did disappear", NSStringFromClass([self class]));
//}

- (BOOL) canGoBack {
  return YES;
}

- (BOOL) canClose {
  return YES;
}

@end
