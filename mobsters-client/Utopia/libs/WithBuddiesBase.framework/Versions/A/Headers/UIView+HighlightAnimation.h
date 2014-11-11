//
//  UIView+HighlightAnimation.h
//  WithBuddiesBase
//
//  Created by odyth on 12/7/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HighlightAnimation)

-(void)highlightAnimationWithRepeatCount:(CGFloat)repeatCount completionHandler:(void(^)())completionHandler;
-(void)startHighlightAnimation;
-(void)stopHighlightAnimation;
-(BOOL)isShowingHighlightAnimation;

@end
