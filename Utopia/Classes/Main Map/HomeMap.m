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
#import "MyCroniesViewController.h"
#import "MenuNavigationController.h"
#import "EnhanceViewController.h"
#import "CCAnimation+SpriteLoading.h"
#import "CCSoundAnimation.h"

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

#define RESOURCE_GEN_MIN_RES 10

@implementation HomeMap

@synthesize redGid, greenGid;

- (id) init {
  self = [self initWithFile:@"home.tmx"];
  return self;
}

- (id) initWithFile:(NSString *)tmxFile {
  _loading = YES;
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
    
    if ([Globals isLongiPhone]) {
      [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
    } else {
      [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenuSmall" owner:self options:nil];
    }
    
    _timers = [[NSMutableArray alloc] init];
    
    _loading = NO;
    
    [self refresh];
    [self moveToCenterAnimated:NO];
    
    CCSprite *map = [CCSprite spriteWithImageNamed:@"missionmap2.png"];
    [self addChild:map z:-1000];
    
    map.position = ccp(map.contentSize.width/2-33, map.contentSize.height/2-50);
    
    //    CCSprite *road = [CCSprite spriteWithImageNamed:@"homeroad.png"];
    //    [self addChild:road z:-998];
    //    road.position = ccp(self.contentSize.width/2-17, self.contentSize.height/2-7);
    
    [self beginMapAnimations];
    
    bottomLeftCorner = ccp(map.position.x-map.contentSize.width/2, map.position.y-map.contentSize.height/2);
    topRightCorner = ccp(map.position.x+map.contentSize.width/2, map.position.y+map.contentSize.height/2);
  }
  return self;
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
  boat.position = ccp(780, 35);
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
  CGPoint startPos = ccp(68, 58);
  CGPoint farEndPos = ccp(143, 118);
  CGPoint finalEndPos = ccp(143, 105);
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

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  PurchaseConfirmMenu *menu = (PurchaseConfirmMenu *)[self getChildByName:PURCHASE_CONFIRM_MENU_TAG recursively:YES];
  
  if ([menu hitTestWithWorldPos:[touch locationInWorld]]) {
    return NO;
  }
  return YES;
}

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
      HomeBuilding *hb = (HomeBuilding *)node;
      [self updateTimersForBuilding:hb];
    }
  }
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
    if (!fsp) {return;}
    HomeBuilding *homeBuilding = [HomeBuilding buildingWithUserStruct:s map:self];
    [self addChild:homeBuilding z:0 name:STRUCT_TAG(s.userStructId)];
    
    homeBuilding.orientation = s.orientation;
    homeBuilding.userStruct = s;
    
    [arr addObject:homeBuilding];
    [homeBuilding placeBlock];
    
    if (!s.isComplete) {
      homeBuilding.isConstructing = YES;
      _constrBuilding = homeBuilding;
    }
  }
  
  [self reloadHospitals];
  [self reloadStorages];
  
  NSMutableArray *toRemove = [NSMutableArray array];
  for (CCNode *c in self.children) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      [toRemove addObject:c];
    }
  }
  
  for (SelectableSprite *c in toRemove) {
    [c removeFromParent];
  }
  
  for (CCNode *node in arr) {
    if ([node isKindOfClass:[HomeBuilding class]]) {
      [(HomeBuilding *)node placeBlock];
    }
  }
  
  if (_constrBuilding) {
    [_constrBuilding displayProgressBar];
  }
  
  [self doReorder];
  _loading = NO;
  
  if (self.isRunningInActiveScene) {
    [self beginTimers];
  }
}

- (void) reloadHospitals {
  GameState *gs = [GameState sharedGameState];
  NSArray *hosps = [gs myValidHospitals];
  for (CCSprite *spr in self.children) {
    if ([spr isKindOfClass:[HospitalBuilding class]]) {
      HospitalBuilding *hosp = (HospitalBuilding *)spr;
      UserStruct *s = hosp.userStruct;
      NSInteger index = [hosps indexOfObject:s];
      int monsterId = 0;
      
      if (index != NSNotFound && index < gs.monsterHealingQueue.count) {
        UserMonsterHealingItem *item = gs.monsterHealingQueue[index];
        UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
        monsterId = um.monsterId;
      }
      
      if (monsterId) {
        [hosp beginAnimatingWithMonsterId:monsterId];
      } else {
        [hosp stopAnimating];
      }
    }
  }
}

