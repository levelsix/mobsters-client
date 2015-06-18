//
//  HomeMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "HomeMap.h"
#import "Building.h"
#import "Globals.h"
#import "GameState.h"
#import "UserData.h"
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"
#import "CCAnimation+SpriteLoading.h"
#import "CCSoundAnimation.h"
#import "AchievementUtil.h"
#import "HireViewController.h"
#import "HomeViewController.h"
#import "PersistentEventProto+Time.h"
#import "SpeedupItemsFiller.h"
#import "IAPHelper.h"
#import "MiniEventManager.h"
#import "LeaderBoardBuilding.h"
#import "LeaderBoardViewController.h"

#define FAR_LEFT_EXPANSION_START 58
#define FAR_RIGHT_EXPANSION_START 58
#define NEAR_LEFT_EXPANSION_START 45
#define NEAR_RIGHT_EXPANSION_START 45
#define EXPANSION_EXTRA_TILES 3

#define EXPANSION_LAYER_NAME @"Expansion"
#define BUILDABLE_LAYER_NAME @"Buildable"
#define METATILES_LAYER_NAME @"MetaLayer"
#define WALKABLE_LAYER_NAME @"Walkable"
#define TREES_LAYER_NAME @"Treez"

#define PURCHASE_CONFIRM_MENU_TAG @"PurchConfirm"

#define RESOURCE_GEN_MIN_AMT 0.03

@implementation HomeMap

@synthesize redGid, greenGid;

- (id) init {
  self = [self initWithFile:@"maptest.tmx"];
  return self;
}

- (id) initWithFile:(NSString *)tmxFile {
  if ((self = [super initWithFile:tmxFile])) {
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    
    for (CCNode *child in [self children]) {
      if ([child isKindOfClass:[CCTiledMapLayer class]]) {
        CCTiledMapLayer *layer = (CCTiledMapLayer *)child;
        if ([[layer layerName] isEqualToString: METATILES_LAYER_NAME]) {
          // Put meta tile layer at front,
          // when something is selected, we will make it z = 1000
          child.zOrder = 1001;
          CGPoint redGidPt = ccp(_mapSize.width-1, _mapSize.height-1);
          CGPoint greenGidPt = ccp(_mapSize.width-1, _mapSize.height-2);
          redGid = [layer tileGIDAt:redGidPt];
          greenGid = [layer tileGIDAt:greenGidPt];
          [layer removeTileAt:redGidPt];
          [layer removeTileAt:greenGidPt];
        } else {
          child.zOrder = -1;
        }
      }
    }
    
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.buildableData addObject:row];
    }
    
    self.walkableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.walkableData addObject:row];
    }
    
    CCTiledMapLayer *layer = [self layerNamed:BUILDABLE_LAYER_NAME];
    layer.visible = NO;
    layer = [self layerNamed:WALKABLE_LAYER_NAME];
    layer.visible = NO;
    
    [self setUpHomeBuildingMenu];
    
    _timers = [[NSMutableArray alloc] init];
    
    [self moveToCenterAnimated:NO];
    
    CCSprite *map = [CCSprite spriteWithImageNamed:@"homemapbig.jpg"];
    [self addChild:map z:-1000];
    
    
//    CCSprite *map2 = [CCSprite spriteWithImageNamed:@"homemapright.jpg"];
//    [map addChild:map2];
//    map2.position = ccp(map.contentSize.width+map2.contentSize.width/2, map.contentSize.height/2);
//    map.contentSize = CGSizeMake(map.contentSize.width+map2.contentSize.width, map.contentSize.height);
    
    map.position = ccp(map.contentSize.width/2-30, map.contentSize.height/2-50);
    
    [self beginMapAnimations];
    
    bottomLeftCorner = ccp(map.position.x-map.contentSize.width/2, map.position.y-map.contentSize.height/2);
    topRightCorner = ccp(map.position.x+map.contentSize.width/2, map.position.y+map.contentSize.height/2);
  }
  return self;
}

- (void) setUpHomeBuildingMenu {
  [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
  
  self.buildingNameLabel.strokeSize = 1.5f;
  self.buildingNameLabel.strokeColor = [UIColor colorWithWhite:51/255.f alpha:1.f];
  self.buildingNameLabel.shadowBlur = 0.9f;
  self.buildingNameLabel.gradientStartColor = [UIColor whiteColor];
  self.buildingNameLabel.gradientEndColor = [UIColor colorWithWhite:245/255.f alpha:1.f];
}

- (void) beginMapAnimations {
  [self createBoat];
  
  [self schedule:@selector(createNewWave) interval:3.5f];
}

- (void) createBoat {
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Boat.plist"];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"Boat" delay:0.1];
  CCSprite *boat = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [boat runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  [self addChild:boat z:1];
  boat.position = ccp(970, 80);
}

- (void) createNewWave {
  [self createNewWave:NO];
}

- (CCSprite *)createWave {
  CCSprite *wave = [CCSprite spriteWithImageNamed:@"wave.png"];
  
  // Right
  CCSprite *w1 = [CCSprite spriteWithImageNamed:@"wave.png"];
  w1.position = ccp(wave.contentSize.width, wave.contentSize.height/2);
  [wave addChild:w1];
  
  // Far Right
  w1 = [CCSprite spriteWithImageNamed:@"wave.png"];
  w1.position = ccp(wave.contentSize.width*3/2, wave.contentSize.height/2);
  [wave addChild:w1];
  
  // Left
  w1 = [CCSprite spriteWithImageNamed:@"wave.png"];
  w1.position = ccp(0, wave.contentSize.height/2);
  [wave addChild:w1];
  
  // Far Left
  w1 = [CCSprite spriteWithImageNamed:@"wave.png"];
  w1.position = ccp(-wave.contentSize.width/2, wave.contentSize.height/2);
  [wave addChild:w1];
  
  return wave;
}

- (void) createNewWave:(BOOL)right {
  CGPoint startPos = ccp(100, 90);
  CGPoint farEndPos = ccp(192, 164);
  CGPoint finalEndPos = ccp(175, 153);
  float dur1 = 5.0f, dur2 = 0.9f;
  float waveMove1 = 100, waveMove2 = 10;
  
  if (right) {
    startPos.x = self.contentSize.width-startPos.x+5;
    farEndPos.x = self.contentSize.width-farEndPos.x+5;
    finalEndPos.x = self.contentSize.width-finalEndPos.x+5;
  }
  
  CCNode *node = [CCNode node];
  node.position = startPos;
  node.rotation = 35.85*(1-right*2);
  [self addChild:node];
  
  [node runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:dur1 position:farEndPos],
    [CCActionMoveTo actionWithDuration:dur2 position:finalEndPos],
    [CCActionCallFunc actionWithTarget:node selector:@selector(removeFromParent)],
    nil]];
  
  CCSprite *wave = [self createWave];
  [node addChild:wave];
  
  [wave recursivelyApplyOpacity:0.f];
  [wave runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:dur1 opacity:1.f],
    [RecursiveFadeTo actionWithDuration:dur2 opacity:0.f],
    nil]];
  [wave runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(-waveMove1, 0)],
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(-waveMove2, 2)],
    nil]];
  
  
  CCSprite *wave2 = [self createWave];
  wave2.position = ccp(0, -5);
  [node addChild:wave2];
  
  [wave2 recursivelyApplyOpacity:0.f];
  [wave2 runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:dur1 opacity:0.5f],
    [RecursiveFadeTo actionWithDuration:dur2 opacity:0.f],
    nil]];
  [wave2 runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(waveMove1, 0)],
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(waveMove2, 2)],
    nil]];
  
  
  CCSprite *wave3 = [self createWave];
  wave3.position = ccp(0, -10);
  [node addChild:wave3];
  
  [wave3 recursivelyApplyOpacity:0.f];
  [wave3 runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:dur1 opacity:0.2f],
    [RecursiveFadeTo actionWithDuration:dur2 opacity:0.f],
    nil]];
  [wave3 runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(-waveMove1, 0)],
    [CCActionMoveTo actionWithDuration:dur1 position:ccp(-waveMove2, 4)],
    nil]];
}

- (NSArray *) myStructsList {
  GameState *gs = [GameState sharedGameState];
  return [gs myStructs];
}

- (int) numberOfBuilders {
  GameState *gs = [GameState sharedGameState];
  return gs.numberOfBuilders;
}

- (void) refresh {
  if (_loading) return;
  self.selected = nil;
  _loading = YES;
  _waitingForResponse = NO;
  
  [self invalidateAllTimers];
  
  NSMutableArray *arr = [NSMutableArray array];

  [arr addObjectsFromArray:[self refreshForExpansion]];
  
  LeaderBoardBuilding *leaderBoardBuilding = [[LeaderBoardBuilding alloc] initWithFile:@"leaderboardstatue.png" location:CGRectMake(42, 18.5, 2, 2) map:self];
  [self addChild:leaderBoardBuilding z:0 name:@"leaderboard"];
  [arr addObject:leaderBoardBuilding];
  
  [self setupTeamSprites];
  [arr addObjectsFromArray:self.myTeamSprites];
  
  for (UserStruct *s in self.myStructsList) {
    StructureInfoProto *fsp = s.staticStruct.structInfo;
    if (!fsp)
      continue;
    
    HomeBuilding *homeBuilding = [HomeBuilding buildingWithUserStruct:s map:self];
    [self addChild:homeBuilding z:0 name:STRUCT_TAG(s.userStructUuid)];
    
    [arr addObject:homeBuilding];
    [homeBuilding placeBlock:NO];
    
    if (!s.isComplete) {
      homeBuilding.isConstructing = YES;
      [homeBuilding displayProgressBar];
    }
  }
  
  [arr addObjectsFromArray:[self reloadObstacles]];
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (CCNode *c in self.children) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      [toRemove addObject:c];
    }
  }
  
  for (SelectableSprite *c in toRemove) {
    [c removeFromParent];
  }
  
  [self reloadUpgradeSigns];
  [self reloadAllBubbles];
  
  // Search through the structs and see if any are at 0,0
  for (HomeBuilding *hb in [self childrenOfClassType:[HomeBuilding class]]) {
    if (CGPointEqualToPoint(hb.location.origin, CGPointZero)) {
      UserStruct *us = hb.userStruct;
      StructureInfoProto *fsp = us.staticStruct.structInfo;
      CGPoint coords = [self openSpaceNearCenterWithSize:CGSizeMake(fsp.width, fsp.height)];
      
      [hb liftBlock];
      hb.location = CGRectMake(coords.x, coords.y, fsp.width, fsp.height);
      [hb placeBlock:NO];
      
      [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:us atX:coords.x atY:coords.y];
    }
  }
  
  [self doReorder];
  _loading = NO;
  
  if (self.isRunningInActiveScene) {
    [self beginTimers];
  }
}

#pragma mark - Obstacles

- (ObstacleProto *) randomObstacle {
  GameState *gs = [GameState sharedGameState];
  NSArray *obstacles = gs.staticObstacles.allValues;
  NSMutableArray *normalizedPercs = [NSMutableArray array];
  
  float sum = 0;
  for (ObstacleProto *op in obstacles) {
    sum += op.chanceToAppear;
  }
  if (sum <= 0) {
    return nil;
  }
  
  for (ObstacleProto *op in obstacles) {
    [normalizedPercs addObject:@(op.chanceToAppear/sum)];
  }
  
  float rand = CCRANDOM_0_1();
  float curPerc = 0;
  for (int i = 0; i < obstacles.count; i++) {
    float val = [normalizedPercs[i] floatValue];
    
    if (rand < curPerc+val) {
      return obstacles[i];
    } else {
      curPerc += val;
    }
  }
  return nil;
}

