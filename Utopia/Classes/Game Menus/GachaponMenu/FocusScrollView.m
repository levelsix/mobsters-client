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

@interface RepeatScrollView : UIScrollView

@property (nonatomic, assign) BOOL shouldLoop;

@end

@implementation RepeatScrollView

- (void) awakeFromNib {
  self.shouldLoop = YES;
}

- (void) setContentOffset:(CGPoint)contentOffset {
  if (self.shouldLoop) {
    float repeatSize = self.contentSize.width/3;
    if (repeatSize) {
      contentOffset.x = fmodf(contentOffset.x, repeatSize)+repeatSize;
    }
  }
  
  [super setContentOffset:contentOffset];
}

@end

@implementation FocusImageView

- (id) initWithFrame:(CGRect)frame image:(UIImage *)image {
  if ((self = [super initWithFrame:frame])) {
    _initSize = image.size;
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    GPUImageView *blurView = [[GPUImageView alloc] initWithFrame:self.bounds];
    //    blurView.layer.contentsGravity = kCAGravityResizeAspect;
    blurView.backgroundColor = [UIColor blueColor];
    blurView.fillMode = kGPUImageFillModeStretch;
    [self addSubview:blurView];
    [picture addTarget:blurFilter];
    [blurFilter addTarget:blurView];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.picture = picture;
    self.blurFilter = blurFilter;
    self.blurView = blurView;
    
    _blurRadius = -1;
    [self setBlurRadius:0];
    
    self.frame = frame;
  }
  return self;
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  CGSize s = _initSize;
  CGRect r = self.blurView.frame;
  r.size.width = frame.size.width;
  r.size.height = r.size.width*s.height/s.width;
  r.origin.y = frame.size.height/2-r.size.height/2;
  self.blurView.frame = r;
}

- (void) setBlurRadius:(float)blurRadius {
  if (blurRadius != _blurRadius && !_isProcessing) {
    _blurRadius = blurRadius;
    self.blurFilter.blurRadiusInPixels = blurRadius;
    
    _isProcessing = YES;
    [self.picture processImageWithCompletionHandler:^{
      _isProcessing = NO;
    }];
  }
}

@end

@implementation FocusScrollView

- (void) reloadData {
  
  for (UIView *v in self.innerViews) {
    [v removeFromSuperview];
  }
  self.innerViews = [NSMutableArray array];
  
  _numItems = [self.delegate numberOfItems];
  BOOL shouldLoop = [self.delegate shouldLoopItems];
  
  CGFloat width = [self.delegate widthPerItem];
  float xBase = self.frame.size.width/2-width/2;
  self.scrollView.frame = CGRectMake(xBase, self.scrollView.frame.origin.y, width, self.frame.size.height);
  
  for (int i = 0; i < (shouldLoop ? NUM_REPEATED_FOR_LOOPING : 1); i++) {
    for (int itemNum = 0; itemNum < _numItems; itemNum++) {
      UIView *blurView = [self.delegate viewForItemNum:itemNum];
      _initSize = blurView.frame.size;
      
      blurView.center = ccp(width*itemNum+i*width*_numItems+width/2, self.scrollView.frame.size.height/2);
      [self.scrollView addSubview:blurView];
      [self.innerViews addObject:blurView];
      
      UIImageView *grad = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"covergradient.png"]];
      [blurView addSubview:grad];
      grad.contentMode = UIViewContentModeScaleToFill;
      grad.frame = CGRectMake(blurView.frame.size.width-grad.frame.size.width, 0, grad.frame.size.width, blurView.frame.size.height);
      grad.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    }
  }
  
  if (!shouldLoop) {
    self.scrollView.contentSize = CGSizeMake(width*_numItems, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = ccp(0, 0);
  } else {
    self.scrollView.contentSize = CGSizeMake(NUM_REPEATED_FOR_LOOPING*width*_numItems, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = ccp(NUM_REPEATED_FOR_LOOPING*_numItems/2*width, 0);
  }
  
  [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - Scroll View Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat width = [self.delegate widthPerItem];
  CGFloat scaleFactorForOutOfFocus = [self.delegate scaleForOutOfFocusView];
  
  float curCenter = scrollView.contentOffset.x+scrollView.frame.size.width/2;
  for (UIView *focus in self.innerViews) {
    CGPoint focusCenter = focus.center;
    float distFactor = MIN(1.f, ABS(focusCenter.x-curCenter)/width);
    // Allow close to the center values to be completely unblurred
    distFactor = MAX(0.f, (distFactor-0.2)/0.8);
    
    float alphaBase = focusCenter.x > curCenter ? 0.f : 0.6f;
    focus.alpha = alphaBase+(1-alphaBase)*(1-distFactor);
    for (UIView *v in focus.subviews) {
      if ([v isKindOfClass:[UIImageView class]]) {
        v.alpha = distFactor;
      }
    }
    
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
