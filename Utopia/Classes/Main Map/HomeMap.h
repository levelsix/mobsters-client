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

#define CENTER_TILE_X 13
#define CENTER_TILE_Y 13

#define EXPANSION_BLOCK_SIZE 6
#define EXPANSION_MID_SQUARE_SIZE 6
#define EXPANSION_ROAD_SIZE 2

#define STRUCT_TAG(d) [NSString stringWithFormat:@"UserStruct%d", d]

@class HomeBuildingMenu;

@interface HomeMap : GameMap <MapBotViewDelegate, UpgradeViewControllerDelegate> {
  NSMutableArray *_buildableData;
  BOOL _isMoving;
  BOOL _canMove;
  BOOL _loading;
  BOOL _purchasing;
  BOOL _isSpeedingUp;
  int _purchStructId;
  
  Building *_constrBuilding;
  HomeBuilding *_purchBuilding;
  
  NSMutableArray *_timers;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

@property (nonatomic, retain) IBOutlet MapBotView *buildBotView;
@property (nonatomic, retain) IBOutlet MapBotView *upgradeBotView;
@property (nonatomic, retain) IBOutlet MapBotView *expandBotView;
@property (nonatomic, retain) IBOutlet MapBotView *expandingBotView;

@property (nonatomic, assign) IBOutlet UILabel *buildingNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingIncomeLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingUpgradeButtonTopLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingUpgradeCashCostLabel;
@property (nonatomic, assign) IBOutlet UILabel *buildingUpgradeOilCostLabel;
@property (nonatomic, assign) IBOutlet UIView *buildingUpgradeOilView;
@property (nonatomic, assign) IBOutlet UILabel *enterTopLabel;
@property (nonatomic, assign) IBOutlet UILabel *enterBottomLabel;
@property (nonatomic, assign) IBOutlet UIView *buildingTextView;
@property (nonatomic, assign) IBOutlet UIView *buildingUpgradeView;
@property (nonatomic, assign) IBOutlet UIView *buildingEnterView;

@property (nonatomic, assign) IBOutlet UIButton *enterButton;
@property (nonatomic, assign) IBOutlet UIButton *speedupButton;

@property (nonatomic, assign) IBOutlet UILabel *upgradingNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradingIncomeLabel;
@property (nonatomic, assign) IBOutlet UILabel *upgradingSpeedupCostLabel;

@property (nonatomic, assign) IBOutlet UILabel *expandSubtitleLabel;
@property (nonatomic, assign) IBOutlet UILabel *expandCostLabel;

@property (nonatomic, assign) IBOutlet UILabel *expandingSubtitleLabel;
@property (nonatomic, assign) IBOutlet UILabel *expandingSpeedupCostLabel;

@property (nonatomic, retain) UpgradeViewController *upgradeViewController;

@property (nonatomic, assign, readonly) BOOL loading;
@property (nonatomic, assign) int redGid;
@property (nonatomic, assign) int greenGid;

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
- (BOOL) isBlockBuildable: (CGRect) buildBlock;
- (void) refresh;
- (void) preparePurchaseOfStruct:(int)structId;
- (UserStruct *) sendPurchaseStruct:(BOOL)allowGems;
- (void) purchaseBuildingAllowGems:(BOOL)allowGems;
- (BOOL) speedUpBuilding;
- (void) scrollScreenForTouch:(CGPoint)pt;
- (void) retrieveFromBuilding:(HomeBuilding *)hb;
- (void) updateTimersForBuilding:(MapSprite *)ms;
- (void) invalidateAllTimers;

- (NSArray *) reloadObstacles;

- (void) reselectCurrentSelection;

- (void) sendNormStructComplete:(UserStruct *)us;
- (void) sendSpeedupBuilding:(UserStruct *)us;

- (void) moveToStruct:(int)structId showArrow:(BOOL)showArrow animated:(BOOL)animated;

- (void) beginTimers;

- (void) collectAllIncome;

- (IBAction)finishExpansionClicked:(id)sender;
- (IBAction)littleUpgradeClicked:(id)sender;
- (IBAction)enterClicked:(id)sender;

- (void) constructionComplete:(NSTimer *)timer;
- (void) waitForIncomeComplete:(NSTimer *)timer;

@end