- (UserObstacle *) createNewObstacle {
  ObstacleProto *op = [self randomObstacle];
  
  if (op) {
    CGPoint pt = [self randomOpenSpaceWithSize:CGSizeMake(op.width, op.height)];
    
    if (!CGPointEqualToPoint(pt, ccp(-1, -1))) {
      UserObstacle *uo = [[UserObstacle alloc] init];
      uo.obstacleId = op.obstacleId;
      uo.coordinates = pt;
      uo.orientation = arc4random()%2 ? StructOrientationPosition1 : StructOrientationPosition2;
      
      return uo;
    }
  }
  return nil;
}

- (NSArray *) reloadObstacles {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSArray *obstacles = gs.myObstacles;
  NSMutableArray *sprites = [NSMutableArray array];
  for (UserObstacle *uo in obstacles) {
    ObstacleSprite *os = [[ObstacleSprite alloc] initWithObstacle:uo map:self];
    [self addChild:os z:0 name:STRUCT_TAG(uo.userObstacleUuid)];
    
    if (uo.endTime) {
      [os displayProgressBar];
    }
    
    [sprites addObject:os];
  }
  
  NSInteger numObstacles = obstacles.count;
  if (numObstacles < gl.maxObstacles) {
    MSDate *lastCreated = gs.lastObstacleCreateTime;
    NSInteger numToCreate = lastCreated ? (-lastCreated.timeIntervalSinceNow)/(gl.minutesPerObstacle*60.f) : gl.maxObstacles;
    numToCreate = MIN(numToCreate, gl.maxObstacles-numObstacles);
    
    LNLog(@"Generating %d more obstacles.", (int)numToCreate);
    
    NSMutableArray *newObstacles = [NSMutableArray array];
    for (int i = 0; i < numToCreate; i++) {
      UserObstacle *uo = [self createNewObstacle];
      
      if (uo) {
        ObstacleSprite *os = [[ObstacleSprite alloc] initWithObstacle:uo map:self];
        [self addChild:os];
        
        [sprites addObject:os];
        [newObstacles addObject:uo];
      }
    }
    
    if (newObstacles.count > 0) {
      [[OutgoingEventController sharedOutgoingEventController] spawnObstacles:newObstacles delegate:self];
    }
  }
  
  return sprites;
}

- (void) handleSpawnObstacleResponseProto:(FullEvent *)fe {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (ObstacleSprite *ob in self.children) {
    if ([ob isKindOfClass:[ObstacleSprite class]]) {
      [toRemove addObject:ob];
    }
  }
  
  for (ObstacleSprite *ob in toRemove) {
    [ob removeFromParent];
  }
  
  [self reloadObstacles];
}

#pragma mark - Reloading buildings

- (NSArray *) refreshForExpansion {
  NSMutableArray *arr = [NSMutableArray array];
  
  CCTiledMapLayer *buildLayer = [self layerNamed:BUILDABLE_LAYER_NAME];
  CCTiledMapLayer *walkLayer = [self layerNamed:WALKABLE_LAYER_NAME];
  int width = self.mapSize.width;
  int height = self.mapSize.height;
  
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      NSMutableArray *brow = [self.buildableData objectAtIndex:i];
      NSMutableArray *wrow = [self.walkableData objectAtIndex:i];
      
      [brow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
      [wrow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
      
      // Convert their coordinates to our coordinate system
      CGPoint tileCoord = ccp(height-j-1, width-i-1);
      int btileGid = [buildLayer tileGIDAt:tileCoord];
      if (btileGid) {
        [brow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
      }
      
      int wtileGid = [walkLayer tileGIDAt:tileCoord];
      if (wtileGid || btileGid) {
        [wrow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
      }
    }
  }
  
  return arr;
}

- (void) reloadHospitals {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int hurtMobsters = 0;
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && um.curHealth < [gl calculateMaxHealthForMonster:um]) {
      hurtMobsters++;
    }
  }
  
  for (CCSprite *spr in [self childrenOfClassType:[HospitalBuilding class]]) {
    HospitalBuilding *hosp = (HospitalBuilding *)spr;
    UserStruct *s = hosp.userStruct;
    HospitalQueue *hq = [gs hospitalQueueForUserHospitalStructUuid:s.userStructUuid];
    UserMonsterHealingItem *hi = [hq.healingItems firstObject];
    
    if (hi) {
      [hosp beginAnimatingWithHealingItem:hi];
      
      [hosp setBubbleType:BuildingBubbleTypeNone];
    } else {
      [hosp stopAnimating];
      
      [hosp setBubbleType:hurtMobsters ? BuildingBubbleTypeHeal : BuildingBubbleTypeNone withNum:hurtMobsters];
    }
  }
}

- (void) reloadItemFactory {
  GameState *gs = [GameState sharedGameState];
  
  for (CCSprite *spr in [self childrenOfClassType:[ItemFactoryBuilding class]]) {
    ItemFactoryBuilding *ifb = (ItemFactoryBuilding *)spr;
    BattleItemQueue *hq = gs.battleItemUtil.battleItemQueue;
    BattleItemQueueObject *item = [hq.queueObjects firstObject];
    
    if (item) {
      [ifb beginAnimatingWithBattleItemQueueObject:item];
      
      [ifb setBubbleType:BuildingBubbleTypeNone];
    } else {
      [ifb stopAnimating];
      
      BattleItemFactoryProto *bif = (BattleItemFactoryProto *)ifb.userStruct.staticStruct;
      int quantity = [gs.battleItemUtil totalPowerAmount];
      BOOL showBubble = quantity < bif.powerLimit;
      [ifb setBubbleType:showBubble ? BuildingBubbleTypeCreate : BuildingBubbleTypeNone];
    }
  }
}

- (void) reloadMiniJobCenter {
  GameState *gs = [GameState sharedGameState];
  UserStruct *mjc = [gs myMiniJobCenter];
  
  if (mjc) {
    MiniJobCenterBuilding *mjcb = (MiniJobCenterBuilding *)[self getChildByName:STRUCT_TAG(mjc.userStructUuid) recursively:NO];
    
    if (mjc.staticStruct.structInfo.level == 0) {
      [mjcb setBubbleType:BuildingBubbleTypeFix];
    } else {
      [mjcb setBubbleType:BuildingBubbleTypeNone];
      
      UserMiniJob *active = nil;
      for (UserMiniJob *mj in gs.myMiniJobs) {
        if (mj.timeStarted || mj.timeCompleted) {
          active = mj;
        }
      }
      
      // Only set the activeMiniJob if the mini job timer is currently active. Otherwise use a bubble.
      if (!active && gs.myMiniJobs.count > 0) {
        [mjcb setBubbleType:BuildingBubbleTypeMiniJob withNum:(int)gs.myMiniJobs.count];
        [mjcb updateForActiveMiniJob:nil];
      } else {
        if (active.timeCompleted) {
          [mjcb setBubbleType:BuildingBubbleTypeComplete];
          [mjcb updateForActiveMiniJob:nil];
        } else {
          [mjcb updateForActiveMiniJob:active];
        }
      }
    }
  }
}

- (void) reloadStorages {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *oilArr = [NSMutableArray array];
  NSMutableArray *cashArr = [NSMutableArray array];
  for (CCSprite *spr in [self childrenOfClassType:[ResourceStorageBuilding class]]) {
    ResourceType type = ((ResourceStorageProto *)((ResourceStorageBuilding *)spr).userStruct.staticStruct).resourceType;
    if (type == ResourceTypeCash) {
      [cashArr addObject:spr];
    } else if (type == ResourceTypeOil) {
      [oilArr addObject:spr];
    }
  }
  
  int curCash = gs.cash;
  int curOil = gs.oil;
  BOOL cashFull = curCash >= [gs maxCash];
  BOOL oilFull = curOil >= [gs maxOil];
  
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStructForCurrentConstructionLevel];
  
  NSComparator comp = ^NSComparisonResult(ResourceStorageBuilding *obj1, ResourceStorageBuilding *obj2) {
    int capacity1 = ((ResourceStorageProto *)obj1.userStruct.staticStructForCurrentConstructionLevel).capacity;
    int capacity2 = ((ResourceStorageProto *)obj2.userStruct.staticStructForCurrentConstructionLevel).capacity;
    return [@(capacity1) compare:@(capacity2)];
  };
  [cashArr sortUsingComparator:comp];
  [oilArr sortUsingComparator:comp];
  
  for (NSMutableArray *arr in @[cashArr, oilArr]) {
    int curVal = arr == cashArr ? curCash : curOil;
    curVal -= thp.resourceCapacity;
    BuildingBubbleType bubbleType = (arr == cashArr ? cashFull : oilFull) ? BuildingBubbleTypeFull : BuildingBubbleTypeNone;
    while (arr.count > 0) {
      NSInteger count = arr.count;
      int amount = curVal/count;
      ResourceStorageBuilding *res = arr[0];
      int capacity1 = ((ResourceStorageProto *)res.userStruct.staticStruct).capacity;
      
      if (capacity1 >= amount) {
        // Rest of the storages can handle cap
        for (ResourceStorageBuilding *r in arr) {
          float cap = ((ResourceStorageProto *)r.userStruct.staticStruct).capacity;
          [r setPercentage:amount/cap];
          
          [r setBubbleType:bubbleType];
        }
        break;
      } else {
        // This storage is full
        [res setPercentage:1.f];
        curVal -= capacity1;
        [arr removeObject:res];
        
        [res setBubbleType:bubbleType];
      }
    }
  }
}

- (NSArray *)childrenOfClassType:(Class)class {
  NSMutableArray *arr = [NSMutableArray array];
  for (id obj in self.children) {
    if ([obj isKindOfClass:class]) {
      [arr addObject:obj];
    }
  }
  return arr;
}

- (void) reloadTeamCenter {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int numOnTeam = (int)[gs allBattleAvailableAliveMonstersOnTeamWithClanSlot:NO].count;
  
  BOOL hasAvailMobsters = NO;
  for (UserMonster *um in gs.myMonsters) {
    if ([um isAvailable] && !um.teamSlot && um.curHealth > 0 && [gl currentBattleReadyTeamHasCostFor:um]) {
      hasAvailMobsters = YES;
    }
  }
  
  BuildingBubbleType type = !numOnTeam || (numOnTeam < gl.maxTeamSize && hasAvailMobsters) ? BuildingBubbleTypeTeamRed : BuildingBubbleTypeTeamGreen;
  
  for (TeamCenterBuilding *b in [self childrenOfClassType:[TeamCenterBuilding class]]) {
    [b setBubbleType:type withNum:numOnTeam];
    [b setNumEquipped:numOnTeam];
  }
}

- (void) reloadClanHouse {
  GameState *gs = [GameState sharedGameState];
  for (ClanHouseBuilding *b in [self childrenOfClassType:[ClanHouseBuilding class]]) {
    if (b != _purchBuilding) {
      if (!gs.clan) {
        [b setBubbleType:BuildingBubbleTypeJoinClan];
      } else {
        // Check if anyone needs help
        int numHelps = (int)[gs.clanHelpUtil getAllHelpableClanHelps].count;
        if (numHelps > 0) {
          [b setBubbleType:BuildingBubbleTypeClanHelp withNum:numHelps];
        } else {
          [b setBubbleType:BuildingBubbleTypeNone];
        }
      }
    }
  }
}

