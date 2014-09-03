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

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define BALLIN_SCORE 400
#define CANTTOUCHTHIS_SCORE 540
#define HAMMERTIME_SCORE 720
#define MAKEITRAIN_SCORE 900

#define STRENGTH_FOR_MAX_SHOTS MAKEITRAIN_SCORE

#define PUZZLE_BGD_TAG 1456

#define NO_INPUT_LAYER_OPACITY 0.6f

#define BGD_SCALE 1.f//((self.contentSize.width-480)/88.f*0.3+1.f)

#define COMBO_FIRE_TAG @"ComboFire"

@implementation BattleBgdLayer

- (id) initWithPrefix:(NSString *)prefix {
  if ((self = [super init])) {
    self.prefix = prefix;
    [self addNewScene];
  }
  return self;
}

- (void) scrollToNewScene {
  // Get max y pos
  float maxY = _curBasePoint.y;
  
  // Base Y will be negative
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float nextBaseY = self.position.y-Y_MOVEMENT_FOR_NEW_SCENE;
  int numScenesToAdd = ceilf((-1*nextBaseY+self.parent.contentSize.height-maxY)/offsetPerScene.y);
  for (int i = 0; i < numScenesToAdd; i++) {
    [self addNewScene];
  }
  
  float nextBaseX = self.position.x-Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y;
  [self runAction:[CCActionSequence actions:
                   [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:ccp(nextBaseX, nextBaseY)],
                   [CCActionCallFunc actionWithTarget:self selector:@selector(removePastScenes)],
                   [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(reachedNextScene)],
                   nil]];
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
  CCSprite *left1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene1left.png"]];
  CCSprite *right1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene1right.png"]];
  
  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
  right1.position = ccp(left1.position.x+left1.contentSize.width/2+right1.contentSize.width/2,
                        left1.position.y);
  
  [self addChild:left1];
  [self addChild:right1];
  
  CCSprite *left2 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene2left.png"]];
  CCSprite *right2 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene2right.png"]];
  
  left2.position = ccp(pos.x+left2.contentSize.width/2+POINT_OFFSET_PER_SCENE.x/2,
                       left1.position.y+left1.contentSize.height/2+left2.contentSize.height/2);
  right2.position = ccp(left2.position.x+left2.contentSize.width/2+right2.contentSize.width/2,
                        left2.position.y);
  
  [self addChild:left2];
  [self addChild:right2];
}

@end

@implementation NewBattleLayer

#pragma mark - Setup

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize {
  return [self initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:gridSize bgdPrefix:@"1"];
}

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix {
  if ((self = [super init])) {
    _puzzleIsOnLeft = puzzleIsOnLeft;
    _gridSize = gridSize.width ? gridSize : CGSizeMake(8, 8);
    
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonster *um in monsters) {
      [arr addObject:[BattlePlayer playerWithMonster:um]];
    }
    self.myTeam = arr;
    
    self.contentSize = [CCDirector sharedDirector].viewSize;
    
    [self initOrbLayer];
    
    OrbMainLayer *puzzleBg = self.orbLayer;
    float puzzX = puzzleIsOnLeft ? puzzleBg.contentSize.width/2+14 : self.contentSize.width-puzzleBg.contentSize.width/2-14;
    puzzleBg.position = ccp(puzzX, puzzleBg.contentSize.height/2+16);
    
    self.noInputLayer = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4f:ccc4f(0, 0, 0, NO_INPUT_LAYER_OPACITY)] width:self.orbLayer.contentSize.width height:self.orbLayer.contentSize.height];
    [self.orbLayer addChild:self.noInputLayer z:self.orbLayer.swipeLayer.zOrder];
    self.noInputLayer.position = self.orbLayer.swipeLayer.position;
    
    self.bgdContainer = [CCNode node];
    self.bgdContainer.contentSize = self.contentSize;
    [self addChild:self.bgdContainer z:0];
    
    bgdPrefix = bgdPrefix.length ? bgdPrefix : @"1";
    self.bgdLayer = [[BattleBgdLayer alloc] initWithPrefix:bgdPrefix];
    [self.bgdContainer addChild:self.bgdLayer z:-100];
    self.bgdLayer.position = BGD_LAYER_INIT_POSITION;
    if (_puzzleIsOnLeft) self.bgdLayer.position = ccpAdd(BGD_LAYER_INIT_POSITION, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    self.bgdLayer.delegate = self;
    
    // Scale the bgdContainer
    CGPoint basePt = CENTER_OF_BATTLE;
    if (_puzzleIsOnLeft) basePt = ccpAdd(CENTER_OF_BATTLE, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    CGPoint beforeScale = [self.bgdContainer convertToNodeSpace:basePt];
    self.bgdContainer.scale = BGD_SCALE;
    CGPoint afterScale = [self.bgdContainer convertToNodeSpace:basePt];
    CGPoint diff = ccpSub(afterScale, beforeScale);
    self.bgdContainer.position = ccpAdd(self.bgdContainer.position, ccpMult(diff, self.bgdContainer.scale));
    
#ifdef MOBSTERS
    [skillManager updateBattleLayer:self];
#endif
    
    [self setupUI];
    
    _canPlayNextComboSound = YES;
    _canPlayNextGemPop = YES;
    
    [self loadHudView];
    [self removeOrbLayerAnimated:NO withBlock:nil];
  }
  return self;
}

