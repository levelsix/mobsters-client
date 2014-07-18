//
//  UIView+ViewPositioning.h
//  WithBuddiesCore
//
//  Created by Tim Gostony on 8/25/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewPositioning)

#pragma mark - centering
-(void)centerHorizontallyInSuperview;
-(void)centerVerticallyInSuperview;

#pragma mark - getting frame properties
-(CGPoint)origin;
-(CGSize)size;

#pragma mark - directly setting frame properties
-(void)setOrigin:(CGPoint)origin;
-(void)setSize:(CGSize)size;

#pragma mark - edge alignment tools
-(void)topAlignInSuperviewWithMargin:(float)margin;
-(void)leftAlignInSuperviewWithMargin:(float)margin;
-(void)rightAlignInSuperviewWithMargin:(float)margin;
-(void)bottomAlignInSuperviewWithMargin:(float)margin;


#pragma mark - aligning to other views
-(void)topAlignWithView:(UIView*)otherView;
-(void)leftAlignWithView:(UIView*)otherView;
-(void)rightAlignWithView:(UIView*)otherView;
-(void)bottomAlignWithView:(UIView*)otherView;

#pragma mark - reposition view
-(void)moveOriginByOffset:(CGPoint)offset;

#pragma mark - modify size
-(void)changeSizeBySize:(CGSize)size;

#pragma mark - convenience methods for setting autoresizing masks
typedef NS_ENUM(NSUInteger, WBResizeMode)
{
    WBResizeModeFixed,
    WBResizeModeFlexible
};

// base setters
-(void)setResizeModeForWidth:(WBResizeMode)mode;
-(void)setResizeModeForHeight:(WBResizeMode)mode;
-(void)setResizeModeForTopMargin:(WBResizeMode)mode;
-(void)setResizeModeForRightMargin:(WBResizeMode)mode;
-(void)setResizeModeForBottomMargin:(WBResizeMode)mode;
-(void)setResizeModeForLeftMargin:(WBResizeMode)mode;

// convenience size setter
-(void)setResizeModeForWidth:(WBResizeMode)widthMode height:(WBResizeMode)heightMode;

// convenience margin setters
-(void)setResizeModeForAllMargins:(WBResizeMode)allMarginsMode;
-(void)setResizeModeForVerticalMargins:(WBResizeMode)verticalMarginsMode;
-(void)setResizeModeForHorizontalMargins:(WBResizeMode)horizontalMarginsMode;
-(void)setResizeModeForVerticalMargins:(WBResizeMode)verticalMarginsMode horizontalMargins:(WBResizeMode)horizontalMarginsMode;
-(void)setResizeModeForTopMargin:(WBResizeMode)topMarginMode rightMargin:(WBResizeMode)rightMarginMode bottomMargin:(WBResizeMode)bottomMarginMode leftMargin:(WBResizeMode)leftMarginMode;

// convenience size + margin setters
-(void)setResizeModeForWidth:(WBResizeMode)widthMode height:(WBResizeMode)heightMode allMargins:(WBResizeMode)allMarginsMode;
-(void)setResizeModeForWidth:(WBResizeMode)widthMode height:(WBResizeMode)heightMode verticalMargins:(WBResizeMode)verticalMarginsMode horizontalMargins:(WBResizeMode)horizontalMarginsMode;
-(void)setResizeModeForWidth:(WBResizeMode)widthMode height:(WBResizeMode)heightMode topMargin:(WBResizeMode)topMarginMode rightMargin:(WBResizeMode)rightMarginMode bottomMargin:(WBResizeMode)bottomMarginMode leftMargin:(WBResizeMode)leftMarginMode;

#pragma mark - higher-level methods for setting resize masks

typedef NS_ENUM(NSUInteger, WBFrameMode)
{
    WBFrameModeGrowsWithParent,
    WBFrameModeTopAligned,
    WBFrameModeCenterAligned,
    WBFrameModeBottomAligned,
    WBFrameModeLeftAligned = WBFrameModeTopAligned,
    WBFrameModeRightAligned = WBFrameModeBottomAligned
};

-(void)applyFrameModeVertical:(WBFrameMode)frameMode;
-(void)applyFrameModeHorizontal:(WBFrameMode)frameMode;



@end