- (void) reloadBubblesOnMiscBuildings {
  GameState *gs = [GameState sharedGameState];
  
  int numOverInv = [gs currentlyUsedInventorySlots] - [gs maxInventorySlots];
  for (Building *b in [self childrenOfClassType:[ResidenceBuilding class]]) {
    [b setBubbleType:(numOverInv > 0 ? BuildingBubbleTypeSell : BuildingBubbleTypeNone)  withNum:numOverInv];
  }
  
  BOOL evoInProgress = gs.userEvolution != nil;
  for (EvoBuilding *b in [self childrenOfClassType:[EvoBuilding class]]) {
    if (!evoInProgress) {
      // Check for live scientist event
      PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
      
      [b stopAnimating];
      if (pe && pe.cooldownEndTime.timeIntervalSinceNow <= 0) {
        [b setBubbleType:BuildingBubbleTypeScientist withNum:pe.monsterElement];
      } else {
        [b setBubbleType:BuildingBubbleTypeEvolve];
      }
    } else {
      [b setBubbleType:BuildingBubbleTypeNone];
      [b beginAnimatingWithEvolution:gs.userEvolution];
    }
  }
  
  BOOL enhancementInProgress = gs.userEnhancement && !gs.userEnhancement.isComplete;
  for (LabBuilding *b in [self childrenOfClassType:[LabBuilding class]]) {
    if (enhancementInProgress) {
      [b setBubbleType:BuildingBubbleTypeNone];
      [b beginAnimatingWithEnhancement:gs.userEnhancement];
    } else {
      [b stopAnimating];
      if (gs.userEnhancement.isComplete) {
        [b setBubbleType:BuildingBubbleTypeComplete];
      } else if (b.userStruct.staticStruct.structInfo.level > 0) {
        // Check for live cake kid event
        BOOL showFatKid = NO;
        
        PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
        if (pe && [Globals shouldShowFatKidDungeon]) {
          int cdTimeLeft = pe.cooldownEndTime.timeIntervalSinceNow;
          
          showFatKid = cdTimeLeft <= 0;
        }
        
        if (showFatKid) {
          [b setBubbleType:BuildingBubbleTypeCakeKid withNum:pe.monsterElement];
        } else {
          [b setBubbleType:BuildingBubbleTypeEnhance];
        }
      } else {
        [b setBubbleType:BuildingBubbleTypeLocked];
      }
    }
  }
  
  UserResearch *ur = [gs.researchUtil currentResearch];
  for (ResearchBuilding *b in [self childrenOfClassType:[ResearchBuilding class]]) {
    if (ur) {
      [b beginAnimatingWithUserResearch:ur];
      
      [b setBubbleType:BuildingBubbleTypeNone];
    } else {
      [b stopAnimating];
      
      [b setBubbleType:BuildingBubbleTypeResearch];
    }
  }
}

- (void) reloadMoneyTree:(NSTimer *)timer {
  for (MoneyTreeBuilding *b in [self childrenOfClassType:[MoneyTreeBuilding class]]) {
    UserStruct *us = b.userStruct;
    
    [b setupBuildingSprite:[b fileNameForUserStruct:us]];
    
    if (us.numResourcesAvailable <= 0 &&  us.isExpired) {
      [b setBubbleType:BuildingBubbleTypeRenew];
    } else {
      [b setBubbleType:BuildingBubbleTypeNone];
    }
  }
  
  [_timers removeObject:timer];
}

- (void) reloadLeaderBoard {
  for (LeaderBoardBuilding *lbb in [self childrenOfClassType:[LeaderBoardBuilding class]]) {
    [lbb reloadCharacterSprites];
  }
}

- (void) reloadAllBubbles {
  [self reloadHospitals];
  [self reloadStorages];
  [self reloadMiniJobCenter];
  [self reloadBubblesOnMiscBuildings];
  [self reloadTeamCenter];
  [self reloadClanHouse];
  [self reloadMoneyTree:nil];
  [self reloadItemFactory];
  [self reloadLeaderBoard];
  
  // In case there's a purch building
  [_purchBuilding setBubbleType:BuildingBubbleTypeNone];
}

- (void) reloadUpgradeSigns {
  GameState *gs = [GameState sharedGameState];
  BOOL availBuilder = [self hasAvailableBuilder];
  for (HomeBuilding *building in [self childrenOfClassType:[HomeBuilding class]]) {
    
    building.greenSign.visible = NO;
    building.redSign.visible = NO;
    
    if (availBuilder && building.userStruct.isComplete && building.userStruct.satisfiesAllPrerequisites) {
      
      StructureInfoProto *fsp = building.userStruct.staticStructForNextLevel.structInfo;
      
      if (fsp) {
        int cost = fsp.buildCost;
        BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
        int curAmount = isOilBuilding ? gs.oil : gs.cash;
        
        if (cost > curAmount) {
          building.redSign.visible = availBuilder;
        } else {
          building.greenSign.visible = availBuilder;
        }
      }
    }
  }
}

#pragma mark - Moving

- (BOOL) moveToStruct:(int)structId quantity:(int)quantity animated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int baseStructId = [gl baseStructIdForStructId:structId];
  StructureInfoProto *sip = [[gs structWithId:structId] structInfo];
  
  NSMutableArray *validStructs = [NSMutableArray array];
  for (UserStruct *us in self.myStructsList) {
    StructureInfoProto *sip2 = us.staticStructForCurrentConstructionLevel.structInfo;
    if (us.baseStructId == baseStructId && sip2.level < sip.level) {
      [validStructs addObject:us];
    }
  }
  
  // Descending order
  [validStructs sortUsingComparator:^NSComparisonResult(UserStruct *obj1, UserStruct *obj2) {
    return [@(obj2.staticStruct.structInfo.level) compare:@(obj1.staticStruct.structInfo.level)];
  }];
  
  // Get the lowest level one that is within quantity
  // i.e. if we have level 3 4 5 and we only need quantity 2, return the level 4 one
  int idx = quantity-1;
  UserStruct *chosen = idx < validStructs.count ? validStructs[idx] : [validStructs lastObject];
  
  HomeBuilding *mb = (HomeBuilding *)[self getChildByName:STRUCT_TAG(chosen.userStructUuid) recursively:NO];
  
  if (mb) {
    MapBotViewButtonConfig config = mb.userStruct.isComplete ? MapBotViewButtonUpgrade : MapBotViewButtonSpeedup;
    [self pointArrowOnBuilding:mb config:config];
    return YES;
  } else {
    return NO;
  }
}

- (void) pointArrowOnManageTeamWithPulsingAlpha:(BOOL)pulsing {
  NSArray *arr = [self childrenOfClassType:[TeamCenterBuilding class]];
  if (arr.count > 0) {
    HomeBuilding *b = arr[0];
    [self pointArrowOnBuilding:b config:MapBotViewButtonTeam withPulsingAlpha:pulsing];
  }
}

- (void) pointArrowOnSellMobsters {
  HomeBuilding *b = nil;
  NSArray *arr = [self childrenOfClassType:[ResidenceBuilding class]];
  for (HomeBuilding *x in arr) {
    if (x.userStruct.isComplete && x.userStruct.staticStruct.structInfo.level > b.userStruct.staticStruct.structInfo.level) {
      b = x;
    }
  }
  
  if (b) {
    [self pointArrowOnBuilding:b config:MapBotViewButtonSell];
  }
}

- (void) pointArrowOnEnhanceMobsters {
  HomeBuilding *b = nil;
  NSArray *arr = [self childrenOfClassType:[LabBuilding class]];
  for (HomeBuilding *x in arr) {
    if (!b || (x.userStruct.isComplete > b.userStruct.isComplete) ||
        (x.userStruct.isComplete == b.userStruct.isComplete && x.userStruct.staticStruct.structInfo.level < b.userStruct.staticStruct.structInfo.level)) {
      b = x;
    }
  }
  
  if (b) {
    [self pointArrowOnBuilding:b config:MapBotViewButtonEnhance];
  }
}

- (void) pointArrowOnUpgradeResidence {
  HomeBuilding *b = nil;
  NSArray *arr = [self childrenOfClassType:[ResidenceBuilding class]];
  for (HomeBuilding *x in arr) {
    // Try to prioritize complete residences but if you don't have one then use the upgrading one
    if (!b || (x.userStruct.isComplete > b.userStruct.isComplete) ||
        (x.userStruct.isComplete == b.userStruct.isComplete && x.userStruct.staticStruct.structInfo.level < b.userStruct.staticStruct.structInfo.level)) {
      b = x;
    }
  }
  
  if (b) {
    [self pointArrowOnBuilding:b config:MapBotViewButtonUpgrade];
  }
}

- (void) pointArrowOnHospitalWithPulsingAlpha:(BOOL)pulsing {
  HomeBuilding *b = nil;
  NSArray *arr = [self childrenOfClassType:[HospitalBuilding class]];
  for (HomeBuilding *x in arr) {
    // Try to prioritize complete residences but if you don't have one then use the upgrading one
    if (!b || (x.userStruct.isComplete > b.userStruct.isComplete) ||
        (x.userStruct.isComplete == b.userStruct.isComplete && x.userStruct.staticStruct.structInfo.level < b.userStruct.staticStruct.structInfo.level)) {
      b = x;
    }
  }
  
  if (b) {
    [self pointArrowOnBuilding:b config:MapBotViewButtonHeal withPulsingAlpha:pulsing];
  }
}

- (void) pointArrowOnClanHQ {
  HomeBuilding *b = nil;
  NSArray *arr = [self childrenOfClassType:[ClanHouseBuilding class]];
  for (HomeBuilding *x in arr) {
    if (!b || (x.userStruct.isComplete > b.userStruct.isComplete) ||
        (x.userStruct.isComplete == b.userStruct.isComplete && x.userStruct.staticStruct.structInfo.level < b.userStruct.staticStruct.structInfo.level)) {
      b = x;
    }
  }
  
  if (b) {
    [self pointArrowOnBuilding:b config:MapBotViewButtonJoinClan];
  }
}

- (void) pointArrowOnBuilding:(HomeBuilding *)b config:(MapBotViewButtonConfig)config {
  [self pointArrowOnBuilding:b config:config withPulsingAlpha:NO];
}

- (void) pointArrowOnBuilding:(HomeBuilding *)b config:(MapBotViewButtonConfig)config withPulsingAlpha:(BOOL)pulsing {
  [_arrowBuilding removeArrowAnimated:YES];
  
  self.selected = nil;
  
  [b displayArrowWithPulsingAlpha:pulsing];
  [self moveToSprite:b animated:YES];
  
  _arrowBuilding = b;	
  _arrowButtonConfig = config;
  
  if (!pulsing) {
    [self scheduleOnce:@selector(removeArrowOnBuilding) delay:8.f];
  }
}

- (void) removeArrowOnBuilding {
  if (_arrowBuilding) {
    [Globals removeUIArrowFromViewRecursively:self.buildBotView];
    [_arrowBuilding removeArrowAnimated:YES];
    _arrowBuilding = nil;
    _arrowButtonConfig = 0;
  }
}

#pragma mark - Reordering

- (void) doReorder {
  [super doReorder];
  
  if ((_isMoving && self.selected) || ([self.selected isKindOfClass:[HomeBuilding class]] && !((HomeBuilding *)self.selected).isSetDown)) {
    self.selected.zOrder = 1000;
  }
}

