//
//  UIViewController+ChildViewController.h
//  WithBuddiesBase
//
//  Created by odyth on 12/10/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ChildViewController)

-(void)properlyAddChildViewController:(UIViewController *)childViewController;
-(void)properlyAddChildViewController:(UIViewController *)childViewController aboveView:(UIView *)aboveView;
-(void)properlyAddChildViewController:(UIViewController *)childViewController belowView:(UIView *)belowView;
-(void)properlyRemoveChildViewController:(UIViewController *)childViewController;

@end