- (void) reloadStorages {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *oilArr = [NSMutableArray array];
  NSMutableArray *cashArr = [NSMutableArray array];
  for (CCSprite *spr in self.children) {
    if ([spr isKindOfClass:[ResourceStorageBuilding class]]) {
      ResourceType type = ((ResourceStorageProto *)((ResourceStorageBuilding *)spr).userStruct.staticStruct).resourceType;
      if (type == ResourceTypeCash) {
        [cashArr addObject:spr];
      } else if (type == ResourceTypeOil) {
        [oilArr addObject:spr];
      }
    }
  }
  
  int curCash = gs.silver;
  int curOil = gs.oil;
  
  NSComparator comp = ^NSComparisonResult(ResourceStorageBuilding *obj1, ResourceStorageBuilding *obj2) {
    int capacity1 = ((ResourceStorageProto *)obj1.userStruct.staticStruct).capacity;
    int capacity2 = ((ResourceStorageProto *)obj2.userStruct.staticStruct).capacity;
    return [@(capacity1) compare:@(capacity2)];
  };
  [cashArr sortUsingComparator:comp];
  [oilArr sortUsingComparator:comp];
  
  for (NSMutableArray *arr in @[cashArr, oilArr]) {
    int curVal = arr == cashArr ? curCash : curOil;
    while (arr.count > 0) {
      NSInteger count = arr.count;
      int amount = curVal/count;
      ResourceStorageBuilding *res = arr[0];
      int capacity1 = ((ResourceStorageProto *)res.userStruct.staticStruct).capacity;
      
      if (capacity1 >= amount) {
        for (ResourceStorageBuilding *r in arr) {
          float cap = ((ResourceStorageProto *)r.userStruct.staticStruct).capacity;
          [r setPercentage:amount/cap];
        }
        break;
      } else {
        [res setPercentage:1.f];
        curVal -= capacity1;
        [arr removeObject:res];
      }
    }
  }
}

- (NSArray *) refreshForExpansion {
  GameState *gs = [GameState sharedGameState];
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
  
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      if (i == 0 && j == 0) {
        continue;
      }
      
      UserExpansion *ue = [gs getExpansionForX:i y:j];
      
      if (false) {//(!ue || ue.isExpanding) {
        CGPoint offset = ccp(0,0);
        
        CGRect r = CGRectZero;
        r.size.width = i == 0 ? EXPANSION_MID_SQUARE_SIZE : EXPANSION_BLOCK_SIZE;
        r.size.height = j == 0 ? EXPANSION_MID_SQUARE_SIZE : EXPANSION_BLOCK_SIZE;
        r.origin = ccp(CENTER_TILE_X, CENTER_TILE_Y);
        r.origin.x += i*(EXPANSION_MID_SQUARE_SIZE/2+EXPANSION_ROAD_SIZE+EXPANSION_BLOCK_SIZE/2)-r.size.width/2+offset.x;
        r.origin.y += j*(EXPANSION_MID_SQUARE_SIZE/2+EXPANSION_ROAD_SIZE+EXPANSION_BLOCK_SIZE/2)-r.size.height/2+offset.y;
        ExpansionBoard *eb = [[ExpansionBoard alloc] initWithExpansionBlock:ccp(i,j) location:r map:self isExpanding:NO];
        [self addChild:eb z:-999];
        [arr addObject:eb];
        
        r.origin.x -= offset.x;
        r.origin.y -= offset.y;
        for (int i = r.origin.x; i < r.origin.x+r.size.width; i++) {
          for (int j = r.origin.y; j < r.origin.y+r.size.height; j++) {
            [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
            [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
          }
        }
        
        if (ue.isExpanding) {
          [eb beginExpanding];
        }
      }
    }
  }
  
  return arr;
  //return [NSArray array];
}

- (void) moveToStruct:(int)structId showArrow:(BOOL)showArrow animated:(BOOL)animated {
  //  Globals *gl = [Globals sharedGlobals];
  HomeBuilding *mb = nil;
  //  for (int tag = baseTag; tag < baseTag+gl.maxRepeatedNormStructs; tag++) {
  //    MoneyBuilding *check;
  //    if ((check = (MoneyBuilding *)[self getChildByTag:tag])) {
  //      if (!mb || check.userStruct.staticStruct.structInfo.level > mb.userStruct.staticStruct.structInfo.level) {
  //        mb = check;
  //      }
  //    } else {
  //      break;
  //    }
  //  }
  
  if (mb) {
    [self moveToSprite:mb animated:animated];
    if (showArrow) {
      [mb displayArrow];
    }
  }
}