- (CGPoint) randomOpenSpaceWithSize:(CGSize)size {
  CGRect loc;
  loc.size = size;
  loc.origin = ccp(0,0);
  
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < self.mapSize.width; i++) {
    for (int j = 0; j < self.mapSize.height; j++) {
      loc.origin = ccp(i,j);
      if ([self isBlockWalkable:loc]) {
        [arr addObject:[NSValue valueWithCGPoint:loc.origin]];
      }
    }
  }
  return arr.count > 0 ? [[arr objectAtIndex:arc4random()%arr.count] CGPointValue] : ccp(-1, -1);
}

- (CGPoint) openSpaceNearCenterWithSize:(CGSize)size {
  CGRect loc;
  loc.size = size;
  loc.origin = ccp(0,0);
  
  CGPoint mapMid = ccp(self.mapSize.width/2, self.mapSize.height/2);
  CGRect closest = loc;
  for (int i = 0; i < self.mapSize.width; i++) {
    for (int j = 0; j < self.mapSize.height; j++) {
      loc.origin = ccp(i, j);
      
      CGPoint locMid = ccp(i+size.width/2, j+size.height/2);
      CGPoint closeMid = ccp(closest.origin.x+size.width/2, closest.origin.y+size.height/2);
      float distLoc = ccpDistance(mapMid, locMid);
      float distClose = ccpDistance(mapMid, closeMid);
      
      if (distLoc < distClose && [self isBlockBuildable:loc]) {
        closest = loc;
      }
    }
  }
  return closest.origin;
}

- (void) preparePurchaseOfStruct:(int)structId {
  if (_purchasing) {
    self.selected = nil;
    [_purchBuilding liftBlock];
    [_purchBuilding removeFromParent];
  }
  
  self.selected = nil;
  
  UserStruct *us = [[UserStruct alloc] init];
  us.structId = structId;
  us.isComplete = YES;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  us.coordinates = [self openSpaceNearCenterWithSize:CGSizeMake(fsp.width, fsp.height)];
  
  _purchBuilding = [HomeBuilding buildingWithUserStruct:us map:self];
  _purchBuilding.isPurchasing = YES;
  
  [self addChild:_purchBuilding];
  [_purchBuilding placeBlock:YES];
  
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  self.selected = _purchBuilding;
  
  [self doReorder];
  
  [self moveToSprite:_purchBuilding animated:YES];
  
  PurchaseConfirmMenu *m = [[PurchaseConfirmMenu alloc] initWithCheckTarget:self checkSelector:@selector(moveCheckClicked:) cancelTarget:self cancelSelector:@selector(cancelMoveClicked:)];
  m.name = PURCHASE_CONFIRM_MENU_TAG;
  [_purchBuilding addChild:m];
  m.positionType = CCPositionTypeNormalized;
  // 10 pixels up from height
  m.position = ccp(0.5f, 1.f+10.f/_purchBuilding.contentSize.height);
}

- (void) setSelected:(SelectableSprite *)selected {
  [super setSelected:selected];
  
  // Turn off moving so you can't do some janky stuff like dragging after it's been placed.
  // Previous bug occurred where you speedup and then drag so selection gets reset, but you can continue dragging after and place anywhere.
  _isMoving = NO;
  if ([self.selected isKindOfClass: [HomeBuilding class]]) {
    HomeBuilding *mb = (HomeBuilding *) self.selected;
    if (_purchasing) {
      self.bottomOptionView = nil;
    } else {
      self.bottomOptionView = self.buildBotView;
      [mb removeArrowAnimated:YES];
      
      _canMove = YES;
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]] ||
             [self.selected isKindOfClass:[LeaderBoardBuilding class]]) {
    _canMove = NO;
    
    self.bottomOptionView = self.buildBotView;
  } else {
    // Remove any arrows
    self.bottomOptionView = nil;
    _canMove = NO;
    [self closeCurrentViewController];
    if (_purchasing) {
      _purchasing = NO;
      [_purchBuilding removeFromParent];
      [_purchBuilding liftBlock];
      [_purchBuilding clearMeta];
    }
    
    [self removeArrowOnBuilding];
  }
}

- (void) setBottomOptionView:(MapBotView *)bottomOptionView {
  // Need to do this check in event that the selected doesn't get redone fast enough, i.e. after speedup
  for (MapBotViewButton *b in self.bottomOptionView.animateViews) {
    b.delegate = nil;
  }
  
  [super setBottomOptionView:bottomOptionView];
}

- (void) updateMapBotView:(MapBotView *)botView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSMutableArray *buttonViews = [NSMutableArray array];
  
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    HomeBuilding *mb = (HomeBuilding *)self.selected;
    UserStruct *us = mb.userStruct;
    StructureInfoProto *fsp = us.staticStruct.structInfo;
    StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
    
    BOOL isUpgradableBuilding = fsp.predecessorStructId || fsp.successorStructId;
    NSString *lvlStr = isUpgradableBuilding ? [NSString stringWithFormat:@" (%@)", fsp.level ? [NSString stringWithFormat:@"LVL %d", fsp.level] : @"Broken"] : @"";
    
    if (fsp.structType != StructureInfoProto_StructTypeMoneyTree) {
      self.buildingNameLabel.text = [NSString stringWithFormat:@"%@%@", fsp.name, lvlStr];
    } else {
      if (us.isExpired) {
        self.buildingNameLabel.text = [NSString stringWithFormat:@"%@ (Expired)", fsp.name];
      } else {
        self.buildingNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", fsp.name, [Globals convertTimeToSingleLongString:[us timeTillExpiry]]];
      }
    }
    
    // SPECIAL CASE.. Money Tree
    BOOL continueNormally = YES;
    if (fsp.structType == StructureInfoProto_StructTypeMoneyTree && us.isExpired) {
      MoneyTreeProto *mtp = (MoneyTreeProto *)us.staticStruct;
      
      IAPHelper *iap = [IAPHelper sharedIAPHelper];
      SKProduct *prod = [iap productForIdentifier:mtp.iapProductId];
      NSString *price = [iap priceForProduct:prod];
      [buttonViews addObject:[MapBotViewButton fixButtonWithIapString:price]];
      
      continueNormally = NO;
    }
    
    if (continueNormally) {
      if (us.isComplete) {
        if (fsp.successorStructId) {
          if (fsp.level == 0) {
            [buttonViews addObject:[MapBotViewButton fixButtonWithResourceType:nextFsp.buildResourceType buildCost:nextFsp.buildCost]];
          } else {
            [buttonViews addObject:[MapBotViewButton upgradeButtonWithResourceType:nextFsp.buildResourceType buildCost:nextFsp.buildCost]];
          }
        } else {
          [buttonViews addObject:[MapBotViewButton infoButton]];
        }
      } else {
        int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:self.selected];
        int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
        BOOL canGetHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeUpgradeStruct userDataUuid:us.userStructUuid] < 0;
        
        if (gemCost && canGetHelp) {
          [buttonViews addObject:[MapBotViewButton clanHelpButton]];
        } else {
          [buttonViews addObject:[MapBotViewButton speedupButtonWithGemCost:gemCost]];
        }
      }
      
      if (fsp.level > 1 || (us.isComplete && fsp.level == 1)) {
        switch (fsp.structType) {
          case StructureInfoProto_StructTypeResidence:
            [buttonViews addObject:[MapBotViewButton bonusSlotsButton]];
            [buttonViews addObject:[MapBotViewButton sellButton]];
            break;
            
          case StructureInfoProto_StructTypeHospital:
            [buttonViews addObject:[MapBotViewButton healButton]];
            break;
            
          case StructureInfoProto_StructTypeEvo:
            [buttonViews addObject:[MapBotViewButton evolveButton]];
            break;
            
          case StructureInfoProto_StructTypeResearchHouse:
            [buttonViews addObject:[MapBotViewButton researchButton]];
            break;
            
          case StructureInfoProto_StructTypeLab:
            [buttonViews addObject:[MapBotViewButton enhanceButton]];
            break;
            
          case StructureInfoProto_StructTypeMiniJob:
            [buttonViews addObject:[MapBotViewButton miniJobsButton]];
            break;
            
          case StructureInfoProto_StructTypeTeamCenter:
            [buttonViews addObject:[MapBotViewButton teamButton]];
            break;
            
          case StructureInfoProto_StructTypeClan:
            [buttonViews addObject:[MapBotViewButton joinClanButton]];
            break;
            
          case StructureInfoProto_StructTypePvpBoard:
            [buttonViews addObject:[MapBotViewButton pvpBoardButton]];
            break;
            
          case StructureInfoProto_StructTypeBattleItemFactory:
            [buttonViews addObject:[MapBotViewButton itemFactoryButton]];
            break;
            
          default:
            break;
        }
      }
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    ObstacleSprite *ob = (ObstacleSprite *)self.selected;
    UserObstacle *ue = ob.obstacle;
    ObstacleProto *op = ue.staticObstacle;
    
    self.buildingNameLabel.text = op.name;
    if (!ue.removalTime) {
      [buttonViews addObject:[MapBotViewButton removeButtonWithResourceType:op.removalCostType removeCost:op.cost]];
    } else {
      int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:self.selected];
      [buttonViews addObject:[MapBotViewButton speedupButtonWithGemCost:[gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:NO]]];
    }
  } else if ([self.selected isKindOfClass:[LeaderBoardBuilding class]]) {
    self.buildingNameLabel.text = @"Leaderboard";
    
    [buttonViews addObject:[MapBotViewButton leaderBoardButton]];
  }
  
  for (MapBotViewButton *b in buttonViews) {
    b.delegate = self;
  }
  
  [botView addAnimateViewsToContainerView:buttonViews];
  
  if (self.selected == _arrowBuilding) {
    MapBotViewButton *button = nil;
    for (MapBotViewButton *b in buttonViews) {
      if (b.config == _arrowButtonConfig) {
        button = b;
      }
    }
    
    if (button) {
      NSInteger idx = [buttonViews indexOfObject:button];
      
      // Check if its on the right, then left, then in middle
      float angle = idx == buttonViews.count-1 ? 0 : idx == 0 ?  M_PI : M_PI_2;
      [Globals createUIArrowForView:button atAngle:angle];
    }
  }
}

- (void) mapBotViewButtonSelected:(MapBotViewButton *)button {
  // Fake the IBActions
  switch (button.config) {
    case MapBotViewButtonInfo:
    case MapBotViewButtonUpgrade:
    case MapBotViewButtonRemove:
    case MapBotViewButtonFix:
      [self littleUpgradeClicked:button];
      break;
      
    case MapBotViewButtonMiniJob:
    case MapBotViewButtonEnhance:
    case MapBotViewButtonHeal:
    case MapBotViewButtonEvolve:
    case MapBotViewButtonTeam:
    case MapBotViewButtonSell:
    case MapBotViewButtonJoinClan:
    case MapBotViewButtonPvpBoard:
    case MapBotViewButtonItemFactory:
    case MapBotViewButtonResearch:
      [self enterClicked:button];
      break;
      
    case MapBotViewButtonSpeedup:
      [self finishNowClicked:button];
      break;
      
    case MapBotViewButtonBonusSlots:
      [self bonusSlotsClicked:button];
      break;
      
    case MapBotViewButtonClanHelp:
      [self getHelpClicked:button];
      break;
      
    case MapBotViewButtonLeaderBoard:
      [self openLeaderBoard:button];
  }
  
  [self removeArrowOnBuilding];
}

#pragma mark - Gesture Recognizers

