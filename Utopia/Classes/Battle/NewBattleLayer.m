//
//  NewBattleLayer.m
//  PadClone
//
//  Created by Ashwin Kamath on 8/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NewBattleLayer.h"
#import "GameMap.h"
#import "Globals.h"
#import "SoundEngine.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "CCAnimation.h"
#import "CCTextureCache.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import <Kamcord/Kamcord.h>
#import "DestroyedOrb.h"
#import "SkillManager.h"
#import "MonsterPopUpViewController.h"

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define BALLIN_SCORE 400
#define CANTTOUCHTHIS_SCORE 540
#define HAMMERTIME_SCORE 720
#define MAKEITRAIN_SCORE 900

#define STRENGTH_FOR_MAX_SHOTS MAKEITRAIN_SCORE

#define PUZZLE_BGD_TAG 1456

#define BGD_SCALE 1.f//((self.contentSize.width-480)/88.f*0.3+1.f)

#define COMBO_FIRE_TAG @"ComboFire"

@implementation BattleBgdLayer

- (id) initWithPrefix:(NSString *)prefix {
  if ((self = [super init])) {
    self.prefix = prefix;
    [self addNewScene];
    
    _curBasePoint = ccp(-175, 0);
  }
  return self;
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  
  // Add any additional scenes
  [self addAdditionalScenes];
}

- (void) scrollToNewScene {
  [self addAdditionalScenes];
  
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float nextBaseY = self.position.y-Y_MOVEMENT_FOR_NEW_SCENE;
  float nextBaseX = self.position.x-Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y;
  [self runAction:[CCActionSequence actions:
                   [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:ccp(nextBaseX, nextBaseY)],
                   [CCActionCallFunc actionWithTarget:self selector:@selector(removePastScenes)],
                   [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(reachedNextScene)],
                   nil]];
}

- (void) addAdditionalScenes {
  // Get max y pos
  float maxY = _curBasePoint.y;
  
  // Base Y will be negative
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float nextBaseY = self.position.y-Y_MOVEMENT_FOR_NEW_SCENE;
  int numScenesToAdd = ceilf((-1*nextBaseY+self.parent.contentSize.height-maxY)/offsetPerScene.y);
  for (int i = 0; i < numScenesToAdd; i++) {
    [self addNewScene];
  }
}

- (void) addNewScene {
  [self addSceneAtBasePosition:_curBasePoint];
  _curBasePoint = ccpAdd(_curBasePoint, POINT_OFFSET_PER_SCENE);
}

- (void) removePastScenes {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (CCNode *n in self.children) {
    if (n.position.y+n.contentSize.height/2 < -1*self.position.y) {
      [toRemove addObject:n];
    }
  }
  
  for (CCNode *n in toRemove) {
    [n removeFromParent];
  }
}

- (void) addSceneAtBasePosition:(CGPoint)pos {
  CCSprite *left1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene.png"]];
  
  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
  
  [self addChild:left1];
//  CCSprite *left1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene1left.png"]];
//  CCSprite *right1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene1right.png"]];
//  
//  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
//  right1.position = ccp(left1.position.x+left1.contentSize.width/2+right1.contentSize.width/2,
//                        left1.position.y);
//  
//  [self addChild:left1];
//  [self addChild:right1];
//  
//  CCSprite *left2 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene2left.png"]];
//  CCSprite *right2 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene2right.png"]];
//  
//  left2.position = ccp(pos.x+left2.contentSize.width/2+POINT_OFFSET_PER_SCENE.x/2,
//                       left1.position.y+left1.contentSize.height/2+left2.contentSize.height/2);
//  right2.position = ccp(left2.position.x+left2.contentSize.width/2+right2.contentSize.width/2,
//                        left2.position.y);
//  
//  [self addChild:left2];
//  [self addChild:right2];
}

@end

@implementation NewBattleLayer

#pragma mark - Setup

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize {
  return [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:@"1" layoutProto:nil];
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix {
  return [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:bgdPrefix layoutProto:nil];
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix layoutProto:(BoardLayoutProto *)layoutProto {
  if ((self = [super init])) {
    _puzzleIsOnLeft = puzzleIsOnLeft;
    
    if (layoutProto) {
      _layoutProto = layoutProto;
      _gridSize = CGSizeMake(layoutProto.width, layoutProto.height);
    } else {
      _gridSize = gridSize.width ? gridSize : CGSizeMake(9, 9);
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonster *um in monsters) {
      [arr addObject:[BattlePlayer playerWithMonster:um]];
    }
    self.myTeam = arr;
    
    self.contentSize = [CCDirector sharedDirector].viewSize;
    
    [skillManager updateBattleLayer:self];
    
    [self initOrbLayer];
    
    OrbMainLayer *puzzleBg = self.orbLayer;
    // Need to make it equidistant on all sides
    float distFromSide = ORB_LAYER_DIST_FROM_SIDE;
    float puzzX = puzzleIsOnLeft ? puzzleBg.contentSize.width/2+distFromSide : self.contentSize.width-puzzleBg.contentSize.width/2-distFromSide;
    puzzleBg.position = ccp(puzzX, puzzleBg.contentSize.height/2+distFromSide);
    
    self.bgdContainer = [CCNode node];
    self.bgdContainer.contentSize = self.contentSize;
    [self addChild:self.bgdContainer z:0];
    
    bgdPrefix = bgdPrefix.length ? bgdPrefix : @"1";
    self.bgdLayer = [[BattleBgdLayer alloc] initWithPrefix:bgdPrefix];
    [self.bgdContainer addChild:self.bgdLayer z:-100];
    self.bgdLayer.position = BGD_LAYER_INIT_POSITION;
    if (_puzzleIsOnLeft) self.bgdLayer.position = ccpAdd(BGD_LAYER_INIT_POSITION, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    self.bgdLayer.delegate = self;
    
    // Scale the bgdContainer and readjust to the center of battle
    CGPoint basePt = CENTER_OF_BATTLE;
    if (_puzzleIsOnLeft) basePt = ccpAdd(CENTER_OF_BATTLE, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    CGPoint beforeScale = [self.bgdContainer convertToNodeSpace:basePt];
    self.bgdContainer.scale = BGD_SCALE;
    CGPoint afterScale = [self.bgdContainer convertToNodeSpace:basePt];
    CGPoint diff = ccpSub(afterScale, beforeScale);
    self.bgdContainer.position = ccpAdd(self.bgdContainer.position, ccpMult(diff, self.bgdContainer.scale));
    
    [self setupUI];
    
    _canPlayNextComboSound = YES;
    _canPlayNextGemPop = YES;
    
    self.shouldShowContinueButton = NO;
    self.shouldShowChatLine = NO;
    self.droplessStageNums = [NSMutableArray array];
    
    _enemyCounter = 0;
    
    [self loadHudView];
    [self removeOrbLayerAnimated:NO withBlock:nil];
  }
  return self;
}

- (void) initOrbLayer {
  OrbMainLayer *ol;
  
  if (_layoutProto) {
    ol = [[OrbMainLayer alloc] initWithLayoutProto:_layoutProto];
  } else {
    ol = [[OrbMainLayer alloc] initWithGridSize:_gridSize numColors:6];
  }
  
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  [self begin];
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  [self.orbLayer.bgdLayer addChild:clip z:100];
  clip.contentSize = CGSizeMake(_comboBgd.contentSize.width*2, _comboBgd.contentSize.height*3);
  clip.anchorPoint = ccp(1, 0.5);
  clip.position = ccp(self.orbLayer.swipeLayer.position.x+self.orbLayer.swipeLayer.contentSize.width, 54);
  clip.scale = 1.5;
  
  [clip addChild:_comboBgd];
  _comboBgd.position = ccp(clip.contentSize.width+2*_comboBgd.contentSize.width, _comboBgd.parent.contentSize.height/2);
  
  CCDrawNode *stencil = [CCDrawNode node];
  CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
  [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
  clip.stencil = stencil;
}

- (void) onExitTransitionDidStart {
  CCClippingNode *clip = (CCClippingNode *)_comboBgd.parent;
  clip.stencil = nil;
  [super onExitTransitionDidStart];
  
  [self.hudView removeFromSuperview];
}

- (BattlePlayer *) firstMyPlayer {
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    if (b.curHealth > 0 && (!bp || b.slotNum < bp.slotNum)) {
      bp = b;
    }
  }
  return bp;
}
- (void) createScheduleWithSwap:(BOOL)swap {
  [self createScheduleWithSwap:swap playerHitsFirst:NO];
}

- (void) createScheduleWithSwap:(BOOL)swap playerHitsFirst:(BOOL)playerFirst {
#ifdef DEBUG_BATTLE_MODE
  playerFirst = YES;
#endif

  if (self.myPlayerObject && self.enemyPlayerObject) {
    ScheduleFirstTurn order;
    if(swap) {
      order = ScheduleFirstTurnEnemy;
    } else {
      order = playerFirst ? ScheduleFirstTurnPlayer : ScheduleFirstTurnRandom;
    }
    
    // Cake kid mechanics handling and creating schedule
    if ([skillManager cakeKidSchedule])
      order = ScheduleFirstTurnPlayer;
    if (! swap || ! [skillManager cakeKidSchedule]) { // update schedule for all cases except if swap && cakeKidSchedule (for that we just remove one turn)
      self.battleSchedule = [[BattleSchedule alloc] initWithPlayerA:self.myPlayerObject.speed playerB:self.enemyPlayerObject.speed andOrder:order];
    }
    
    _shouldDisplayNewSchedule = YES;
  } else {
    [self.hudView removeBattleScheduleView];
    self.battleSchedule = nil;
  }
}

- (void) begin {
  BattlePlayer *bp = [self firstMyPlayer];
  if (bp) {
    [self deployBattleSprite:bp];
  }
  
  [Kamcord startRecording];
}

- (void) setupUI {
  OrbMainLayer *puzzleBg = self.orbLayer;
  
  _movesBgd = [CCSprite spriteWithImageNamed:@"movesbg.png"];
  [puzzleBg addChild:_movesBgd z:-1];
  
  CCLabelTTF *movesLabel = [CCLabelTTF labelWithString:@"MOVES " fontName:@"GothamNarrow-UltraItalic" fontSize:10 dimensions:CGSizeMake(100, 30)];
  movesLabel.horizontalAlignment = CCTextAlignmentRight;
  [_movesBgd addChild:movesLabel];
  [movesLabel setColor:[CCColor whiteColor]];
  [movesLabel setShadowOffset:ccp(0,-1)];
  [movesLabel setShadowColor:[CCColor colorWithWhite:0.f alpha:0.3f]];
  [movesLabel setShadowBlurRadius:1.f];
  
  _movesLeftLabel = [CCLabelTTF labelWithString:@"5" fontName:@"GothamNarrow-UltraItalic" fontSize:19 dimensions:CGSizeMake(100, 30)];
  [_movesBgd addChild:_movesLeftLabel];
  [_movesLeftLabel setHorizontalAlignment:CCTextAlignmentRight];
  [_movesLeftLabel setColor:[CCColor colorWithCcColor3b:ccc3(255, 200, 0)]];
  [_movesLeftLabel setShadowOffset:ccp(0,-1)];
  [_movesLeftLabel setShadowColor:[CCColor colorWithWhite:0.f alpha:0.3f]];
  [_movesLeftLabel setShadowBlurRadius:1.f];
  
  if (_puzzleIsOnLeft) {
    _movesBgd.anchorPoint = ccp(0, 0.5);
    movesLabel.anchorPoint = ccp(0, 0.5);
    movesLabel.anchorPoint = ccp(0, 0.5);
    
    _movesBgd.position = ccp(puzzleBg.contentSize.width, 36);
    movesLabel.position = ccp(3, 6);
    _movesLeftLabel.position = ccp(3, 24);
    
    _movesBgd.flipX = YES;
  } else {
    _movesBgd.anchorPoint = ccp(1, 0);
    movesLabel.anchorPoint = ccp(1, 0.5);
    _movesLeftLabel.anchorPoint = ccp(1, 0.5);
    
    _movesBgd.position = ccp(3, -2);
    movesLabel.position = ccp(45, 3);
    _movesLeftLabel.position = ccp(45, 24);
  }
  
  _lootBgd = [CCSprite spriteWithImageNamed:@"collectioncapsule.png"];
  [self addChild:_lootBgd];
  _lootBgd.position = ccp(-self.lootBgd.contentSize.width/2, 80);
  
  _lootLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Ziggurat-HTF-Black" fontSize:10];
  [_lootBgd addChild:_lootLabel];
  _lootLabel.color = [CCColor blackColor];
  _lootLabel.rotation = -20.f;
  _lootLabel.position = ccp(_lootBgd.contentSize.width-13, _lootBgd.contentSize.height/2-1);
  
  _comboBgd = [CCSprite spriteWithImageNamed:@"combobg.png"];
  _comboBgd.anchorPoint = ccp(1, 0.5);
  
  _comboLabel = [CCLabelTTF labelWithString:@"2x" fontName:@"Gotham-UltraItalic" fontSize:23];
  _comboLabel.anchorPoint = ccp(1, 0.5);
  _comboLabel.position = ccp(_comboBgd.contentSize.width-5, 32);
  [_comboBgd addChild:_comboLabel z:1];
  
  _comboBotLabel = [CCLabelTTF labelWithString:@"COMBO" fontName:@"Gotham-Ultra" fontSize:12];
  _comboBotLabel.anchorPoint = ccp(1, 0.5);
  _comboBotLabel.position = ccp(_comboBgd.contentSize.width-5, 14);
  [_comboBgd addChild:_comboBotLabel z:1];
  
  _movesLeft = NUM_MOVES_PER_TURN;
  _curStage = -1;
  
  [self updateHealthBars];
}

- (CGPoint) myPlayerLocation {
  return MY_PLAYER_LOCATION;
}

- (void) createNextMyPlayerSprite {
  BattleSprite *mp = [[BattleSprite alloc] initWithPrefix:self.myPlayerObject.spritePrefix nameString:self.myPlayerObject.attrName rarity:self.myPlayerObject.rarity animationType:self.myPlayerObject.animationType isMySprite:YES verticalOffset:self.myPlayerObject.verticalOffset];
  mp.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)self.myPlayerObject.element];
  [self.bgdContainer addChild:mp z:1];
  mp.position = [self myPlayerLocation];
  if (_puzzleIsOnLeft) mp.position = ccpAdd(mp.position, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
  mp.isFacingNear = NO;
  self.myPlayer = mp;
  [self updateHealthBars];
}

- (float) makeMyPlayerWalkOutWithBlock:(void (^)(void))completion {
  CGPoint startPos = self.myPlayer.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -self.myPlayer.contentSize.width;
  float xDelta = startPos.x-startX;
  CGPoint endPos = ccp(startX, startPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  float dur = ccpDistance(startPos, endPos)/MY_WALKING_SPEED;
  self.myPlayer.isFacingNear = YES;
  [self.myPlayer beginWalking];
  [self.myPlayer runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:dur position:endPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (completion) {
         completion();
       }
     }],
    [CCActionRemove action], nil]];
  [self stopPulsing];
  
  return dur;
}

- (void) makePlayer:(BattleSprite *)player walkInFromEntranceWithSelector:(SEL)selector {
  CGPoint finalPos = player.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -player.contentSize.width-MY_PLAYER_LOCATION.x+finalPos.x;
  float xDelta = finalPos.x-startX;
  CGPoint newPos = ccp(startX, finalPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  [player beginWalking];
  player.position = newPos;
  [player runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, newPos)/MY_WALKING_SPEED position:finalPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (player == self.myPlayer) {
         float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
         if (perc < PULSE_CONT_THRESH) {
           [self pulseBloodContinuously];
           [self pulseHealthLabel:NO];
         } else {
           [self stopPulsing];
         }
         
         [self updateHealthBars];
       }
       
       [player stopWalking];
       
       if (selector) {
         [self performSelector:selector withObject:player];
       }
     }],
    nil]];
}

