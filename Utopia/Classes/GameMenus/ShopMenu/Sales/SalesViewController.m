//
//  SalesViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SalesViewController.h"

#import "GemPackageViewController.h"
#import "SalePackageViewController.h"

#import <cocos2d.h>
#import "GameViewController.h"
#import "GameState.h"

#import "SoundEngine.h"

@interface SalesScrollView : CancellableScrollView

@end

@implementation SalesScrollView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (point.x < 0 || point.x > self.contentSize.width) {
    return NO;
  }
  
  return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  CGRect r;
  r.origin = self.contentOffset;
  r.size = self.size;
  
  if (CGRectContainsPoint(r, point)) {
    return [super hitTest:point withEvent:event];
  }
  return self;
}

@end

@interface SalesView : UIView

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end

@implementation SalesView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *v = [super hitTest:point withEvent:event];
  
  if (v == self) {
    return self.scrollView;
  }
  
  return v;
}

@end

@implementation SalesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [self reloadViewControllers];
  [self scrollViewDidScroll:self.scrollView];
  [self scrollViewDidEndDecelerating:self.scrollView];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTap:)];
  [self.view addGestureRecognizer:tap];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.loadingView stop];
}

- (void) checkTap:(UITapGestureRecognizer *)tap {
  CGPoint pt = [tap locationInView:self.view];
  
  if (!CGRectContainsPoint(self.scrollView.frame, pt)) {
    [self.parentViewController close];
    
    [SoundEngine closeButtonClick];
  }
}

- (void) reloadViewControllers {
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (SalesPackageProto *spp in gs.mySales) {
    SalePackageViewController *spvc = [[SalePackageViewController alloc] initWithSalePackageProto:spp];
    spvc.delegate = self;
    
    [arr addObject:spvc];
    
    [self addChildViewController:spvc];
    
    if ([spp.uuid isEqualToString:_initialSale.uuid]) {
      NSInteger idx = [arr indexOfObject:spvc];
      
      self.scrollView.contentOffset = ccp(idx*self.scrollView.width, 0);
      
      _initialSale = nil;
    }
  }
  
  {
    GemPackageViewController *gpvc = [[GemPackageViewController alloc] init];
    gpvc.delegate = self;
    
    [arr addObject:gpvc];
    
    [self addChildViewController:gpvc];
  }
  
  self.viewControllers = arr;
  
  self.scrollView.contentSize = CGSizeMake(self.viewControllers.count * self.scrollView.width, self.scrollView.height);
}

- (void) iapClicked:(id<InAppPurchaseData>)iap {
  if (_isLoading) {
    return;
  }
  
  BOOL success = [iap makePurchaseWithDelegate:self];
  if (success) {
    GameViewController *gvc = [GameViewController baseController];
    [self.loadingView display:gvc.view];
    _isLoading = YES;
  }
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
}

#pragma mark - Scroll View


- (void) checkViewsForCurrentPosition {
  CGFloat width = self.scrollView.width;
  float curIdx = self.scrollView.contentOffset.x/width;
  int leftIdx = floorf(curIdx-self.scrollView.originX/width);
  int rightIdx = floorf(curIdx+(self.view.width-self.scrollView.originX)/width);
  
  for (int i = leftIdx; i <= rightIdx; i++) {
    if (i >= 0 && i < self.viewControllers.count) {
      UIViewController *uvc = self.viewControllers[i];
      
      if (![uvc isViewLoaded]) {
        [self.scrollView addSubview:uvc.view];
        
        uvc.view.centerX = width*(i+0.5);
        uvc.view.originY = self.scrollView.height-uvc.view.height;
        
        if (self.scrollView.subviews.count == self.viewControllers.count) {
          _allVcsLoaded = YES;
        }
      }
    }
  }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat width = self.scrollView.width;
  
  if (!_allVcsLoaded) {
    [self checkViewsForCurrentPosition];
  }
  
  float curCenter = scrollView.contentOffset.x+scrollView.width/2;
  for (UIView *sv in self.scrollView.subviews) {
    UIView *darken = [sv viewWithTag:DARKEN_VIEW_TAG];
    
    if (darken) {
      CGPoint focusCenter = sv.center;
      float distFactor = MIN(1.f, ABS(focusCenter.x-curCenter)/width);
      // Allow close to the center values to be completely unblurred
      //  distFactor = MAX(0.f, (distFactor-0.2)/0.8);
      
      darken.alpha = distFactor;
    }
  }
}

- (void) stopAllJigglingExceptIdx:(int)idx {
  for (int i = 0; i < self.viewControllers.count; i++) {
    SalePackageViewController *vc = self.viewControllers[i];
    // Gem package vc doesn't have the jiggle method
    if ([vc isKindOfClass:[SalePackageViewController class]]) {
      if (idx == i) {
        [vc startAllJiggling];
      } else {
        [vc stopAllJiggling];
      }
    }
  }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self stopAllJigglingExceptIdx:-1];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  int curIdx = roundf(self.scrollView.contentOffset.x/self.scrollView.width);
  [self stopAllJigglingExceptIdx:curIdx];
}

@end