- (void) doReorder {
  [super doReorder];
  
  if ((_isMoving && self.selected) || ([self.selected isKindOfClass:[HomeBuilding class]] && !((HomeBuilding *)self.selected).isSetDown)) {
    self.selected.zOrder = 1000;
  }
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
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  us.coordinates = [self openSpaceNearCenterWithSize:CGSizeMake(fsp.width, fsp.height)];
  
  _purchBuilding = [HomeBuilding buildingWithUserStruct:us map:self];
  _purchBuilding.isPurchasing = YES;
  
  [self addChild:_purchBuilding];
  [_purchBuilding placeBlock];
  
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  self.selected = _purchBuilding;
  
  [self doReorder];
  
  [self moveToSprite:_purchBuilding animated:YES];
  
  PurchaseConfirmMenu *m = [[PurchaseConfirmMenu alloc] initWithCheckTarget:self checkSelector:@selector(moveCheckClicked:) cancelTarget:self cancelSelector:@selector(cancelMoveClicked:)];
  m.name = PURCHASE_CONFIRM_MENU_TAG;
  [_purchBuilding addChild:m];
  m.position = ccp(_purchBuilding.contentSize.width/2, (_purchBuilding.contentSize.height+10)*_purchBuilding.baseScale);
}

- (void) setSelected:(SelectableSprite *)selected {
  [super setSelected:selected];
  
  if ([self.selected isKindOfClass: [HomeBuilding class]]) {
    HomeBuilding *mb = (HomeBuilding *) self.selected;
    if (_purchasing) {
      self.bottomOptionView = nil;
    } else {
      self.bottomOptionView = mb.userStruct.isComplete ? self.buildBotView : self.upgradeBotView;
      [mb removeArrowAnimated:YES];
      
      _canMove = YES;
    }
  } else if ([self.selected isKindOfClass:[ExpansionBoard class]]) {
    GameState *gs = [GameState sharedGameState];
    ExpansionBoard *exp = (ExpansionBoard *)self.selected;
    UserExpansion *ue = [gs getExpansionForX:exp.expandSpot.x y:exp.expandSpot.y];
    
    _canMove = NO;
    
    if (!ue.isExpanding) {
      self.bottomOptionView = self.expandBotView;
    } else {
      self.bottomOptionView = self.expandingBotView;
    }
  } else {
    self.bottomOptionView = nil;
    _canMove = NO;
    [self.upgradeViewController closeClicked:nil];
    self.upgradeViewController = nil;
    if (_purchasing) {
      _purchasing = NO;
      [_purchBuilding removeFromParent];
    }
  }
}