- (NSInteger) currentStageNum {
  return _curStage;
}

- (NSInteger) stagesLeft
{
  return self.enemyTeam.count - _curStage - 1;
}

- (void) moveToNextEnemy {
  [self moveToNextEnemyWithPlayerFirst:NO];
}

- (void) moveToNextEnemyWithPlayerFirst:(BOOL)playerHitsFirst {
  _dungeonPlayerHitsFirst = playerHitsFirst;
  [self.hudView removeButtons];
  
  if (_lootSprite) {
    [self pickUpLoot];
  }
  
  if ([self spawnNextEnemy]) {
    [self.myPlayer beginWalking];
    [self.bgdLayer scrollToNewScene];
    
    [self displayWaveNumber];
    
    _reachedNextScene = NO;
    _displayedWaveNumber = NO;
  } else {
    if (_lootSprite) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
      
      [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallFunc actionWithTarget:self selector:@selector(youWon)], nil]];
    } else {
      [self youWon];
    }
  }
}

- (BOOL) spawnNextEnemy {
  BOOL success = [self createNextEnemyObject];
  
  if (success) {
    [self createNextEnemySprite];
    
    CGPoint finalPos = ENEMY_PLAYER_LOCATION;
    if (_puzzleIsOnLeft) finalPos = ccpAdd(finalPos, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
    CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
    
    self.currentEnemy.position = newPos;
    [self.currentEnemy runAction:[CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos]];
    
    [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
    self.currentEnemy.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255,255,255)];
    
    SkillLogStart(@"TRIGGER STARTED: enemy initialized");
    [skillManager triggerSkills:SkillTriggerPointEnemyInitialized withCompletion:^(BOOL triggered, id params) {
      SkillLogEnd(triggered, @"  Enemy initialized trigger ENDED");
      [self createScheduleWithSwap:NO playerHitsFirst:_dungeonPlayerHitsFirst];
    }];
  }
  
  return success;
}

- (BOOL) createNextEnemyObject {
  self.enemyPlayerObject = nil;
  
  while (_curStage+1 < (int)self.enemyTeam.count && !self.enemyPlayerObject) {
    _curStage++;
    
    self.enemyPlayerObject = [self.enemyTeam objectAtIndex:_curStage];
    
    if (self.enemyPlayerObject.curHealth <= 0) {
      self.enemyPlayerObject = nil;
    }
  }
  
  return self.enemyPlayerObject != nil;
}

- (void) createNextEnemySprite {
  BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:self.enemyPlayerObject.spritePrefix nameString:self.enemyPlayerObject.attrName rarity:self.enemyPlayerObject.rarity animationType:self.enemyPlayerObject.animationType isMySprite:NO verticalOffset:self.enemyPlayerObject.verticalOffset];
  bs.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)self.enemyPlayerObject.element];
  [bs showRarityTag];
  [self.bgdContainer addChild:bs];
  self.currentEnemy = bs;
  self.currentEnemy.isFacingNear = YES;
  [self updateHealthBars];
}

#pragma mark - UI Updates

- (void) updateHealthBars {
  if (self.enemyPlayerObject) {
    self.currentEnemy.healthBar.percentage = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth*100;
    self.currentEnemy.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:self.enemyPlayerObject.curHealth], [Globals commafyNumber:self.enemyPlayerObject.maxHealth]];
    
    self.currentEnemy.healthBar.parent.visible = YES;
  } else {
    self.currentEnemy.healthBar.parent.visible = NO;
  }
  
  if (self.myPlayerObject) {
    self.myPlayer.healthBar.percentage = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth*100;
    self.myPlayer.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:self.myPlayerObject.curHealth], [Globals commafyNumber:self.myPlayerObject.maxHealth]];
    
    self.myPlayer.healthBar.parent.visible = YES;
  } else {
    self.myPlayer.healthBar.parent.visible = NO;
  }
  
  _movesLeftLabel.string = [NSString stringWithFormat:@"%d ", _movesLeft];
  _comboLabel.string = [NSString stringWithFormat:@"%dx", _comboCount];
}

- (void) pulseLabel:(CCNode *)label {
  if (![label getActionByTag:924]) {
    CCActionScaleBy *a = [CCActionScaleBy actionWithDuration:0.4f scale:1.2];
    CCAction *b = [a reverse];
    CCActionSequence *seq = [CCActionEaseInOut actionWithAction:[CCActionSequence actions:a, b, nil]];
    seq.tag = 924;
    [label runAction:seq];
  }
}

#pragma mark - Turn Sequence

- (void) prepareScheduleView
{
  NSArray *bools = [self.battleSchedule getNextNMoves:self.hudView.battleScheduleView.numSlots];
  NSMutableArray *ids = [NSMutableArray array];
  NSMutableArray *enemyBands = [NSMutableArray array];
  NSMutableArray *playerTurns = [NSMutableArray array];
  for (NSNumber *num in bools) {
    BOOL val = num.boolValue;
    if (val) {
      [ids addObject:@(self.myPlayerObject.monsterId)];
      [enemyBands addObject:@NO];
      [playerTurns addObject:@YES];
    } else {
      [ids addObject:@(self.enemyPlayerObject.monsterId)];
      [enemyBands addObject:@(self.enemyPlayerObject.element == self.myPlayerObject.element)];
      [playerTurns addObject:@NO];
    }
  }
  self.hudView.battleScheduleView.delegate = self;
  [self.hudView.battleScheduleView setOrdering:ids showEnemyBands:enemyBands playerTurns:playerTurns];
}

- (void) beginNextTurn {
  
  // Enemy could be reset during Cake Drop explosion
  if (! _currentEnemy)
  {
    [self moveToNextEnemy];
    return;
  }
  
  // There are two methods calling this method in a race condition (reachedNextScene and displayWaveNumber)
  // These two flags are used to call beginNextTurn only once, upon the last call of the two
  if (_displayedWaveNumber && _reachedNextScene) {
    float delay = 1.0;
    float delay2 = 0.0;
    
    if (_shouldDisplayNewSchedule) {
      
      [self prepareScheduleView];
      _shouldDisplayNewSchedule = NO;
      delay = 1.3;
      delay2 = 0.2;
      [self.hudView displayBattleScheduleView];
      
    } else {
      // If nth is YES, this is your move, otherwise enemy's move
      BOOL nth = [self.battleSchedule getNthMove:self.hudView.battleScheduleView.numSlots-1];
      int monsterId = nth ? self.myPlayerObject.monsterId : self.enemyPlayerObject.monsterId;
      BOOL showEnemyBand = nth ? NO : self.enemyPlayerObject.element == self.myPlayerObject.element;
      [self.hudView.battleScheduleView addMonster:monsterId showEnemyBand:showEnemyBand player:nth];
    }
    
    self.hudView.bottomView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
      self.hudView.waveNumLabel.alpha = 1.f;
    }];
    
    // To allow the schedule cards to refresh before the bump of the last
    [self performAfterDelay:delay2 block:^{
      
      if (_firstTurn) {
        // Trigger skills when new enemy joins the battle
        SkillLogStart(@"TRIGGER STARTED: enemy appeared");
        ++_enemyCounter;
        [skillManager triggerSkills:SkillTriggerPointEnemyAppeared withCompletion:^(BOOL triggered, id params) {
          SkillLogEnd(triggered, @"  Enemy appeared trigger ENDED");
          [self processNextTurn: triggered ? 0.3 : delay]; // Don't wait if we're in the middle of enemy turn (ie skill was triggered and now is his turn)
        }];
      } else {
        [self processNextTurn: delay];
      }

    }];
  }
}

