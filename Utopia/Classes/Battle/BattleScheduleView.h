//
//  BattleScheduleView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BattleScheduleView : UIView

@property (nonatomic, assign) IBOutlet UIImageView *bgdView;
@property (nonatomic, assign) UIImageView *overlayView;
@property (nonatomic, assign) IBOutlet UIView *containerView;
@property (nonatomic, assign) IBOutlet UIImageView *currentBorder;

@property (nonatomic, assign) int numSlots;
@property (nonatomic, retain) NSMutableArray *monsterViews;

- (void) displayOverlayView;
- (void) removeOverlayView;

- (void) setOrdering:(NSArray *)ordering;
- (void) addMonster:(int)monsterId;

@end
