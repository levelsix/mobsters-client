//
//  PopoverViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopoverViewController.h"

#import "Globals.h"

@interface PopoverViewController ()

@end

@implementation PopoverViewController

static BOOL _instanceOpened = NO;

- (id) init {
  if (!_instanceOpened) {
    return [super init];
  }
  LNLog(@"Trying to create popovers. Rejecting..");
  return nil;
}

+ (BOOL) canCreateNewVc {
  return !_instanceOpened;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.headerView.layer.cornerRadius = 6.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Hide view until either of the show methods are called
  self.mainView.alpha = 0;
  self.bgdView.alpha = 0;
  
  _instanceOpened = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEM_SELECT_OPENED_NOTIFICATION object:self];
}

- (void) showCenteredOnScreen
{
  _centeredOnScreen = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) showAnchoredToInvokingView:(UIView*)invokingView withDirection:(ViewAnchoringDirection)direction inkovingViewImage:(UIImage*)invokingViewImage
{
  [self showAnchoredToInvokingView:invokingView withDirection:direction inkovingViewImage:invokingViewImage preserveHeight:NO];
}

- (void) showAnchoredToInvokingView:(UIView*)invokingView withDirection:(ViewAnchoringDirection)direction inkovingViewImage:(UIImage*)invokingViewImage preserveHeight:(BOOL)preserveHeight
{
  if (invokingView != nil && direction != ViewAnchoringDirectionNone)
  {
    _centeredOnScreen = NO;
    
    const CGPoint invokingViewAbsolutePosition = invokingView.superview
      ? [Globals convertPointToWindowCoordinates:invokingView.frame.origin fromViewCoordinates:invokingView.superview]
      : invokingView.frame.origin; // Already in screen space
    const CGSize windowSize = [Globals screenSize];
    CGFloat viewTargetX = self.mainView.frame.origin.x;
    CGFloat viewTargetY = self.mainView.frame.origin.y;
    CGFloat viewScale = 1.f;
    CGFloat viewTargetHeight = self.mainView.frame.size.height;
    CGFloat arrowTargetX = -1.f;
    CGFloat arrowTargetY = -1.f;
    CGPoint viewAnchorPoint = CGPointMake(.5f, .5f);
    
    const CGFloat screenPadding = 5.f; // Uniform padding from the edges of the screen
    
    switch (direction)
    {
      case ViewAnchoringPreferTopPlacement:
      {
        if (!preserveHeight) viewTargetHeight = invokingViewAbsolutePosition.y - screenPadding; // Fill up available vertical space
        viewTargetX = invokingViewAbsolutePosition.x - (self.mainView.frame.size.width - invokingView.frame.size.width) * .5f;
        viewTargetY = invokingViewAbsolutePosition.y - viewTargetHeight;
        
        CGFloat offCenterX = 0.f;
        offCenterX += MAX(screenPadding - viewTargetX, 0.f); // Shift right if needed to remain on screen
        offCenterX -= MAX(viewTargetX + self.mainView.frame.size.width - (windowSize.width - screenPadding), 0.f); // Shift left if needed to remain on screen
        viewTargetX += offCenterX;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(M_PI_2)]; // Point arrow down
        
        arrowTargetX = invokingViewAbsolutePosition.x - (self.triangle.frame.size.width - invokingView.frame.size.width) * .5f - viewTargetX;
        arrowTargetY = viewTargetHeight - 10.f; // This magic number is the bottom padding of the view, coming from the nib
        
        viewAnchorPoint = CGPointMake(.5f - (offCenterX / self.mainView.frame.size.width), 1.f);
      }
        break;
        
      case ViewAnchoringPreferBottomPlacement:
      {
        if (!preserveHeight) viewTargetHeight = windowSize.height - (invokingViewAbsolutePosition.y + invokingView.frame.size.height) - screenPadding; // Fill up available vertical space
        viewTargetX = invokingViewAbsolutePosition.x - (self.mainView.frame.size.width - invokingView.frame.size.width) * .5f;
        viewTargetY = invokingViewAbsolutePosition.y + invokingView.frame.size.height;
        
        CGFloat offCenterX = 0.f;
        offCenterX += MAX(screenPadding - viewTargetX, 0.f); // Shift right if needed to remain on screen
        offCenterX -= MAX(viewTargetX + self.mainView.frame.size.width - (windowSize.width - screenPadding), 0.f); // Shift left if needed to remain on screen
        viewTargetX += offCenterX;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(-M_PI_2)]; // Point arrow up
        
        arrowTargetX = invokingViewAbsolutePosition.x - (self.triangle.frame.size.width - invokingView.frame.size.width) * .5f - viewTargetX;
        arrowTargetY = 2.f; // Adding a small offset so that the arrow blends with the view
        
        viewAnchorPoint = CGPointMake(.5f - (offCenterX / self.mainView.frame.size.width), 0.f);
      }
        break;
        
      case ViewAnchoringPreferLeftPlacement:
      {
        if (!preserveHeight) viewTargetHeight = windowSize.height - screenPadding * 2.f; // Fill up available vertical space
        viewTargetX = invokingViewAbsolutePosition.x - self.mainView.frame.size.width;
        viewTargetY = screenPadding;
        
        // Arrow is initially pointing to the right
        
        arrowTargetX = self.mainView.frame.size.width - 9.f; // This magic number is the right padding of the view, coming from the nib
        arrowTargetY = invokingViewAbsolutePosition.y - (self.triangle.frame.size.height - invokingView.frame.size.height) * .5f - viewTargetY;
        
        CGFloat offCenterY = windowSize.height * .5f - (invokingViewAbsolutePosition.y + invokingView.frame.size.height * .5f);
        const CGFloat horizontalClearance = invokingViewAbsolutePosition.x;
        if (horizontalClearance < self.mainView.frame.size.width) // Not enough room horizontally; scale down the view
        {
          viewScale = horizontalClearance / self.mainView.frame.size.width;
          viewTargetX += self.mainView.frame.size.width * (1.f - viewScale) * .5f;
          viewTargetY -= offCenterY * (1.f - viewScale);
        }
        
        viewAnchorPoint = CGPointMake(1.f, .5f - (offCenterY / viewTargetHeight));
      }
        break;
        
      case ViewAnchoringPreferRightPlacement:
      {
        if (!preserveHeight) viewTargetHeight = windowSize.height - screenPadding * 2.f; // Fill up available vertical space
        viewTargetX = invokingViewAbsolutePosition.x + invokingView.frame.size.width;
        viewTargetY = screenPadding;
        
        [self.triangle setTransform:CGAffineTransformMakeRotation(M_PI)]; // Point arrow to the left
        
        arrowTargetX = 2.f; // Adding a small offset so that the arrow blends with the view
        arrowTargetY = invokingViewAbsolutePosition.y - (self.triangle.frame.size.height - invokingView.frame.size.height) * .5f - viewTargetY;
        
        CGFloat offCenterY = windowSize.height * .5f - (invokingViewAbsolutePosition.y + invokingView.frame.size.height * .5f);
        const CGFloat horizontalClearance = windowSize.width - (invokingViewAbsolutePosition.x + invokingView.frame.size.width);
        if (horizontalClearance < self.mainView.frame.size.width) // Not enough room horizontally; scale down the view
        {
          viewScale = horizontalClearance / self.mainView.frame.size.width;
          viewTargetX -= self.mainView.frame.size.width * (1.f - viewScale) * .5f;
          viewTargetY -= offCenterY * (1.f - viewScale);
        }
        
        viewAnchorPoint = CGPointMake(0.f, .5f - (offCenterY / viewTargetHeight));
      }
        break;
        
      default:
        break;
    }
    
    [self.mainView setFrame:CGRectMake(viewTargetX, viewTargetY, self.mainView.frame.size.width, viewTargetHeight)];
    if (viewScale < 1.f) [self.mainView setTransform:CGAffineTransformMakeScale(viewScale, viewScale)];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView anchorPoint:viewAnchorPoint];
    
    if (arrowTargetX > 0 || arrowTargetY > 0)
    {
      // Place arrow relative to its parent view
      [self.triangle setFrame:CGRectMake(arrowTargetX, arrowTargetY, self.triangle.size.width, self.triangle.size.height)];
      [self.triangle setHidden:NO];
    }
    
    // Use masking layers to darken behind the dialog but have the invokingViewImage show through
    if (invokingViewImage != nil)
    {
      const CGRect maskImageFrame = CGRectMake(invokingViewAbsolutePosition.x + (invokingView.frame.size.width - invokingViewImage.size.width) * .5f,
                                               invokingViewAbsolutePosition.y + (invokingView.frame.size.height - invokingViewImage.size.height) * .5f,
                                               invokingViewImage.size.width, invokingViewImage.size.height);
      
      CALayer* maskLayer = [CALayer layer];
      CALayer* maskTopLayer = [CALayer layer];
      {
        [maskTopLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bgdView.frame), maskImageFrame.origin.y)];
        [maskTopLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskTopLayer];
      }
      CALayer* maskBottomLayer = [CALayer layer];
      {
        [maskBottomLayer setFrame:CGRectMake(0, maskImageFrame.origin.y + maskImageFrame.size.height,
                                             CGRectGetWidth(self.bgdView.frame), windowSize.height - (maskImageFrame.origin.y + maskImageFrame.size.height))];
        [maskBottomLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskBottomLayer];
      }
      CALayer* maskLeftLayer = [CALayer layer];
      {
        [maskLeftLayer setFrame:CGRectMake(0, maskImageFrame.origin.y, maskImageFrame.origin.x, maskImageFrame.size.height)];
        [maskLeftLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskLeftLayer];
      }
      CALayer* maskRightLayer = [CALayer layer];
      {
        [maskRightLayer setFrame:CGRectMake(maskImageFrame.origin.x + maskImageFrame.size.width, maskImageFrame.origin.y,
                                            windowSize.width - (maskImageFrame.origin.x + maskImageFrame.size.width), maskImageFrame.size.height)];
        [maskRightLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [maskLayer addSublayer:maskRightLayer];
      }
      
      CALayer* maskImageLayer = [CALayer layer];
      CGImageRef invokingViewImageRef = invokingViewImage.CGImage;
      CGImageRef invokingViewMaskImageRef = CGImageMaskCreate(CGImageGetWidth(invokingViewImageRef),
                                                              CGImageGetHeight(invokingViewImageRef),
                                                              CGImageGetBitsPerComponent(invokingViewImageRef),
                                                              CGImageGetBitsPerPixel(invokingViewImageRef),
                                                              CGImageGetBytesPerRow(invokingViewImageRef),
                                                              CGImageGetDataProvider(invokingViewImageRef), NULL, false);
      [maskImageLayer setFrame:maskImageFrame];
      [maskImageLayer setContents:(__bridge id)(invokingViewMaskImageRef)];
      [maskLayer addSublayer:maskImageLayer];
      
      CGImageRelease(invokingViewMaskImageRef);
      
      self.bgdView.layer.mask = maskLayer;
    }
  }
  else
  {
    [self showCenteredOnScreen];
  }
}

- (IBAction)closeClicked:(id)sender {
  // Do the appearance transition so that viewWillDisappear gets called immediately
  [self beginAppearanceTransition:NO animated:YES];
  
  if (_centeredOnScreen)
  {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
      [self endAppearanceTransition];
    }];
  }
  else
  {
    // Will use the anchor point already set on the view's layer
    [Globals shrinkView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
      [self endAppearanceTransition];
    }];
  }
  
  _instanceOpened = NO;
}

@end