- (void) processNextTurn:(float)delay
{
  _firstTurn = NO;
  BOOL nextMove = [self.battleSchedule dequeueNextMove];
  if (nextMove) {
    [self beginMyTurn];
  } else {
    [self beginEnemyTurn:delay];
  }
}

- (BOOL) isFirstEnemy
{
  return (_enemyCounter <= 1);
}

- (void) beginMyTurn {
  _comboCount = 0;
  _orbCount = 0;
  _movesLeft = NUM_MOVES_PER_TURN;
  _soundComboCount = 0;
  _enemyShouldAttack = NO;
  
  _myDamageDealt = 0;
  _myDamageForThisTurn = 0;
  _enemyDamageDealt = 0;
  
  for (int i = 0; i < OrbColorNone; i++) {
    _orbCounts[i] = 0;
  }
  
  [self updateHealthBars];
  
  // Skills trigger for enemy turn started
  SkillLogStart(@"TRIGGER STARTED: beginning of player turn");
  [skillManager triggerSkills:SkillTriggerPointStartOfPlayerTurn withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Beginning of player turn ENDED");
    
    if (self.myPlayerObject.isStunned)
    {
      
      [self performAfterDelay:0.5 block:^{
        //[self.hudView.battleScheduleView bounceLastView];
        _enemyShouldAttack = YES;
        [self checkEnemyHealthAndStartNewTurn];
      }];
      return;
    }
    
    [self.orbLayer.bgdLayer turnTheLightsOn];
    [self.orbLayer allowInput];
    [skillManager enableSkillButton:YES];
    
    [self.hudView prepareForMyTurn];
    
    [self performAfterDelay:0.5 block:^{
      [self.hudView.battleScheduleView bounceLastView];
    }];
  }];
}

- (void) beginEnemyTurn:(float)delay {
  [self.hudView removeButtons];
  
  // Bounce if needed
  BOOL needToBounce = YES;
  if (! [skillManager willEnemySkillTrigger:SkillTriggerPointStartOfEnemyTurn])
  {
    [self performAfterDelay:0.5 block:^{
      [self.hudView.battleScheduleView bounceLastView];
    }];
    needToBounce = NO;
  }
  
  // Skills trigger for enemy turn started
  [self performAfterDelay:delay block:^{
    
    SkillLogStart(@"TRIGGER STARTED: beginning of enemy turn");
    [skillManager triggerSkills:SkillTriggerPointStartOfEnemyTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  Beginning of enemy turn ENDED");
      if (_enemyPlayerObject) // can be set to nil during the skill execution - Cake Drop does that and starts different sequence
      {
        BOOL enemyIsKilled = [self checkEnemyHealth];
        if (! enemyIsKilled)
        {
          if (needToBounce)
            [self.hudView.battleScheduleView bounceLastView];
          [self performAfterDelay:0.5 block:^{
            _enemyDamageDealt = [self.enemyPlayerObject randomDamage];
            _enemyDamageDealt = _enemyDamageDealt*[self damageMultiplierIsEnemyAttacker:YES];
            _enemyDamageDealt = (int)[skillManager modifyDamage:_enemyDamageDealt forPlayer:NO];
            
            // If the enemy's stunned, short the attack function
            if (self.enemyPlayerObject.isStunned)
            {
              [self endEnemyTurn];
              return;
            }
            
            // If the enemy's confused, he will deal damage to himself. Instead of the usual flow, show
            // the popup above his head, followed by flinch animation and showing the damage label
            if (self.enemyPlayerObject.isConfused)
            {
              CCSprite* confusedPopup = [CCSprite spriteWithImageNamed:@"confusionbubble.png"];
              [confusedPopup setAnchorPoint:CGPointMake(.5f, 0.f)];
              [confusedPopup setPosition:CGPointMake(self.currentEnemy.contentSize.width * .5f, self.currentEnemy.contentSize.height + 13.f)];
              [confusedPopup setScale:0.f];
              [self.currentEnemy addChild:confusedPopup];
              
              [confusedPopup runAction:[CCActionSequence actions:
                                        [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:1.f]],
                                        [CCActionDelay actionWithDuration:.5f],
                                        [CCActionCallFunc actionWithTarget:self selector:@selector(enemyDealsDamageToSelf)],
                                        [CCActionDelay actionWithDuration:1.5f],
                                        [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:0.f]],
                                        [CCActionRemove action],
                                        nil]];
            }
            else
              [self.currentEnemy performNearAttackAnimationWithEnemy:self.myPlayer
                                                        shouldReturn:YES
                                                         shouldEvade:[skillManager playerWillEvade:YES]
                                                        shouldFlinch:(_enemyDamageDealt>0)
                                                              target:self
                                                            selector:@selector(dealEnemyDamage)
                                                      animCompletion:nil];
          }];
        }
      }
    }];
  }];
}

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy {
  Globals *gl = [Globals sharedGlobals];
  Element attackerElement = isEnemy ? self.enemyPlayerObject.element : self.myPlayerObject.element;
  Element defenderElement = !isEnemy ? self.enemyPlayerObject.element : self.myPlayerObject.element;
  return [gl calculateDamageMultiplierForAttackElement:attackerElement defenseElement:defenderElement];
}

- (void) checkIfAnyMovesLeft {
  if (_movesLeft <= 0) {
    [self myTurnEnded];
  } else {
    [skillManager enableSkillButton:YES];
    [self.orbLayer allowInput];
    [self.orbLayer.bgdLayer turnTheLightsOn];
    _myDamageForThisTurn = 0;
  }
}

- (void) myTurnEnded {
  [self showHighScoreWord];
  [self.orbLayer disallowInput];
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self.hudView removeButtons];
  
  self.movesLeftLabel.string = [NSString stringWithFormat:@"%d", _movesLeft];
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(doMyAttackAnimation)];
}

- (void) doMyAttackAnimation {
  
  _myDamageDealt = _myDamageDealt*[self damageMultiplierIsEnemyAttacker:NO];
  
  // Changing damage with a skill
  NSInteger scoreModifier = _myDamageDealt > 0 ? 1 : 0; // used to make current score not 0 if damage was modified to 0 by skillManager
  _myDamageDealt = (int)[skillManager modifyDamage:_myDamageDealt forPlayer:YES];
  if (_myDamageDealt > 0)
    scoreModifier = 0;
  
  int currentScore = (float)(_myDamageDealt + scoreModifier)/(float)[self.myPlayerObject totalAttackPower]*100.f;
  
  if (currentScore > 0) {
    if (currentScore > MAKEITRAIN_SCORE) {
      [self.myPlayer restoreStandingFrame];
      [self spawnPlaneWithTarget:nil selector:nil];
    }
    
    // If the player's confused, he will deal damage to himself. Instead of the usual flow, show
    // the popup above his head, followed by flinch animation and showing the damage label
    if (self.myPlayerObject.isConfused)
    {
      CCSprite* confusedPopup = [CCSprite spriteWithImageNamed:@"confusionbubble.png"];
      [confusedPopup setAnchorPoint:CGPointMake(.5f, 0.f)];
      [confusedPopup setPosition:CGPointMake(self.myPlayer.contentSize.width * .5f, self.myPlayer.contentSize.height + 13.f)];
      [confusedPopup setScale:0.f];
      [self.myPlayer addChild:confusedPopup];
      
      [confusedPopup runAction:[CCActionSequence actions:
                                [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:1.f]],
                                [CCActionDelay actionWithDuration:.5f],
                                [CCActionCallFunc actionWithTarget:self selector:@selector(playerDealsDamageToSelf)],
                                [CCActionDelay actionWithDuration:1.5f],
                                [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:0.f]],
                                [CCActionRemove action],
                                nil]];
    }
    else
    {
      float strength = MIN(1, currentScore/(float)STRENGTH_FOR_MAX_SHOTS);
      [self.myPlayer performFarAttackAnimationWithStrength:strength
                                               shouldEvade:[skillManager playerWillEvade:NO]
                                                     enemy:self.currentEnemy
                                                    target:self
                                                  selector:@selector(dealMyDamage)
                                            animCompletion:nil];
    }
  } else {
    [self beginNextTurn];
  }
}

- (void) dealMyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by player");
  [skillManager triggerSkills:SkillTriggerPointPlayerDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by player trigger ENDED");
    
    _enemyShouldAttack = YES;
    
    // The block invocation that will lead to this method being called is quite convoluted
    // and can take a few different paths. Ideally we would use 'params' to send along any
    // arguments needed, but for the sake of my sanity I'm resorting to doing the following
    const BOOL usingAbility = skillManager.playerUsedAbility || skillManager.enemyUsedAbility;
    skillManager.playerUsedAbility = NO;
    skillManager.enemyUsedAbility = NO;
    
    [self dealDamage:_myDamageDealt enemyIsAttacker:NO usingAbility:usingAbility withTarget:self withSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    
    float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
    if (perc < PULSE_CONT_THRESH) {
      [self pulseHealthLabel:YES];
    } else {
      [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
      self.currentEnemy.healthLabel.color = [CCColor whiteColor];
    }
  }];
}

- (void) dealEnemyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [skillManager triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    _totalDamageTaken += _enemyDamageDealt;
    
    // The block invocation that will lead to this method being called is quite convoluted
    // and can take a few different paths. Ideally we would use 'params' to send along any
    // arguments needed, but for the sake of my sanity I'm resorting to doing the following
    const BOOL usingAbility = skillManager.playerUsedAbility || skillManager.enemyUsedAbility;
    skillManager.playerUsedAbility = NO;
    skillManager.enemyUsedAbility = NO;
    
    [self dealDamage:_enemyDamageDealt enemyIsAttacker:YES usingAbility:usingAbility withTarget:self withSelector:@selector(endEnemyTurn)];
    
    float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
    if (!_bloodSplatter || _bloodSplatter.numberOfRunningActions == 0) {
      if (perc < PULSE_CONT_THRESH) {
        [self pulseBloodContinuously];
        [self pulseHealthLabel:NO];
      } else if (perc < PULSE_ONCE_THRESH) {
        [self pulseBloodOnce];
      }
    } else if (perc > PULSE_ONCE_THRESH) {
      [self stopPulsing];
    }
  }];
}

- (void) endEnemyTurn {
  BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
  if (!playerIsKilled){
    SkillLogStart(@"TRIGGER STARTED: enemy turn end");
    [skillManager triggerSkills:SkillTriggerPointEndOfEnemyTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  end of enemy turn trigger ENDED");
      if (![self checkEnemyHealth]){
        [self checkMyHealth];
      }
    }];
  } else {
    [self checkMyHealth];
  }
}

