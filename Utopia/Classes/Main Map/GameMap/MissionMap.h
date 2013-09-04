//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"
#import "CCLabelFX.h"
#import "MissionBuildingMenus.h"
#import "MissionMapViews.h"
#import "BossViews.h"

#define ASSET_TAG_BASE 2555

#define DRAGON_TAG 5456

@interface TaskProgressBar : CCSprite {
  CCProgressTimer *_progressBar;
  CCLabelFX *_label;
}

@property (nonatomic, assign) BOOL isAnimating;

- (void) animateBarWithText:(NSString *)str;

@end

@interface MissionMap : GameMap <UserBossDelegate> {
  int _cityId;
  
  TaskProgressBar *_taskProgBar;
  
  BOOL _receivedTaskActionResponse;
  BOOL _performingTask;
  
  NSMutableArray *_jobs;
  
  CCLabelTTF *_bossTimeLabel;
  CCLabelTTF *_powerAttackLabel;
  CCProgressTimer *_powerAttackBar;
  CCSprite *_powerAttackBgd;
  CCMenu *_infoMenu;
  
  int _curPowerAttack;
  
  BOOL _allowSelection;
}

@property (nonatomic, retain) IBOutlet MissionBuildingSummaryMenu *summaryMenu;
@property (nonatomic, retain) IBOutlet MissionOverBuildingMenu *obMenu;
@property (nonatomic, retain) IBOutlet ResetStaminaView *resetStaminaView;
@property (nonatomic, retain) IBOutlet CityGemsView *gemsView;
@property (nonatomic, retain) IBOutlet BossUnlockedView *bossUnlockedView;
@property (nonatomic, retain) IBOutlet CityBossView *bossView;
@property (nonatomic, retain) IBOutlet GemTutorialView *tutView;
@property (nonatomic, retain) IBOutlet BossInfoView *bossInfoView;

@property (nonatomic, retain) NSMutableArray *userGems;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) moveToAssetId:(int)a animated:(BOOL)animated;
- (void) performCurrentTask;
- (void) receivedTaskResponse:(TaskActionResponseProto *)tarp;
- (void) receivedBossResponse:(BossActionResponseProto *)barp;
- (void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk;
- (void) receivedRedeemGemsResponse:(RedeemUserCityGemsResponseProto *)proto;
- (void) endGemTutorial;

- (void) displayGemsView;

- (void) killEnemy:(int)userId;

- (void) closeMenus:(SelectableSprite *)selected;

- (IBAction)bossAttackClicked:(UIView *)sender;

@end
