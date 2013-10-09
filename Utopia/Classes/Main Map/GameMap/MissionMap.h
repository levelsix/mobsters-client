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
#import "MissionMapViews.h"
#import "BossViews.h"

#define ASSET_TAG_BASE 2555

#define DRAGON_TAG 5456

@interface MissionMap : GameMap {
  int _cityId;
  
  NSMutableArray *_jobs;
  
  CCLabelTTF *_bossTimeLabel;
  CCLabelTTF *_powerAttackLabel;
  CCProgressTimer *_powerAttackBar;
  CCSprite *_powerAttackBgd;
  CCMenu *_infoMenu;
  
  int _curPowerAttack;
  
  BOOL _allowSelection;
}

@property (nonatomic, retain) IBOutlet BossUnlockedView *bossUnlockedView;
@property (nonatomic, retain) IBOutlet CityBossView *bossView;
@property (nonatomic, retain) IBOutlet BossInfoView *bossInfoView;

@property (nonatomic, retain) IBOutlet UIView *missionBotView;

@property (nonatomic, assign) IBOutlet UILabel *missionNameLabel;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) moveToAssetId:(int)a animated:(BOOL)animated;
- (void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk;

- (void) killEnemy:(int)userId;

@end