- (void) playerDealsDamageToSelf {
  SkillLogStart(@"TRIGGER STARTED: deal damage by player");
  [skillManager triggerSkills:SkillTriggerPointPlayerDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by player trigger ENDED");
    
    _enemyShouldAttack = YES;
    _totalDamageTaken += _myDamageDealt;
    
    [self dealDamageToSelf:_myDamageDealt enemyIsAttacker:NO withTarget:self andSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    
    float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
    if (!_bloodSplatter || _bloodSplatter.numberOfRunningActions == 0) {
      if (perc < PULSE_CONT_THRESH) {
        [self pulseBloodContinuously];
        [self pulseHealthLabel:NO];
      } else if (perc < PULSE_ONCE_THRESH) {
        [self pulseBloodOnce];
      }
    } else if (perc > PULSE_ONCE_THRESH) {
      [self stopPulsing];
    }
  }];
  
  [self.myPlayer performFarFlinchAnimationWithDelay:0.f];
}

- (void) enemyDealsDamageToSelf {
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [skillManager triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    [self dealDamageToSelf:_enemyDamageDealt enemyIsAttacker:YES withTarget:self andSelector:@selector(endEnemyTurn)];
    
    float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
    if (perc < PULSE_CONT_THRESH) {
      [self pulseHealthLabel:YES];
    } else {
      [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
      self.currentEnemy.healthLabel.color = [CCColor whiteColor];
    }
    
    [self.currentEnemy performNearFlinchAnimationWithStrength:0 delay:0.f];
  }];
}

- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withTarget:(id)target andSelector:(SEL)selector
{
  BattlePlayer *bp = enemyIsAttacker ? self.enemyPlayerObject : self.myPlayerObject;
  BattleSprite *bs = enemyIsAttacker ? self.currentEnemy : self.myPlayer;
  CCLabelTTF *healthLabel = enemyIsAttacker ? self.currentEnemy.healthLabel : self.myPlayer.healthLabel;
  CCProgressNode *healthBar = enemyIsAttacker ? self.currentEnemy.healthBar : self.myPlayer.healthBar;
  
  int curHealth = bp.curHealth;
  int newHealth = MIN(bp.maxHealth, MAX(bp.minHealth, curHealth - damageDone));
  float newPercent = (float)newHealth / bp.maxHealth * 100.f;
  float percChange = ABS(healthBar.percentage - newPercent);
  float duration = percChange / HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           [self updateHealthBars];
                           [SoundEngine puzzleDamageTickStop];
                           
                           if (newHealth <= 0) {
                             [self blowupBattleSprite:bs withBlock:^{
                               [target performSelector:selector];
                             }];
                             
                             if (enemyIsAttacker) {
                               // Drop loot
                               _lootSprite = [self getCurrentEnemyLoot];
                               
                               if (_lootSprite)
                                 [self dropLoot:_lootSprite];
                             }
                           } else {
                             [target performSelector:selector];
                           }
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@",
                                                 [Globals commafyNumber:(int)(healthBar.percentage / 100.f * bp.maxHealth)],
                                                 [Globals commafyNumber:bp.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:.03f],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  NSString *str = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:damageDone]];
  CCLabelBMFont *damageLabel = [CCLabelBMFont labelWithString:str fntFile:@"hpfont.fnt"];
  [self.bgdContainer addChild:damageLabel z:bs.zOrder];
  damageLabel.position = ccpAdd(bs.position, ccp(0, bs.contentSize.height - 15));
  damageLabel.scale = .01f;
  [damageLabel runAction:[CCActionSequence actions:
                          [CCActionSpawn actions:
                           [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1.f]],
                           [CCActionFadeOut actionWithDuration:1.5f],
                           [CCActionMoveBy actionWithDuration:1.5f position:ccp(0, 25)],nil],
                          [CCActionCallFunc actionWithTarget:damageLabel selector:@selector(removeFromParent)], nil]];
  
  bp.curHealth = newHealth;
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector {
  BattlePlayer *att, *def;
  BattleSprite *attSpr, *defSpr;
  CCLabelTTF *healthLabel;
  CCProgressNode *healthBar;
  if (enemyIsAttacker) {
    att = self.enemyPlayerObject; def = self.myPlayerObject;
    attSpr = self.currentEnemy; defSpr = self.myPlayer;
    healthLabel = self.myPlayer.healthLabel; healthBar = self.myPlayer.healthBar;
  } else {
    def = self.enemyPlayerObject; att = self.myPlayerObject;
    defSpr = self.currentEnemy; attSpr = self.myPlayer;
    healthLabel = self.currentEnemy.healthLabel; healthBar = self.currentEnemy.healthBar;
  }
  
  int curHealth = def.curHealth;
  int newHealth = MIN(def.maxHealth, MAX(def.minHealth, curHealth-damageDone));
  float newPercent = ((float)newHealth)/def.maxHealth*100;
  float percChange = ABS(healthBar.percentage-newPercent);
  float duration = percChange/HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           [self updateHealthBars];
                           [SoundEngine puzzleDamageTickStop];
                           
                           if (newHealth <= 0) {
                             [self blowupBattleSprite:defSpr withBlock:^{
                               [target performSelector:selector];
                             }];
                             
                             if (!enemyIsAttacker) {
                               // Drop loot
                               _lootSprite = [self getCurrentEnemyLoot];
                               
                               if (_lootSprite)
                                 [self dropLoot:_lootSprite];
                             }
                           } else {
                             [target performSelector:selector];
                           }
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:(int)(healthBar.percentage/100.f*def.maxHealth)], [Globals commafyNumber:def.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:0.03],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  NSString *str = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:damageDone]];
  CCLabelBMFont *damageLabel = [CCLabelBMFont labelWithString:str fntFile:@"hpfont.fnt"];
  [self.bgdContainer addChild:damageLabel z:defSpr.zOrder];
  damageLabel.position = ccpAdd(defSpr.position, ccp(0, defSpr.contentSize.height-15));
  damageLabel.scale = 0.01;
  [damageLabel runAction:[CCActionSequence actions:
                          [CCActionSpawn actions:
                           [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                           [CCActionFadeOut actionWithDuration:1.5f],
                           [CCActionMoveBy actionWithDuration:1.5f position:ccp(0,25)],nil],
                          [CCActionCallFunc actionWithTarget:damageLabel selector:@selector(removeFromParent)], nil]];
  
  if ( ! usingAbility )
  {
    CGPoint pos = defSpr.position;
    int val = 40*(enemyIsAttacker ? 1 : -1);
    pos = ccpAdd(pos, ccp(val, 15));
    //[self displayEffectivenessForAttackerElement:att.element defenderElement:def.element position:pos];
  }
  
  def.curHealth = newHealth;
}

- (void) healForAmount:(int)heal enemyIsHealed:(BOOL)enemyIsHealed withTarget:(id)target andSelector:(SEL)selector {
  BattlePlayer *bp;
  BattleSprite *sprite;
  CCLabelTTF *healthLabel;
  CCProgressNode *healthBar;
  if (enemyIsHealed) {
    bp = self.enemyPlayerObject;
    sprite = self.currentEnemy;
    healthLabel = self.currentEnemy.healthLabel;
    healthBar = self.currentEnemy.healthBar;
  } else {
    bp = self.myPlayerObject;
    sprite = self.myPlayer;
    healthLabel = self.myPlayer.healthLabel;
    healthBar = self.myPlayer.healthBar;
  }
  
  int curHealth = bp.curHealth;
  int newHealth = MIN(bp.maxHealth, MAX(bp.minHealth, curHealth + heal));
  float newPercent = ((float)newHealth) / bp.maxHealth * 100.f;
  float percChange = ABS(healthBar.percentage - newPercent);
  float duration = percChange / HEALTH_BAR_SPEED;
  
  [SoundEngine puzzleDamageTickStart];
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:duration percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1827];
                           [self updateHealthBars];
                           [SoundEngine puzzleDamageTickStop];
                           [target performSelector:selector];
                         }],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                       [CCActionSequence actions:
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           healthLabel.string = [NSString stringWithFormat:@"%@/%@",
                                                 [Globals commafyNumber:(int)(healthBar.percentage / 100.f * bp.maxHealth)],
                                                 [Globals commafyNumber:bp.maxHealth]];
                         }],
                        [CCActionDelay actionWithDuration:.03f],
                        nil]];
  [f setTag:1827];
  [healthLabel runAction:f];
  
  NSString *str = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:heal]];
  CCLabelBMFont *healLabel = [CCLabelBMFont labelWithString:str fntFile:@"earthpointsfont.fnt"];
  [self.bgdContainer addChild:healLabel z:sprite.zOrder];
  [healLabel setPosition:ccpAdd(sprite.position, ccp(0.f, sprite.contentSize.height - 15.f))];
  [healLabel setScale:.01f];
  [healLabel runAction:[CCActionSequence actions:
                        [CCActionSpawn actions:
                         [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1.1f]],
                         [CCActionFadeOut actionWithDuration:1.5f],
                         [CCActionMoveBy actionWithDuration:1.5f position:ccp(0.f, 25.f)], nil],
                        [CCActionCallFunc actionWithTarget:healLabel selector:@selector(removeFromParent)], nil]];
  
  bp.curHealth = newHealth;
}

- (void) instantSetHealthForEnemey:(BOOL)enemy to:(int)health withTarget:(id)target andSelector:(SEL)selector
{
  BattlePlayer* bp = enemy ? self.enemyPlayerObject : self.myPlayerObject;
  BattleSprite* bs = enemy ? self.currentEnemy : self.myPlayer;
  
  bp.curHealth = MIN(bp.maxHealth, MAX(bp.minHealth, health));
  [self updateHealthBars];
  
  if (health <= 0) {
    [self blowupBattleSprite:bs withBlock:^{
      [target performSelector:selector];
    }];
    
    if (enemy) {
      // Drop loot
      _lootSprite = [self getCurrentEnemyLoot];
      
      if (_lootSprite)
        [self dropLoot:_lootSprite];
    }
  } else {
    [target performSelector:selector];
  }
}

- (void) displayEffectivenessForAttackerElement:(Element)atkElement defenderElement:(Element)defElement position:(CGPoint)position {
  Globals *gl = [Globals sharedGlobals];
  float mult = [gl calculateDamageMultiplierForAttackElement:atkElement defenseElement:defElement];
  CCSprite *eff = nil;
  
  if (mult == gl.elementalStrength) {
    eff = [CCSprite spriteWithImageNamed:@"supereffective.png"];
  } else if (mult == gl.elementalWeakness) {
    eff = [CCSprite spriteWithImageNamed:@"noteffective.png"];
  }
  
  if (eff) {
    [self.bgdContainer addChild:eff z:100];
    
    // Ignore position and use center point
    eff.position = ccpAdd(CENTER_OF_BATTLE, ccp(20, 10));
    
    eff.scale = 0.5f;
    //eff.position = position;
    eff.opacity = 0.f;
    [eff runAction:
     [CCActionSequence actions:
      [CCActionSpawn actions:
       [CCActionScaleTo actionWithDuration:0.2f scale:1.f],
       [CCActionFadeIn actionWithDuration:0.2f], nil],
      [CCActionDelay actionWithDuration:0.7f],
      [CCActionSpawn actions:
       [CCActionScaleTo actionWithDuration:0.2f scale:0.5f],
       [CCActionFadeOut actionWithDuration:0.2f], nil],
      [CCActionCallFunc actionWithTarget:eff selector:@selector(removeFromParent)], nil]];
  }
}

