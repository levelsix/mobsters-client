//
//  MapBotView.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapBotView;

@protocol MapBotViewDelegate <NSObject>

- (void) updateMapBotView:(MapBotView *)botView;

@end

@interface MapBotView : UIView

@property (nonatomic, assign) IBOutlet id<MapBotViewDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *animateViews;

- (void) update;
- (void) animateIn:(void(^)())block;
- (void) animateOut:(void(^)())block;

@end