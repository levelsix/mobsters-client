//
//  TimingFunctionTableView.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/1/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface TimingFunctionTableView : CancellableTableView

@property (nonatomic, assign) CGSize repeatSize;
@property (nonatomic, assign) UIView *headerUnderlay;

/// @name Managing the Display of Content

/**
 *  Sets the contentOffset of the ScrollView and animates the transition. The
 *  animation takes 0.25 seconds.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction;


/**
 *  Sets the contentOffset of the ScrollView and animates the transition.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 * @param duration       Duration of the animation in seconds.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration;

@end