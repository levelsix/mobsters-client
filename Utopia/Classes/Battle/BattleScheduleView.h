//
//  BattleScheduleView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BattleScheduleViewDelegate <NSObject>
- (void) mobsterViewTapped:(id)sender;
@end

@interface BattleScheduleView : UIView

@property (nonatomic, assign) IBOutlet UIImageView *bgdView;
@property (nonatomic, assign) UIImageView *overlayView;
@property (nonatomic, assign) IBOutlet UIView *containerView;
@property (nonatomic, assign) IBOutlet UIImageView *currentBorder;

@property (nonatomic, assign) int numSlots;
@property (nonatomic, retain) NSMutableArray *monsterViews;

@property (nonatomic, weak) id<BattleScheduleViewDelegate> delegate;

- (void) displayOverlayView;
- (void) removeOverlayView;

- (void) setOrdering:(NSArray *)ordering showEnemyBands:(NSArray *)showEnemyBands playerTurns:(NSArray*)playerTurns;
- (void) addMonster:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player;
- (void) bounceLastView;

@end
