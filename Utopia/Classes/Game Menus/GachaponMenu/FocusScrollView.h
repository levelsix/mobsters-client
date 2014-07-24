//
//  FocusScrollView.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@protocol FocusScrollViewDelegate

- (int) numberOfItems;
- (CGFloat) widthPerItem;
- (BOOL) shouldLoopItems;
- (UIView *) viewForItemNum:(int)itemNum reusableView:(id)view;
- (CGFloat) scaleForOutOfFocusView;

@end

@interface FocusScrollView : UIView <UIScrollViewDelegate> {
  int _numItems;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableArray *reusableViews;
@property (nonatomic, retain) NSMutableArray *innerViews;

@property (nonatomic, assign) IBOutlet id<FocusScrollViewDelegate> delegate;

- (void) reloadData;

@end