- (void) drag:(UIGestureRecognizer *)recognizer {
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  pt = [self convertToNodeSpace:pt];
  
  if (_canMove) {
    if ([self.selected isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
      if([recognizer state] == UIGestureRecognizerStateBegan ) {
        // This fat statement just checks that the drag touch is somewhere closeby the selected sprite
        if (CGRectContainsPoint(CGRectMake(self.selected.position.x-self.selected.contentSize.width/2*self.selected.scale-20, self.selected.position.y-20, self.selected.contentSize.width*self.selected.scale+40, self.selected.contentSize.height*self.selected.scale+40), pt)) {
          [homeBuilding setStartTouchLocation: pt];
          [homeBuilding liftBlock];
          
          [homeBuilding updateMeta];
          _isMoving = YES;
          return;
        }
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateChanged) {
        [self scrollScreenForTouch:pt];
        [homeBuilding clearMeta];
        [homeBuilding locationAfterTouch:pt];
        [homeBuilding updateMeta];
        return;
      } else if (_isMoving && ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled)) {
        [homeBuilding placeBlock:YES];
        _isMoving = NO;
        [self doReorder];
        
        if (homeBuilding.isSetDown && !_purchasing) {
          HomeBuilding *m = (HomeBuilding *)homeBuilding;
          [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:m.userStruct atX:m.location.origin.x atY:m.location.origin.y];
        }
        return;
      }
    }
  }
  
  [super drag:recognizer];
}

- (void) tap:(UIGestureRecognizer *)recognizer {
  if (!_purchasing && !_isMoving) {
    [super tap:recognizer];
    // Reorder in case something got deselected?
    [self doReorder];
  }
}

- (void) scrollScreenForTouch:(CGPoint)pt {
  // CGPoint relPt = [self convertToNodeSpace:pt];
  // TODO: Implement this
  // As you get closer to edge, it scrolls faster
}

- (void) reloadRetrievableIcons {
  for (ResourceGeneratorBuilding *res in self.children) {
    // This is called when game state is updated and is used to reload the retrievable icon if its up since it might need to show red now.
    if ([res isKindOfClass:[ResourceGeneratorBuilding class]] && res.retrievable) {
      res.retrievable = YES;
    } else if([res isKindOfClass:[MoneyTreeBuilding class]] && res.retrievable) {
      res.retrievable = YES;
    }
  }
}

- (void) retrieveFromMoneyTree:(MoneyTreeBuilding *)mt {
  ResourceType resType = ResourceTypeGems;
  
  int amountCollected = [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mt.userStruct];
  mt.retrievable = NO;
  
  if (amountCollected > 0) {
    
    // Spawn a label on building
    NSString *fnt = @"gemscollected.fnt";
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:[Globals commafyNumber:amountCollected] fntFile:fnt];
    [self addChild:label z:1000];
    label.position = ccp(mt.position.x, mt.position.y+mt.contentSize.height*4/5);
    
    [label runAction:[CCActionSequence actions:
                      [CCActionSpawn actions:
                       [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                       [CCActionSequence actions:
                        [CCActionDelay actionWithDuration:1.f],
                        [CCActionFadeOut actionWithDuration:1.f], nil],
                       [CCActionMoveBy actionWithDuration:2.f position:ccp(0,40)],nil],
                      [CCActionCallFunc actionWithTarget:label selector:@selector(removeFromParent)], nil]];
    
    [AchievementUtil checkCollectResource:resType amount:amountCollected];
    
    [self reloadMoneyTree:nil];
  } else {
    //this section is for when storages are full but there is infinite gem storage
    [Globals addAlertNotification:@"Something went wrong with the Gem Mine"];
  }
  [SoundEngine structCollectGems];
  
  [self updateTimersForBuilding:mt];
  
}

- (void) retrieveFromBuilding:(ResourceGeneratorBuilding *)mb {
  GameState *gs = [GameState sharedGameState];
  ResourceType resType = ((ResourceGeneratorProto *)mb.userStruct.staticStruct).resourceType;
  
  int amountCollected = [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mb.userStruct];
  mb.retrievable = NO;
  
  if (amountCollected > 0) {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger totalTimesCollected = [defaults integerForKey:TOTAL_TIMES_RESOURCES_COLLECTED_KEY];
    totalTimesCollected++;
    [defaults setInteger:totalTimesCollected forKey:TOTAL_TIMES_RESOURCES_COLLECTED_KEY];
    
    if(totalTimesCollected == 20 && ![defaults boolForKey:[Globals userConfimredPushNotificationsKey]]) {
      GameViewController *gvc = [GameViewController baseController];
      [gvc openPushNotificationRequestWithMessage:@"Would you like to recieve push notifications when all your resource collecters are full?"];
    }
    
    // Spawn a label on building
    NSString *fnt = resType == ResourceTypeCash ? @"cashcollected.fnt" : @"oilcollected.fnt";
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:[Globals commafyNumber:amountCollected] fntFile:fnt];
    [self addChild:label z:1000];
    label.position = ccp(mb.position.x, mb.position.y+mb.contentSize.height*4/5);
    
    [label runAction:[CCActionSequence actions:
                      [CCActionSpawn actions:
                       [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                       [CCActionSequence actions:
                        [CCActionDelay actionWithDuration:1.f],
                        [CCActionFadeOut actionWithDuration:1.f], nil],
                       [CCActionMoveBy actionWithDuration:2.f position:ccp(0,40)],nil],
                      [CCActionCallFunc actionWithTarget:label selector:@selector(removeFromParent)], nil]];
    
    [AchievementUtil checkCollectResource:resType amount:amountCollected];
  } else {
    ResourceType resType = ((ResourceGeneratorProto *)mb.userStruct.staticStruct).resourceType;
    
    // Find the storage building
    NSString *name = nil;
    for (ResourceStorageProto *rsp in gs.staticStructs.allValues) {
      if (rsp.structInfo.structType == StructureInfoProto_StructTypeResourceStorage &&
          rsp.resourceType == resType && !rsp.structInfo.predecessorStructId) {
        name = rsp.structInfo.name;
      }
    }
    
    [Globals addAlertNotification:[NSString stringWithFormat:@"Your storages are full.%@", name ? [NSString stringWithFormat:@" Upgrade or build more %@s to store more!", name] : @""]];
  }
  
  if (resType == ResourceTypeCash) {
    [SoundEngine structCollectCash];
  } else if (resType == ResourceTypeOil) {
    [SoundEngine structCollectOil];
  }
  
  [self setupIncomeTimerForBuilding:mb];
}

- (void) sendNormStructComplete:(UserStruct *)us {
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:us delegate:self];
  us.hasShownFreeSpeedup = NO;
  _waitingForResponse = YES;
}

#pragma mark - Timers

- (void) invalidateAllTimers {
  // Invalidate all timers
  [_timers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSTimer *t = (NSTimer *)obj;
    [t invalidate];
  }];
  [_timers removeAllObjects];
}

- (void) beginTimers {
  for (CCNode *node in _children) {
    if (node != _purchBuilding && [node isKindOfClass:[HomeBuilding class]]) {
      [self updateTimersForBuilding:(HomeBuilding *)node justBuilt:NO];
    }
    if ([node isKindOfClass:[ObstacleSprite class]]) {
      [self updateTimersForBuilding:(ObstacleSprite *)node justBuilt:NO];
    }
  }
  
  [self updateTimerForHealingJustQueuedUp:NO];
  [self updateTimerForPersistentEvents];
}

- (void) updateTimerForHealingDidJustQueueUp {
  [self updateTimerForHealingJustQueuedUp:YES];
}

