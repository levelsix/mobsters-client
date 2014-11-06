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

@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *backLabel;
@property (nonatomic, retain) IBOutlet MaskedButton *backMaskedButton;

@property (nonatomic, retain) IBOutlet UIView *leftCornerViewContainer;
@property (nonatomic, retain) IBOutlet UIView *leftCornerView;

@property (nonatomic, retain) IBOutlet UIView *curTitleView;
@property (nonatomic, retain) IBOutlet UILabel *curTitleLabel;

// Navigation controller stack
@property (nonatomic, retain) PopupSubViewController *topViewController;
@property (nonatomic, retain) NSMutableArray *viewControllers;

- (void) displayInParentViewController:(UIViewController *)gvc;

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController;
- (void) replaceRootWithViewController:(PopupSubViewController *)viewController fromRight:(BOOL)fromRight animated:(BOOL)animated;
- (void) pushViewController:(PopupSubViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void) unloadAllControllers;

- (void) replaceTitleView:(UIView *)oldView withNewView:(UIView *)newView fromRight:(BOOL)fromRight animated:(BOOL)animated;
- (void) loadNextTitleSelectionFromRight:(BOOL)fromRight animated:(BOOL)animated;
- (void) reloadTitleLabel;

- (IBAction) backClicked:(id)sender;
- (void) goBack;
- (IBAction) closeClicked:(id)sender;
- (void) close;

- (BOOL) shouldStopCCDirector;

@end
