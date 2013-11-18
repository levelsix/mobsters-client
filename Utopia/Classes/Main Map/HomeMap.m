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
#import "GameLayer.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "GameViewController.h"

#define HOME_BUILDING_TAG_OFFSET 123456

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

#define PURCHASE_CONFIRM_MENU_TAG 39245

@implementation HomeMap

@synthesize redGid, greenGid;

- (id) init {
  self = [self initWithTMXFile:@"testtilemap.tmx"];
  return self;
}

- (id) initWithTMXFile:(NSString *)tmxFile {
  _loading = YES;
  if ((self = [super initWithTMXFile:tmxFile])) {
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    
    for (CCNode *child in [self children]) {
      if ([child isKindOfClass:[CCTMXLayer class]]) {
        CCTMXLayer *layer = (CCTMXLayer *)child;
        if ([[layer layerName] isEqualToString: METATILES_LAYER_NAME]) {
          // Put meta tile layer at front,
          // when something is selected, we will make it z = 1000
          [self reorderChild:layer z:1001];
          CGPoint redGidPt = ccp(_mapSize.width-1, _mapSize.height-1);
          CGPoint greenGidPt = ccp(_mapSize.width-1, _mapSize.height-2);
          redGid = [layer tileGIDAt:redGidPt];
          greenGid = [layer tileGIDAt:greenGidPt];
          [layer removeTileAt:redGidPt];
          [layer removeTileAt:greenGidPt];
        } else {
          [self reorderChild:layer z:-1];
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
    
    CCTMXLayer *layer = [self layerNamed:BUILDABLE_LAYER_NAME];
    layer.visible = NO;
    layer = [self layerNamed:WALKABLE_LAYER_NAME];
    layer.visible = NO;
    
    [self refreshForExpansion];
    
    if ([Globals isLongiPhone]) {
      [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
    } else {
      [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenuSmall" owner:self options:nil];
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"UpgradeBuildingMenu" owner:self options:nil];
    
    _timers = [[NSMutableArray alloc] init];
    
    _loading = NO;
    
    [self refresh];
    [self moveToCenterAnimated:NO];
    
    CCSprite *s1 = [CCSprite spriteWithFile:@"backgroundleft.png"];
    CCSprite *s2 = [CCSprite spriteWithFile:@"backgroundright.png"];
    [self addChild:s1 z:-1000];
    [self addChild:s2 z:-1000];
    
    s1.position = ccp(s1.contentSize.width/2-29, s1.contentSize.height/2-52);
    s2.position = ccp(s1.position.x+s1.contentSize.width/2+s2.contentSize.width/2, s1.position.y);
    
    CCSprite *road = [CCSprite spriteWithFile:@"homeroad.png"];
    [self addChild:road z:-998];
    road.position = ccp(self.contentSize.width/2+0.5, self.contentSize.height/2+0.5);
    
    self.scale = 1;
    
    bottomLeftCorner = ccp(s1.position.x-s1.contentSize.width/2, s1.position.y-s1.contentSize.height/2);
    topRightCorner = ccp(s2.position.x+s2.contentSize.width/2, s2.position.y+s2.contentSize.height/2);//ccp(s2.position.x+s2.contentSize.width/2, s2.position.y+s2.contentSize.height/2);
  }
  return self;
}

- (int) baseTagForStructId:(int)structId {
  return [[Globals sharedGlobals] maxRepeatedNormStructs]*structId+HOME_BUILDING_TAG_OFFSET;
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
    if (node != _purchBuilding && [node isKindOfClass:[MoneyBuilding class]]) {
      [self updateTimersForBuilding:(MoneyBuilding *)node];
    }
  }
}

- (void) refresh {
  if (_loading) return;
  self.selected = nil;
  _constrBuilding = nil;
  _loading = YES;
  
  [self invalidateAllTimers];
  
  NSMutableArray *arr = [NSMutableArray array];
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  [arr addObjectsFromArray:[self refreshForExpansion]];
  
  [self setupTeamSprites];
  [arr addObjectsFromArray:self.myTeamSprites];
  
  for (UserStruct *s in [gs myStructs]) {
    int tag = [self baseTagForStructId:s.structId];
    MoneyBuilding *moneyBuilding = (MoneyBuilding *)[self getChildByTag:tag];
    
    int offset = 0;
    while (moneyBuilding && [arr containsObject:moneyBuilding]) {
      offset++;
      if (offset >= [gl maxRepeatedNormStructs]) {
        moneyBuilding = nil;
        break;
      }
      // Check if we already assigned this building and it is in arr.
      moneyBuilding = (MoneyBuilding *)[self getChildByTag:tag+offset];
    }
    
    FullStructureProto *fsp = [gs structWithId:s.structId];
    if (!fsp) {return;}
    CGRect loc = CGRectMake(s.coordinates.x, s.coordinates.y, fsp.xLength, fsp.yLength);
    if (!moneyBuilding) {
      NSString *imgName = [Globals imageNameForStruct:s.structId];
      moneyBuilding = [[MoneyBuilding alloc] initWithFile:imgName location:loc map:self];
      [self addChild:moneyBuilding z:0 tag:tag+offset];
    } else {
      [moneyBuilding liftBlock];
      moneyBuilding.location = loc;
    }
    
    moneyBuilding.orientation = s.orientation;
    moneyBuilding.userStruct = s;
    
    UserStructState st = s.state;
    switch (st) {
      case kBuilding:
        moneyBuilding.retrievable = NO;
        
        moneyBuilding.isConstructing = YES;
        _constrBuilding = moneyBuilding;
        break;
        
      case kWaitingForIncome:
        moneyBuilding.retrievable = NO;
        break;
        
      case kRetrieving:
        moneyBuilding.retrievable = YES;
        break;
        
      default:
        break;
    }
    
    [arr addObject:moneyBuilding];
    [moneyBuilding placeBlock];
  }
  
  CCNode *c;
  NSMutableArray *toRemove = [NSMutableArray array];
  CCARRAY_FOREACH(self.children, c) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      [toRemove addObject:c];
    }
  }
  
  for (SelectableSprite *c in toRemove) {
    if ([c isKindOfClass:[HomeBuilding class]]) {
      [(HomeBuilding *)c liftBlock];
    }
    [self removeChild:c cleanup:YES];
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
  
  if (self.isRunning) {
    [self beginTimers];
  }
}

- (NSArray *) refreshForExpansion {
  //  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  //  UserExpansion *ue = gs.userExpansion;
  
  CCTMXLayer *buildLayer = [self layerNamed:BUILDABLE_LAYER_NAME];
  CCTMXLayer *walkLayer = [self layerNamed:WALKABLE_LAYER_NAME];
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
  
  CGPoint offsets[3][3] = EXPANSION_OVERLAY_OFFSETS;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      if (i == 0 && j == 0) {
        continue;
      }
      
      UserExpansion *ue = [gs getExpansionForX:i y:j];
      
      if (!ue || ue.isExpanding) {
        CGPoint offset = offsets[i+1][j+1];
        
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
}

- (void) moveToStruct:(int)structId showArrow:(BOOL)showArrow animated:(BOOL)animated {
  Globals *gl = [Globals sharedGlobals];
  int baseTag = [self baseTagForStructId:structId];
  MoneyBuilding *mb = nil;
  for (int tag = baseTag; tag < baseTag+gl.maxRepeatedNormStructs; tag++) {
    MoneyBuilding *check;
    if ((check = (MoneyBuilding *)[self getChildByTag:tag])) {
      if (!mb || check.userStruct.fsp.level > mb.userStruct.fsp.level) {
        mb = check;
      }
    } else {
      break;
    }
  }
  
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
    [self reorderChild:self.selected z:1000];
  }
}

- (void) preparePurchaseOfStruct:(int)structId {
  if (_purchasing || _constrBuilding) {
    [Globals popupMessage:@"The carpenter is already constructing a building."];
    return;
  }
  
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
  CGRect loc = CGRectMake(CENTER_TILE_X, CENTER_TILE_Y, fsp.xLength, fsp.yLength);
  _purchBuilding = [[MoneyBuilding alloc] initWithFile:[Globals imageNameForStruct:structId] location:loc map:self];
  _purchBuilding.isPurchasing = YES;
  _purchBuilding.verticalOffset = fsp.imgVerticalPixelOffset;
  
  int baseTag = [self baseTagForStructId:structId];
  int tag;
  for (tag = baseTag; tag < baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]; tag++) {
    if (![self getChildByTag:tag]) {
      break;
    }
  }
  if (tag == baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]) {
    [Globals popupMessage:@"Already have max of this building."];
    return;
  }
  
  [self addChild:_purchBuilding z:0 tag:tag];
  
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  self.selected = _purchBuilding;
  
  [self doReorder];
  
  [self moveToSprite:_purchBuilding animated:YES];
  
  PurchaseConfirmMenu *m = [[PurchaseConfirmMenu alloc] initWithCheckTarget:self checkSelector:@selector(moveCheckClicked:) cancelTarget:self cancelSelector:@selector(cancelMoveClicked:)];
  m.tag = PURCHASE_CONFIRM_MENU_TAG;
  [_purchBuilding addChild:m];
  m.position = ccp(_purchBuilding.contentSize.width/2, _purchBuilding.contentSize.height+10);
}

- (void) setSelected:(SelectableSprite *)selected {
  if (self.selected != selected) {
    [super setSelected:selected];
    if ([selected isKindOfClass: [MoneyBuilding class]]) {
      MoneyBuilding *mb = (MoneyBuilding *) selected;
      UserStruct *us = mb.userStruct;
      if (_purchasing) {
        // Do nothing
      } else if (us.state == kBuilding) {
        self.bottomOptionView = self.upgradeBotView;
        [mb removeArrowAnimated:YES];
        
        [self beginMoveClicked:nil];
      } else if (us.state == kRetrieving) {
        // Retrieve the cash!
        [self retrieveFromBuilding:((MoneyBuilding *) selected)];
        self.selected = nil;
      } else {
        self.bottomOptionView = self.buildBotView;
        
        [mb removeArrowAnimated:YES];
        
        [self beginMoveClicked:nil];
      }
    } else if ([selected isKindOfClass:[ExpansionBoard class]]) {
      GameState *gs = [GameState sharedGameState];
      ExpansionBoard *exp = (ExpansionBoard *)self.selected;
      UserExpansion *ue = [gs getExpansionForX:exp.expandSpot.x y:exp.expandSpot.y];
      
      if (!ue.isExpanding) {
        self.bottomOptionView = self.expandBotView;
      } else {
        self.bottomOptionView = self.expandingBotView;
      }
    } else {
      self.bottomOptionView = nil;
      _canMove = NO;
      if (_purchasing) {
        _purchasing = NO;
        [self removeChild:_purchBuilding cleanup:YES];
      }
    }
  }
}

- (void) updateMapBotView:(MapBotView *)botView {
  if (botView == self.buildBotView) {
    if ([self.selected isKindOfClass:[MoneyBuilding class]]) {
      MoneyBuilding *mb = (MoneyBuilding *)self.selected;
      FullStructureProto *fsp = mb.userStruct.fsp;
      FullStructureProto *nextFsp = mb.userStruct.fspForNextLevel;
      self.buildingNameLabel.text = [NSString stringWithFormat:@"%@ (lvl %d)", fsp.name, fsp.level];
      self.buildingIncomeLabel.text = [NSString stringWithFormat:@"%@ EVERY %@", [Globals cashStringForNumber:fsp.income], [Globals convertTimeToLongString:fsp.minutesToGain*60]];
      BOOL isPremium = nextFsp ? nextFsp.isPremiumCurrency : fsp.isPremiumCurrency;
      
      if (nextFsp) {
        self.buildingUpgradeCashCostLabel.text = [Globals cashStringForNumber:nextFsp.buildPrice];
        self.buildingUpgradeGemCostLabel.text = [Globals commafyNumber:nextFsp.buildPrice];
        self.buildingUpgradeGemView.hidden = !isPremium;
      } else {
        self.buildingUpgradeCashCostLabel.text = @"N/A";
        self.buildingUpgradeGemCostLabel.text = @"N/A";
        self.buildingUpgradeGemView.hidden = !isPremium;
      }
    }
  } else if (botView == self.upgradeBotView) {
    if ([self.selected isKindOfClass:[MoneyBuilding class]]) {
      Globals *gl = [Globals sharedGlobals];
      MoneyBuilding *mb = (MoneyBuilding *)self.selected;
      UserStruct *us = mb.userStruct;
      FullStructureProto *fsp = us.fsp;
      self.upgradingNameLabel.text = [NSString stringWithFormat:@"%@ (lvl %d)", fsp.name, fsp.level];
      self.upgradingIncomeLabel.text = [NSString stringWithFormat:@"%@ EVERY %@", [Globals cashStringForNumber:fsp.income], [Globals convertTimeToLongString:fsp.minutesToGain*60]];
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

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  pt = [self convertToNodeSpace:pt];
  
  // During drag, take out menus
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
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateEnded) {
        [homeBuilding clearMeta];
        [homeBuilding placeBlock];
        _isMoving = NO;
        [self doReorder];
        
        if (homeBuilding.isSetDown && !_purchasing) {
          MoneyBuilding *m = (MoneyBuilding *)homeBuilding;
          [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:m.userStruct atX:m.location.origin.x atY:m.location.origin.y];
        }
        return;
      }
    }
  } else {
    self.selected = nil;
  }
  
  [super drag:recognizer node:node];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  if (!_purchasing) {
    [super tap:recognizer node:node];
    [self doReorder];
  }
}