- (void) updateTimerForHealingJustQueuedUp:(BOOL)justQueuedUp {
  NSMutableArray *oldTimers = [NSMutableArray array];
  for (NSTimer *t in _timers) {
    if ([t.userInfo isKindOfClass:[HospitalQueue class]]) {
      [oldTimers addObject:t];
    }
  }
  
  for (NSTimer *oldTimer in oldTimers) {
    [oldTimer invalidate];
    [_timers removeObject:oldTimer];
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
    MSDate *date = hq.queueEndTime;
    NSTimeInterval timeLeft = date.timeIntervalSinceNow;
    
    if (timeLeft > 0 && ((justQueuedUp && timeLeft/60.f > gl.maxMinutesForFreeSpeedUp) || !justQueuedUp)) {
      NSTimer *newTimer = [NSTimer timerWithTimeInterval:timeLeft-gl.maxMinutesForFreeSpeedUp*60 target:self selector:@selector(healingSpeedupBecameFree:) userInfo:hq repeats:NO];
      [_timers addObject:newTimer];
      [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
    }
  }
}

- (void) updateTimerForPersistentEvents {
  NSMutableArray *oldTimers = [NSMutableArray array];
  for (NSTimer *t in _timers) {
    if ([t.userInfo isEqual:@"DailyEvent"]) {
      [oldTimers addObject:t];
    }
  }
  
  for (NSTimer *oldTimer in oldTimers) {
    [oldTimer invalidate];
    [_timers removeObject:oldTimer];
  }
  
  GameState *gs = [GameState sharedGameState];
  
  MSDate *finalDate = nil;
  NSMutableArray *dates = [NSMutableArray array];
  
  for (PersistentEventProto *pe in gs.persistentEvents) {
    [dates addObject:pe.startTime];
    
    MSDate *cd = pe.cooldownEndTime;
    if (cd) {
      [dates addObject:pe.cooldownEndTime];
    }
    
    [dates addObject:pe.endTime];
  }
  
  for (MSDate *date in dates) {
    if (date.timeIntervalSinceNow > 0 && (!finalDate || [date compare:finalDate] == NSOrderedAscending)) {
      finalDate = date;
    }
  }
  
  if (finalDate) {
    NSTimer *newTimer = [NSTimer timerWithTimeInterval:finalDate.timeIntervalSinceNow target:self selector:@selector(dailyEventTimerFired:) userInfo:@"DailyEvent" repeats:NO];
    [_timers addObject:newTimer];
    [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
  }
}

- (void) updateTimersForBuilding:(MapSprite *)ms {
  [self updateTimersForBuilding:ms justBuilt:NO];
}

- (void) updateTimersForBuilding:(MapSprite *)ms justBuilt:(BOOL)justBuilt {
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *oldTimers = [NSMutableArray array];
  for (NSTimer *t in _timers) {
    if (t.userInfo == ms) {
      [oldTimers addObject:t];
    }
  }
  
  for (NSTimer *oldTimer in oldTimers) {
    [oldTimer invalidate];
    [_timers removeObject:oldTimer];
  }
  
  if ([ms isKindOfClass:[HomeBuilding class]]) {
    HomeBuilding *mb = (HomeBuilding *)ms;
    if (!mb.userStruct.isComplete) {
      // Add a timer for completion time
      NSTimeInterval timeLeft = mb.userStruct.timeLeftForBuildComplete;
      NSTimer *newTimer = [NSTimer timerWithTimeInterval:mb.userStruct.timeLeftForBuildComplete target:self selector:@selector(constructionComplete:) userInfo:mb repeats:NO];
      [_timers addObject:newTimer];
      [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
      
      // Add a timer for free speedup
      if (timeLeft > 0 && ((justBuilt && timeLeft/60.f > gl.maxMinutesForFreeSpeedUp) || !justBuilt)) {
        NSTimer *newTimer = [NSTimer timerWithTimeInterval:timeLeft-gl.maxMinutesForFreeSpeedUp*60 target:self selector:@selector(buildingSpeedupBecameFree:) userInfo:mb repeats:NO];
        [_timers addObject:newTimer];
        [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
      } else {
        mb.userStruct.hasShownFreeSpeedup = YES;
      }
    } else {
      if ([mb isKindOfClass:[MoneyTreeBuilding class]]){
        MoneyTreeBuilding *rb = (MoneyTreeBuilding *)mb;
        UserStruct *us = rb.userStruct;
        if (us.numResourcesAvailable > 0) {
          rb.retrievable = YES;
        } else if (!us.isExpired) {
          [self setupIncomeTimerForBuilding:rb];
        }
        
        if (!us.isExpired) {
          // Setup timer for expiration
          NSTimer *timer = [NSTimer timerWithTimeInterval:us.timeTillExpiry target:self selector:@selector(reloadMoneyTree:) userInfo:mb repeats:NO];
          [_timers addObject:timer];
          [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
      }
      else if ([mb isKindOfClass:[ResourceGeneratorBuilding class]]) {
        ResourceGeneratorBuilding *rb = (ResourceGeneratorBuilding *)mb;
        if (rb.userStruct.numResourcesAvailable >= RESOURCE_GEN_MIN_AMT*mb.userStruct.productionRate) {
          rb.retrievable = YES;
        } else {
          [self setupIncomeTimerForBuilding:rb];
        }
      }
    }
  } else if ([ms isKindOfClass:[ObstacleSprite class]]) {
    ObstacleSprite *os = (ObstacleSprite *)ms;
    if (os.obstacle.endTime) {
      NSTimer *newTimer = [NSTimer timerWithTimeInterval:os.obstacle.endTime.timeIntervalSinceNow target:self selector:@selector(obstacleComplete:) userInfo:os repeats:NO];
      [_timers addObject:newTimer];
      [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
    }
  }
}

- (void) setupIncomeTimerForBuilding:(ResourceGeneratorBuilding *)mb {
  int numRes;
  UserStruct *us = mb.userStruct;
  if ([mb isKindOfClass:[MoneyTreeBuilding class]]){
    numRes = 1;
  } else {
    numRes = RESOURCE_GEN_MIN_AMT*us.productionRate;
  }
  
  NSTimer *timer = nil;
  // Set timer for when building has x resources
  if ([us numResourcesAvailable] >= numRes) {
    timer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  } else {
    int secs = numRes/us.productionRate*3600;
    
    MSDate *date = [us.lastRetrieved dateByAddingTimeInterval:secs];
    
    timer = [NSTimer timerWithTimeInterval:date.timeIntervalSinceNow target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  }
  [_timers addObject:timer];
  [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void) constructionComplete:(NSTimer *)timer {
  HomeBuilding *mb = [timer userInfo];
  if (mb.userStruct.userStructUuid && !_waitingForResponse) {
    if (!mb.userStruct.isComplete) {
      [self sendNormStructComplete:mb.userStruct];
      [self updateTimersForBuilding:mb justBuilt:NO];
      mb.isConstructing = NO;
      [mb removeProgressBar];
      [mb displayUpgradeComplete];
      if (mb == self.selected) {
        [mb cancelMove];
        [self reselectCurrentSelection];
      }
      
      // Make sure we don't actually have the upgrade view open
      if (self.speedupItemsFiller) {
        [self closeCurrentViewController];
      }
      
      [self reloadUpgradeSigns];
      [self reloadAllBubbles];
      
      [QuestUtil checkAllStructQuests];
      [AchievementUtil checkBuildingUpgrade:mb.userStruct.structId];
      [[MiniEventManager sharedInstance] checkBuildStrength:mb.userStruct.structId];
      
      // Max cash/oil may have changed
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_COMPLETE_NOTIFICATION object:nil];
    }
  } else {
    // Try again in 1 second
    [self performSelector:@selector(updateTimersForBuilding:) withObject:mb afterDelay:1.f];
    
    // Do cleanup or it will crash
    [timer invalidate];
    [_timers removeObject:timer];
  }
}

- (void) buildingSpeedupBecameFree:(NSTimer *)timer {
  HomeBuilding *mb = [timer userInfo];
  UserStruct *us = mb.userStruct;
  
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *sip = [us.staticStruct structInfo];
  NSTimeInterval timeLeft = us.timeLeftForBuildComplete;
  
  if (!us.hasShownFreeSpeedup && timeLeft > 0 && timeLeft/60.f < gl.maxMinutesForFreeSpeedUp) {
    BOOL isInitialConstruction = sip.level == 1;
    NSString *desc = [NSString stringWithFormat:@"%@ %@ is below %d minutes. Free speedup available!", sip.name, isInitialConstruction ? @"construction" : @"upgrade", gl.maxMinutesForFreeSpeedUp];
    [Globals addPurpleAlertNotification:desc isImmediate:NO];
    
    us.hasShownFreeSpeedup = YES;
  }
  
  [self updateMapBotView:self.bottomOptionView];
  
  [_timers removeObject:timer];
}

- (void) healingSpeedupBecameFree:(NSTimer *)timer {
  Globals *gl = [Globals sharedGlobals];
  HospitalQueue *hq = timer.userInfo;
  NSTimeInterval timeLeft = hq.queueEndTime.timeIntervalSinceNow;
  
  if (!hq.hasShownFreeHealingQueueSpeedup && timeLeft > 0 && timeLeft/60.f < gl.maxMinutesForFreeSpeedUp) {
    NSString *desc = [NSString stringWithFormat:@"Healing time is below %d minutes. Free speedup available!", gl.maxMinutesForFreeSpeedUp];
    [Globals addPurpleAlertNotification:desc isImmediate:NO];
    
    hq.hasShownFreeHealingQueueSpeedup = YES;
  }
  
  [_timers removeObject:timer];
}

- (void) obstacleComplete:(NSTimer *)timer {
  ObstacleSprite *os = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] obstacleRemovalComplete:os.obstacle speedup:NO];
  [os removeProgressBar];
  [os disappear];
  [self updateTimersForBuilding:os justBuilt:NO];
  if (os == self.selected) {
    self.selected = nil;
  }
  
  // Make sure we don't actually have the upgrade view open
  if (self.speedupItemsFiller) {
    [self closeCurrentViewController];
  }
  
  [SoundEngine structCompleted];
  
  [AchievementUtil checkObstacleRemoved];
  [[NSNotificationCenter defaultCenter] postNotificationName:OBSTACLE_COMPLETE_NOTIFICATION object:nil];
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  ResourceGeneratorBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  [_timers removeObject:timer];
}

- (void) dailyEventTimerFired:(NSTimer *)timer {
  [self reloadBubblesOnMiscBuildings];
  
  [_timers removeObject:timer];
  [self updateTimerForPersistentEvents];
}

#pragma mark - IBActions

- (IBAction)enterClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  
  GameViewController *gvc = [GameViewController baseController];
  HomeViewController *hvc = nil;
  
  switch (fsp.structType) {
    case StructureInfoProto_StructTypeHospital:
      hvc = [[HomeViewController alloc] initWithHeal:us.userStructUuid];
      break;
      
    case StructureInfoProto_StructTypeLab:
      hvc = [[HomeViewController alloc] initWithEnhance];
      break;
      
    case StructureInfoProto_StructTypeResidence:
      hvc = [[HomeViewController alloc] initWithSell];
      break;
      
    case StructureInfoProto_StructTypeTeamCenter:
        hvc = [[HomeViewController alloc] initWithTeamShowRequestArrow:self.showArrowOnRequestToon];
        self.showArrowOnRequestToon = NO;
      break;
      
    case StructureInfoProto_StructTypeEvo:
      hvc = [[HomeViewController alloc] initWithEvolve];
      break;
      
    case StructureInfoProto_StructTypeMiniJob:
      hvc = [[HomeViewController alloc] initWithMiniJobs];
      break;
      
    case StructureInfoProto_StructTypeBattleItemFactory:
      hvc = [[HomeViewController alloc] initWithBattleItemFactory];
      break;
      
    case StructureInfoProto_StructTypePvpBoard:
    {
      GameViewController *gvc = [GameViewController baseController];
      BoardDesignerViewController* bdvc = [[BoardDesignerViewController alloc] init];
      [bdvc setDelegate:self];
      [bdvc.view setFrame:gvc.view.bounds];
      [gvc addChildViewController:bdvc];
      [gvc.view addSubview:bdvc.view];
      
      self.currentViewController = bdvc;
    }
      break;
      
    case StructureInfoProto_StructTypeResearchHouse:
      hvc = [[HomeViewController alloc] initWithResearchLab];
      break;
      
    case StructureInfoProto_StructTypeClan:
      [gvc openClanView];
      break;
      
    default:
      break;
  }
  
  if (hvc) {
    [gvc.topBarViewController displayHomeViewController:hvc];
    hvc.delegate = self;
    self.currentViewController = hvc;
  }
}

- (IBAction)bonusSlotsClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  if (fsp.structType == StructureInfoProto_StructTypeResidence) {
    [self loadUpgradeViewControllerForIsHire:YES];
  }
}

- (IBAction)getHelpClicked:(id)sender {
  // Might come from timer action or from bottom view
  HomeBuilding *hb = nil;
  if ([sender isKindOfClass:[UserStruct class]]) {
    hb = (HomeBuilding *)[self getChildByName:STRUCT_TAG([sender userStructUuid]) recursively:NO];
  } else {
    hb = (HomeBuilding *)self.selected;
  }
  
  if (hb) {
    // Just need to solicit for constr building
    GameState *gs = [GameState sharedGameState];
    UserStruct *us = hb.userStruct;
    
    if (us) {
      if (us.userStructUuid == nil) {
        [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
      } else if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeUpgradeStruct userDataUuid:us.userStructUuid] < 0) {
        [[OutgoingEventController sharedOutgoingEventController] solicitBuildingHelp:us];
        
        if (hb == self.selected) {
          [self reselectCurrentSelection];
        }
      }
    }
  }
}

//- (void) loadMiniJobsView {
//  // LEGACY
//  GameViewController *gvc = [GameViewController baseController];
//  MiniJobsViewController *rvc = [[MiniJobsViewController alloc] init];
//  [gvc addChildViewController:rvc];
//  rvc.view.frame = gvc.view.bounds;
//  [gvc.view addSubview:rvc.view];
//}

#pragma mark - Purchase

- (NSArray *) constructingBuildingsAndObstacles {
  NSMutableArray *arr = [NSMutableArray array];
  
  for (CCNode *n in self.children) {
    if ([n isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *hb = (HomeBuilding *)n;
      if (!hb.userStruct.isComplete) {
        [arr addObject:n];
      }
    } else if ([n isKindOfClass:[ObstacleSprite class]]) {
      ObstacleSprite *os = (ObstacleSprite *)n;
      if (os.obstacle.removalTime) {
        [arr addObject:n];
      }
    }
  }
  
  return arr;
}

- (BOOL) hasAvailableBuilder {
  int numBuilders = [self numberOfBuilders];
  return [self constructingBuildingsAndObstacles].count < numBuilders;
}

- (Building *) earliestConstructingBuildingOrObstacle {
  NSArray *arr = [self constructingBuildingsAndObstacles];
  Building *winner = nil;
  int time = 0;
  
  for (Building *b in arr) {
    int newTime = [self timeLeftForConstructionBuildingOrObstacle:b];
    if (!winner || newTime < time) {
      winner = b;
      time = newTime;
    }
  }
  
  return winner;
}

- (int) timeLeftForConstructionBuildingOrObstacle:(id)building {
  if ([building isKindOfClass:[HomeBuilding class]]) {
    UserStruct *cus = ((HomeBuilding *)building).userStruct;
    return cus.timeLeftForBuildComplete;
  } else if ([building isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)building).obstacle;
    return ub.endTime.timeIntervalSinceNow;
  }
  return 0;
}

- (IBAction)moveCheckClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  if (homeBuilding.isSetDown && _purchasing) {
    if (![self hasAvailableBuilder]) {
      Building *building = [self earliestConstructingBuildingOrObstacle];
      int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:building];
      BOOL allowFreeSpeedup = [building isKindOfClass:[HomeBuilding class]];
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
      
      _buttonSender = sender;
      if (gemCost) {
        NSString *desc = [NSString stringWithFormat:@"Your builder is busy! Speed him up for %@ gem%@ and upgrade this building?", [Globals commafyNumber:gemCost], gemCost == 1 ? @"" : @"s"];
        [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Busy Builder" gemCost:gemCost target:self selector:@selector(speedupBuildingAndUpgradeOrPurchase)];
      } else {
        [self speedupBuildingAndUpgradeOrPurchase];
      }
    } else {
      int cost = fsp.buildCost;
      BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
      int curAmount = isOilBuilding ? gs.oil : gs.cash;
      
      if (cost > curAmount) {
        ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
        if (svc) {
          ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:fsp.buildResourceType requiredAmount:cost shouldAccumulate:YES];
          rif.delegate = self;
          svc.delegate = rif;
          self.resourceItemsFiller = rif;
          
          GameViewController *gvc = [GameViewController baseController];
          svc.view.frame = gvc.view.bounds;
          [gvc addChildViewController:svc];
          [gvc.view addSubview:svc.view];
          
          [svc showCenteredOnScreen];
        }
      } else {
        [self purchaseBuildingWithItemDict:nil allowGems:NO];
      }
    }
    
    [SoundEngine generalButtonClick];
  } else {
    [Globals addAlertNotification:@"You can't build a building there, silly!"];
    [SoundEngine structCantPlace];
  }
}

- (void) purchaseWithItemDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = fsp.buildCost;
  ResourceType resType = fsp.buildResourceType;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self purchaseBuildingWithItemDict:itemIdsToQuantity allowGems:allowGems];
  }
}