- (void) initOrbLayer {
  OrbMainLayer *ol = [[OrbMainLayer alloc] initWithGridSize:_gridSize numColors:6];
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  [self begin];
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  [self.orbLayer.bgdLayer addChild:clip z:self.orbLayer.swipeLayer.zOrder];
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
  if (self.myPlayerObject && self.enemyPlayerObject) {
    BattleSchedule *sched = [[BattleSchedule alloc] initWithBattlePlayerA:self.myPlayerObject battlePlayerB:self.enemyPlayerObject justSwapped:swap];
    self.battleSchedule = sched;
    
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
  float startX = -player.contentSize.width;
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
       [self performSelector:selector withObject:player];
     }],
    nil]];
}

- (void) moveToNextEnemy {
  [self.hudView removeButtons];
  
  _curStage++;
  if (_curStage < self.enemyTeam.count) {
    [self.myPlayer beginWalking];
    [self.bgdLayer scrollToNewScene];
    
    [self spawnNextEnemy];
    [self displayWaveNumber];
    
    _reachedNextScene = NO;
    _displayedWaveNumber = NO;
  } else {
    if (_lootDropped) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
      
      [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallFunc actionWithTarget:self selector:@selector(youWon)], nil]];
    } else {
      [self youWon];
    }
  }
}

