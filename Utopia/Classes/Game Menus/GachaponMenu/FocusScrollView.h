//
//  FocusScrollView.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface FocusImageView : UIView {
  float _blurRadius;
  CGSize _initSize;
  BOOL _isProcessing;
}

@property (nonatomic, retain) GPUImagePicture *picture;
@property (nonatomic, retain) GPUImageGaussianBlurFilter *blurFilter;
@property (nonatomic, retain) GPUImageView *blurView;

- (id) initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void) setBlurRadius:(float)blurRadius;

@end

@protocol FocusScrollViewDelegate

- (int) numberOfItems;
- (CGFloat) widthPerItem;
- (BOOL) shouldLoopItems;
- (UIView *) viewForItemNum:(int)itemNum;
- (CGFloat) scaleForOutOfFocusView;

@end

@interface FocusScrollView : UIView <UIScrollViewDelegate> {
  int _numItems;
  CGSize _initSize;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableArray *innerViews;

@property (nonatomic, assign) IBOutlet id<FocusScrollViewDelegate> delegate;

- (void) reloadData;

@end