- (void) updateMapBotView:(MapBotView *)botView {
  if (botView == self.buildBotView) {
    if ([self.selected isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *mb = (HomeBuilding *)self.selected;
      StructureInfoProto *fsp = mb.userStruct.staticStruct.structInfo;
      StructureInfoProto *nextFsp = mb.userStruct.staticStructForNextLevel.structInfo;
      self.buildingNameLabel.text = [NSString stringWithFormat:@"%@ (lvl %d)", fsp.name, fsp.level];
      self.buildingIncomeLabel.text = fsp.shortDescription;
      BOOL isOil = nextFsp ? nextFsp.buildResourceType == ResourceTypeOil : fsp.buildResourceType == ResourceTypeOil;
      
      if (nextFsp) {
        self.buildingUpgradeCashCostLabel.text = [Globals cashStringForNumber:nextFsp.buildCost];
        self.buildingUpgradeOilCostLabel.text = [Globals commafyNumber:nextFsp.buildCost];
      } else {
        self.buildingUpgradeCashCostLabel.text = @"N/A";
        self.buildingUpgradeOilCostLabel.text = @"N/A";
      }
      
      BOOL showsEnterButton = YES;
      switch (fsp.structType) {
        case StructureInfoProto_StructTypeHospital:
          self.enterTopLabel.text = @"Manage";
          self.enterBottomLabel.text = @"Mobsters";
          break;
          
        case StructureInfoProto_StructTypeLab:
          self.enterTopLabel.text = @"Enhance";
          self.enterBottomLabel.text = @"Mobsters";
          break;
          
        case StructureInfoProto_StructTypeResidence:
        case StructureInfoProto_StructTypeTownHall:
        case StructureInfoProto_StructTypeResourceStorage:
        case StructureInfoProto_StructTypeResourceGenerator:
          showsEnterButton = NO;
          break;
          
        default:
          break;
      }
      
      CGRect r = self.buildingTextView.frame;
      if (showsEnterButton) {
        r.size.width = self.buildingEnterView.frame.origin.x-4;
        self.buildingEnterView.hidden = NO;
      } else {
        r.size.width = self.buildingUpgradeView.frame.origin.x-4;
        self.buildingEnterView.hidden = YES;
      }
      self.buildingTextView.frame = r;
      
      self.buildingUpgradeOilView.hidden = !isOil;
      [Globals adjustViewForCentering:self.buildingUpgradeOilCostLabel.superview withLabel:self.buildingUpgradeOilCostLabel];
    }
  } else if (botView == self.upgradeBotView) {
    if ([self.selected isKindOfClass:[HomeBuilding class]]) {
      Globals *gl = [Globals sharedGlobals];
      HomeBuilding *mb = (HomeBuilding *)self.selected;
      UserStruct *us = mb.userStruct;
      StructureInfoProto *fsp = us.staticStruct.structInfo;
      self.upgradingNameLabel.text = [NSString stringWithFormat:@"%@ (lvl %d)", fsp.name, fsp.level];
      self.upgradingIncomeLabel.text = fsp.shortDescription;
      int timeLeft = us.timeLeftForBuildComplete;
      self.upgradingSpeedupCostLabel.text = [Globals commafyNumber:[gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
    }
  } else if (botView == self.expandBotView) {
    if ([self.selected isKindOfClass:[ExpansionBoard class]]) {
      Globals *gl = [Globals sharedGlobals];
      ExpansionBoard *ep = (ExpansionBoard *)self.selected;
      self.expandSubtitleLabel.text = [gl expansionPhraseForExpandSpot:ep.expandSpot];
      self.expandCostLabel.text = [Globals cashStringForNumber:[gl calculateSilverCostForNewExpansion]];
    }
  } else if (botView == self.expandingBotView) {
    if ([self.selected isKindOfClass:[ExpansionBoard class]]) {
      GameState *gs = [GameState sharedGameState];
      Globals *gl = [Globals sharedGlobals];
      ExpansionBoard *ep = (ExpansionBoard *)self.selected;
      UserExpansion *exp = [gs currentExpansion];
      int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
      self.expandingSubtitleLabel.text = [gl expansionPhraseForExpandSpot:ep.expandSpot];
      self.expandingSpeedupCostLabel.text = [Globals commafyNumber:[gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
    }
  }
}

#pragma mark - Gesture Recognizers

- (void) drag:(UIGestureRecognizer*)recognizer
{
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
        [homeBuilding placeBlock];
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

- (void) updateTimersForBuilding:(HomeBuilding *)mb {
  NSTimer *oldTimer = nil;
  for (NSTimer *t in _timers) {
    if (t.userInfo == mb) {
      oldTimer = t;
      break;
    }
  }
  
  if (oldTimer) {
    [oldTimer invalidate];
    [_timers removeObject:oldTimer];
  }
  
  if (!mb.userStruct.isComplete) {
    NSTimer *newTimer = [NSTimer timerWithTimeInterval:mb.userStruct.timeLeftForBuildComplete target:self selector:@selector(constructionComplete:) userInfo:mb repeats:NO];
    [_timers addObject:newTimer];
    [[NSRunLoop mainRunLoop] addTimer:newTimer forMode:NSRunLoopCommonModes];
  } else {
    if ([mb isKindOfClass:[ResourceGeneratorBuilding class]]) {
      ResourceGeneratorBuilding *rb = (ResourceGeneratorBuilding *)mb;
      if (rb.userStruct.numResourcesAvailable >= RESOURCE_GEN_MIN_RES) {
        rb.retrievable = YES;
      } else {
        [self setupIncomeTimerForBuilding:rb];
      }
    }
  }
}

- (void) setupIncomeTimerForBuilding:(ResourceGeneratorBuilding *)mb {
  int numRes = RESOURCE_GEN_MIN_RES;
  
  NSTimer *timer = nil;
  // Set timer for when building has x resources
  if ([mb.userStruct numResourcesAvailable] >= numRes) {
    timer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  } else {
    ResourceGeneratorProto *rg = (ResourceGeneratorProto *)mb.userStruct.staticStruct;
    int secs = numRes/rg.productionRate*3600;
    
    NSDate *date = [mb.userStruct.lastRetrieved dateByAddingTimeInterval:secs];
    
    timer = [NSTimer timerWithTimeInterval:date.timeIntervalSinceNow target:self selector:@selector(waitForIncomeComplete:) userInfo:mb repeats:NO];
  }
  [_timers addObject:timer];
  [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void) retrieveFromBuilding:(ResourceGeneratorBuilding *)mb {
  int amountCollected = [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mb.userStruct];
  mb.retrievable = NO;
  
  // Spawn a label on building
  CCLabelTTF *label = [CCLabelTTF labelWithString:[Globals commafyNumber:amountCollected] fontName:[Globals font] fontSize:16.f];
  [self addChild:label z:1000];
  label.position = ccp(mb.position.x, mb.position.y+mb.contentSize.height*3/4);
  UIColor *c = ((ResourceGeneratorProto *)mb.userStruct.staticStruct).resourceType == ResourceTypeCash ? [Globals greenColor] : [Globals yellowColor];
  label.fontColor = [CCColor colorWithUIColor:c];
  label.shadowColor = [CCColor colorWithWhite:0.f alpha:0.5f];
  label.shadowOffset = ccp(0, -1);
  
  [label runAction:[CCActionSequence actions:
                    [CCActionSpawn actions:
                     [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                     [CCActionFadeOut actionWithDuration:1.5f],
                     [CCActionMoveBy actionWithDuration:1.5f position:ccp(0,25)],nil],
                    [CCActionCallFunc actionWithTarget:label selector:@selector(removeFromParent)], nil]];
  
  [self setupIncomeTimerForBuilding:mb];
}

- (void) sendNormStructComplete:(UserStruct *)us {
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:us];
}

- (void) constructionComplete:(NSTimer *)timer {
  HomeBuilding *mb = [timer userInfo];
  [self sendNormStructComplete:mb.userStruct];
  [self updateTimersForBuilding:mb];
  mb.isConstructing = NO;
  [mb removeProgressBar];
  [mb displayUpgradeComplete];
  if (mb == self.selected) {
    [mb cancelMove];
    [self reselectCurrentSelection];
  }
  _constrBuilding = nil;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  ResourceGeneratorBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  [_timers removeObject:timer];
}

- (IBAction)moveCheckClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  if (homeBuilding.isSetDown && _purchasing) {
    if (_constrBuilding) {
      UserStruct *cus = _constrBuilding.userStruct;
      int timeLeft = cus.timeLeftForBuildComplete;
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
      [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"A building is already constructing. Speed it up for %@ gems and purchase this building?", [Globals commafyNumber:gemCost]] title:@"Already Constructing" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupBuildingAndUpgradeOrPurchase)];
    } else {
      int cost = fsp.buildCost;
      BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
      int curAmount = isOilBuilding ? gs.oil : gs.silver;
      
      if (cost > curAmount) {
        [GenericPopupController displayExchangeForGemsViewWithResourceType:fsp.buildResourceType amount:cost-curAmount target:self selector:@selector(useGemsForPurchase)];
      } else {
        [self purchaseBuildingAllowGems:NO];
      }
    }
  }
}

- (void) useGemsForPurchase {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = [gs structWithId:_purchStructId].structInfo;
  
  int cost = fsp.buildCost;
  BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
  int curAmount = isOilBuilding ? gs.oil : gs.silver;
  int gemCost = [gl calculateGemConversionForResourceType:fsp.buildResourceType amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
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
    [self updateTimersForBuilding:_constrBuilding];
    homeBuilding.isConstructing = YES;
    homeBuilding.isPurchasing = NO;
    homeBuilding.name = STRUCT_TAG(us.userStructId);
    
    [_constrBuilding displayProgressBar];
    
    [[SoundEngine sharedSoundEngine] carpenterPurchase];
    
    [homeBuilding removeChildByName:PURCHASE_CONFIRM_MENU_TAG cleanup:YES];
    
    _canMove = NO;
    _purchasing = NO;
    _purchBuilding = NO;
    
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
    [_purchBuilding liftBlock];
    self.selected = nil;
    _canMove = NO;
    _purchasing = NO;
  } else {
    HomeBuilding *hb = (HomeBuilding *)self.selected;
    [hb cancelMove];
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
  }
}

#pragma mark - IBActions

- (IBAction)enterClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  
  GameViewController *gvc = [GameViewController baseController];
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  [gvc presentViewController:m animated:YES completion:nil];
  
  switch (fsp.structType) {
    case StructureInfoProto_StructTypeHospital:
    case StructureInfoProto_StructTypeResidence:
      [m pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
      break;
      
    case StructureInfoProto_StructTypeLab:
      [m pushViewController:[[EnhanceViewController alloc] init] animated:YES];
      break;
      
    default:
      break;
  }
}

- (IBAction)littleUpgradeClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  int maxLevel = us.maxLevel;
  if (us.staticStruct.structInfo.level < maxLevel) {
    GameViewController *gvc = [GameViewController baseController];
    UpgradeViewController *uvc = [[UpgradeViewController alloc] initWithUserStruct:us];
    uvc.delegate = self;
    [gvc addChildViewController:uvc];
    [gvc.view addSubview:uvc.view];
    self.upgradeViewController = uvc;
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"The maximum level for the %@ is %d.", us.staticStruct.structInfo.name, maxLevel]];
  }
}

- (void) bigUpgradeClicked {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
  
  if (_constrBuilding) {
    UserStruct *cus = _constrBuilding.userStruct;
    int timeLeft = cus.timeLeftForBuildComplete;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"A building is already constructing. Speed it up for %@ gems and upgrade this building?", [Globals commafyNumber:gemCost]] title:@"Already Constructing" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupBuildingAndUpgradeOrPurchase)];
  } else if (nextFsp.structType == StructureInfoProto_StructTypeLab && gs.userEnhancement) {
    [GenericPopupController displayConfirmationWithDescription:@"Your current enhancement will be cancelled. Continue?" title:@"Cancel Enhancement" okayButton:@"Continue" cancelButton:@"Cancel" target:self selector:@selector(cancelEnhancementAndUpgrade)];
  } else if (nextFsp) {
    int cost = nextFsp.buildCost;
    BOOL isOilBuilding = nextFsp.buildResourceType == ResourceTypeOil;
    int curAmount = isOilBuilding ? gs.oil : gs.silver;
    if (cost > curAmount) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:nextFsp.buildResourceType amount:cost-curAmount target:self selector:@selector(useGemsForUpgrade)];
    } else {
      [self sendUpgrade:us allowGems:NO];
    }
  }
}