- (void) spawnNextEnemy {
  [self createNextEnemyObject];
  [self createNextEnemySprite];
  
  CGPoint finalPos = ENEMY_PLAYER_LOCATION;
  if (_puzzleIsOnLeft) finalPos = ccpAdd(finalPos, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
  
  self.currentEnemy.position = newPos;
  [self.currentEnemy runAction:[CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos]];
  
  [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
  self.currentEnemy.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255,255,255)];
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

- (void) createNextEnemyObject {
  if (self.enemyTeam.count > _curStage) {
    self.enemyPlayerObject = [self.enemyTeam objectAtIndex:_curStage];
    
    [self createScheduleWithSwap:NO];
  } else {
    self.enemyPlayerObject = nil;
  }
  
  // Setup SkillManager for enemy
#ifdef MOBSTERS
  if ( _enemyPlayerObject )
  {
    [skillManager updateEnemy:_enemyPlayerObject andSprite:_currentEnemy];
    if (skillManager.enemySkillType != SkillTypeNoSkill)
    {
      BOOL existedBefore = (_skillIndicatorEnemy != nil && _skillIndicatorEnemy.parent);
      if ( existedBefore )
        [_skillIndicatorEnemy removeFromParent];
      _skillIndicatorEnemy = [[SkillBattleIndicatorView alloc] initWithSkillController:skillManager.enemySkillController];
      if (_skillIndicatorEnemy)
      {
        _skillIndicatorEnemy.position = CGPointMake(_skillIndicatorEnemy.contentSize.width/2, 120 - (UI_DEVICE_IS_IPHONE_4 ? 10 : 0));
        [_skillIndicatorEnemy update];
        [self.orbLayer addChild:_skillIndicatorEnemy z:-10];
        [_skillIndicatorEnemy appear:existedBefore];
      }
    }
  }
  else
  {
    if (_skillIndicatorEnemy)
      [_skillIndicatorEnemy disappear];
  }
#endif
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

- (void) beginNextTurn {
  if (_displayedWaveNumber && _reachedNextScene) {
    BOOL shouldDelay = NO;
    if (_shouldDisplayNewSchedule) {
      NSArray *bools = [self.battleSchedule getNextNMoves:self.hudView.battleScheduleView.numSlots];
      NSMutableArray *ids = [NSMutableArray array];
      NSMutableArray *enemyBands = [NSMutableArray array];
      for (NSNumber *num in bools) {
        BOOL val = num.boolValue;
        if (val) {
          [ids addObject:@(self.myPlayerObject.monsterId)];
          [enemyBands addObject:@NO];
        } else {
          [ids addObject:@(self.enemyPlayerObject.monsterId)];
          [enemyBands addObject:@(self.enemyPlayerObject.element == self.myPlayerObject.element)];
        }
      }
      [self.hudView.battleScheduleView setOrdering:ids showEnemyBands:enemyBands];
      
      _shouldDisplayNewSchedule = NO;
      shouldDelay = YES;
      
      [self.hudView displayBattleScheduleView];
      
    } else {
      // If nth is YES, this is your move, otherwise enemy's move
      BOOL nth = [self.battleSchedule getNthMove:self.hudView.battleScheduleView.numSlots-1];
      int monsterId = nth ? self.myPlayerObject.monsterId : self.enemyPlayerObject.monsterId;
      BOOL showEnemyBand = nth ? NO : self.enemyPlayerObject.element == self.myPlayerObject.element;
      [self.hudView.battleScheduleView addMonster:monsterId showEnemyBand:showEnemyBand];
    }
    
    self.hudView.bottomView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
      self.hudView.waveNumLabel.alpha = 1.f;
    }];
    
    BOOL nextMove = [self.battleSchedule dequeueNextMove];
    if (nextMove) {
      [self beginMyTurn];
    } else {
      [self runAction:[CCActionSequence actions:
                       [CCActionDelay actionWithDuration:shouldDelay ? 1.3f : 1.f],
                       [CCActionCallBlock actionWithBlock:
                        ^{
                          [self beginEnemyTurn];
                        }], nil]];
    }
  }
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
  [self removeNoInputLayer];
  [self.orbLayer allowInput];
  
  [self.hudView prepareForMyTurn];
}

- (void) beginEnemyTurn {
  [self.hudView removeButtons];
  
  _enemyDamageDealt = [self.enemyPlayerObject randomDamage];
  _enemyDamageDealt = _enemyDamageDealt*[self damageMultiplierIsEnemyAttacker:YES];
  
  [self.currentEnemy performNearAttackAnimationWithEnemy:self.myPlayer target:self selector:@selector(dealEnemyDamage)];
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
    [self.orbLayer allowInput];
    _myDamageForThisTurn = 0;
  }
}

- (void) myTurnEnded {
  [self showHighScoreWord];
  [self displayNoInputLayer];
  [self.hudView removeButtons];
  
  self.movesLeftLabel.string = [NSString stringWithFormat:@"%d", _movesLeft];
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(doMyAttackAnimation)];
}