- (void) scrollScreenForTouch:(CGPoint)pt {
  // CGPoint relPt = [self convertToNodeSpace:pt];
  // TODO: Implement this
  // As you get closer to edge, it scrolls faster
}

- (void) updateTimersForBuilding:(MoneyBuilding *)mb {
  [_timers removeObject:mb.timer];
  [mb createTimerForCurrentState];
  
  if (mb.timer) {
    [_timers addObject:mb.timer];
    [[NSRunLoop mainRunLoop] addTimer:mb.timer forMode:NSRunLoopCommonModes];
  }
}

- (void) retrieveFromBuilding:(MoneyBuilding *)mb {
  [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mb.userStruct];
  if (mb.userStruct.state == kWaitingForIncome) {
    mb.retrievable = NO;
    [self updateTimersForBuilding:mb];
    //    [self addSilverDrop:[[Globals sharedGlobals] calculateIncomeForUserStruct:mb.userStruct] fromSprite:mb toPosition:CGPointZero secondsToPickup:0];
  }
}

- (void) constructionComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:mb.userStruct];
  [self updateTimersForBuilding:mb];
  mb.isConstructing = NO;
  [mb removeProgressBar];
  [mb displayUpgradeComplete];
  if (mb == self.selected) {
    [mb cancelMove];
    [self reselectCurrentSelection];
  }
  _constrBuilding = nil;
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  if (mb == self.selected) {
    if (_canMove) {
      [mb cancelMove];
      _canMove = NO;
    }
    self.selected = nil;
  }
}

