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
#import "HomeBuilding.h"
#import "UpgradeViewController.h"
#import "SpeedupItemsFiller.h"

#define CENTER_TILE_X 13
#define CENTER_TILE_Y 13

#define EXPANSION_BLOCK_SIZE 6
#define EXPANSION_MID_SQUARE_SIZE 6
#define EXPANSION_ROAD_SIZE 2

#define STRUCT_TAG(d) [NSString stringWithFormat:@"UserStruct%@", d]

@class HomeBuildingMenu;

@interface HomeMap : GameMap <MapBotViewDelegate, MapBotViewButtonDelegate, UpgradeViewControllerDelegate> {
  NSMutableArray *_buildableData;
  BOOL _isMoving;
  BOOL _canMove;
  BOOL _purchasing;
  BOOL _isSpeedingUp;
  int _purchStructId;
  
  Building *_constrBuilding;
  HomeBuilding *_purchBuilding;
  
  NSMutableArray *_timers;
  
  Building *_arrowBuilding;
  MapBotViewButtonConfig _arrowButtonConfig;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

@property (nonatomic, retain) IBOutlet MapBotView *buildBotView;
@property (nonatomic, assign) IBOutlet THLabel *buildingNameLabel;

@property (nonatomic, retain) UIViewController *currentViewController;
@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;

@property (nonatomic, assign, readonly) BOOL loading;
@property (nonatomic, assign) int redGid;
@property (nonatomic, assign) int greenGid;

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
- (BOOL) isBlockBuildable: (CGRect) buildBlock;
- (void) refresh;
- (void) preparePurchaseOfStruct:(int)structId;
- (UserStruct *) sendPurchaseStruct:(BOOL)allowGems;
- (void) purchaseBuildingAllowGems:(BOOL)allowGems;

- (void) pointArrowOnManageTeam;
- (void) pointArrowOnSellMobsters;
- (void) pointArrowOnUpgradeResidence;
- (void) pointArrowOnBuilding:(HomeBuilding *)b config:(MapBotViewButtonConfig)config;

- (BOOL) speedUpBuilding;
- (void) scrollScreenForTouch:(CGPoint)pt;
- (void) retrieveFromBuilding:(HomeBuilding *)hb;
- (void) invalidateAllTimers;

- (NSArray *) reloadObstacles;
- (void) reloadTeamCenter;

- (void) reselectCurrentSelection;

- (void) sendNormStructComplete:(UserStruct *)us;
- (void) sendSpeedupBuilding:(UserStruct *)us;

- (BOOL) moveToStruct:(int)structId animated:(BOOL)animated;

- (void) beginTimers;

- (void) reloadBubblesOnMiscBuildings;

- (void) collectAllIncome;

- (IBAction)littleUpgradeClicked:(id)sender;
- (IBAction)enterClicked:(id)sender;
- (IBAction)finishNowClicked:(id)sender;
- (IBAction)getHelpClicked:(id)sender;

- (void) constructionComplete:(NSTimer *)timer;
- (void) waitForIncomeComplete:(NSTimer *)timer;

@end