- (void) sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify {
  if (_enemyDamageDealt || !verify) {
    [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:self.myPlayerObject.userMonsterUuid curHealth:self.myPlayerObject.curHealth];
  }
}

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block {
  [sprite runAction:[CCActionSequence actions:
                     [RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                     [CCActionDelay actionWithDuration:0.7f],
                     [CCActionCallFunc actionWithTarget:sprite selector:@selector(removeFromParent)],
                     [CCActionCallBlock actionWithBlock:^{if (block) block();}], nil]];
  
  CCParticleSystem *q = [CCParticleSystem particleWithFile:@"characterdie.plist"];
  q.autoRemoveOnFinish = YES;
  q.position = ccpAdd(sprite.position, ccp(0, sprite.contentSize.height/2-5));
  [self.bgdContainer addChild:q z:2];
  
  [SoundEngine puzzleMonsterDefeated];
}

- (BOOL) checkEnemyHealth {
  
  if (self.enemyPlayerObject.curHealth <= 0) {
    
    // Trigger skills for move made by the player
    SkillLogStart(@"TRIGGER STARTED: enemy defeated");
    [skillManager triggerSkills:SkillTriggerPointEnemyDefeated withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  Enemy defeated trigger ENDED");
      
      self.currentEnemy = nil;
      
      [self.hudView removeBattleScheduleView];
      [self.hudView hideSkillPopup:nil];
      
      // Send server updated values here because monster just died
      // But make sure that I actually did damage..
      [self sendServerUpdatedValuesVerifyDamageDealt:YES];
      
      self.enemyPlayerObject = nil;
      [self updateHealthBars];
      [self moveToNextEnemy];
      
    }];
    
    return YES;
  }
  
  return NO;
}

- (void) checkEnemyHealthAndStartNewTurn {
  BOOL enemyIsDead = [self checkEnemyHealth];
  if (! enemyIsDead)
  {
    SkillLogStart(@"TRIGGER STARTED: player turn ended");
    [skillManager triggerSkills:SkillTriggerPointEndOfPlayerTurn withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  player turn ended trigger ENDED");
      
      BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
      if (playerIsKilled){
        [self checkMyHealth];
      } else if (_enemyShouldAttack) {
        [self beginNextTurn];
      }
    }];
  }
}

- (CCSprite *) getCurrentEnemyLoot {
  // Should be implemented
  return nil;
}

- (void) checkMyHealth {
  [self sendServerUpdatedValuesVerifyDamageDealt:YES];
  if (self.myPlayerObject.curHealth <= 0) {
    _movesLeft = 0;
    [self stopPulsing];
    
    self.myPlayer = nil;
    
    self.myPlayerObject = nil;
    [self updateHealthBars];
    
    [self currentMyPlayerDied];
  } else {
    [self beginNextTurn];
  }
}

- (NSInteger) playerMobstersLeft
{
  NSInteger result = 0;
  for (BattlePlayer *bp in self.myTeam)
    if (bp.curHealth > 0)
      result++;
  return result;
}

- (void) currentMyPlayerDied {
  
  if ([self playerMobstersLeft] > 0) {
    SkillLogStart(@"TRIGGER STARTED: mob defeated");
    [skillManager triggerSkills:SkillTriggerPointPlayerMobDefeated withCompletion:^(BOOL triggered, id params) {
      SkillLogEnd(triggered, @"  Mob defeated trigger ENDED");
      [self displayDeployViewAndIsCancellable:NO];
    }];
  } else {
    [self youLost];
  }
}

- (void) displayWaveNumber {
  float initDelay = TIME_TO_SCROLL_PER_SCENE-2.2;
  float fadeTime = 0.35;
  float delayTime = 2.1;
  int z = 2;
  
  CCNodeColor *bgd = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(0, 0, 0, 0)] width:self.contentSize.width height:self.contentSize.height];
  [self addChild:bgd z:z];
  
  CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Enemy %d/%d", _curStage+1, (int)self.enemyTeam.count] fontName:@"Ziggurat-HTF-Black" fontSize:21];
  [self addChild:label z:z];
  label.position = ccp(24, self.contentSize.height/2+29);
  label.anchorPoint = ccp(0, 0.5);
  label.color = [CCColor colorWithRed:255/255.f green:204/255.f blue:0.f];
  label.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  label.shadowOffset = ccp(0, -1);
  label.shadowBlurRadius = 1.3;
  
  CCSprite *spr = [CCSprite spriteWithImageNamed:@"enemydivider.png"];
  [self addChild:spr z:z];
  spr.scaleX = MIN(label.position.x+label.contentSize.width+20, self.contentSize.width-label.position.x*2-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE*2);
  spr.anchorPoint = ccp(0, 0.5);
  spr.position = ccpAdd(label.position, ccp(0, -label.contentSize.height/2-8));
  
  
  CCSprite *bgdIcon = [CCSprite spriteWithImageNamed:@"youwonitembg.png"];
  [self addChild:bgdIcon z:z];
  bgdIcon.anchorPoint = ccp(0, 0.5);
  bgdIcon.position = ccpAdd(label.position, ccp(0, -58));
  
  if (self.enemyPlayerObject.spritePrefix.length) {
    CCSprite *inside = [CCSprite node];
    [bgdIcon addChild:inside];
    inside.position = ccp(bgdIcon.contentSize.width/2, bgdIcon.contentSize.height/2);
    
    NSString *fileName = [self.enemyPlayerObject.spritePrefix stringByAppendingString:@"Card.png"];
    [Globals imageNamed:fileName toReplaceSprite:inside completion:^(BOOL success) {
      inside.scale = bgdIcon.contentSize.height/inside.contentSize.height;
    }];
    
    if (self.enemyPlayerObject.evoLevel > 1)
    {
      CCSprite *evo = [CCSprite node];
      [bgdIcon addChild:evo];
      
      [Globals imageNamed:@"evobadge2.png" toReplaceSprite:evo];
      evo.position = ccp(evo.contentSize.width-1, evo.contentSize.height-1);
      
      CCLabelTTF *evoLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", self.enemyPlayerObject.evoLevel] fontName:@"Gotham-Ultra" fontSize:8];
      [evo addChild:evoLabel];
      evoLabel.horizontalAlignment = CCTextAlignmentCenter;
      evoLabel.position = ccp(evo.contentSize.width/2, evo.contentSize.height/2-1);
      evoLabel.color = [CCColor colorWithWhite:1.0f alpha:1.0f];
      evoLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.3f];
      evoLabel.shadowOffset = ccp(0, -1);
      evoLabel.shadowBlurRadius = .6;
      
    }
    
  }
  
  CCSprite *border = [CCSprite spriteWithImageNamed:@"youwonitemborder.png"];
  [bgdIcon addChild:border];
  border.position = ccp(bgdIcon.contentSize.width/2, bgdIcon.contentSize.height/2);
  
  
  
  CCLabelTTF *nameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Ziggurat-HTF-Black" fontSize:10];
  nameLabel.attributedString = self.enemyPlayerObject.attrName;
  [bgdIcon addChild:nameLabel];
  nameLabel.color = [CCColor whiteColor];
  nameLabel.shadowOffset = ccp(0, -1);
  nameLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  nameLabel.shadowBlurRadius = 1.5f;
  nameLabel.anchorPoint = ccp(0, 0.5);
  
  CCSprite *elem = [CCSprite spriteWithImageNamed:[Globals imageNameForElement:self.enemyPlayerObject.element suffix:@"orb.png"]];
  elem.scale = 0.5;
  elem.anchorPoint = ccp(0, 0.5);
  [nameLabel addChild:elem];
  elem.position = ccp(-elem.contentSize.width*elem.scale-3, nameLabel.contentSize.height/2);
  
  
  
  if (self.enemyPlayerObject.monsterType != TaskStageMonsterProto_MonsterTypeRegular) {
    NSString *newText = self.enemyPlayerObject.monsterType == TaskStageMonsterProto_MonsterTypeMiniBoss ? @"Mini Boss" : @"Boss";
    label.string = newText;
    label.color = [CCColor whiteColor];
    [label runAction:[CCActionRepeatForever actionWithAction:
                      [CCActionSequence actions:
                       [CCActionTintTo actionWithDuration:0.25 color:[CCColor colorWithRed:1.f green:84/255.f blue:0.f]],
                       [CCActionTintTo actionWithDuration:0.25 color:[CCColor whiteColor]], nil]]];
    
    delayTime = 3;
  }
  
  
  if (self.enemyPlayerObject.rarity != QualityCommon) {
    NSString *rarityStr = [@"battle" stringByAppendingString:[Globals imageNameForRarity:self.enemyPlayerObject.rarity suffix:@"tag.png"]];
    CCSprite *rarityTag = [CCSprite spriteWithImageNamed:rarityStr];
    [bgdIcon addChild:rarityTag];
    rarityTag.anchorPoint = ccp(0, 0.5);
    rarityTag.position = ccp(bgdIcon.contentSize.width+9, 34);
    
    nameLabel.position = ccp(bgdIcon.contentSize.width+9-elem.position.x, 10);
  } else {
    nameLabel.position = ccp(bgdIcon.contentSize.width+9-elem.position.x, 29);
  }
  
  NSMutableArray *arr = [NSMutableArray array];
  [arr addObject:label];
  [arr addObject:bgdIcon];
  
  int moveAmt = 50;//s.contentSize.width/2;
  for (int i = 0; i < arr.count; i++) {
    CCNode *s = arr[i];
    [s recursivelyApplyOpacity:0];
    s.position = ccpAdd(s.position, ccp(-moveAmt, 0));
    
    CCAction *a =
    [CCActionSequence actions:
     [CCActionDelay actionWithDuration:initDelay+fadeTime+i*0.09],
     [CCActionSpawn actions:
      [CCActionMoveBy actionWithDuration:0.3f position:ccp(moveAmt, 0)],
      [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f], nil],
     [CCActionDelay actionWithDuration:delayTime-1.f+i*0.09],
     [CCActionSpawn actions:
      [CCActionMoveBy actionWithDuration:0.3f position:ccp(-moveAmt, 0)],
      [RecursiveFadeTo actionWithDuration:0.3f opacity:0.f], nil],
     [CCActionRemove action],
     nil];
    a.tag = 12;
    [s runAction:a];
  }
  
  spr.opacity = 0.f;
  spr.position = ccpAdd(spr.position, ccp(-moveAmt, 0));
  [spr runAction:[label getActionByTag:12].copy];
  
  [bgd runAction:[CCActionSequence actions:
                  [CCActionDelay actionWithDuration:initDelay],
                  [CCActionFadeTo actionWithDuration:fadeTime opacity:0.65f],
                  [CCActionDelay actionWithDuration:delayTime],
                  [CCActionFadeTo actionWithDuration:fadeTime opacity:0.f],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [bgd removeFromParentAndCleanup:YES];
                     
                     // One of the two racing calls for beginNextTurn. _displayWaveNumber is used as the flag
                     _displayedWaveNumber = YES;
                     [self beginNextTurn];
                   }],
                  nil]];
  
  self.hudView.waveNumLabel.text = [NSString stringWithFormat:@"ENEMY %d/%d", _curStage+1, (int)self.enemyTeam.count];
  
  [UIView animateWithDuration:fadeTime delay:initDelay options:UIViewAnimationOptionCurveLinear animations:^{
    self.hudView.waveNumLabel.alpha = 0.3f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:fadeTime delay:delayTime options:UIViewAnimationOptionCurveLinear animations:^{
      self.hudView.waveNumLabel.alpha = 1.f;
    } completion:nil];
  }];
}

- (void) dropLoot:(CCSprite *)ed {
  [self.bgdContainer addChild:ed z:-1 name:LOOT_TAG];
  ed.anchorPoint = ccp(0.5, 0);
  ed.position = ccpAdd(self.currentEnemy.position, ccp(0,self.currentEnemy.contentSize.height/2));
  ed.scale = 0.01;
  ed.opacity = 0.1f;
  
  float scale = 1.f;
  
  [ed runAction:[CCActionSpawn actions:
                 [CCActionFadeIn actionWithDuration:0.1],
                 [CCActionScaleTo actionWithDuration:0.1 scale:scale],
                 [CCActionSequence actions:
                  [CCActionMoveBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,20)],
                  [CCActionEaseBounceOut actionWithAction:
                   [CCActionMoveBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-27-self.currentEnemy.contentSize.height/2)]],
                  nil], nil]];
}