- (IBAction)beginMoveClicked:(id)sender {
  _canMove = YES;
}

- (IBAction)moveCheckClicked:(id)sender {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  if (homeBuilding.isSetDown) {
    if (_purchasing) {
      _purchasing = NO;
      if ([homeBuilding isKindOfClass:[MoneyBuilding class]]) {
        MoneyBuilding *moneyBuilding = (MoneyBuilding *)homeBuilding;
        
        // Use return value as an indicator that purchase is accepted by client
        UserStruct *us = [[OutgoingEventController sharedOutgoingEventController] purchaseNormStruct:_purchStructId atX:moneyBuilding.location.origin.x atY:moneyBuilding.location.origin.y];
        if (us) {
          moneyBuilding.userStruct = us;
          _constrBuilding = moneyBuilding;
          [self updateTimersForBuilding:_constrBuilding];
          moneyBuilding.isConstructing = YES;
          moneyBuilding.isPurchasing = NO;
          
          [_constrBuilding displayProgressBar];
          
          [[SoundEngine sharedSoundEngine] carpenterPurchase];
          
          [moneyBuilding removeChildByTag:PURCHASE_CONFIRM_MENU_TAG cleanup:YES];
        } else {
          [moneyBuilding liftBlock];
          [self removeChild:moneyBuilding cleanup:YES];
        }
      }
    }
    _canMove = NO;
    [self doReorder];
    
    [self reselectCurrentSelection];
  }
}

