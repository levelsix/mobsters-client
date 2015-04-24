//
//  NewGachaFocusScrollView.h
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@protocol NewGachaFocusScrollViewDelegate

- (int) numberOfItems;
- (CGFloat) widthPerItem;
- (BOOL) shouldLoopItems;
- (UIView *) viewForItemNum:(int)itemNum reusableView:(id)view;
- (CGFloat) scaleForOutOfFocusView;

@end

@interface NewGachaFocusScrollView : UIView <UIScrollViewDelegate> {
  int _numItems;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;

@property (nonatomic, retain) NSMutableArray *reusableViews;
@property (nonatomic, retain) NSMutableArray *innerViews;

@property (nonatomic, weak) IBOutlet id<NewGachaFocusScrollViewDelegate> delegate;

- (void) reloadData;

@end
