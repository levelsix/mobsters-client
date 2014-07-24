//
//  FocusScrollView.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FocusScrollView.h"
#import "Globals.h"
#import "GPUImage.h"

#define NUM_REPEATED_FOR_LOOPING 5

#define GRADIENT_TAG 9239

@implementation FocusScrollView

- (void) awakeFromNib {
  self.reusableViews = [NSMutableArray array];
}

- (void) reloadData {
  for (UIView *v in self.innerViews) {
    [v removeFromSuperview];
  }
  
  for (UIView *v in self.innerViews) {
    [v removeFromSuperview];
    [self.reusableViews addObject:v];
  }
  self.innerViews = [NSMutableArray array];
  
  _numItems = [self.delegate numberOfItems];
  BOOL shouldLoop = [self.delegate shouldLoopItems];
  
  CGFloat width = [self.delegate widthPerItem];
  float xBase = self.frame.size.width/2-width/2;
  self.scrollView.frame = CGRectMake(xBase, self.scrollView.frame.origin.y, width, self.frame.size.height);
  
  if (!shouldLoop) {
    self.scrollView.contentSize = CGSizeMake(width*_numItems, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = ccp(0, 0);
  } else {
    self.scrollView.contentSize = CGSizeMake(NUM_REPEATED_FOR_LOOPING*width*_numItems, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = ccp(NUM_REPEATED_FOR_LOOPING*_numItems/2*width, 0);
  }
  
  [self scrollViewDidScroll:self.scrollView];
}

- (void) checkViewsForCurrentPosition {
  CGFloat width = [self.delegate widthPerItem];
  float curIdx = (self.scrollView.contentOffset.x+self.scrollView.frame.size.width/2)/width;
  int leftIdx = floorf(curIdx-self.frame.size.width/width/2);
  int rightIdx = floorf(curIdx+self.frame.size.width/width/2);
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (UIView *v in self.innerViews) {
    int idx = (v.center.x-width/2)/width;
    if (idx < leftIdx || idx > rightIdx) {
      [toRemove addObject:v];
    }
  }
  
  for (UIView *v in toRemove) {
    [v removeFromSuperview];
    [self.innerViews removeObject:v];
    [self.reusableViews addObject:v];
  }
  
  for (int i = leftIdx; i <= rightIdx; i++) {
    int itemNum = i % _numItems;
    if (itemNum < 0) itemNum += _numItems;
    
    // Check if the view is already being displayed
    BOOL found = NO;
    for (UIView *v in self.innerViews) {
      float idx = (v.center.x-width/2)/width;
      if (idx == i) {
        [v.superview bringSubviewToFront:v];
        found = YES;
      }
    }
    if (!found) {
      UIView *reusable = [self.reusableViews firstObject];
      UIView *blurView = [self.delegate viewForItemNum:itemNum reusableView:reusable];
      
      blurView.center = ccp(i*width+width/2, self.scrollView.frame.size.height/2);
      [blurView.superview bringSubviewToFront:blurView];
      [self.scrollView addSubview:blurView];
      [self.innerViews addObject:blurView];
      [self.reusableViews removeObject:blurView];
      
      if (![blurView viewWithTag:GRADIENT_TAG]) {
        UIImageView *grad = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"covergradient.png"]];
        [blurView addSubview:grad];
        grad.contentMode = UIViewContentModeScaleToFill;
        grad.frame = CGRectMake(blurView.frame.size.width-grad.frame.size.width, 0, grad.frame.size.width, blurView.frame.size.height);
        grad.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        grad.tag = GRADIENT_TAG;
      }
    }
  }
}

#pragma mark - Scroll View Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat width = [self.delegate widthPerItem];
  CGFloat scaleFactorForOutOfFocus = [self.delegate scaleForOutOfFocusView];
  
  [self checkViewsForCurrentPosition];
  
  float curCenter = scrollView.contentOffset.x+scrollView.frame.size.width/2;
  for (UIView *focus in self.innerViews) {
    CGPoint focusCenter = focus.center;
    float distFactor = MIN(1.f, ABS(focusCenter.x-curCenter)/width);
    // Allow close to the center values to be completely unblurred
    distFactor = MAX(0.f, (distFactor-0.2)/0.8);
    
    float alphaBase = focusCenter.x > curCenter ? 0.f : 0.6f;
    focus.alpha = alphaBase+(1-alphaBase)*(1-distFactor);
    [[focus viewWithTag:GRADIENT_TAG] setAlpha:distFactor];
    
    float scale = scaleFactorForOutOfFocus+(1-scaleFactorForOutOfFocus)*(1-distFactor);
    focus.transform = CGAffineTransformMakeScale(scale, scale);
  }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  return self.scrollView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if ([self.delegate shouldLoopItems]) {
    float repeatSize = scrollView.contentSize.width/NUM_REPEATED_FOR_LOOPING;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.x = fmodf(contentOffset.x, repeatSize)+repeatSize*(NUM_REPEATED_FOR_LOOPING/2);
    
    scrollView.contentOffset = contentOffset;
  }
}

@end