- (IBAction)rotateClicked:(id)sender {
  if ([self.selected isKindOfClass:[Building class]] && !_purchasing) {
    Building *building = (Building *)self.selected;
    [building setOrientation:building.orientation+1];
  }
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

- (IBAction)sellClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)self.selected).userStruct;
  FullStructureProto *fsp = us.fsp;
  
  NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to sell your %@ for %@?", fsp.name, fsp.isPremiumCurrency ? [NSString stringWithFormat:@"%@ gems", [Globals commafyNumber:fsp.sellPrice]] : [Globals cashStringForNumber:fsp.sellPrice]];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Sell Building?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sellSelected)];
}

- (void) sellSelected {
  UserStruct *us = ((MoneyBuilding *)self.selected).userStruct;
  int structId = us.structId;
  [[OutgoingEventController sharedOutgoingEventController] sellNormStruct:us];
  if (![[[GameState sharedGameState] myStructs] containsObject:us]) {
    MoneyBuilding *spr = (MoneyBuilding *)self.selected;
    self.selected = nil;
    [_timers removeObject:spr.timer];
    spr.timer = nil;
    
    [spr runAction:[CCSequence actions:[RecursiveFadeTo actionWithDuration:1.f opacity:0],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [spr liftBlock];
                       [self removeChild:spr cleanup:YES];
                       
                       // Fix tag fragmentation
                       int tag = [self baseTagForStructId:structId];
                       int renameTag = tag;
                       for (int i = tag; i < tag+[[Globals sharedGlobals] maxRepeatedNormStructs]; i++) {
                         CCNode *c = [self getChildByTag:i];
                         if (c) {
                           [c setTag:renameTag];
                           renameTag++;
                         }
                       }
                     }], nil]];
    
    if (_constrBuilding == spr) {
      _constrBuilding = nil;
    }
  }
}

