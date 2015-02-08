//
//  PopoverViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
  ViewAnchoringDirectionNone = 0,
  ViewAnchoringPreferLeftPlacement,   // View will be anchored to the LEFT of the invoking view, if possible
  ViewAnchoringPreferRightPlacement,  // RIGHT
  ViewAnchoringPreferTopPlacement,    // TOP
  ViewAnchoringPreferBottomPlacement, // BOTTOM
} ViewAnchoringDirection;

@interface PopoverViewController : UIViewController {
  BOOL _centeredOnScreen;
}

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *triangle;

+ (BOOL) canCreateNewVc;

- (void) showCenteredOnScreen;
- (void) showAnchoredToInvokingView:(UIView*)invokingView withDirection:(ViewAnchoringDirection)direction inkovingViewImage:(UIImage*)invokingViewImage;
- (IBAction)closeClicked:(id)sender;

@end