- (void) pickUpLoot {
  CCSprite *ed = _lootSprite;
  
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  CGPoint initPos = ed.position;
  CGFloat finalX = self.myPlayer.position.x+5;
  CGFloat diffX = finalX-initPos.x;
  CGPoint finalPos = ccpAdd(initPos, ccp(diffX, diffX/ptOffset.x*ptOffset.y));
  CGFloat travelY = initPos.y-finalPos.y;
  float distScale = travelY/Y_MOVEMENT_FOR_NEW_SCENE;
  
  ccBezierConfig bezier;
  bezier.endPosition = [self.bgdContainer convertToNodeSpace:[self.lootLabel.parent.parent convertToWorldSpace:self.lootLabel.parent.position]];
  bezier.controlPoint_1 = ccp(finalPos.x+(bezier.endPosition.x-finalPos.x)/3,bezier.endPosition.y+(finalPos.y-bezier.endPosition.y)/3+40);
  bezier.controlPoint_2 = ccp(finalPos.x+(bezier.endPosition.x-finalPos.x)*2/3,bezier.endPosition.y+(finalPos.y-bezier.endPosition.y)*2/3+40);
  CCActionBezierTo *bezierForward = [CCActionBezierTo actionWithDuration:0.3f bezier:bezier];
  
  [ed runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE*distScale position:finalPos],
    [CCActionSpawn actions:bezierForward,
     [CCActionScaleBy actionWithDuration:bezierForward.duration scale:0.3], nil],
    [CCActionCallBlock actionWithBlock:
     ^{
       [ed removeFromParent];
       
       _lootCount++;
       CCActionScaleBy *scale = [CCActionScaleBy actionWithDuration:0.25 scale:1.4];
       _lootLabel.string = [Globals commafyNumber:_lootCount];
       [_lootLabel runAction:
        [CCActionSequence actions:
         scale,
         scale.reverse, nil]];
       
       _lootSprite = nil;
     }],
    nil]];
}

- (void) spawnPlaneWithTarget:(id)target selector:(SEL)selector {
  CGPoint pt = POINT_OFFSET_PER_SCENE;
  
  CCSprite *plane = [CCSprite spriteWithImageNamed:@"airplane.png"];
  [self.bgdContainer addChild:plane];
  plane.position = ccp(-plane.contentSize.width/2,
                       self.currentEnemy.position.y+5-(self.currentEnemy.position.x+plane.contentSize.width/2)*pt.y/pt.x);
  
  [plane runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:1.f position:ccpAdd(self.currentEnemy.position, ccp(0,5))],
    [CCActionDelay actionWithDuration:0.01f],
    [CCActionMoveBy actionWithDuration:0.5f position:ccpMult(pt, 0.4)],
    [CCActionCallBlock actionWithBlock:
     ^{
       [plane removeFromParentAndCleanup:YES];
     }],
    nil]];
  
  int end = 5;
  for (int i = 0; i <= end; i++) {
    CCSprite *bomb = [CCSprite spriteWithImageNamed:@"bomb.png"];
    [self.bgdContainer addChild:bomb];
    bomb.scale = 0.3;
    
    CGPoint endPos = ccpAdd(self.currentEnemy.position, ccp(5,10));
    endPos = ccpAdd(endPos, ccpMult(POINT_OFFSET_PER_SCENE, 0.02*(i-2)));
    
    bomb.position = ccp(endPos.x, endPos.y+250);
    
    [bomb runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:0.75f+0.1*i],
      [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.9f position:endPos]],
      [CCActionCallBlock actionWithBlock:
       ^{
         [[CCTextureCache sharedTextureCache] addImage:@"bombdrop.png"];
         CCParticleSystem *q = [CCParticleSystem particleWithFile:@"bombdrop.plist"];
         q.autoRemoveOnFinish = YES;
         q.position = bomb.position;
         [self.bgdContainer addChild:q];
         
         [bomb removeFromParentAndCleanup:YES];
         
         if (i == end) {
           [target performSelector:selector];
         }
         
         if (i == 0) {
           [self shakeScreenWithIntensity:2.f];
         }
       }],
      nil]];
  }
  
  [SoundEngine puzzlePlaneDrop];
}

- (void) shakeScreenWithIntensity:(float)intensity {
  // Shake everything with zOrder 0
  CCActionMoveBy *move = [CCActionMoveBy actionWithDuration:0.02f position:ccp(3*intensity, 0)];
  CCActionSequence *seq = [CCActionSequence actions:move, move.reverse, move.reverse, move, nil];
  CCActionRepeat *repeat = [CCActionRepeat actionWithAction:seq times:5+(intensity*3)];
  
  // Dont shake curEnemy because it messes with it coming back after flinch
  NSArray *arr = [NSArray arrayWithObjects:self.bgdContainer, nil];
  for (CCNode *n in arr) {
    CGPoint curPos = n.position;
    [n runAction:[CCActionSequence actions:repeat.copy, [CCActionCallBlock actionWithBlock:^{
      n.position = curPos;
    }], nil]];
  }
}

- (void) showHighScoreWordWithTarget:(id)target selector:(SEL)selector {
  CCSprite *phrase = nil;
  NSString *phraseFile = nil;
  BOOL isMakeItRain = NO;
  int currentScore = _myDamageDealt/(float)[self.myPlayerObject totalAttackPower]*100.f;
  if (currentScore > MAKEITRAIN_SCORE) {
    isMakeItRain = YES;
  } else if (currentScore > HAMMERTIME_SCORE) {
    phraseFile = @"hammertime.png";
  } else if (currentScore > CANTTOUCHTHIS_SCORE) {
    phraseFile = @"canttouchthis.png";
  } else if (currentScore > BALLIN_SCORE) {
    phraseFile = @"ballin.png";
  }
  
  if (isMakeItRain) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"makeitrain.plist"];
    CCAnimation *anim = [CCAnimation animation];
    anim.delayPerUnit = 0.1f;
    [anim addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir1.png"]];
    [anim addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir2.png"]];
    [anim addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir3.png"]];
    phrase = [CCSprite spriteWithImageNamed:@"mir1.png"];
    [phrase runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  } else {
    if (phraseFile) {
      phrase = [CCSprite spriteWithImageNamed:phraseFile];
    }
  }
  
  if (phrase) {
    CCNodeColor *l = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(0, 0, 0, 0)] width:self.contentSize.width height:self.contentSize.height];
    [self addChild:l z:3];  // was 1, changed by Mikhail to darken skill indicators
    [l runAction:[CCActionSequence actions:
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0.6f],
                  [CCActionDelay actionWithDuration:1.1],
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [l removeFromParentAndCleanup:YES];
                   }], nil]];
    
    [self addChild:phrase z:4]; // was 3, see above
    phrase.position = ccp(-phrase.contentSize.width/2, self.contentSize.height/2);
    CCActionSequence *seq =
    [CCActionSequence actions:
     [CCActionMoveBy actionWithDuration:0.15 position:ccp(phrase.contentSize.width+self.contentSize.width/5, 0)],
     [CCActionMoveBy actionWithDuration:1.1 position:ccp(self.contentSize.width*3/5-phrase.contentSize.width, 0)],
     [CCActionMoveBy actionWithDuration:0.15 position:ccp(phrase.contentSize.width+self.contentSize.width/5, 0)],
     [CCActionCallBlock actionWithBlock:
      ^{
        [phrase removeFromParentAndCleanup:YES];
        [target performSelector:selector];
      }],
     nil];
    [phrase runAction:seq];
    
    [SoundEngine puzzleMakeItRain];
  } else {
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:0.5f], [CCActionCallFunc actionWithTarget:target selector:selector], nil]];
  }
}

- (void) spawnRibbonForOrb:(BattleOrb *)orb target:(CGPoint)endPosition baseDuration:(CGFloat)dur skill:(BOOL)skill {
  
  BOOL cake = (orb.specialOrbType == SpecialOrbTypeCake);
  
  // Create random bezier
  if (orb.orbColor != OrbColorNone || cake) {
    ccBezierConfig bez;
    bez.endPosition = endPosition;
    CGPoint initPoint = [self.orbLayer convertToNodeSpace:[self.orbLayer.swipeLayer convertToWorldSpace:[self.orbLayer.swipeLayer pointForColumn:orb.column row:orb.row]]];
    
    // basePt1 is chosen with any y and x is between some neg num and approx .5
    // basePt2 is chosen with any y and x is anywhere between basePt1's x and .85
    BOOL chooseRight = arc4random()%2;
    CGPoint basePt1 = ccp(drand48()-0.8, drand48());
    CGPoint basePt2 = ccp(basePt1.x+drand48()*(0.7-basePt1.x), drand48());
    
    // outward potential increases based on distance between orbs
    float xScale = ccpDistance(initPoint, bez.endPosition);
    float yScale = (50+xScale/5)*(chooseRight?-1:1);
    float angle = ccpToAngle(ccpSub(bez.endPosition, initPoint));
    if (cake)
    {
      xScale = 1.0;
      yScale = 1.0;
      angle = 0.0;
      basePt1 = ccp(-10.0, -50.0);
      basePt2 = ccp(-100.0, -20.0);
    }
    
    // Transforms are applied in reverse order!! So rotate, then scale
    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
    bez.controlPoint_1 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt1, t));
    bez.controlPoint_2 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt2, t));
    
    CCActionBezierTo *move = [CCActionBezierTo actionWithDuration:(cake?1.5f:(dur+xScale/800.f)) bezier:bez];
    CCNode *dg;
    float stayDelay = 0.7f;
    if (skill)
    {
      // Tail for an orb flying to skill indicator
//    dg = [[SparklingTail alloc] initWithColor:orb.orbColor];
      
      CCSprite *orbSprite = [self.orbLayer.swipeLayer spriteForOrb:orb].orbSprite;
      dg = [CCSprite spriteWithTexture:orbSprite.texture rect:orbSprite.textureRect];
      move = [CCActionSpawn actions:move, [CCActionScaleTo actionWithDuration:move.duration scale:.3f], nil];

      stayDelay = 0.0;
    }
    else
    {
      // Cake or sparkle
      if (cake)
        dg = [[DestroyedOrb alloc] initWithCake];
      else
        dg = [[DestroyedOrb alloc] initWithColor:[self.orbLayer.swipeLayer colorForSparkle:orb.orbColor]];
    }
    
    [self.orbLayer addChild:dg z:10];
    dg.position = initPoint;
    [dg runAction:[CCActionSequence actions:move,
                   [CCActionSpawn actions:
                    [CCActionScaleTo actionWithDuration:.5f scale:.1f],
                    [CCActionFadeOut actionWithDuration:.5f],
                    nil],
                   [CCActionDelay actionWithDuration:stayDelay],
                   [CCActionCallFunc actionWithTarget:dg selector:@selector(removeFromParent)], nil]];
  }
}

- (void) youWon {
  [self endBattle:YES];
}

- (void) youLost {
  [self endBattle:NO];
}

- (void) youForfeited {
  // Make sure you can actually make a move
  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self youLost];
  }
}