- (IBAction)littleUpgradeClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)self.selected).userStruct;
  int maxLevel = us.maxLevel;
  if (us.fsp.level < maxLevel) {
    [self.upgradeMenu displayForUserStruct:us];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"The maximum level for the %@ is %d.", us.fsp.name, maxLevel]];
  }
}

- (IBAction)bigUpgradeClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)self.selected).userStruct;
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *nextFsp = us.fspForNextLevel;
  
  if (_constrBuilding) {
    [Globals popupMessage:@"The carpenter is already constructing a building!"];
  } else if (nextFsp) {
    int cost = nextFsp.buildPrice;
    BOOL isGoldBuilding = nextFsp.isPremiumCurrency;
    if (!isGoldBuilding && cost > gs.silver) {
      //        [[RefillMenuController sharedRefillMenuController] displayBuySilverView:cost];
      [Analytics notEnoughSilverForUpgrade:us.structId cost:cost];
      self.selected = nil;
    } else if (cost > gs.gold) {
      //        [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
      [Analytics notEnoughGoldForUpgrade:us.structId cost:cost];
      self.selected = nil;
    } else {
      [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us];
      
      if (us.state == kBuilding) {
        _constrBuilding = (MoneyBuilding *)self.selected;
        [self updateTimersForBuilding:_constrBuilding];
        [self.upgradeMenu closeClicked:nil];
        [_constrBuilding displayProgressBar];
        _constrBuilding.isConstructing = YES;
        
        [[SoundEngine sharedSoundEngine] carpenterPurchase];
        
        [self reselectCurrentSelection];
      }
    }
  }
}

