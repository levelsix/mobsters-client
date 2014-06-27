//
//  PopupNavViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@class PopupSubViewController;

@interface PopupNavViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *backLabel;
@property (nonatomic, retain) IBOutlet MaskedButton *backMaskedButton;

// Navigation controller stack
@property (nonatomic, retain) NSMutableArray *viewControllers;

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController;
- (void) replaceRootWithViewController:(PopupSubViewController *)viewController fromRight:(BOOL)fromRight animated:(BOOL)animated;
- (void) pushViewController:(PopupSubViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

- (void) replaceTitleView:(UIView *)oldView withNewView:(UIView *)newView fromRight:(BOOL)fromRight animated:(BOOL)animated;

- (IBAction) backClicked:(id)sender;
- (void) goBack;
- (IBAction) closeClicked:(id)sender;
- (void) close;

@end