- (void) endBattle:(BOOL)won {
  [CCBReader load:@"BattleEndView" owner:self];
  
  // Set endView's parent so that the position normalization doesn't get screwed up
  // since we're only adding it to the parent once orb layer gets removed
  self.endView.parent = self;
  
  _wonBattle = won;
  
  [self.hudView removeButtons];
  [self.hudView removeBattleScheduleView];
  [self.hudView hideSkillPopup:nil];
  self.hudView.bottomView.hidden = YES;
  
  [self removeOrbLayerAnimated:YES withBlock:^{
    [SoundEngine puzzleWinLoseUI];
    
    if ([self shouldShowChatLine]) {
      [self.endView showTextFieldWithTarget:self selector:@selector(sendButtonClicked:)];
    }
    
    self.endView.parent = nil;
    [self addChild:self.endView z:10000];
    
    if (won) {
      [self.endView.continueButton removeFromParent];
      
      [SoundEngine puzzleYouWon];
    } else {
      if ([self shouldShowContinueButton]) {
         [self.endView.shareButton removeFromParent];
      } else {
        [self.endView.continueButton removeFromParent];
      }
      
      [SoundEngine puzzleYouLose];
    }
  }];
}

#pragma mark - Blood Splatter

- (CCSprite *) bloodSplatter {
  if (!_bloodSplatter) {
    CCSprite *s = [CCSprite spriteWithImageNamed:@"bloodsplatter.png"];
    [self addChild:s z:1];
    s.opacity = 0.f;
    s.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    s.scaleX = self.contentSize.width/s.contentSize.width;
    s.scaleY = self.contentSize.height/s.contentSize.height;
    _bloodSplatter = s;
  }
  return _bloodSplatter;
}

- (void) pulseBloodOnce {
  CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:0.5f opacity:1.f];
  CCActionFadeTo *fadeOut = [CCActionFadeTo actionWithDuration:0.5f opacity:0];
  self.bloodSplatter.opacity = 0;
  [self.bloodSplatter runAction:
   [CCActionSequence actions:fadeIn, fadeOut, nil]];
}

- (void) pulseBloodContinuously {
  [self stopAllActions];
  CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:1.f opacity:1.f];
  CCActionFadeTo *fadeOut = [CCActionFadeTo actionWithDuration:1.f opacity:0.5f];
  self.bloodSplatter.opacity = 0;
  [self.bloodSplatter runAction:
   [CCActionRepeatForever actionWithAction:
    [CCActionSequence actions:fadeIn, fadeOut, nil]]];
}

- (void) pulseHealthLabel:(BOOL)isEnemy {
  CCLabelTTF *label = isEnemy ? self.currentEnemy.healthLabel : self.myPlayer.healthLabel;
  
  if (![label getActionByTag:RED_TINT_TAG]) {
    CCActionTintTo *tintRed = [CCActionTintTo actionWithDuration:1.f color:[CCColor colorWithCcColor3b:ccc3(255, 0, 0)]];
    CCActionTintTo *tintWhite = [CCActionTintTo actionWithDuration:1.f color:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
    CCActionSequence *seq = [CCActionSequence actions:tintRed, tintWhite, nil];
    CCActionRepeatForever *rep = [CCActionRepeatForever actionWithAction:seq];
    rep.tag = RED_TINT_TAG;
    [label runAction:rep];
  }
}

- (void) stopPulsing {
  [_bloodSplatter stopAllActions];
  [self.bloodSplatter runAction:[CCActionFadeTo actionWithDuration:self.bloodSplatter.opacity*0.2f opacity:0.f]];
  _bloodSplatter.opacity = 0;
  [self.myPlayer.healthLabel stopActionByTag:RED_TINT_TAG];
  self.myPlayer.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
}

#pragma mark - Delegate Methods

- (void) moveBegan {
  _movesLeft--;
  [self updateHealthBars];
  [self.hudView removeSwapButtonAnimated:YES];
  [skillManager enableSkillButton:NO];
}

- (void) newComboFound {
  _comboCount++;
  _totalComboCount++;
  
  // Update combo count label but do it somewhat slowly
  __block int base = MAX(2, [_comboLabel.string intValue]);
  if (base < _comboCount) {
    CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
      base += 1;
      _comboLabel.string = [NSString stringWithFormat:@"%dx", base];
    }];
    CCActionRepeat *rep = [CCActionRepeat actionWithAction:[CCActionSequence actions:block, [CCActionDelay actionWithDuration:0.15f], nil] times:_comboCount-base];
    rep.tag = 83239;
    [_comboLabel stopActionByTag:rep.tag];
    [_comboLabel runAction:rep];
  } else {
    _comboLabel.string = [NSString stringWithFormat:@"%dx", _comboCount];
  }
  
#if !(TARGET_IPHONE_SIMULATOR)
  
  if (_comboCount == 2) {
    [_comboBgd stopAllActions];
    [[_comboBgd getChildByName:COMBO_FIRE_TAG recursively:NO] removeFromParent];
    [_comboBgd runAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_comboBgd.parent.contentSize.width, _comboBgd.parent.contentSize.height/2)]];
    
    _comboLabel.color = [CCColor whiteColor];
    [_comboLabel setShadowOffset:ccp(0, -1)];
    [_comboLabel setShadowBlurRadius:0.7f];
    _comboBotLabel.color = [CCColor colorWithCcColor3b:ccc3(255,228,122)];
    [_comboLabel setShadowOffset:ccp(0, -1)];
    [_comboLabel setShadowBlurRadius:0.7f];
  }
  if (_comboCount == 5 && ![_comboBgd getChildByName:COMBO_FIRE_TAG recursively:NO]) {
    // Spawn fire
    CCParticleSystem *q = [CCParticleSystem particleWithFile:@"ComboFire4.plist"];
    q.autoRemoveOnFinish = YES;
    q.position = ccp(_comboBgd.contentSize.width/2+15, _comboBgd.contentSize.height/2+5);
    [_comboBgd addChild:q z:0 name:COMBO_FIRE_TAG];
    
    _comboLabel.color = [CCColor blackColor];
    _comboBotLabel.color = [CCColor blackColor];
    
    [SoundEngine puzzleComboFire];
  }
  
#endif
  
  if (_canPlayNextComboSound) {
    _soundComboCount++;
    [SoundEngine puzzleComboCreated];
    [SoundEngine puzzleFirework];
    _canPlayNextComboSound = NO;
    [self scheduleOnce:@selector(allowComboSound) delay:0.02];
  }
}

- (void) allowComboSound {
  _canPlayNextComboSound = YES;
}

- (void) orbKilled:(BattleOrb *)orb {
  OrbColor color = orb.orbColor;
  
  _orbCount++;
  _orbCounts[color]++;
  _totalOrbCounts[color]++;
  
  [skillManager orbDestroyed:orb.orbColor special:orb.specialOrbType];
  
  // Update tile
  BattleTile* tile = [self.orbLayer.layout tileAtColumn:orb.column row:orb.row];
  
  BOOL mudOnBoard = [SkillController specialTilesOnBoardCount:TileTypeMud layout:self.orbLayer.layout] > 0; // All mud tiles have to be removed before any damage can be done
  if (tile.allowsDamage && !mudOnBoard) // Certain tiles (e.g. jelly) do not allow damage
  {
    // Increment damage, create label and ribbon
    int dmg = [self.myPlayerObject damageForColor:color] * (int)orb.damageMultiplier;
    _myDamageDealt += dmg;
    _myDamageForThisTurn += dmg;
  
    if (color != OrbColorNone && ElementIsValidValue((Element)color)) {
      NSString *dmgStr = [NSString stringWithFormat:@"%@", [Globals commafyNumber:dmg]];
      NSString *fntFile = [Globals imageNameForElement:(Element)color suffix:@"pointsfont.fnt"];
      fntFile = color != OrbColorRock ? fntFile : @"nightpointsfont.fnt";
      if (fntFile) {
        CCLabelBMFont *dmgLabel = [CCLabelBMFont labelWithString:dmgStr fntFile:fntFile];
        dmgLabel.position = [self.orbLayer convertToNodeSpace:
                             [self.orbLayer.swipeLayer convertToWorldSpace:
                              [self.orbLayer.swipeLayer pointForColumn:orb.column row:orb.row]]];
        [self.orbLayer addChild:dmgLabel z:101];
        
        dmgLabel.scale = 0.25;
        [dmgLabel runAction:[CCActionSequence actions:
                             [CCActionScaleTo actionWithDuration:0.2f scale:1],
                             [CCActionSpawn actions:
                              [CCActionFadeOut actionWithDuration:0.5f],
                              [CCActionMoveBy actionWithDuration:0.5f position:ccp(0,10)],nil],
                             [CCActionCallFunc actionWithTarget:dmgLabel selector:@selector(removeFromParent)], nil]];
      }
      
      CGPoint endPoint = [self.orbLayer convertToNodeSpace:[self.bgdContainer convertToWorldSpace:ccpAdd(self.myPlayer.position, ccp(0, self.myPlayer.contentSize.height/2))]];
      [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.15f skill:NO];
      
      // Skill ribbons
      if ([skillManager shouldSpawnRibbonForPlayerSkill:orb.orbColor])
      {
        endPoint = [skillManager playerSkillIndicatorPosition];
        [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:YES];
      }
      if ([skillManager shouldSpawnRibbonForEnemySkill:orb.orbColor])
      {
        endPoint = [skillManager enemySkillIndicatorPosition];
        [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:YES];
      }

    }
    else if (orb.specialOrbType == SpecialOrbTypeCake)
    {
      CGPoint endPoint = [self.orbLayer convertToNodeSpace:[self.bgdContainer convertToWorldSpace:ccpAdd(self.currentEnemy.position, ccp(0, self.currentEnemy.contentSize.height/2))]];
      [self spawnRibbonForOrb:orb target:endPoint baseDuration:0.4f skill:NO];
    }
  }
  
  // Update all tiles
  [tile orbRemoved];
  [self.orbLayer.bgdLayer updateTile:tile];
  
  if (_canPlayNextGemPop) {
    [SoundEngine puzzleDestroyPiece];
    _canPlayNextGemPop = NO;
    [self scheduleOnce:@selector(allowGemPop) delay:0.02];
  }
}

- (void) allowGemPop {
  _canPlayNextGemPop = YES;
}

- (void) powerupCreated:(BattleOrb *)orb {
  _powerupCounts[orb.powerupType]++;
}

- (void) moveComplete {
  /*
   * 12/16/14 - BN - This check means if a turn results in no damage (e.g. because of
   * jelly or mud), it will not count as a turn. It can lead to unlimited turns and
   * combos. Why is it here? Whyeeeeeeeee?
   *
  if (_myDamageForThisTurn == 0) {
    [self.orbLayer allowInput];
    return;
  }
   */
  
  _soundComboCount = 0;
  
  [_comboBgd stopAllActions];
  [_comboBgd runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionMoveTo actionWithDuration:0.3f position:ccp(_comboBgd.parent.contentSize.width+2*self.comboBgd.contentSize.width, _comboBgd.parent.contentSize.height/2)],
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [[self.comboBgd getChildByName:COMBO_FIRE_TAG recursively:NO] removeFromParent];
     }], nil]];
  
  [self updateHealthBars];
  
  // Trigger skills for move made by the player
  SkillLogStart(@"TRIGGER STARTED: end of player move");
  [skillManager triggerSkills:SkillTriggerPointEndOfPlayerMove withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  End of player move ENDED");
    BOOL enemyIsKilled = [self checkEnemyHealth];
    if (! enemyIsKilled)
    {
      BOOL playerIsKilled = (self.myPlayerObject.curHealth <= 0.0);
      if (playerIsKilled)
        [self checkMyHealth];
      else
        [self checkIfAnyMovesLeft];
    }
  }];
  
  
  
  _comboCount = 0;
}