- (void) cancelEnhancementAndUpgrade {
  [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
  [self bigUpgradeClicked];
}

- (void) useGemsForUpgrade {
  UserStruct *us = ((HomeBuilding *)self.selected).userStruct;
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
  
  int cost = nextFsp.buildCost;
  BOOL isOilBuilding = nextFsp.buildResourceType == ResourceTypeOil;
  int curAmount = isOilBuilding ? gs.oil : gs.silver;
  int gemCost = [gl calculateGemConversionForResourceType:nextFsp.buildResourceType amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendUpgrade:us allowGems:YES];
  }
}

- (void) sendUpgrade:(UserStruct *)us allowGems:(BOOL)allowGems {
  [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us allowGems:allowGems];
  
  if (!us.isComplete) {
    _constrBuilding = (HomeBuilding *)self.selected;
    [self updateTimersForBuilding:_constrBuilding];
    [_constrBuilding displayProgressBar];
    _constrBuilding.isConstructing = YES;
    
    [self reselectCurrentSelection];
  }
}

- (IBAction)finishNowClicked:(id)sender {
  if (_isSpeedingUp) return;
  HomeBuilding *mb = (HomeBuilding *)self.selected;
  UserStruct *us = mb.userStruct;
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = us.timeLeftForBuildComplete;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  NSString *desc = [NSString stringWithFormat:@"Finish instantly for %@ gem%@?", [Globals commafyNumber:goldCost], goldCost == 1 ? @"" : @"s"];
  [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Speed Up!" gemCost:goldCost target:self selector:@selector(speedUpBuilding)];
}

- (void) sendSpeedupBuilding:(UserStruct *)us {
  [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:us];
}

- (BOOL) speedUpBuilding {
  if (_isSpeedingUp) return NO;
  HomeBuilding *mb = (HomeBuilding *)_constrBuilding;
  UserStruct *us = mb.userStruct;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (!us.isComplete) {
    int timeLeft = us.timeLeftForBuildComplete;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    if (gs.gold < gemCost) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      [self sendSpeedupBuilding:mb.userStruct];
      if (us.isComplete) {
        _isSpeedingUp = YES;
        
        // Only animate it, if it is currently selected
        // It might not be selected if trying to speed up by building a new building
        void (^comp)(void) = ^{
          mb.isConstructing = NO;
          [mb displayUpgradeComplete];
          
          if (mb == self.selected) {
            [self reselectCurrentSelection];
          }
          
          if (_constrBuilding == mb) {
            _constrBuilding = nil;
          }
          [self updateTimersForBuilding:mb];
          
          _isSpeedingUp = NO;
        };
        
        if (mb == self.selected) {
          [mb instaFinishUpgradeWithCompletionBlock:comp];
        } else {
          comp();
          [mb removeProgressBar];
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

- (IBAction)expandClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.isExpanding) {
    UserExpansion *exp = [gs currentExpansion];
    int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
    NSString *desc = [NSString stringWithFormat:@"A block is already expanding. Speed it up for %d gems and start new expansion?", [gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Already Expanding" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupExpansionAndStartNewOne)];
  } else {
    NSString *desc = [NSString stringWithFormat:@"Would you like to expand to this block for %@?", [Globals cashStringForNumber:[gl calculateSilverCostForNewExpansion]]];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Expand?" okayButton:@"Expand" cancelButton:@"Cancel" target:self selector:@selector(expandAccepted)];
  }
}

- (void) expandAccepted {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  ExpansionBoard *exp = (ExpansionBoard *)self.selected;
  
  int silverCost = [gl calculateSilverCostForNewExpansion];
  if (gs.silver < silverCost) {
    [Globals popupMessage:@"Not enough cash to expand."];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseCityExpansionAtX:exp.expandSpot.x atY:exp.expandSpot.y];
    [exp beginExpanding];
    [self reselectCurrentSelection];
  }
}

- (IBAction)finishExpansionClicked:(id)sender {
  if (_isSpeedingUp) return;
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *exp = [gs currentExpansion];
  int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
  NSString *desc = [NSString stringWithFormat:@"Would you like to speed up this expansion for %d gold?", [gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up?" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupExpansion)];
}

- (void) speedupExpansion {
  if (_isSpeedingUp) return;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserExpansion *exp = [gs currentExpansion];
  
  int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  if (gs.gold < goldCost) {
    //    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] expansionWaitComplete:YES atX:exp.xPosition atY:exp.yPosition];
    
    // Get the expansion board
    ExpansionBoard *expBoard = nil;
    for (CCNode *n in self.children) {
      if ([n isKindOfClass:[ExpansionBoard class]]) {
        ExpansionBoard *b = (ExpansionBoard *)n;
        if (b.expandSpot.x == exp.xPosition && b.expandSpot.y == exp.yPosition) {
          expBoard = b;
          break;
        }
      }
    }
    
    _isSpeedingUp = YES;
    void (^comp)(void) = ^{
      _isSpeedingUp = NO;
      if (expBoard == self.selected) {
        self.selected = nil;
      }
      
      [expBoard removeFromParent];
      
      CGRect r = expBoard.location;
      for (int i = r.origin.x; i < r.origin.x+r.size.width; i++) {
        for (int j = r.origin.y; j < r.origin.y+r.size.height; j++) {
          [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
          [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
      }
    };
    
    if (expBoard == self.selected) {
      [expBoard instaFinishUpgradeWithCompletionBlock:comp];
    } else {
      comp();
    }
  }
}

- (void) speedupExpansionAndStartNewOne {
  [self speedupExpansion];
  [self expandAccepted];
}

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
      [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
      [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
    }
  }
}

- (BOOL) isBlockBuildable: (CGRect) buildBlock {
  for (int i = buildBlock.origin.x; i < buildBlock.size.width+buildBlock.origin.x; i++) {
    for (int j = buildBlock.origin.y; j < buildBlock.size.height+buildBlock.origin.y; j++) {
      if (![[[self.buildableData objectAtIndex:i] objectAtIndex:j] boolValue]) {
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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHospitals) name:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTeamSprites) name:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
  
  [self.upgradeViewController.view removeFromSuperview];
  [self.upgradeViewController removeFromParentViewController];
  self.upgradeViewController = nil;
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

@end