- (void) purchaseBuildingWithItemDict:(NSDictionary *)itemIdsToQuantity allowGems:(BOOL)allowGems {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  if (!_waitingForResponse) {
    // Use return value as an indicator that purchase is accepted by client
    UserStruct *us = [self sendPurchaseStructWithItemDict:itemIdsToQuantity allowGems:allowGems];
    if (us) {
      homeBuilding.userStruct = us;
      [self updateTimersForBuilding:homeBuilding justBuilt:YES];
      homeBuilding.isConstructing = YES;
      homeBuilding.isPurchasing = NO;
      homeBuilding.name = PURCH_STRUCT_TAG;
      
      [homeBuilding displayProgressBar];
      
      [homeBuilding removeChildByName:PURCHASE_CONFIRM_MENU_TAG cleanup:YES];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_PURCHASED_NOTIFICATION object:nil];
      
      _canMove = NO;
      _purchasing = NO;
      _purchBuilding = nil;
      
      [self reselectCurrentSelection];
      
      [self reloadUpgradeSigns];
    } else {
      [homeBuilding liftBlock];
      [homeBuilding removeFromParent];
      
      self.selected = nil;
    }
    [self doReorder];
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request!"];
  }
}

- (UserStruct *) sendPurchaseStructWithItemDict:(NSDictionary *)itemIdsToQuantity allowGems:(BOOL)allowGems {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  _waitingForResponse = YES;
  
  [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
  
  // Use return value as an indicator that purchase is accepted by client
  return [[OutgoingEventController sharedOutgoingEventController] purchaseNormStruct:_purchStructId atX:homeBuilding.location.origin.x atY:homeBuilding.location.origin.y allowGems:allowGems delegate:self];
}

- (IBAction)cancelMoveClicked:(id)sender {
  if (_purchasing) {
    self.selected = nil;
    
    [SoundEngine closeButtonClick];
  }
}

#pragma mark - Upgrade

- (IBAction)littleUpgradeClicked:(id)sender {
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    UserStruct *us = (UserStruct *)[(HomeBuilding *)self.selected userStruct];
    
    if ([self.selected isKindOfClass:[MoneyTreeBuilding class]] && us.isExpired) {
      // Re-purchase money tree
      MoneyTreeBuilding *mtb = (MoneyTreeBuilding *)self.selected;
      GameViewController *gvc = [GameViewController baseController];
      [gvc buildingPurchased:mtb.userStruct.structId];
    } else {
      [self loadUpgradeViewControllerForIsHire:NO];
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    [self bigUpgradeClicked:sender];
  }
}

- (void) loadUpgradeViewControllerForIsHire:(BOOL)isHire {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  GameViewController *gvc = [GameViewController baseController];
  
  if (!self.currentViewController) {
    if (!isHire) {
      HomeViewController *hvc = [[HomeViewController alloc] init];
      hvc.delegate = self;
      
      UpgradeViewController *up = [[UpgradeViewController alloc] initWithUserStruct:us];
      up.delegate = self;
      
      [gvc.topBarViewController displayHomeViewController:hvc];
      
      [hvc pushViewController:up animated:NO];
      
      self.currentViewController = hvc;
    } else {
      HireViewController *hvc = [[HireViewController alloc] initWithUserStruct:us];
      hvc.delegate = self;
      
      [gvc addChildViewController:hvc];
      hvc.view.frame = gvc.view.bounds;
      [gvc.view addSubview:hvc.view];
      
      self.currentViewController = hvc;
    }
  }
}

- (void) bigUpgradeClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int cost = 0;
  ResourceType resType = 0;
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
    StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
    
    cost = nextFsp.buildCost;
    resType = nextFsp.buildResourceType;
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)self.selected).obstacle;
    ObstacleProto *op = ub.staticObstacle;
    
    if (!ub.userObstacleUuid) {
      [Globals addAlertNotification:@"Hold on, we're still processing your previous request!"];
      return;
    }
    
    cost = op.cost;
    resType = op.removalCostType;
  }
  
  int curAmount = resType == ResourceTypeOil ? gs.oil : gs.cash;
  if (![self hasAvailableBuilder]) {
    Building *building = [self earliestConstructingBuildingOrObstacle];
    int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:building];
    BOOL allowFreeSpeedup = [building isKindOfClass:[HomeBuilding class]];
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
    
    _buttonSender = sender;
    if (gemCost) {
      NSString *desc = [NSString stringWithFormat:@"Your builder is busy! Speed him up for %@ gem%@ and upgrade this building?", [Globals commafyNumber:gemCost], gemCost == 1 ? @"" : @"s"];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Busy Builder" gemCost:gemCost target:self selector:@selector(speedupBuildingAndUpgradeOrPurchase)];
    } else {
      [self speedupBuildingAndUpgradeOrPurchase];
    }
  } else {
    if (cost > curAmount) {
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:resType requiredAmount:cost shouldAccumulate:YES];
        rif.delegate = self;
        svc.delegate = rif;
        self.resourceItemsFiller = rif;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        if (sender == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if (self.currentViewController == nil &&
              [sender isKindOfClass:[MapBotViewButton class]]) // Removing an obstacle
          {
            UIButton* invokingButton = ((MapBotViewButton*)sender).bgdButton;
            [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferTopPlacement inkovingViewImage:invokingButton.currentImage];
          }
          if (self.currentViewController != nil &&
              [self.currentViewController isKindOfClass:[HomeViewController class]] &&
              [sender isKindOfClass:[UIButton class]]) // Upgrading a building
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferLeftPlacement inkovingViewImage:invokingButton.currentImage];
          }
        }
      }
    } else {
      [self sendUpgradeWithItemDict:nil allowGems:NO];
    }
  }
}

- (void) upgradeWithItemDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = 0;
  ResourceType resType = 0;
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
    StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
    
    cost = nextFsp.buildCost;
    resType = nextFsp.buildResourceType;
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)self.selected).obstacle;
    ObstacleProto *op = ub.staticObstacle;
    
    cost = op.cost;
    resType = op.removalCostType;
  }
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendUpgradeWithItemDict:itemIdsToQuantity allowGems:allowGems];
  }
}

- (void) sendUpgradeWithItemDict:(NSDictionary *)itemIdsToQuantity allowGems:(BOOL)allowGems {
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    HomeBuilding *hb = (HomeBuilding *)self.selected;
    UserStruct *us = hb.userStruct;
    
    if (us.userStructUuid == nil || _waitingForResponse) {
      [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
      [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us allowGems:allowGems delegate:self];
      _waitingForResponse = YES;
    }
    
    if (!us.isComplete) {
      [self updateTimersForBuilding:hb justBuilt:YES];
      hb.isConstructing = YES;
      [hb displayProgressBar];
      
      [self reselectCurrentSelection];
      
      [self reloadUpgradeSigns];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_PURCHASED_NOTIFICATION object:nil];
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    ObstacleSprite *os = (ObstacleSprite *)self.selected;
    UserObstacle *uo = os.obstacle;
    
    [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
    [[OutgoingEventController sharedOutgoingEventController] beginObstacleRemoval:uo spendGems:allowGems];
    
    if (uo.endTime) {
      [self updateTimersForBuilding:os justBuilt:NO];
      [os displayProgressBar];
      
      [self reselectCurrentSelection];
      
      [self reloadUpgradeSigns];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:OBSTACLE_REMOVAL_BEGAN_NOTIFICATION object:nil];
    }
  }
}

#pragma mark - Speedup

- (IBAction)finishNowClicked:(id)sender {
  [self finishNow:nil sender:sender];
}

- (void) finishNow:(id)building sender:(id)sender {
  if (_isSpeedingUp) return;
  
  // Might come from timer action or from bottom view
  Building *hb = nil;
  GameActionType gameActionType = 0;
  if ([building isKindOfClass:[UserStruct class]]) {
    
    hb = (Building *)[self getChildByName:STRUCT_TAG([building userStructUuid]) recursively:NO];
    //timerView for building upgrades
    gameActionType = GameActionTypeUpgradeStruct;
  } else if ([building isKindOfClass:[UserObstacle class]]) {
    //timerView for removing obstacles
    hb = (Building *)[self getChildByName:STRUCT_TAG([building userObstacleUuid]) recursively:NO];
    gameActionType = GameActionTypeRemoveObstacle;
  } else {
    hb = (Building *)self.selected;
    if ([hb isKindOfClass:[HomeBuilding class]]) {
      gameActionType = GameActionTypeUpgradeStruct;
    } else {
      gameActionType = GameActionTypeRemoveObstacle;
    }
  }
  
  if (hb) {
    _speedupBuilding = hb;
    
    Globals *gl = [Globals sharedGlobals];
    int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:hb];
    BOOL allowFreeSpeedup = [hb isKindOfClass:[HomeBuilding class]];
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
    
    if (goldCost) {
      if (!self.currentViewController) {
        ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
        if (svc) {
          SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] initWithGameActionType:gameActionType];
          sif.delegate = self;
          svc.delegate = sif;
          self.speedupItemsFiller = sif;
          self.currentViewController = svc;
          
          GameViewController *gvc = [GameViewController baseController];
          svc.view.frame = gvc.view.bounds;
          [gvc addChildViewController:svc];
          [gvc.view addSubview:svc.view];
          
          if (sender == nil)
          {
            [svc showCenteredOnScreen];
          }
          else
          {
            if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
            {
              UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
              const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
              [svc showAnchoredToInvokingView:invokingButton
                                withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                            inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
            }
            else if ([sender isKindOfClass:[MapBotViewButton class]]) // Speeding up building upgrade or obstacle removal
            {
              UIButton* invokingButton = ((MapBotViewButton*)sender).bgdButton;
              [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferTopPlacement inkovingViewImage:invokingButton.currentImage];
            }
          }
        }
      }
    } else {
      [self speedUpBuildingQueueUp:NO];
    }
  }
}