- (void) doMyAttackAnimation {
  int currentScore = _myDamageDealt/(float)[self.myPlayerObject totalAttackPower]*100.f;
  
  if (currentScore > 0) {
    if (currentScore > MAKEITRAIN_SCORE) {
      [self.myPlayer restoreStandingFrame];
      [self spawnPlaneWithTarget:nil selector:nil];
    }
    
    float strength = MIN(1, currentScore/(float)STRENGTH_FOR_MAX_SHOTS);
    [self.myPlayer performFarAttackAnimationWithStrength:strength enemy:self.currentEnemy target:self selector:@selector(dealMyDamage)];
  } else {
    [self beginNextTurn];
  }
}

- (void) dealMyDamage {
  _myDamageDealt = _myDamageDealt*[self damageMultiplierIsEnemyAttacker:NO];
  _enemyShouldAttack = YES;
  [self dealDamage:_myDamageDealt enemyIsAttacker:NO usingAbility:NO withTarget:self withSelector:@selector(checkEnemyHealthAndStartNewTurn)];
  
  float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
  if (perc < PULSE_CONT_THRESH) {
    [self pulseHealthLabel:YES];
  } else {
    [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
    self.currentEnemy.healthLabel.color = [CCColor whiteColor];
  }
}

- (void) dealEnemyDamage {
  _totalDamageTaken += _enemyDamageDealt;
  [self dealDamage:_enemyDamageDealt enemyIsAttacker:YES usingAbility:NO withTarget:self withSelector:@selector(checkMyHealth)];
  
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
  int newHealth = MIN(def.maxHealth, MAX(0, curHealth-damageDone));
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
                         }],
                        [CCActionCallFunc actionWithTarget:target selector:selector],
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
    [self displayEffectivenessForAttackerElement:att.element defenderElement:def.element position:pos];
  }
  
  def.curHealth = newHealth;
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

- (void) sendServerUpdatedValues {
  if (_enemyDamageDealt) {
    [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:self.myPlayerObject.userMonsterId curHealth:self.myPlayerObject.curHealth];
  }
}

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block {
  [sprite runAction:[CCActionSequence actions:
                     [RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                     [CCActionDelay actionWithDuration:0.7f],
                     [CCActionCallFunc actionWithTarget:sprite selector:@selector(removeFromParent)],
                     [CCActionCallBlock actionWithBlock:block], nil]];
  
  CCParticleSystem *q = [CCParticleSystem particleWithFile:@"characterdie.plist"];
  q.autoRemoveOnFinish = YES;
  q.position = ccpAdd(sprite.position, ccp(0, sprite.contentSize.height/2-5));
  [self.bgdContainer addChild:q z:2];
  
  [SoundEngine puzzleMonsterDefeated];
}

- (BOOL) checkEnemyHealth {
  
  if (self.enemyPlayerObject.curHealth <= 0) {
    CCSprite *loot = [self getCurrentEnemyLoot];
    if (loot) {
      [self dropLoot:loot];
      _lootDropped = YES;
    } else {
      _lootDropped = NO;
    }
    
#ifdef MOBSTERS
    if (_skillIndicatorEnemy && _skillIndicatorEnemy.parent)
      [_skillIndicatorEnemy disappear];
#endif
    
    [self blowupBattleSprite:self.currentEnemy withBlock:
     ^{
       self.enemyPlayerObject = nil;
       [self updateHealthBars];
       [self moveToNextEnemy];
     }];
    self.currentEnemy = nil;
    
    [self.hudView removeBattleScheduleView];
    
    // Send server updated values here because monster just died
    // But make sure that I actually did damage..
    [self sendServerUpdatedValues];
    
    return YES;
  }
  
  return NO;
}

- (void) checkEnemyHealthAndStartNewTurn {
  BOOL enemyIsDead = [self checkEnemyHealth];
  if (! enemyIsDead)
  {
    if (_enemyShouldAttack) {
      [self beginNextTurn];
    }
  }
}

- (CCSprite *) getCurrentEnemyLoot {
  // Should be implemented
  return nil;
}

- (void) checkMyHealth {
  [self sendServerUpdatedValues];
  if (self.myPlayerObject.curHealth <= 0) {
    [self stopPulsing];
    
    [self blowupBattleSprite:self.myPlayer withBlock:^{
      self.myPlayerObject = nil;
      [self updateHealthBars];
      
      [self currentMyPlayerDied];
    }];
    self.myPlayer = nil;
  } else {
    [self beginNextTurn];
  }
}

- (void) currentMyPlayerDied {
  BOOL someoneIsAlive = NO;
  for (BattlePlayer *bp in self.myTeam) {
    if (bp.curHealth > 0) {
      someoneIsAlive = YES;
    }
  }
  
  if (someoneIsAlive) {
    [self displayDeployViewAndIsCancellable:NO];
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
  spr.scaleX = self.contentSize.width-label.position.x*2-self.orbLayer.contentSize.width-30;
  spr.anchorPoint = ccp(0, 0.5);
  spr.position = ccpAdd(label.position, ccp(0, -label.contentSize.height/2-8));
  
  
  CCSprite *bgdIcon = [CCSprite spriteWithImageNamed:@"youwonitembg.png"];
  [self addChild:bgdIcon z:z];
  bgdIcon.anchorPoint = ccp(0, 0.5);
  bgdIcon.position = ccpAdd(label.position, ccp(0, -58));
  
  if (self.enemyPlayerObject.spritePrefix.length) {
    CCSprite *inside = [CCSprite spriteWithImageNamed:[self.enemyPlayerObject.spritePrefix stringByAppendingString:@"Card.png"]];
    [bgdIcon addChild:inside];
    inside.position = ccp(bgdIcon.contentSize.width/2, bgdIcon.contentSize.height/2);
    inside.scale = bgdIcon.contentSize.height/inside.contentSize.height;
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
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [self pickUpLoot:ed];
                   }],
                  nil], nil]];
}