- (void) reshuffleWithPrompt:(NSString*)prompt {
  CCLabelTTF *label = [CCLabelTTF labelWithString:prompt fontName:@"GothamBlack" fontSize:15];
  label.horizontalAlignment = CCTextAlignmentCenter;
  label.verticalAlignment = CCVerticalTextAlignmentCenter;
  label.position = ccp(self.orbLayer.contentSize.width/2, self.orbLayer.contentSize.height/2);
  label.opacity = 0.0;
  [self.orbLayer addChild:label];
  
  [label runAction:[CCActionSequence actions:
                                [CCActionCallBlock actionWithBlock:^{
                                  [self.orbLayer.bgdLayer turnTheLightsOff]; }],
                                [CCActionFadeIn actionWithDuration:0.3],
                                [CCActionDelay actionWithDuration:0.7f],
                                [CCActionCallBlock actionWithBlock:^{
                                  [self.orbLayer.bgdLayer turnTheLightsOn]; }],
                                [CCActionFadeOut actionWithDuration:0.3],
                                [CCActionRemove action], nil]];
}

- (void) reachedNextScene {
  
  [self.myPlayer stopWalking];
  
  if (self.enemyPlayerObject) {
    
    _hasStarted = YES;
    _reachedNextScene = YES;
    
    // Mark first turn as true only if not loaded from a save
    _firstTurn = YES;
    
    [self beginNextTurn]; // One of the two racing calls for beginNextTurn, _reachedNextScene used as a flag
    [self updateHealthBars];
    [self.currentEnemy doRarityTagShine];
  }
}

- (void) mobsterViewTapped:(id)sender
{
  UIButton* senderButton = sender;
  UserMonster* monster;
  if (senderButton.tag)
    monster = [self.myPlayerObject getIncompleteUserMonster];
  else
    monster = [self.enemyPlayerObject getIncompleteUserMonster];
  
  if (! monster)
    return;
  
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:monster allowSell:YES];
  UIViewController *parent = [GameViewController baseController];
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

#pragma mark - No Input Layer Methods

- (void) displayOrbLayer {
  [self.orbLayer runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.4f position:ccp(self.contentSize.width-self.orbLayer.contentSize.width/2-ORB_LAYER_DIST_FROM_SIDE, self.orbLayer.position.y)] rate:3]];
  [self.lootBgd runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.2f position:ccp(_lootBgd.contentSize.width/2 + 10, _lootBgd.position.y)] rate:3]];
  
  [SoundEngine puzzleOrbsSlideIn];
}

- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block {
  if (!block) {
    block = ^{};
  }
  
  CGPoint pos = ccp(self.contentSize.width+self.orbLayer.contentSize.width,
                    self.orbLayer.position.y);
  CGPoint lootPos = ccp(-self.lootBgd.contentSize.width/2, self.lootBgd.position.y);
  
  if (animated) {
    [self.orbLayer runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:0.3f position:pos],
      [CCActionCallBlock actionWithBlock:block], nil]];
    [self.lootBgd runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:0.3f position:lootPos], nil]];
  } else {
    self.orbLayer.position = pos;
    self.lootBgd.position = lootPos;
    block();
  }
}

#pragma mark - Hud views

#define DEPLOY_CENTER_X (self.contentSize.width-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE)/2

- (void) loadHudView {
  GameViewController *gvc = [GameViewController baseController];
  UIView *view = gvc.view;
  
  NSString *bundleName = ![Globals isSmallestiPhone] ? @"BattleHudView" : @"BattleHudViewSmall";
  [[NSBundle mainBundle] loadNibNamed:bundleName owner:self options:nil];
  self.hudView.frame = view.bounds;
  [view insertSubview:self.hudView aboveSubview:[CCDirector sharedDirector].view];
  
  // Make the bottom view flush with the board
  float bottomDist = ORB_LAYER_DIST_FROM_SIDE-2;
  self.hudView.bottomView.originY = self.hudView.bottomView.superview.height-self.hudView.bottomView.height-bottomDist;
  self.hudView.swapView.originY = self.hudView.swapView.superview.height-self.hudView.swapView.height-bottomDist;
  
  self.hudView.bottomView.centerX = DEPLOY_CENTER_X;
  
  UIImage *img = [Globals imageNamed:@"6movesqueuebgwide.png"];
  if (DEPLOY_CENTER_X*2 > img.size.width+bottomDist*2) {
    self.hudView.battleScheduleView.bgdView.image = img;
    self.hudView.battleScheduleView.width = img.size.width;
  }
  
  // Move schedule up in case board is too close to the edge so that it is flush with top of the board
  if (self.hudView.battleScheduleView.containerView.originY > bottomDist) {
    self.hudView.battleScheduleView.originX = bottomDist;
    self.hudView.battleScheduleView.originY = bottomDist-self.hudView.battleScheduleView.containerView.originY;
    
    self.hudView.elementButton.originY = self.hudView.battleScheduleView.originY+self.hudView.battleScheduleView.height-12;
  }
}

- (IBAction)swapClicked:(id)sender {
  if (_orbCount == 0 && !self.orbLayer.swipeLayer.isTrackingTouch) {
    [self.hudView removeSwapButtonAnimated:YES];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self.orbLayer disallowInput];
  
  [self.hudView.deployView updateWithBattlePlayers:self.myTeam];
  
  [self.hudView displayDeployViewToCenterX:DEPLOY_CENTER_X cancelTarget:cancel ? self : nil selector:@selector(cancelDeploy:)];
  
  [SoundEngine puzzleSwapWindow];
}


- (IBAction)cancelDeploy:(id)sender {
  [self deployBattleSprite:nil];
  [SoundEngine puzzleSwapWindow];
}

- (IBAction)deployCardClicked:(id)sender {
  while (![sender isKindOfClass:[BattleDeployCardView class]]) {
    sender = [sender superview];
  }
  BattleDeployCardView *card = (BattleDeployCardView *)sender;
  
  BattlePlayer *bp = nil;
  for (BattlePlayer *b in self.myTeam) {
    if (b.slotNum == card.tag && b.curHealth > 0) {
      bp = b;
    }
  }
  
  if (bp) {
    [self deployBattleSprite:bp];
  }
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  [self.hudView removeDeployView];
  BOOL isSwap = self.myPlayer != nil;
  if (bp && ![bp.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
    self.myPlayerObject = bp;
    
    [self createScheduleWithSwap:isSwap];
    
    if (isSwap) {
      [self makeMyPlayerWalkOutWithBlock:nil];
      [self.hudView removeButtons];
    }
    [self createNextMyPlayerSprite];
    
    // Skills trigger for player appeared
    SkillLogStart(@"TRIGGER STARTED: player initialized");
    [skillManager triggerSkills:SkillTriggerPointPlayerInitialized withCompletion:^(BOOL triggered, id params) {
      
      SkillLogEnd(triggered, @"  Player initialized trigger ENDED");
      
      // If it is swap, enemy should attack
      // If it is game start, wait till battle response has arrived
      // Otherwise, it is coming back from player just dying
      SEL selector = isSwap ? @selector(beginNextTurn) : !_hasStarted ? @selector(reachedNextScene) : @selector(beginNextTurn);
      [self makePlayer:self.myPlayer walkInFromEntranceWithSelector:selector];
      
    }];
    
  } else if (isSwap) {
    [self.hudView displaySwapButton];
    [self.orbLayer allowInput];
    [self.orbLayer.bgdLayer turnTheLightsOn];
  }
}

#pragma mark - Continue View Actions

- (IBAction)forfeitClicked:(id)sender {
  if (self.orbLayer.swipeLayer.userInteractionEnabled) {
    [GenericPopupController displayNegativeConfirmationWithDescription:@"You will lose everything - are you sure you want to forfeit?"
                                                                 title:@"Forfeit Battle"
                                                            okayButton:@"Forfeit"
                                                          cancelButton:@"Cancel"
                                                              okTarget:self
                                                            okSelector:@selector(youForfeited)
                                                          cancelTarget:nil
                                                        cancelSelector:nil];
  }
}

- (IBAction)winExitClicked:(id)sender {
  [self exitFinal];
  
  [SoundEngine generalButtonClick];
}

- (void) exitFinal {
  if (!_isExiting) {
    _isExiting = YES;
    
    [self.hudView removeButtons];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[self battleCompleteValues]];
    [self.delegate battleComplete:dict];
    
    // in case it hasnt stopped yet
    [Kamcord stopRecording];
  }
}

- (NSDictionary *) battleCompleteValues {
  return nil;
}

- (IBAction)shareClicked:(id)sender {
  [Kamcord stopRecording];
  [Kamcord showView];
  
  [SoundEngine generalButtonClick];
}

- (IBAction)continueClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int gemsAmount = [gl calculateGemCostToHealTeamDuringBattle:self.myTeam];
  
  if (gemsAmount > 0) {
    NSString *desc = [NSString stringWithFormat:@"Would you like to heal your entire team for %d gems?", gemsAmount];
    [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Heal Team?" gemCost:gemsAmount target:self selector:@selector(continueConfirmed)];
  } else {
    [self continueConfirmed];
  }
  
  [SoundEngine generalButtonClick];
}

- (void) continueConfirmed {
  [self.endView removeFromParent];
  
  [self displayDeployViewAndIsCancellable:NO];
  [self displayOrbLayer];
}

- (void) forceSkillClickOver:(DialogueViewController *)dvc {
  _forcedSkillDialogueViewController = dvc;
  
  [self.forcedSkillView removeFromSuperview];
  GameViewController *gvc = [GameViewController baseController];
  [gvc.view addSubview:self.forcedSkillView];
  
  [skillManager triggerSkills:SkillTriggerPointEnemyAppeared withCompletion:^(BOOL triggered, id params) {
    SkillBattleIndicatorView *enemyIndicatorView = [skillManager enemySkillIndicatorView];
    CGPoint enemyIndicatorPos = [skillManager enemySkillIndicatorPosition];
    enemyIndicatorPos = ccpAdd(enemyIndicatorPos, ccp(-enemyIndicatorView.contentSize.width, 0));
    CGPoint worldCCSpacePoint = [enemyIndicatorView.parent convertToWorldSpace:enemyIndicatorPos];
    CGPoint worldUISpace = [[CCDirector sharedDirector] convertToUI:worldCCSpacePoint];
    CGPoint localUISpace = [self.forcedSkillInnerView.superview convertPoint:worldUISpace fromView:[CCDirector sharedDirector].view];
    [self.forcedSkillInnerView setCenter:localUISpace];
    self.forcedSkillView.alpha = 0.f;
    self.forcedSkillView.hidden = NO;
    
    [Globals createUIArrowForView:self.forcedSkillButton atAngle:M_PI * .5f];
    
    [UIView animateWithDuration:0.3f delay:0.6f options:UIViewAnimationOptionCurveEaseIn animations:^{
      self.forcedSkillView.alpha = 1.f;
    } completion:nil];
    
  }];
  
}

- (IBAction)skillClicked:(id)sender {
  [[skillManager enemySkillIndicatorView] popupOrbCounter];
  [_forcedSkillDialogueViewController animateNext];
  [UIView animateWithDuration:0.3f animations:^{
    self.forcedSkillView.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.forcedSkillView.hidden = YES;
    
  }];
}

- (IBAction)sendButtonClicked:(id)sender {
  // Do nothing
}

@end

#pragma clang diagnostic pop
