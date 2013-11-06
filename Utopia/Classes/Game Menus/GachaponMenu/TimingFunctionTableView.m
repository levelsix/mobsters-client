//
//  TimingFunctionTableView.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/1/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TimingFunctionTableView.h"


const static CFTimeInterval kDefaultSetContentOffsetDuration = 0.25;

// constants used for Newton approximation of cubic function root
const static double approximationTolerance = 0.00000001;
const static int maximumSteps = 10;


@implementation TimingFunctionTableView {
  
  // display link used to trigger event to scroll the view
  CADisplayLink *_displayLink;
  
  // animation properties
  CAMediaTimingFunction *_timingFunction;
  CFTimeInterval _duration;
  
  // state at the start of an animation
  CFTimeInterval _beginTime;
  CGPoint _beginContentOffset;
  
  // delta between the contentOffset at the start of the animation and
  // the contentOffset at the end of the animation
  CGPoint _deltaContentOffset;
}


#pragma mark - Set ContentOffset with Custom Animation

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction {
  
  [self setContentOffset:contentOffset
      withTimingFunction:timingFunction
                duration:kDefaultSetContentOffsetDuration];
}

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration {
  
  CGPoint offset = self.contentOffset;
  [self setContentOffset:offset animated:NO];
  
  _duration = duration;
  _timingFunction = timingFunction;
  
  _deltaContentOffset = CGPointMake(contentOffset.x - self.contentOffset.x,
                                    contentOffset.y - self.contentOffset.y);
  
  if (!_displayLink) {
    _displayLink = [CADisplayLink
                    displayLinkWithTarget:self
                    selector:@selector(updateContentOffset:)];
    _displayLink.frameInterval = 1;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
  } else {
    _beginTime = 0.0;
    _displayLink.paused = NO;
  }
}

- (void)updateContentOffset:(CADisplayLink *)displayLink {
  
  // on the first invokation in an animation beginTime is zero
  if (_beginTime == 0.0) {
    
    _beginTime = displayLink.timestamp;
    _beginContentOffset = self.contentOffset;
  } else {
    
    CFTimeInterval deltaTime = displayLink.timestamp - _beginTime;
    
    // ratio of duration that went by
    CGFloat ratio = (CGFloat) (deltaTime / _duration);
    // ratio adjusted by timing function
    CGFloat adjustedRatio;
    
    if (ratio > 1) {
      adjustedRatio = 1.0;
    } else {
      adjustedRatio = (CGFloat) timingFunctionValue(_timingFunction, ratio);
    }
    
    if (1 - adjustedRatio < 0.00001) {
      
      adjustedRatio = 1.0;
      _displayLink.paused = YES;
      _beginTime = 0.0;
    }
    
    CGPoint currentDeltaContentOffset = CGPointMake(_deltaContentOffset.x * adjustedRatio,
                                                    _deltaContentOffset.y * adjustedRatio);
    
    CGPoint contentOffset = CGPointMake(_beginContentOffset.x + currentDeltaContentOffset.x,
                                        _beginContentOffset.y + currentDeltaContentOffset.y);
    
    self.contentOffset = contentOffset;
    
    if (adjustedRatio == 1.0) {
      // inform delegate about end of animation
      if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:self];
      }
    }
  }
}

double cubicFunctionValue(double a, double b, double c, double d, double x) {
  
  return (a*x*x*x)+(b*x*x)+(c*x)+d;
}

double cubicDerivativeValue(double a, double b, double c, double __unused d, double x) {
  
  // derivation of the cubic (a*x*x*x)+(b*x*x)+(c*x)+d
  return (3*a*x*x)+(2*b*x)+c;
}

double rootOfCubic(double a, double b, double c, double d, double startPoint) {
  
  // we use 0 as start point as the root will be in the interval [0,1]
  double x = startPoint;
  double lastX = 1;
  
  // approximate a root by using the Newton-Raphson method
  int y = 0;
  while (y <= maximumSteps && fabs(lastX - x) > approximationTolerance) {
    lastX = x;
    x = x - (cubicFunctionValue(a, b, c, d, x) / cubicDerivativeValue(a, b, c, d, x));
    y++;
  }
  
  return x;
}

double timingFunctionValue(CAMediaTimingFunction *function, double x) {
  
  float a[2];
  float b[2];
  float c[2];
  float d[2];
  
  [function getControlPointAtIndex:0 values:a];
  [function getControlPointAtIndex:1 values:b];
  [function getControlPointAtIndex:2 values:c];
  [function getControlPointAtIndex:3 values:d];
  
  // look for t value that corresponds to provided x
  double t = rootOfCubic(-a[0]+3*b[0]-3*c[0]+d[0], 3*a[0]-6*b[0]+3*c[0], -3*a[0]+3*b[0], a[0]-x, x);
  
  // return corresponding y value
  double y = cubicFunctionValue(-a[1]+3*b[1]-3*c[1]+d[1], 3*a[1]-6*b[1]+3*c[1], -3*a[1]+3*b[1], a[1], t);
  
  return y;
}

@end