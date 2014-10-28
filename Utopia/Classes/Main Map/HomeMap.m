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
#import "MiniJobsViewController.h"
#import "HireViewController.h"
#import "HomeViewController.h"

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

#define RESOURCE_GEN_MIN_AMT 10

@implementation HomeMap

@synthesize redGid, greenGid;

- (id) init {
  self = [self initWithFile:@"home.tmx"];
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
    
    CCSprite *map = [CCSprite spriteWithImageNamed:@"homemapleft.jpg"];
    [self addChild:map z:-1000];
    
    
    CCSprite *map2 = [CCSprite spriteWithImageNamed:@"homemapright.jpg"];
    [map addChild:map2];
    map2.position = ccp(map.contentSize.width+map2.contentSize.width/2, map.contentSize.height/2);
    map.contentSize = CGSizeMake(map.contentSize.width+map2.contentSize.width, map.contentSize.height);
    
    map.position = ccp(map.contentSize.width/2-30, map.contentSize.height/2-48);
    
    [self beginMapAnimations];
    
    bottomLeftCorner = ccp(map.position.x-map.contentSize.width/2, map.position.y-map.contentSize.height/2);
    topRightCorner = ccp(map.position.x+map.contentSize.width/2, map.position.y+map.contentSize.height/2);
    
    [self refresh];
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

- (void) refresh {
  if (_loading) return;
  self.selected = nil;
  _constrBuilding = nil;
  _loading = YES;
  
  [self invalidateAllTimers];
  
  NSMutableArray *arr = [NSMutableArray array];
  [arr addObjectsFromArray:[self refreshForExpansion]];
  
  [self setupTeamSprites];
  [arr addObjectsFromArray:self.myTeamSprites];
  
  for (UserStruct *s in self.myStructsList) {
    StructureInfoProto *fsp = s.staticStruct.structInfo;
    if (!fsp)
      continue;
    HomeBuilding *homeBuilding = [HomeBuilding buildingWithUserStruct:s map:self];
    [self addChild:homeBuilding z:0 name:STRUCT_TAG(s.userStructId)];
    
    [arr addObject:homeBuilding];
    [homeBuilding placeBlock:NO];
    
    if (!s.isComplete) {
      homeBuilding.isConstructing = YES;
      _constrBuilding = homeBuilding;
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
  
  [self reloadAllBubbles];
  [_constrBuilding displayProgressBar];
  
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
  GameState *gs = [GameState sharedGameState];
  ObstacleProto *op = [self randomObstacle];
  
  if (op) {
    CGPoint pt = [self randomOpenSpaceWithSize:CGSizeMake(op.width, op.height)];
    
    if (!CGPointEqualToPoint(pt, ccp(-1, -1))) {
      UserObstacle *uo = [[UserObstacle alloc] init];
      uo.userId = gs.userId;
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
    [self addChild:os];
    
    if (uo.endTime) {
      _constrBuilding = os;
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
  
  NSArray *hosps = [gs myValidHospitals];
  for (CCSprite *spr in [self childrenOfClassType:[HospitalBuilding class]]) {
    HospitalBuilding *hosp = (HospitalBuilding *)spr;
    UserStruct *s = hosp.userStruct;
    NSInteger index = [hosps indexOfObject:s];
    UserMonsterHealingItem *hi = nil;
    
    if (index != NSNotFound && index < gs.monsterHealingQueue.count) {
      hi = gs.monsterHealingQueue[index];
    }
    
    if (hi) {
      [hosp beginAnimatingWithHealingItem:hi];
      
      [hosp setBubbleType:BuildingBubbleTypeNone];
    } else {
      [hosp stopAnimating];
      
      [hosp setBubbleType:hurtMobsters ? BuildingBubbleTypeHeal : BuildingBubbleTypeNone withNum:hurtMobsters];
    }
  }
}

- (void) reloadMiniJobCenter {
  GameState *gs = [GameState sharedGameState];
  UserStruct *mjc = [gs myMiniJobCenter];
  
  if (mjc) {
    MiniJobCenterBuilding *mjcb = (MiniJobCenterBuilding *)[self getChildByName:STRUCT_TAG(mjc.userStructId) recursively:NO];
    
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
  int numOnTeam = (int)gs.allBattleAvailableAliveMonstersOnTeam.count;
  for (TeamCenterBuilding *b in [self childrenOfClassType:[TeamCenterBuilding class]]) {
    [b setBubbleType:BuildingBubbleTypeManage withNum:numOnTeam];
    [b setNumEquipped:numOnTeam];
  }
}

- (void) reloadClanHouse {
  GameState *gs = [GameState sharedGameState];
  for (TeamCenterBuilding *b in [self childrenOfClassType:[ClanHouseBuilding class]]) {
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

- (void) reloadBubblesOnMiscBuildings {
  GameState *gs = [GameState sharedGameState];
  
  int numOverInv = (int)gs.myMonsters.count - [gs maxInventorySlots];
  for (Building *b in [self childrenOfClassType:[ResidenceBuilding class]]) {
    [b setBubbleType:(numOverInv > 0 ? BuildingBubbleTypeSell : BuildingBubbleTypeNone)  withNum:numOverInv];
  }
  
  BOOL evoInProgress = gs.userEvolution != nil;
  for (EvoBuilding *b in [self childrenOfClassType:[EvoBuilding class]]) {
    if (!evoInProgress) {
        [b setBubbleType:BuildingBubbleTypeEvolve];
      [b stopAnimating];
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
        [b setBubbleType:BuildingBubbleTypeEnhance];
      } else {
        [b setBubbleType:BuildingBubbleTypeFix];
      }
    }
  }
}

- (void) reloadAllBubbles {
  [self reloadHospitals];
  [self reloadStorages];
  [self reloadMiniJobCenter];
  [self reloadBubblesOnMiscBuildings];
  [self reloadTeamCenter];
  [self reloadClanHouse];
}

#pragma mark - Moving

- (BOOL) moveToStruct:(int)structId animated:(BOOL)animated {
  Globals *gl = [Globals sharedGlobals];
  
  int baseStructId = [gl baseStructIdForStructId:structId];
  
  UserStruct *chosen = nil;
  for (UserStruct *us in self.myStructsList) {
    int trueStructId = us.isComplete ? us.structId : us.staticStructForPrevLevel.structInfo.structId;
    if (us.baseStructId == baseStructId && (!chosen || trueStructId < chosen.structId) && trueStructId < structId) {
      chosen = us;
    }
  }
  
  HomeBuilding *mb = (HomeBuilding *)[self getChildByName:STRUCT_TAG(chosen.userStructId) recursively:NO];
  
  if (mb) {
    MapBotViewButtonConfig config = mb.userStruct.isComplete ? MapBotViewButtonUpgrade : MapBotViewButtonSpeedup;
    [self pointArrowOnBuilding:mb config:config];
    return YES;
  } else {
    return NO;
  }
}

- (void) pointArrowOnManageTeam {
  NSArray *arr = [self childrenOfClassType:[TeamCenterBuilding class]];
  if (arr.count > 0) {
    HomeBuilding *b = arr[0];
    [self pointArrowOnBuilding:b config:MapBotViewButtonTeam];
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

- (void) pointArrowOnBuilding:(HomeBuilding *)b config:(MapBotViewButtonConfig)config {
  [_arrowBuilding removeArrowAnimated:YES];
  
  self.selected = nil;
  
  [b displayArrow];
  [self moveToSprite:b animated:YES];
  
  _arrowBuilding = b;
  _arrowButtonConfig = config;
  
  [self scheduleOnce:@selector(removeArrowOnBuilding) delay:8.f];
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
  
  if ([self.selected isKindOfClass: [HomeBuilding class]]) {
    HomeBuilding *mb = (HomeBuilding *) self.selected;
    if (_purchasing) {
      self.bottomOptionView = nil;
    } else {
      self.bottomOptionView = self.buildBotView;
      [mb removeArrowAnimated:YES];
      
      _canMove = YES;
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    _canMove = NO;
    
    self.bottomOptionView = self.buildBotView;
  } else {
    // Remove any arrows
    self.bottomOptionView = nil;
    _canMove = NO;
    [self.currentViewController performSelector:@selector(closeClicked:) withObject:nil];
    self.currentViewController = nil;
    if (_purchasing) {
      _purchasing = NO;
      [_purchBuilding removeFromParent];
      [_purchBuilding liftBlock];
      [_purchBuilding clearMeta];
    }
    
    [self removeArrowOnBuilding];
  }
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
    self.buildingNameLabel.text = [NSString stringWithFormat:@"%@%@", fsp.name, lvlStr];
    if (us.isComplete) {
      
      if (isUpgradableBuilding) {
        if (fsp.successorStructId) {
          if (fsp.level == 0) {
            [buttonViews addObject:[MapBotViewButton fixButtonWithResourceType:nextFsp.buildResourceType buildCost:nextFsp.buildCost]];
          } else {
            [buttonViews addObject:[MapBotViewButton upgradeButtonWithResourceType:nextFsp.buildResourceType buildCost:nextFsp.buildCost]];
          }
        } else {
          [buttonViews addObject:[MapBotViewButton infoButton]];
        }
      }
      
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
          
        case StructureInfoProto_StructTypeLab:
          if (fsp.level > 0) {
            [buttonViews addObject:[MapBotViewButton enhanceButton]];
          }
          break;
          
        case StructureInfoProto_StructTypeMiniJob:
          if (fsp.level > 0) {
            [buttonViews addObject:[MapBotViewButton miniJobsButton]];
          }
          break;
          
        case StructureInfoProto_StructTypeTeamCenter:
          [buttonViews addObject:[MapBotViewButton teamButton]];
          break;
          
        case StructureInfoProto_StructTypeClan:
          [buttonViews addObject:[MapBotViewButton joinClanButton]];
          break;
          
        default:
          break;
      }
    } else {
      int timeLeft = [self timeLeftForConstructionBuilding];
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
      BOOL canGetHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeUpgradeStruct userDataId:us.userStructId] < 0;
      
      if (gemCost && canGetHelp) {
        [buttonViews addObject:[MapBotViewButton clanHelpButton]];
      } else {
        [buttonViews addObject:[MapBotViewButton speedupButtonWithGemCost:gemCost]];
      }
      
      // For a single residence, put the sell button in
      if (fsp.structType == StructureInfoProto_StructTypeResidence) {
        NSArray *arr = [self childrenOfClassType:[ResidenceBuilding class]];
        if (arr.count == 1) {
          [buttonViews addObject:[MapBotViewButton sellButton]];
        }
      } else if (fsp.structType == StructureInfoProto_StructTypeTeamCenter) {
        [buttonViews addObject:[MapBotViewButton teamButton]];
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
      int timeLeft = [self timeLeftForConstructionBuilding];
      [buttonViews addObject:[MapBotViewButton speedupButtonWithGemCost:[gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:NO]]];
    }
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
      
    default:
      break;
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
    if ([res isKindOfClass:[ResourceGeneratorBuilding class]] && res.retrievable) {
      res.retrievable = YES;
    }
  }
}

- (void) retrieveFromBuilding:(ResourceGeneratorBuilding *)mb {
  GameState *gs = [GameState sharedGameState];
  
  int amountCollected = [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mb.userStruct];
  mb.retrievable = NO;
  
  if (amountCollected > 0) {
    // Spawn a label on building
    ResourceType resType = ((ResourceGeneratorProto *)mb.userStruct.staticStruct).resourceType;
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
  [self setupIncomeTimerForBuilding:mb];
}

- (void) sendNormStructComplete:(UserStruct *)us {
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:us];
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
}

- (void) updateTimerForHealingDidJustQueueUp {
  [self updateTimerForHealingJustQueuedUp:YES];
}

- (void) updateTimerForHealingJustQueuedUp:(BOOL)justQueuedUp {
  NSMutableArray *oldTimers = [NSMutableArray array];
  for (NSTimer *t in _timers) {
    if ([t.userInfo isEqual:@"Healing"]) {
      [oldTimers addObject:t];
    }
  }
  
  for (NSTimer *oldTimer in oldTimers) {
    [oldTimer invalidate];
    [_timers removeObject:oldTimer];
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.monsterHealingQueue.count) {
    MSDate *date = gs.monsterHealingQueueEndTime;
    NSTimeInterval timeLeft = date.timeIntervalSinceNow;
    
    if (timeLeft > 0 && ((justQueuedUp && timeLeft/60.f > gl.maxMinutesForFreeSpeedUp) || !justQueuedUp)) {
      NSTimer *newTimer = [NSTimer timerWithTimeInterval:timeLeft-gl.maxMinutesForFreeSpeedUp*60 target:self selector:@selector(healingSpeedupBecameFree:) userInfo:@"Healing" repeats:NO];
      [_timers addObject:newTimer];
      [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
    }
  }
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
      }
    } else {
      if ([mb isKindOfClass:[ResourceGeneratorBuilding class]]) {
        ResourceGeneratorBuilding *rb = (ResourceGeneratorBuilding *)mb;
        if (rb.userStruct.numResourcesAvailable >= RESOURCE_GEN_MIN_AMT) {
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
  int numRes = RESOURCE_GEN_MIN_AMT;
  
  NSTimer *timer = nil;
  // Set timer for when building has x resources
  if ([mb.userStruct numResourcesAvailable] >= numRes) {
    timer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  } else {
    ResourceGeneratorProto *rg = (ResourceGeneratorProto *)mb.userStruct.staticStruct;
    int secs = numRes/rg.productionRate*3600;
    
    MSDate *date = [mb.userStruct.lastRetrieved dateByAddingTimeInterval:secs];
    
    timer = [NSTimer timerWithTimeInterval:date.timeIntervalSinceNow target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  }
  [_timers addObject:timer];
  [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void) constructionComplete:(NSTimer *)timer {
  HomeBuilding *mb = [timer userInfo];
  if (mb.userStruct.userStructId) {
    [self sendNormStructComplete:mb.userStruct];
    [self updateTimersForBuilding:mb justBuilt:NO];
    mb.isConstructing = NO;
    [mb removeProgressBar];
    [mb displayUpgradeComplete];
    if (mb == self.selected) {
      [mb cancelMove];
      [self reselectCurrentSelection];
    }
    _constrBuilding = nil;
    
    [self reloadAllBubbles];
    
    [QuestUtil checkAllStructQuests];
    [AchievementUtil checkBuildingUpgrade:mb.userStruct.structId];
    
    // Max cash/oil may have changed
    [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_COMPLETE_NOTIFICATION object:nil];
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
    [Globals addPurpleAlertNotification:desc];
    
    us.hasShownFreeSpeedup = YES;
  }
  
  [_timers removeObject:timer];
}

- (void) healingSpeedupBecameFree:(NSTimer *)timer {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSTimeInterval timeLeft = gs.monsterHealingQueueEndTime.timeIntervalSinceNow;
  
  if (!gs.hasShownFreeHealingQueueSpeedup && timeLeft > 0 && timeLeft/60.f < gl.maxMinutesForFreeSpeedUp) {
    NSString *desc = [NSString stringWithFormat:@"Healing time is below %d minutes. Free speedup available!", gl.maxMinutesForFreeSpeedUp];
    [Globals addPurpleAlertNotification:desc];
    
    gs.hasShownFreeHealingQueueSpeedup = YES;
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
  _constrBuilding = nil;
  
  [SoundEngine structCompleted];
  
  [AchievementUtil checkObstacleRemoved];
  [[NSNotificationCenter defaultCenter] postNotificationName:OBSTACLE_COMPLETE_NOTIFICATION object:nil];
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  ResourceGeneratorBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  [_timers removeObject:timer];
}

#pragma mark - IBActions

- (IBAction)moveCheckClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  if (homeBuilding.isSetDown && _purchasing) {
    if (_constrBuilding) {
      int timeLeft = [self timeLeftForConstructionBuilding];
      BOOL allowFreeSpeedup = [_constrBuilding isKindOfClass:[HomeBuilding class]];
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
      
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
        [GenericPopupController displayExchangeForGemsViewWithResourceType:fsp.buildResourceType amount:cost-curAmount target:self selector:@selector(useGemsForPurchase)];
      } else {
        [self purchaseBuildingAllowGems:NO];
      }
    }
    
    [SoundEngine generalButtonClick];
  } else {
    [Globals addAlertNotification:@"You can't build a building there, silly!"];
    [SoundEngine structCantPlace];
  }
}

- (void) useGemsForPurchase {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  int cost = fsp.buildCost;
  BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
  int curAmount = isOilBuilding ? gs.oil : gs.cash;
  int gemCost = [gl calculateGemConversionForResourceType:fsp.buildResourceType amount:cost-curAmount];
  
  if (gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self purchaseBuildingAllowGems:YES];
  }
}

- (void) purchaseBuildingAllowGems:(BOOL)allowGems {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  // Use return value as an indicator that purchase is accepted by client
  UserStruct *us = [self sendPurchaseStruct:allowGems];
  if (us) {
    homeBuilding.userStruct = us;
    _constrBuilding = homeBuilding;
    [self updateTimersForBuilding:homeBuilding justBuilt:YES];
    homeBuilding.isConstructing = YES;
    homeBuilding.isPurchasing = NO;
    homeBuilding.name = STRUCT_TAG(us.userStructId);
    
    [homeBuilding displayProgressBar];
    
    [homeBuilding removeChildByName:PURCHASE_CONFIRM_MENU_TAG cleanup:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_PURCHASED_NOTIFICATION object:nil];
    
    _canMove = NO;
    _purchasing = NO;
    _purchBuilding = nil;
    
    [self reselectCurrentSelection];
  } else {
    [homeBuilding liftBlock];
    [homeBuilding removeFromParent];
    
    self.selected = nil;
  }
  [self doReorder];
}

- (UserStruct *) sendPurchaseStruct:(BOOL)allowGems {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  // Use return value as an indicator that purchase is accepted by client
  return [[OutgoingEventController sharedOutgoingEventController] purchaseNormStruct:_purchStructId atX:homeBuilding.location.origin.x atY:homeBuilding.location.origin.y allowGems:allowGems];
}

- (IBAction)cancelMoveClicked:(id)sender {
  if (_purchasing) {
    self.selected = nil;
    
    [SoundEngine closeButtonClick];
  }
}

- (IBAction)enterClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  
  GameViewController *gvc = [GameViewController baseController];
  HomeViewController *hvc = nil;
  
  switch (fsp.structType) {
    case StructureInfoProto_StructTypeHospital:
      hvc = [[HomeViewController alloc] initWithHeal];
      break;
      
    case StructureInfoProto_StructTypeLab:
      hvc = [[HomeViewController alloc] initWithEnhance];
      break;
      
    case StructureInfoProto_StructTypeResidence:
      hvc = [[HomeViewController alloc] initWithSell];
      break;
      
    case StructureInfoProto_StructTypeTeamCenter:
      hvc = [[HomeViewController alloc] initWithTeam];
      break;
      
    case StructureInfoProto_StructTypeEvo:
      hvc = [[HomeViewController alloc] initWithEvolve];
      break;
      
    case StructureInfoProto_StructTypeMiniJob:
      hvc = [[HomeViewController alloc] initWithMiniJobs];
      break;
      
    case StructureInfoProto_StructTypeClan:
      [gvc openClanView];
      break;
      
    default:
      break;
  }
  
  if (hvc) {
    [gvc.topBarViewController displayHomeViewController:hvc];
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
  // Just need to solicit for constr building
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = ((HomeBuilding *)_constrBuilding).userStruct;
  
  if (us) {
    if (us.userStructId == 0) {
      [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
    } else if ([gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeUpgradeStruct userDataId:us.userStructId] < 0) {
      [[OutgoingEventController sharedOutgoingEventController] solicitBuildingHelp:us];
      
      if (_constrBuilding == self.selected) {
        [self reselectCurrentSelection];
      }
    }
  }
}

- (void) loadMiniJobsView {
  // LEGACY
  GameViewController *gvc = [GameViewController baseController];
  MiniJobsViewController *rvc = [[MiniJobsViewController alloc] init];
  [gvc addChildViewController:rvc];
  rvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:rvc.view];
}

#pragma mark - Upgrade

- (IBAction)littleUpgradeClicked:(id)sender {
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    [self loadUpgradeViewControllerForIsHire:NO];
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    [self bigUpgradeClicked];
  }
}

- (void) loadUpgradeViewControllerForIsHire:(BOOL)isHire {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  GameViewController *gvc = [GameViewController baseController];
  UIViewController *uvc;
  
  if (!isHire) {
    UpgradeViewController *up = [[UpgradeViewController alloc] initWithUserStruct:us];
    up.delegate = self;
    uvc = up;
  } else {
    uvc = [[HireViewController alloc] initWithUserStruct:us];
  }
  
  [gvc addChildViewController:uvc];
  uvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:uvc.view];
  self.currentViewController = uvc;
}

- (int) timeLeftForConstructionBuilding {
  if ([_constrBuilding isKindOfClass:[HomeBuilding class]]) {
    UserStruct *cus = ((HomeBuilding *)_constrBuilding).userStruct;
    return cus.timeLeftForBuildComplete;
  } else if ([_constrBuilding isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)_constrBuilding).obstacle;
    return ub.endTime.timeIntervalSinceNow;
  }
  return 0;
}

- (void) bigUpgradeClicked {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int cost = 0;
  BOOL isOilBuilding = NO;
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
    StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
    
    cost = nextFsp.buildCost;
    isOilBuilding = nextFsp.buildResourceType == ResourceTypeOil;
    
    if (nextFsp.structType == StructureInfoProto_StructTypeMiniJob) {
      BOOL activeQuest = NO;
      for (UserMiniJob *mj in gs.myMiniJobs) {
        if (mj.timeStarted || mj.timeCompleted) {
          activeQuest = YES;
        }
      }
      
      if (activeQuest) {
        [GenericPopupController displayNotificationViewWithText:@"You have a currently active mini job. Complete it before upgrading." title:@"Active Mini Job"];
        return;
      }
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)self.selected).obstacle;
    ObstacleProto *op = ub.staticObstacle;
    
    cost = op.cost;
    isOilBuilding = op.removalCostType == ResourceTypeOil;
  }
  
  int curAmount = isOilBuilding ? gs.oil : gs.cash;
  if (_constrBuilding) {
    int timeLeft = [self timeLeftForConstructionBuilding];
    BOOL allowFreeSpeedup = [_constrBuilding isKindOfClass:[HomeBuilding class]];
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
    
    if (gemCost) {
      NSString *desc = [NSString stringWithFormat:@"Your builder is busy! Speed him up for %@ gem%@ and upgrade this building?", [Globals commafyNumber:gemCost], gemCost == 1 ? @"" : @"s"];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Busy Builder" gemCost:gemCost target:self selector:@selector(speedupBuildingAndUpgradeOrPurchase)];
    } else {
      [self speedupBuildingAndUpgradeOrPurchase];
    }
  } else if (cost) {
    if (cost > curAmount) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:isOilBuilding ? ResourceTypeOil : ResourceTypeCash amount:cost-curAmount target:self selector:@selector(useGemsForUpgrade)];
    } else {
      [self sendUpgradeAllowGems:NO];
    }
  }
}

- (void) useGemsForUpgrade {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int cost = 0;
  BOOL isOilBuilding = NO;
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
    StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
    
    cost = nextFsp.buildCost;
    isOilBuilding = nextFsp.buildResourceType == ResourceTypeOil;
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    UserObstacle *ub = ((ObstacleSprite *)self.selected).obstacle;
    ObstacleProto *op = ub.staticObstacle;
    
    cost = op.cost;
    isOilBuilding = op.removalCostType == ResourceTypeOil;
  }
  
  int curAmount = isOilBuilding ? gs.oil : gs.cash;
  int gemCost = [gl calculateGemConversionForResourceType:isOilBuilding ? ResourceTypeOil : ResourceTypeCash amount:cost-curAmount];
  
  if (gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendUpgradeAllowGems:YES];
  }
}

- (void) sendUpgradeAllowGems:(BOOL)allowGems {
  if ([self.selected isKindOfClass:[HomeBuilding class]]) {
    HomeBuilding *hb = (HomeBuilding *)self.selected;
    UserStruct *us = hb.userStruct;
    
    if (us.userStructId == 0) {
      [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us allowGems:allowGems];
    }
  
    if (!us.isComplete) {
      _constrBuilding = hb;
      [self updateTimersForBuilding:hb justBuilt:YES];
      hb.isConstructing = YES;
      [hb displayProgressBar];
      
      [self reselectCurrentSelection];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:STRUCT_PURCHASED_NOTIFICATION object:nil];
    }
  } else if ([self.selected isKindOfClass:[ObstacleSprite class]]) {
    ObstacleSprite *os = (ObstacleSprite *)self.selected;
    UserObstacle *uo = os.obstacle;
    
    [[OutgoingEventController sharedOutgoingEventController] beginObstacleRemoval:uo spendGems:allowGems];
    
    if (uo.endTime) {
      _constrBuilding = os;
      [self updateTimersForBuilding:os justBuilt:NO];
      [os displayProgressBar];
      
      [self reselectCurrentSelection];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:OBSTACLE_REMOVAL_BEGAN_NOTIFICATION object:nil];
    }
  }
}

