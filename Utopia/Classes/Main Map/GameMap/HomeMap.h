//
//  HomeMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "HomeBuildingMenus.h"
#import "AnimatedSprite.h"

#define CENTER_TILE_X 18
#define CENTER_TILE_Y 18
#define ROAD_SIZE 2

#define EXPANSION_BLOCK_SIZE 8
#define EXPANSION_MID_SQUARE_SIZE 12
#define EXPANSION_ROAD_SIZE 2
#define EXPANSION_OVERLAY_OFFSETS \
{{ccp(0.2, 0.2), ccp(0,-0.1), ccp(0.1,-1.)}, \
{ccp(0,0.1), ccp(0,0), ccp(-0.1,-0.3)}, \
{ccp(-1.05,0.2), ccp(-0.3,0), ccp(-1,-1.05)}}

@class HomeBuildingMenu;

@interface HomeMap : GameMap {
  NSMutableArray *_buildableData;
  BOOL _isMoving;
  BOOL _canMove;
  BOOL _loading;
  BOOL _purchasing;
  BOOL _isSpeedingUp;
  int _purchStructId;
  
  MoneyBuilding *_constrBuilding;
  MoneyBuilding *_upgrBuilding;
  HomeBuilding *_purchBuilding;
  
  NSMutableArray *_timers;
  
  TutorialGirl *_tutGirl;
  Carpenter *_carpenter;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

@property (nonatomic, retain) IBOutlet HomeBuildingMenu *hbMenu;
@property (nonatomic, retain) IBOutlet HomeBuildingCollectMenu *collectMenu;
@property (nonatomic, retain) IBOutlet UpgradeBuildingMenu *upgradeMenu;
@property (nonatomic, retain) IBOutlet ExpansionView *expansionView;
@property (nonatomic, retain) IBOutlet UIView *buildBotView;
@property (nonatomic, retain) IBOutlet UIView *upgradeBotView;
@property (nonatomic, retain) IBOutlet UIView *expandBotView;
@property (nonatomic, retain) IBOutlet UIView *expandingBotView;

@property (nonatomic, assign) IBOutlet UILabel *buildingNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingIncomeLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingUpgradeCostLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradingNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *expandingCostLabel;

@property (nonatomic, assign, readonly) BOOL loading;
@property (nonatomic, assign) int redGid;
@property (nonatomic, assign) int greenGid;

+ (HomeMap *)sharedHomeMap;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
- (BOOL) isBlockBuildable: (CGRect) buildBlock;
- (void) refresh;
- (int) baseTagForStructId:(int)structId;
- (void) preparePurchaseOfStruct:(int)structId;
- (void) scrollScreenForTouch:(CGPoint)pt;
- (void) retrieveFromBuilding:(HomeBuilding *)hb;
- (void) updateTimersForBuilding:(HomeBuilding *)hb;
- (void) invalidateAllTimers;

- (void) moveToStruct:(int)structId showArrow:(BOOL)showArrow animated:(BOOL)animated;
- (void) moveToTutorialGirlAnimated:(BOOL)animated;
- (void) moveToCarpenterShowArrow:(BOOL)showArrow structId:(int)structId animated:(BOOL)animated;

- (void) beginTimers;

- (void) collectAllIncome;

- (IBAction)finishExpansionClicked:(id)sender;

- (void) buildComplete:(NSTimer *)timer;
- (void) upgradeComplete:(NSTimer *)timer;
- (void) waitForIncomeComplete:(NSTimer *)timer;

@end