- (IBAction)finishNowClicked:(id)sender {
  if (_isSpeedingUp) return;
  MoneyBuilding *mb = (MoneyBuilding *)self.selected;
  UserStruct *us = mb.userStruct;
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = us.timeLeftForBuildComplete;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  NSString *desc = [NSString stringWithFormat:@"Finish instantly for %@ gold?", [Globals commafyNumber:goldCost]];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up!" okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(speedUpBuilding)];
}

- (void) speedUpBuilding {
  MoneyBuilding *mb = (MoneyBuilding *)self.selected;
  UserStruct *us = mb.userStruct;
  UserStructState state = us.state;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (state == kBuilding) {
    int timeLeft = us.timeLeftForBuildComplete;
    int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    if (gs.gold < goldCost) {
      //      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:mb.userStruct];
      if (mb.userStruct.state == kWaitingForIncome) {
        _isSpeedingUp = YES;
        [mb instaFinishUpgradeWithCompletionBlock:^{
          mb.isConstructing = NO;
          [mb displayUpgradeComplete];
          [self reselectCurrentSelection];
          
          if (_constrBuilding == mb) {
            _constrBuilding = nil;
          }
          [self updateTimersForBuilding:mb];
          
          _isSpeedingUp = NO;
        }];
      }
    }
  }
}

- (IBAction)expandClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (gs.isExpanding) {
    UserExpansion *exp = [gs currentExpansion];
    int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
    NSString *desc = [NSString stringWithFormat:@"A block is already expanding. Speed it up for %d gold?", [gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Already Expanding" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupExpansion)];
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
    //    [[RefillMenuController sharedRefillMenuController] displayBuySilverView:silverCost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] purchaseCityExpansionAtX:exp.expandSpot.x atY:exp.expandSpot.y];
    [exp beginExpanding];
    [self reselectCurrentSelection];
  }
}

- (IBAction)finishExpansionClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *exp = [gs currentExpansion];
  int timeLeft = exp.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
  NSString *desc = [NSString stringWithFormat:@"Would you like to speed up this expansion for %d gold?", [gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up?" okayButton:@"Speed Up" cancelButton:@"Cancel" target:self selector:@selector(speedupExpansion)];
}

- (void) speedupExpansion {
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
    
    if (expBoard) {
      self.selected = nil;
      [expBoard instaFinishUpgradeWithCompletionBlock:^{
        [self refresh];
      }];
    } else {
      self.selected = nil;
      [self refresh];
    }
    
  }
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
    if ([node isKindOfClass:[MoneyBuilding class]]) {
      [arr addObject:node];
    }
  }
  
  for (MoneyBuilding *mb in arr) {
    if (mb.userStruct.state == kRetrieving) {
      [self retrieveFromBuilding:mb];
    }
  }
}

- (void) reselectCurrentSelection {
  SelectableSprite *n = self.selected;
  self.selected = nil;
  self.selected = n;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  [self beginTimers];
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

@end