#pragma mark - Speedup

- (IBAction)finishNowClicked:(id)sender {
  if (_isSpeedingUp) return;
  
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = [self timeLeftForConstructionBuilding];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (goldCost) {
    NSString *desc = [NSString stringWithFormat:@"Finish instantly for %@ gem%@?", [Globals commafyNumber:goldCost], goldCost == 1 ? @"" : @"s"];
    [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Speed Up!" gemCost:goldCost target:self selector:@selector(speedUpBuilding)];
  } else {
    [self speedUpBuilding];
  }
}

- (void) sendSpeedupBuilding:(UserStruct *)us {
  if (us.userStructId == 0) {
    [Globals addAlertNotification:@"Hold on, we are still processing your building purchase."];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:us];
  }
}

- (BOOL) speedUpBuilding {
  if (_isSpeedingUp) return NO;
  if (!_constrBuilding) return NO;
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int timeLeft = [self timeLeftForConstructionBuilding];
  BOOL allowFreeSpeedup = [_constrBuilding isKindOfClass:[HomeBuilding class]];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:allowFreeSpeedup];
  if (gs.gems < gemCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    if ([_constrBuilding isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *mb = (HomeBuilding *)_constrBuilding;
      UserStruct *us = mb.userStruct;
      [self sendSpeedupBuilding:mb.userStruct];
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
          
          [self reloadAllBubbles];
          
          if (_constrBuilding == mb) {
            _constrBuilding = nil;
          }
          [self updateTimersForBuilding:mb justBuilt:NO];
          
          [SoundEngine structCompleted];
          
          [QuestUtil checkAllStructQuests];
          [AchievementUtil checkBuildingUpgrade:us.structId];
          
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
    } else if ([_constrBuilding isKindOfClass:[ObstacleSprite class]]) {
      ObstacleSprite *os = (ObstacleSprite *)_constrBuilding;
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
          
          if (_constrBuilding == os) {
            _constrBuilding = nil;
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
  if ([self speedUpBuilding]) {
    if (_purchasing) {
      [self moveCheckClicked:nil];
    } else {
      [self bigUpgradeClicked];
    }
  }
}

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
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  [self beginTimers];
}

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStorages) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRetrievableIcons) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHospitals) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTeamSprites) name:HEAL_QUEUE_CHANGED_NOTIFICATION object:nil];
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
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginTimers) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  
  // Mini job just redeemed
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHospitals) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
  
  [self.currentViewController.view removeFromSuperview];
  [self.currentViewController removeFromParentViewController];
  self.currentViewController = nil;
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

@end