- (void) pickUpLoot:(CCSprite *)ed {
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
    [self addChild:l z:1];
    [l runAction:[CCActionSequence actions:
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0.6f],
                  [CCActionDelay actionWithDuration:1.1],
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [l removeFromParentAndCleanup:YES];
                   }], nil]];
    
    [self addChild:phrase z:3];
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

- (void) spawnRibbonForOrb:(BattleOrb *)orb {
  
  // Create random bezier
  if (orb.orbColor != OrbColorNone) {
    ccBezierConfig bez;
    bez.endPosition = [self.orbLayer convertToNodeSpace:[self.bgdContainer convertToWorldSpace:ccpAdd(self.myPlayer.position, ccp(0, self.myPlayer.contentSize.height/2))]];
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
    
    // Transforms are applied in reverse order!! So rotate, then scale
    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), xScale, yScale);
    bez.controlPoint_1 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt1, t));
    bez.controlPoint_2 = ccpAdd(initPoint, CGPointApplyAffineTransform(basePt2, t));
    
    CCActionBezierTo *move = [CCActionBezierTo actionWithDuration:0.25f+xScale/600.f bezier:bez];
    DestroyedOrb *dg = [[DestroyedOrb alloc] initWithColor:[self.orbLayer.swipeLayer colorForSparkle:orb.orbColor]];
    [self.orbLayer addChild:dg z:10];
    dg.position = initPoint;
    [dg runAction:[CCActionSequence actions:move,
                   [CCActionFadeOut actionWithDuration:0.5f],
                   [CCActionDelay actionWithDuration:0.7f],
                   [CCActionCallFunc actionWithTarget:dg selector:@selector(removeFromParent)], nil]];
  }
}

- (void) youWon {
  [CCBReader load:@"BattleWonView" owner:self];
  [self endBattle:YES];
}

- (void) youLost {
  [CCBReader load:@"BattleLostView" owner:self];
  [self endBattle:NO];
}

- (void) youForfeited {
  [self youLost];
}

