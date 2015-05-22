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

@interface SideEffectActiveTurns : NSObject

@property (nonatomic, retain) NSString* displaySymbol;
@property (nonatomic, assign) NSInteger playerTurns;
@property (nonatomic, assign) NSInteger enemyTurns;

@end

@class BattleSchedule;

@interface BattleScheduleView : UIView
{
  __weak BattleSchedule* _battleSchedule;
  
  NSMutableDictionary* _upcomingSideEffectTurns;
}

@property (nonatomic, assign) IBOutlet UIImageView *bgdView;
@property (nonatomic, assign) UIImageView *overlayView;
@property (nonatomic, assign) IBOutlet UIView *containerView;
@property (nonatomic, assign) IBOutlet UIImageView *currentBorder;

@property (nonatomic, assign) int numSlots;
@property (nonatomic, retain) NSMutableArray *monsterViews;

@property (nonatomic, readonly) BOOL reorderingInProgress;

@property (nonatomic, weak) id<BattleScheduleViewDelegate> delegate;

- (void) setBattleSchedule:(__weak BattleSchedule*)battleSchedule;

- (void) displayOverlayView;
- (void) removeOverlayView;

- (void) setOrdering:(NSArray *)ordering showEnemyBands:(NSArray *)showEnemyBands playerTurns:(NSArray*)playerTurns;
- (void) addMonster:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player speed:(float)speed;

- (void) bounceLastView:(float)speed;

- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key forUpcomingNumberOfTurns:(NSInteger)numTurns forPlayer:(BOOL)player;
- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key forUpcomingNumberOfOpponentTurns:(NSInteger)numTurns forPlayer:(BOOL)player;
- (void) removeSideEffectIconWithKey:(NSString*)key onAllUpcomingTurnsForPlayer:(BOOL)player;

@end