- (void) sendSpeedupBuilding:(UserStruct *)us queueUp:(BOOL)queueUp {
  if (us.userStructUuid == nil || _waitingForResponse) {
    [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:us delegate:self queueUp:queueUp];
    us.hasShownFreeSpeedup = NO;
    
    // If queue up is on, that means a purch is gonna come right after
    if (!queueUp) {
      _waitingForResponse = YES;
    }
  }
}

- (BOOL) speedUpBuildingQueueUp:(BOOL)queueUp {
  if (_isSpeedingUp) return NO;
  if (!_speedupBuilding) return NO;
  
  // Close the speedup popup
  if (_speedupBuilding == self.selected) {
    [self closeCurrentViewController];
  }
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:_speedupBuilding];
  BOOL allowFreeSpeedup = [_speedupBuilding isKindOfClass:[HomeBuilding class]];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
  if (gs.gems < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    if ([_speedupBuilding isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *mb = (HomeBuilding *)_speedupBuilding;
      UserStruct *us = mb.userStruct;
      [self sendSpeedupBuilding:mb.userStruct queueUp:queueUp];
      if (us.isComplete) {
        _isSpeedingUp = YES;
        
        [SoundEngine structSpeedupConstruction];
        
        // Only animate it, if it is currently selected
        // It might not be selected if trying to speed up by building a new building
        void (^comp)(void) = ^{
          mb.isConstructing = NO;
          [mb displayUpgradeComplete];
          
          if (mb == self.selected) {
            [self reselectCurrentSelection];
          }
          
          [self reloadUpgradeSigns];
          [self reloadAllBubbles];
          
          if (_speedupBuilding == mb) {
            _speedupBuilding = nil;
          }
          [self updateTimersForBuilding:mb justBuilt:NO];
          
          [SoundEngine structCompleted];
          
          [QuestUtil checkAllStructQuests];
          [AchievementUtil checkBuildingUpgrade:us.structId];
          [[MiniEventManager sharedInstance] checkBuildStrength:us.structId];
          
          _isSpeedingUp = NO;
        };
        
        if (mb == self.selected) {
          [mb instaFinishUpgradeWithCompletionBlock:comp];
        } else {
          comp();
          [mb removeProgressBar];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_COMPLETE_NOTIFICATION object:nil];
        
        return YES;
      }
    } else if ([_speedupBuilding isKindOfClass:[ObstacleSprite class]]) {
      ObstacleSprite *os = (ObstacleSprite *)_speedupBuilding;
      UserObstacle *ob = os.obstacle;
      
      BOOL success = [[OutgoingEventController sharedOutgoingEventController] obstacleRemovalComplete:ob speedup:YES];
      
      if (success) {
        _isSpeedingUp = YES;
        
        [SoundEngine structSpeedupConstruction];
        
        // Only animate it, if it is currently selected
        // It might not be selected if trying to speed up by building a new building
        void (^comp)(void) = ^{
          [os disappear];
          
          if (os == self.selected) {
            self.selected = nil;
          }
          
          if (_speedupBuilding == os) {
            _speedupBuilding = nil;
          }
          [self updateTimersForBuilding:os justBuilt:NO];
          
          [AchievementUtil checkObstacleRemoved];
          
          _isSpeedingUp = NO;
        };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OBSTACLE_COMPLETE_NOTIFICATION object:nil];
        
        
        if (os == self.selected) {
          [os instaFinishUpgradeWithCompletionBlock:comp];
        } else {
          comp();
          [os removeProgressBar];
        }
        
        return YES;
      }
    }
  }
  return NO;
}

- (void) speedupBuildingAndUpgradeOrPurchase {
  // In case user waits till building is complete before hitting the popup button
  BOOL availBuilder = [self hasAvailableBuilder];
  if (!availBuilder) {
    _speedupBuilding = [self earliestConstructingBuildingOrObstacle];
  }
  
  if (availBuilder || [self speedUpBuildingQueueUp:YES]) {
    if (_purchasing) {
      [self moveCheckClicked:_buttonSender];
    } else {
      [self bigUpgradeClicked:_buttonSender];
    }
    _buttonSender = nil;
  }
}

#pragma mark - Hire/Upgrade delegates

- (void) upgradeViewControllerClosed {
  self.currentViewController = nil;
}

- (void) hireViewControllerClosed {
  self.currentViewController = nil;
}

- (void) homeViewControllerClosed {
  self.currentViewController = nil;
}

- (void) boardDesignerViewControllerClosed {
  self.currentViewController = nil;
}

#pragma mark - Speedup/Resource Items Filler

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:_speedupBuilding];
  BOOL allowFreeSpeedup = [_speedupBuilding isKindOfClass:[HomeBuilding class]];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedUpBuildingQueueUp:NO];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      if ([_speedupBuilding isKindOfClass:[HomeBuilding class]]) {
        HomeBuilding *hb = (HomeBuilding *)_speedupBuilding;
        [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userStruct:hb.userStruct];
        
        [viewController reloadDataAnimated:YES];
        [self updateTimersForBuilding:_speedupBuilding];
        [self updateMapBotView:self.bottomOptionView];
      } else if ([_speedupBuilding isKindOfClass:[ObstacleSprite class]]) {
        ObstacleSprite *hb = (ObstacleSprite *)_speedupBuilding;
        [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userObstacle:hb.obstacle];
        
        [viewController reloadDataAnimated:YES];
        [self updateTimersForBuilding:_speedupBuilding];
        [self updateMapBotView:self.bottomOptionView];
      }
    }
    
    int timeLeft = [self timeLeftForConstructionBuildingOrObstacle:_speedupBuilding];
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  return [self timeLeftForConstructionBuildingOrObstacle:_speedupBuilding];
}

- (int) totalSecondsRequired {
  if ([_speedupBuilding isKindOfClass:[HomeBuilding class]]) {
    Globals *gl = [Globals sharedGlobals];
    HomeBuilding *hb = (HomeBuilding *)_speedupBuilding;
    return [gl calculateSecondsToBuild:hb.userStruct.staticStruct.structInfo];
  } else if ([_speedupBuilding isKindOfClass:[ObstacleSprite class]]) {
    ObstacleSprite *os = (ObstacleSprite *)_speedupBuilding;
    return os.obstacle.staticObstacle.secondsToRemove;
  }
  return 0;
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  if (_purchasing) {
    [self purchaseWithItemDict:itemUsages];
  } else {
    [self upgradeWithItemDict:itemUsages];
  }
}

- (void) itemSelectClosed:(id)viewController {
  if (self.currentViewController == viewController) {
    self.currentViewController = nil;
  }
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

#pragma mark - LeaderBoard

- (void) openLeaderBoard:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  LeaderBoardViewController *lbvc = [[LeaderBoardViewController alloc] initStrengthLeaderBoard];
  [gvc addChildViewController:lbvc];
  [lbvc.view setFrame:gvc.view.bounds];
  [gvc.view addSubview:lbvc.view];
}

#pragma mark - Response Events

- (void) handlePurchaseNormStructureResponseProto:(FullEvent *)fe {
  PurchaseNormStructureResponseProto *proto = (PurchaseNormStructureResponseProto *)fe.event;
  
  if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusSuccess) {
    NSString *newName = STRUCT_TAG(proto.userStructUuid);
    
    HomeBuilding *hb = (HomeBuilding *)[self getChildByName:PURCH_STRUCT_TAG recursively:NO];
    
    if (hb) {
      hb.name = newName;
    } else {
      // Can't find struct, just reload everything
      LNLog(@"Unable to find purchased struct.. reloading everything.");
      [self refresh];
    }
  }
  
  _waitingForResponse = NO;
}

- (void) handleUpgradeNormStructureResponseProto:(FullEvent *)fe {
  _waitingForResponse = NO;
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto:(FullEvent *)fe {
  _waitingForResponse = NO;
}

- (void) handleNormStructWaitCompleteResponseProto:(FullEvent *)fe {
  _waitingForResponse = NO;
}

#pragma mark - Changing arrays

- (void) changeTiles:(CGRect)buildBlock toBuildable:(BOOL)canBuild {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
      // Account for the border for obstacles
      if (!canBuild || !(i < 2 || j < 2 || i > self.mapSize.width-3 || j > self.mapSize.height-3)) {
        [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
        [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
      }
    }
  }
}

- (BOOL) isBlockBuildable:(CGRect)buildBlock {
  NSArray *a = self.buildableData;
  for (int i = buildBlock.origin.x; i < buildBlock.size.width+buildBlock.origin.x; i++) {
    for (int j = buildBlock.origin.y; j < buildBlock.size.height+buildBlock.origin.y; j++) {
      if (i < 0 || i >= a.count || j < 0 ||  j >= [a[i] count] || ![a[i][j] boolValue]) {
        return NO;
      }
    }
  }
  return YES;
}

- (BOOL) isBlockWalkable:(CGRect)buildBlock {
  NSArray *a = self.walkableData;
  for (int i = buildBlock.origin.x; i < buildBlock.size.width+buildBlock.origin.x; i++) {
    for (int j = buildBlock.origin.y; j < buildBlock.size.height+buildBlock.origin.y; j++) {
      if (i < 0 || i >= a.count || j < 0 ||  j >= [a[i] count] || ![a[i][j] boolValue]) {
        return NO;
      }
    }
  }
  return YES;
}

- (void) collectAllIncome {
  NSMutableArray *arr = [NSMutableArray array];
  for (CCNode *node in self.children) {
    if ([node isKindOfClass:[ResourceGeneratorBuilding class]]) {
      [arr addObject:node];
    }
  }
  
  for (ResourceGeneratorBuilding *mb in arr) {
    [self retrieveFromBuilding:mb];
  }
}

- (void) reselectCurrentSelection {
  SelectableSprite *n = self.selected;
  //  self.selected = nil;
  self.selected = n;
  
  [self closeCurrentViewController];
}

- (void) closeCurrentViewController {
  [self.currentViewController performSelector:@selector(closeClicked:) withObject:nil];
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  [self beginTimers];
}

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStorages) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUpgradeSigns) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRetrievableIcons) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHospitals) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTeamSprites) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItemFactory) name:BATTLE_ITEM_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadItemFactory) name:BATTLE_ITEM_REMOVED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimerForHealingDidJustQueueUp) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMiniJobCenter) name:MINI_JOB_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTeamCenter) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadClanHouse) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadClanHouse) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:ENHANCE_MONSTER_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:EVOLUTION_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:FB_INCREASE_SLOTS_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBubblesOnMiscBuildings) name:RESEARCH_CHANGED_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTimers) name:STATIC_DATA_UPDATED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllBubbles) name:STATIC_DATA_UPDATED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUpgradeSigns) name:STATIC_DATA_UPDATED_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTimers) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  
  // Mini job just redeemed, clan donate redeemed
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHospitals) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLeaderBoard) name:LEADERBOARD_UPDATE_NOTIFICATION object:nil];
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
  
  [self closeCurrentViewController];
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

@end