- (void) endBattle:(BOOL)won {
  _wonBattle = won;
  
  [self.hudView removeButtons];
  [self.hudView removeBattleScheduleView];
  self.hudView.bottomView.hidden = YES;
  
  [self removeOrbLayerAnimated:YES withBlock:^{
    [SoundEngine puzzleWinLoseUI];
    if (won) {
      [self addChild:self.wonView z:10000];
      
      self.wonView.anchorPoint = ccp(0.5, 0.5);
      self.wonView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
      
      [SoundEngine puzzleYouWon];
    } else {
      [self addChild:self.lostView z:10000];
      self.lostView.anchorPoint = ccp(0.5, 0.5);
      if ([self shouldShowContinueButton]) [self.lostView.shareButton removeFromParent];
      else [self.lostView.continueButton removeFromParent];
      self.lostView.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
      
      [SoundEngine puzzleYouLose];
    }
  }];
}

- (BOOL) shouldShowContinueButton {
  return NO;
}

#pragma mark - Blood Splatter

- (CCSprite *) bloodSplatter {
  if (!_bloodSplatter) {
    CCSprite *s = [CCSprite spriteWithImageNamed:@"bloodsplatter.png"];
    [self addChild:s z:1];
    s.opacity = 0.f;
    s.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
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
  [self.hudView removeSwapButton];
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

#ifdef MOBSTERS
  [skillManager orbDestroyed:orb.orbColor];
  if (_skillIndicatorPlayer)
    [_skillIndicatorPlayer update];
  if (_skillIndicatorEnemy)
    [_skillIndicatorEnemy update];
#endif
  
  // Update tile
  BattleTile* tile = [self.orbLayer.layout tileAtColumn:orb.column row:orb.row];
  
  // Increment damage, create label and ribbon
  if (tile.allowsDamage)
  {
    int dmg = [self.myPlayerObject damageForColor:color];
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
      
      [self spawnRibbonForOrb:orb];
    }
  }
  
  // Update tile
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
  if (_myDamageForThisTurn == 0) {
    [self.orbLayer allowInput];
    return;
  }
  
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
  
#ifdef MOBSTERS
  // Trying to apply the skills after this move if ready
  [skillManager triggerSkillAfterMoveWithBlock:^(BOOL enemyKilled) {
    if (_skillIndicatorPlayer)
      [_skillIndicatorPlayer update];
    if (_skillIndicatorEnemy)
      [_skillIndicatorEnemy update];
    if (! enemyKilled)
      [self checkIfAnyMovesLeft];
  }];
#else
  [self checkIfAnyMovesLeft];
#endif
  
  _comboCount = 0;
}

- (void) reshuffle {
  CCLabelTTF *label = [CCLabelTTF labelWithString:@"No more moves!\nShuffling..." fontName:@"GothamBlack" fontSize:20];
  label.horizontalAlignment = CCTextAlignmentCenter;
  label.verticalAlignment = CCVerticalTextAlignmentCenter;
  label.position = ccp(self.noInputLayer.contentSize.width/2, self.noInputLayer.contentSize.height/2);
  [self.noInputLayer addChild:label];
  
  [self.noInputLayer stopAllActions];
  self.noInputLayer.opacity = NO_INPUT_LAYER_OPACITY;
  [self.noInputLayer runAction:[CCActionSequence actions:
                                [CCActionDelay actionWithDuration:0.7f],
                                [RecursiveFadeTo actionWithDuration:0.3 opacity:0],
                                [CCActionCallFunc actionWithTarget:label selector:@selector(removeFromParent)], nil]];
}

- (void) reachedNextScene {
  _hasStarted = YES;
  _reachedNextScene = YES;
  [self.myPlayer stopWalking];
  
  if (self.enemyPlayerObject) {
    [self beginNextTurn];
    [self updateHealthBars];
    [self.currentEnemy doRarityTagShine];
  }
}

#pragma mark - No Input Layer Methods

- (void) displayNoInputLayer {
  [self.noInputLayer runAction:[CCActionFadeTo actionWithDuration:0.3 opacity:NO_INPUT_LAYER_OPACITY]];
}

- (void) removeNoInputLayer {
  [self.noInputLayer stopAllActions];
  [self.noInputLayer runAction:[CCActionFadeTo actionWithDuration:0.3 opacity:0]];
}

- (void) displayOrbLayer {
  [self.orbLayer runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.4f position:ccp(self.contentSize.width-self.orbLayer.contentSize.width/2-14, self.orbLayer.position.y)] rate:3]];
  [self.lootBgd runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.4f position:ccp(_lootBgd.contentSize.width/2 + 10, _lootBgd.position.y)] rate:3]];
  
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

- (void) loadHudView {
  GameViewController *gvc = [GameViewController baseController];
  UIView *view = gvc.view;
  
  NSString *bundleName = [Globals isLongiPhone] ? @"BattleHudView" : @"BattleHudViewSmall";
  [[NSBundle mainBundle] loadNibNamed:bundleName owner:self options:nil];
  [view insertSubview:self.hudView aboveSubview:[CCDirector sharedDirector].view];
}

- (IBAction)swapClicked:(id)sender {
  if (_orbCount == 0 && !self.orbLayer.swipeLayer.isTrackingTouch) {
    [self.hudView removeSwapButton];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self displayNoInputLayer];
  [self.orbLayer disallowInput];
  
  [self.hudView.deployView updateWithBattlePlayers:self.myTeam];
  
  float extra = [Globals isLongiPhone] ? self.movesBgd.contentSize.width : 0;
  float centerX = (self.contentSize.width-self.orbLayer.contentSize.width-extra-14)/2;
  [self.hudView displayDeployViewToCenterX:centerX cancelTarget:self selector:@selector(cancelDeploy:)];
  
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
  if (bp && bp.userMonsterId != self.myPlayerObject.userMonsterId) {
    self.myPlayerObject = bp;
    
    [self createScheduleWithSwap:isSwap];
    
    if (isSwap) {
      [self makeMyPlayerWalkOutWithBlock:nil];
      [self.hudView removeButtons];
    }
    [self createNextMyPlayerSprite];
    
    // If it is swap, enemy should attack
    // If it is game start, wait till battle response has arrived
    // Otherwise, it is coming back from player just dying
    SEL selector = isSwap ? @selector(beginNextTurn) : !_hasStarted ? @selector(reachedNextScene) : @selector(beginNextTurn);
    [self makePlayer:self.myPlayer walkInFromEntranceWithSelector:selector];
  } else if (isSwap) {
    [self.hudView displaySwapButton];
    [self.orbLayer allowInput];
    [self removeNoInputLayer];
  }
  
#ifdef MOBSTERS
  // Setup SkillManager for the player
  if (_skillIndicatorPlayer)
    [_skillIndicatorPlayer removeFromParentAndCleanup:YES];
  if (_myPlayer)
  {
    [skillManager updatePlayer:_myPlayerObject andSprite:_myPlayer];
    if (skillManager.playerSkillType != SkillTypeNoSkill)
    {
      _skillIndicatorPlayer = [[SkillBattleIndicatorView alloc] initWithSkillController:skillManager.playerSkillController];
      if (_skillIndicatorPlayer)
      {
        _skillIndicatorPlayer.position = CGPointMake(-_skillIndicatorPlayer.contentSize.width/2, 60 - (UI_DEVICE_IS_IPHONE_4 ? 5 : 0));
        [_skillIndicatorPlayer update];
        [self.orbLayer addChild:_skillIndicatorPlayer z:-10];
      }
    }
  }
#endif
}

#pragma mark - Continue View Actions

- (IBAction)forfeitClicked:(id)sender {
  if (_movesLeft > 0) {
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
  _manageWasClicked = NO;
  [self exitFinal];
  
  [SoundEngine generalButtonClick];
}

- (IBAction)manageClicked:(id)sender {
  _manageWasClicked = YES;
  [self exitFinal];
  
  [SoundEngine generalButtonClick];
}

- (void) exitFinal {
  if (!_isExiting) {
    _isExiting = YES;
    
    [self.hudView removeButtons];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(_manageWasClicked), BATTLE_MANAGE_CLICKED_KEY, nil];
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
  [self.lostView removeFromParent];
  
  [self displayDeployViewAndIsCancellable:NO];
  [self displayOrbLayer];
}

@end

#pragma clang diagnostic pop
