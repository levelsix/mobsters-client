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
#import "BattleItemSelectViewController.h"
#import "ClientProperties.h"
#import "ShopViewController.h"

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
  CCSprite *left1 = [CCSprite spriteWithImageNamed:[self.prefix stringByAppendingString:@"scene.jpg"]];
  
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
  [self addChild:clip z:100];
  clip.contentSize = CGSizeMake(_comboBgd.contentSize.width*2, _comboBgd.contentSize.height*3);
  clip.anchorPoint = ccp(1, 0.5);
  clip.position = ccp(self.position.x+self.contentSize.width, ORB_LAYER_DIST_FROM_SIDE+54);
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
  [self.forcedSkillView removeFromSuperview];
  [self.popoverViewController closeClicked:nil];
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
  
  [self.hudView.battleScheduleView setBattleSchedule:self.battleSchedule];
}

- (void) begin {
  if (!_isResumingState)
    [skillManager flushPersistentSkills];
  
  BattlePlayer *bp = [self firstMyPlayer];
  if (bp) {
    [self deployBattleSprite:bp];
  }
  
  [Kamcord startRecording];
}

- (void) setupUI {
  /*
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
   */
  
  
  _lootBgd = [CCSprite spriteWithImageNamed:@"collectioncapsule.png"];
  [self addChild:_lootBgd];
  _lootBgd.opacity = 0.f;
  
  _lootLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Ziggurat-HTF-Black" fontSize:10];
  [_lootBgd addChild:_lootLabel];
  _lootLabel.color = [CCColor blackColor];
  _lootLabel.rotation = -20.f;
  _lootLabel.position = ccp(_lootBgd.contentSize.width-13, _lootBgd.contentSize.height/2-1);
  _lootLabel.opacity = 0.f;
  
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
  
  _curStage = -1;
  
  _movesLeftHidden = YES;
  
  [self updateHealthBars];
}

- (void) setMovesLeft:(int)movesLeft animated:(BOOL)animated
{
  if (self.myPlayer)
  {
    if (!self.movesLeftContainer)
    {
      self.movesLeftContainer = [CCSprite spriteWithImageNamed:@"movescounterbg.png"];
        [self.movesLeftContainer setAnchorPoint:ccp(.5f, 0.f)];
        [self.movesLeftContainer setPosition:ccp(self.myPlayer.contentSize.width * .5f, self.myPlayer.contentSize.height + 15.f)];
        [self.movesLeftContainer setOpacity:0.f];
        [self.myPlayer addChild:self.movesLeftContainer z:150];
      self.movesLeftLabel = [CCSprite spriteWithImageNamed:@"movelabelmoves.png"];
        [self.movesLeftLabel setAnchorPoint:ccp(0.f, .5f)];
        [self.movesLeftLabel setPosition:ccp(self.movesLeftContainer.contentSize.width * .5f - 15.f, self.movesLeftContainer.contentSize.height * .5f - 1.f)];
        [self.movesLeftLabel setOpacity:0.f];
        [self.movesLeftContainer addChild:self.movesLeftLabel];
      self.movesLeftCounter = [CCSprite spriteWithImageNamed:@"3moveslabel.png"];
        [self.movesLeftCounter setAnchorPoint:ccp(1.f, .5f)];
        [self.movesLeftCounter setPosition:ccp(self.movesLeftContainer.contentSize.width * .5f - 15.f, self.movesLeftContainer.contentSize.height * .5f - 1.f)];
        [self.movesLeftCounter setOpacity:0.f];
        [self.movesLeftContainer addChild:self.movesLeftCounter];
      self.myPlayer.movesCounter = self.movesLeftContainer;
    }
    
    if (movesLeft > 0) // Note: Max turns we have an asset for is 10
    {
      NSString* img = (movesLeft == 1) ? @"movelabelmove.png" : @"movelabelmoves.png";
      [self.movesLeftLabel setSpriteFrame:[CCSpriteFrame frameWithImageNamed:img]];

      const BOOL containerHidden = self.movesLeftContainer.opacity < 1.f;
      if (animated && !containerHidden)
      {
        [self.movesLeftCounter runAction:[CCActionSequence actions:
                                          [CCActionSpawn actions:
                                           [CCActionMoveBy actionWithDuration:.3f position:ccp(0.f, -15.f)],
                                           [CCActionFadeOut actionWithDuration:.3f], nil],
                                          [CCActionRemove action], nil]];
        
        NSString* img = [NSString stringWithFormat:@"%dmoveslabel.png", movesLeft];
        self.movesLeftCounter = [CCSprite spriteWithImageNamed:img];
          [self.movesLeftCounter setAnchorPoint:ccp(1.f, .5f)];
          [self.movesLeftCounter setPosition:ccp(self.movesLeftContainer.contentSize.width * .5f - 15.f, self.movesLeftContainer.contentSize.height * .5f - 1.f + 15.f)];
          [self.movesLeftContainer addChild:self.movesLeftCounter];
          [self.movesLeftCounter runAction:[CCActionSequence actions:
                                            [CCActionSpawn actions:
                                             [CCActionMoveBy actionWithDuration:.3f position:ccp(0.f, -15.f)],
                                             [CCActionFadeIn actionWithDuration:.3f], nil], nil]];
      }
      else
      {
        NSString* img = [NSString stringWithFormat:@"%dmoveslabel.png", movesLeft];
        [self.movesLeftCounter setSpriteFrame:[CCSpriteFrame frameWithImageNamed:img]];
      }
    }
    
    if (movesLeft == 0 && !_movesLeftHidden)
      [self hideMovesLeft:YES withCompletion:^{ _movesLeftHidden = YES; }];
    if (movesLeft > 0 && _movesLeftHidden)
      [self hideMovesLeft:NO withCompletion:^{ _movesLeftHidden = NO; }];
  }
  
  _movesLeft = movesLeft;
}

- (void) hideMovesLeft:(BOOL)hide withCompletion:(void(^)())completion
{
  if (self.movesLeftContainer)
  {
    for (CCNode* child in self.movesLeftContainer.children)
      [self hideMovesLeft:hide node:child withCompletion:^{}];
    [self hideMovesLeft:hide node:self.movesLeftContainer withCompletion:completion];
  }
  else
    completion();
}

- (void) hideMovesLeft:(BOOL)hide node:(CCNode*)node withCompletion:(void(^)())completion
{
  if ((hide && node.opacity == 1.f) || (!hide && node.opacity == 0.f))
  {
    [node runAction:[CCActionSequence actions:
                     hide ? [CCActionFadeOut actionWithDuration:.3f] : [CCActionFadeIn actionWithDuration:.3f],
                     [CCActionCallBlock actionWithBlock:completion], nil]];
  }
  else
    completion();
}

- (void) mobsterInfoDisplayed:(BOOL)displayed onSprite:(BattleSprite*)sprite
{
  if (sprite == self.myPlayer && !_movesLeftHidden)
  {
    [self hideMovesLeft:displayed withCompletion:^{}];
  }
}

- (CGPoint) myPlayerLocation {
  return MY_PLAYER_LOCATION;
}

- (void) createNextMyPlayerSprite {
  [self hideMovesLeft:YES withCompletion:^{
    [self.movesLeftContainer removeFromParent];
    _movesLeftHidden = YES;
  }];
  
  BattleSprite *mp = [[BattleSprite alloc] initWithPrefix:self.myPlayerObject.spritePrefix nameString:self.myPlayerObject.attrName rarity:self.myPlayerObject.rarity animationType:self.myPlayerObject.animationType isMySprite:YES verticalOffset:self.myPlayerObject.verticalOffset];
  mp.battleLayer = self;
  mp.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)self.myPlayerObject.element];
  [self.bgdContainer addChild:mp z:1];
  mp.position = [self myPlayerLocation];
  if (_puzzleIsOnLeft) mp.position = ccpAdd(mp.position, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
  mp.isFacingNear = NO;
  self.myPlayer = mp;
  self.movesLeftContainer = nil;
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
  [self removeButtons];
  
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
    if ([Globals isiPad]) {
      newPos = ccpAdd(newPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
    }
    
    self.currentEnemy.position = newPos;
    [self.currentEnemy runAction:[CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE * ([Globals isiPad] ? 2 : 1) position:finalPos]];
    
    if ([Globals isiPad])
      self.currentEnemy.ipadEnterBufferFlag = YES;
    
    [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
    self.currentEnemy.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255,255,255)];
    
    [self triggerSkillForEnemyCreatedWithBlock:^{
      [self createScheduleWithSwap:NO playerHitsFirst:_dungeonPlayerHitsFirst];
    }];
  }
  
  return success;
}

- (void) triggerSkillForEnemyCreatedWithBlock:(dispatch_block_t)block {
  SkillLogStart(@"TRIGGER STARTED: enemy initialized");
  [skillManager triggerSkills:SkillTriggerPointEnemyInitialized withCompletion:^(BOOL triggered, id params) {
    SkillLogEnd(triggered, @"  Enemy initialized trigger ENDED");
    if (block) {
      block();
    }
  }];
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
  bs.battleLayer = self;
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
  
  self.hudView.enemyNameLabel.attributedText = [self upperCaseAttributedStringFromAttributedString:self.enemyPlayerObject.attrName];
  
}

// Copied from http://stackoverflow.com/questions/6716699/how-to-change-characters-case-to-upper-in-nsattributedstring
// All because NSAttributedString won't let you access the string. Fuck me, right?
- (NSAttributedString *)upperCaseAttributedStringFromAttributedString:(NSAttributedString *)inAttrString {
  // Make a mutable copy of your input string
  NSMutableAttributedString *attrString = [inAttrString mutableCopy];
  
  // Make an array to save the attributes in
  NSMutableArray *attributes = [NSMutableArray array];
  
  // Add each set of attributes to the array in a dictionary containing the attributes and range
  [attrString enumerateAttributesInRange:NSMakeRange(0, [attrString length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
    [attributes addObject:@{@"attrs":attrs, @"range":[NSValue valueWithRange:range]}];
  }];
  
  // Make a plain uppercase string
  NSString *string = [[attrString string]uppercaseString];
  
  // Replace the characters with the uppercase ones
  [attrString replaceCharactersInRange:NSMakeRange(0, [attrString length]) withString:string];
  
  // Reapply each attribute
  for (NSDictionary *attribute in attributes) {
    [attrString setAttributes:attribute[@"attrs"] range:[attribute[@"range"] rangeValue]];
  }
  
  return attrString;
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
  _soundComboCount = 0;
  _enemyShouldAttack = NO;
  
  [self setMovesLeft:NUM_MOVES_PER_TURN animated:NO];
  
  _myDamageDealt = 0;
  _myDamageForThisTurn = 0;
  _enemyDamageDealt = 0;
  _myDamageDealtUnmodified = 0;
  _enemyDamageDealtUnmodified = 0;
  
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
      [[skillManager enemySkillControler] showSkillPopupAilmentOverlay:@"STUNNED" bottomText:@"TURN LOST"];
      [self endMyTurnAfterDelay:1.5f];
      return;
    }
    
    if ([self.orbLayer.layout detectPossibleSwaps].count)
      [self.orbLayer.bgdLayer turnTheLightsOn];
    else
      [self checkNoPossibleMoves];
    [self.orbLayer allowInput];
    [skillManager enableSkillButton:YES];
    
    [self.hudView prepareForMyTurn];
    [self updateItemsBadge];
    
    [self performAfterDelay:0.5 block:^{
      [self.hudView.battleScheduleView bounceLastView];
    }];
  }];
}

- (void) endMyTurnAfterDelay:(NSTimeInterval)delay
{
  [self performAfterDelay:delay block:^{
    _enemyShouldAttack = YES;
    [self checkEnemyHealthAndStartNewTurn];
  }];
}

- (void) beginEnemyTurn:(float)delay {
  [self removeButtons];
  
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
            _enemyDamageDealtUnmodified = _enemyDamageDealt;
            _enemyDamageDealt = (int)[skillManager modifyDamage:_enemyDamageDealt forPlayer:NO];
            
            // If the enemy's stunned, short the attack function
            if (self.enemyPlayerObject.isStunned)
            {
              [[skillManager playerSkillControler] showSkillPopupAilmentOverlay:@"STUNNED" bottomText:@"TURN LOST"];
              [self performAfterDelay:1.5 block:^{
                [self endEnemyTurn];
              }];
              return;
            }
            
            // If the enemy's confused, they will deal damage to themself. Instead of the usual flow, show
            // the popup above their head, followed by flinch animation and showing the damage label
            if (self.enemyPlayerObject.isConfused)
            {
              self.enemyPlayerObject.isConfused = NO;
              
              [[skillManager playerSkillControler] enqueueSkillPopupAilmentOverlay:@"CONFUSED" bottomText:[NSString stringWithFormat:@"%i DMG TO SELF", _enemyDamageDealt]];
              
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
            {
              [self.currentEnemy performNearAttackAnimationWithEnemy:self.myPlayer
                                                        shouldReturn:YES
                                                         shouldEvade:[skillManager playerWillEvade:YES]
                                                          shouldMiss:[skillManager playerWillMiss:NO]
                                                        shouldFlinch:(_enemyDamageDealt>0)
                                                              target:self
                                                            selector:@selector(dealEnemyDamage)
                                                      animCompletion:nil];
            }
            
            
            [skillManager playDamageLogos];
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
  
  _myDamageDealt = _myDamageDealt*[self damageMultiplierIsEnemyAttacker:NO];
  _myDamageDealtUnmodified = _myDamageDealt;
  _myDamageDealt = (int)[skillManager modifyDamage:_myDamageDealt forPlayer:YES];
  
  [self showHighScoreWord];
  [self.orbLayer disallowInput];
  [self.orbLayer.bgdLayer turnTheLightsOff];
  [self removeButtons];
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(doMyAttackAnimation)];
}

- (void) doMyAttackAnimation {
  
  
  // Changing damage with a skill
  NSInteger scoreModifier = _myDamageDealtUnmodified > 0 ? 1 : 0; // used to make current score not 0 if damage was modified to 0 by skillManager
  if (_myDamageDealt > 0)
    scoreModifier = 0;
  
  int currentScore = (float)(_myDamageDealtUnmodified + scoreModifier)/(float)[self.myPlayerObject totalAttackPower]*100.f;
  
  if (currentScore > 0) {
  
    // If the player's confused, he will deal damage to himself. Instead of the usual flow, show
    // the popup above his head, followed by flinch animation and showing the damage label
    if (self.myPlayerObject.isConfused)
    {
      self.myPlayerObject.isConfused = NO;
      
      [[skillManager enemySkillControler] enqueueSkillPopupAilmentOverlay:@"CONFUSED" bottomText:[NSString stringWithFormat:@"%i DMG TO SELF", _myDamageDealt]];
      
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
//#if !TARGET_IPHONE_SIMULATOR
      if (currentScore > MAKEITRAIN_SCORE) {
        [self.myPlayer restoreStandingFrame];
        [self spawnPlaneWithTarget:nil selector:nil];
      }
//#endif
      float strength = MIN(1, currentScore/(float)STRENGTH_FOR_MAX_SHOTS);
      [self.myPlayer performFarAttackAnimationWithStrength:strength
                                               shouldEvade:[skillManager playerWillEvade:NO]
                                                shouldMiss:[skillManager playerWillMiss:YES]
                                                     enemy:self.currentEnemy
                                                    target:self
                                                  selector:@selector(dealMyDamage)
                                            animCompletion:nil];
    }
  } else {
    [self beginNextTurn];
  }
  
  [skillManager playDamageLogos];
}

- (void) dealMyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by player");
  [skillManager triggerSkills:SkillTriggerPointPlayerDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by player trigger ENDED");
    
    _enemyShouldAttack = YES;
    
    [self animateDamageLabel:_myDamageDealtUnmodified modifiedDamage:_myDamageDealt targetSprite:self.currentEnemy withCompletion:^{
      [self dealDamage:_myDamageDealt enemyIsAttacker:NO usingAbility:NO showDamageLabel:NO withTarget:self withSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    }];
  }];
}

- (void) dealEnemyDamage {
  
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [skillManager triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    _totalDamageTaken += _enemyDamageDealt;
    
    [self animateDamageLabel:_enemyDamageDealtUnmodified modifiedDamage:_enemyDamageDealt targetSprite:self.myPlayer withCompletion:^{
      [self dealDamage:_enemyDamageDealt enemyIsAttacker:YES usingAbility:NO showDamageLabel:NO withTarget:self withSelector:@selector(endEnemyTurn)];
    }];
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
    
    [self animateDamageLabel:_myDamageDealtUnmodified modifiedDamage:_myDamageDealt targetSprite:self.myPlayer withCompletion:^{
      [self dealDamageToSelf:_myDamageDealt enemyIsAttacker:NO showDamageLabel:NO withTarget:self andSelector:@selector(checkEnemyHealthAndStartNewTurn)];
    }];
    
    [self.myPlayer performFarFlinchAnimationWithDelay:0.f];
  }];
}

- (void) enemyDealsDamageToSelf {
  SkillLogStart(@"TRIGGER STARTED: deal damage by enemy");
  [skillManager triggerSkills:SkillTriggerPointEnemyDealsDamage withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Deal damage by enemy trigger ENDED");
    
    [self animateDamageLabel:_enemyDamageDealtUnmodified modifiedDamage:_enemyDamageDealt targetSprite:self.currentEnemy withCompletion:^{
      [self dealDamageToSelf:_enemyDamageDealt enemyIsAttacker:YES showDamageLabel:NO withTarget:self andSelector:@selector(endEnemyTurn)];
    }];
    
    [self.currentEnemy performNearFlinchAnimationWithStrength:0 delay:0.f];
  }];
}

- (void) animateDamageLabel:(int)initialDamage modifiedDamage:(int)modifiedDamage targetSprite:(BattleSprite*)targetSprite withCompletion:(void(^)())completion
{
  NSString* labelFont = (initialDamage == modifiedDamage) ? @"hpfont.fnt" : (initialDamage > modifiedDamage ? @"decreased.fnt" : @"increased.fnt");
  CCLabelBMFont* damageLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%@", [Globals commafyNumber:initialDamage]] fntFile:labelFont];
  [self.bgdContainer addChild:damageLabel z:targetSprite.zOrder];
  [damageLabel setPosition:ccpAdd(targetSprite.position, ccp(0, targetSprite.contentSize.height - 15.f))];
  [damageLabel setAlignment:CCTextAlignmentCenter];
  [damageLabel setScale:.01f];
  
  if (initialDamage == modifiedDamage)
  {
    [damageLabel runAction:[CCActionSequence actions:
                            [CCActionCallBlock actionWithBlock:^{ if (completion) completion(); }],
                            [CCActionSpawn actions:
                             [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.f scale:1.f]],
                             [CCActionFadeOut actionWithDuration:1.f],
                             [CCActionMoveBy actionWithDuration:1.f position:ccp(0.f, 25.f)], nil],
                            [CCActionRemove action], nil]];
  }
  else
  {
    const float updateDuration = MIN(abs(initialDamage - modifiedDamage) * .07f, 1.75f);
    const int   updateRepeatCount = ceilf(updateDuration / .07f);
    const float updateDamageIncrement = (initialDamage - modifiedDamage) / (float)updateRepeatCount;
    
    __block float damage = initialDamage;
    
    CCActionFiniteTime* labelUpdateAction = [CCActionSequence actions:
                                             [CCActionDelay actionWithDuration:.25f],
                                             [CCActionSpawn actions:
                                              [CCActionRepeat actionWithAction:
                                               [CCActionSequence actions:
                                                [CCActionCallBlock actionWithBlock: // Update damage number
                                                 ^{
                                                   [damageLabel setString:[NSString stringWithFormat:@"%@", [Globals commafyNumber:floorf(damage)]]];
                                                   damage = MIN(updateDamageIncrement > 0 ? initialDamage : modifiedDamage,           // Upper limit
                                                                MAX(damage - updateDamageIncrement,
                                                                    updateDamageIncrement > 0 ? modifiedDamage : initialDamage));     // Lower limit
                                                 }],
                                                [CCActionDelay actionWithDuration:.05f], nil] times:updateRepeatCount],
                                              nil],
                                             [CCActionCallBlock actionWithBlock:    // Set final damage number
                                              ^{
                                                [damageLabel setString:[NSString stringWithFormat:@"%@", [Globals commafyNumber:modifiedDamage]]];
                                              }], nil];
    
    [damageLabel runAction:[CCActionSequence actions:
                            [CCActionSpawn actions:
                             [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.f scale:1.f]], // Initial scale to appear
                             labelUpdateAction,
                             nil],// Update label
                            [CCActionCallBlock actionWithBlock:^{ if (completion) completion(); }],
                            [CCActionSpawn actions:                                             // Move up and fade out
                             [CCActionFadeOut actionWithDuration:.5f],
                             [CCActionMoveBy actionWithDuration:.5f position:ccp(0.f, 25.f)], nil],
                            [CCActionRemove action], nil]];
  }
}

- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withTarget:(id)target andSelector:(SEL)selector
{
  [self dealDamageToSelf:damageDone enemyIsAttacker:enemyIsAttacker showDamageLabel:YES withTarget:target andSelector:selector];
}

- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker showDamageLabel:(BOOL)showLabel withTarget:(id)target andSelector:(SEL)selector
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
                           [SoundEngine stopRepeatingEffect];
                           
                           if (newHealth <= 0) {
                             if (!enemyIsAttacker) {
                               [self.movesLeftContainer removeFromParent];
                               self.movesLeftContainer = nil;
                             }
                             
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
                        [CCActionDelay actionWithDuration:.02f],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  [self pulseHealthLabelIfRequired:enemyIsAttacker];
  
  if (showLabel)
    [self animateDamageLabel:damageDone modifiedDamage:damageDone targetSprite:bs withCompletion:nil];
  
  bp.curHealth = newHealth;
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector {
  [self dealDamage:damageDone enemyIsAttacker:enemyIsAttacker usingAbility:usingAbility showDamageLabel:YES withTarget:target withSelector:selector];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility showDamageLabel:(BOOL)showLabel withTarget:(id)target withSelector:(SEL)selector {
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
                           [SoundEngine stopRepeatingEffect];
                           
                           if (newHealth <= 0) {
                             if (enemyIsAttacker) {
                               [self.movesLeftContainer removeFromParent];
                               self.movesLeftContainer = nil;
                             }
                             
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
                        [CCActionDelay actionWithDuration:0.02],
                        nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  if (showLabel)
    [self animateDamageLabel:damageDone modifiedDamage:damageDone targetSprite:defSpr withCompletion:nil];
  
  /*
  if ( ! usingAbility )
  {
    CGPoint pos = defSpr.position;
    int val = 40*(enemyIsAttacker ? 1 : -1);
    pos = ccpAdd(pos, ccp(val, 15));
    [self displayEffectivenessForAttackerElement:att.element defenderElement:def.element position:pos];
  }
   */
  
  def.curHealth = newHealth;
  
  [self pulseHealthLabelIfRequired:!enemyIsAttacker];
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
                           [SoundEngine stopRepeatingEffect];
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
                        [CCActionDelay actionWithDuration:.02f],
                        nil]];
  [f setTag:1827];
  [healthLabel runAction:f];
  
  [self pulseHealthLabelIfRequired:enemyIsHealed];
  
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

- (void) instantSetHealthForEnemy:(BOOL)enemy to:(int)health withTarget:(id)target andSelector:(SEL)selector
{
  // TODO - Right now only used to instakill a BattlePlayer. Not sure
  // why we would wanna set the health to any value other than zero
  // and not go through the usual dealDamage: flow
  
  BattlePlayer* bp = enemy ? self.enemyPlayerObject : self.myPlayerObject;
  BattleSprite* bs = enemy ? self.currentEnemy : self.myPlayer;
  
  bp.curHealth = MIN(bp.maxHealth, MAX(bp.minHealth, health));
  [self updateHealthBars];
  
  if (health <= 0) {
    if (!enemy) {
      [self.movesLeftContainer removeFromParent];
      self.movesLeftContainer = nil;
    }
    
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
  
  if (!enemy) {
    [self sendServerUpdatedValuesVerifyDamageDealt:NO];
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
    if (!self.myPlayerObject.isClanMonster) {
      [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:self.myPlayerObject.userMonsterUuid curHealth:self.myPlayerObject.curHealth];
    }
  }
}

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block {
  [sprite runAction:[CCActionSequence actions:
                     [RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                     [CCActionDelay actionWithDuration:0.7f],
                     [CCActionRemove action],
                     [CCActionCallBlock actionWithBlock:^{if (block) block();}], nil]];
  
  CCParticleSystem *q = [CCParticleSystem particleWithFile:@"characterdie.plist"];
  q.autoRemoveOnFinish = YES;
  q.position = ccpAdd(sprite.position, ccp(0, sprite.contentSize.height/2-5));
  [self.bgdContainer addChild:q z:sprite.zOrder];
  
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
  SkillLogStart(@"TRIGGER STARTED: mob defeated");
  [skillManager triggerSkills:SkillTriggerPointPlayerMobDefeated withCompletion:^(BOOL triggered, id params) {
    SkillLogEnd(triggered, @"  Mob defeated trigger ENDED");
    
    [self setMovesLeft:0 animated:NO];
    [self stopPulsing];
    self.myPlayer = nil;
    self.myPlayerObject = nil;
    [self updateHealthBars];
    
    if ([self playerMobstersLeft] > 0) {
      [self displayDeployViewAndIsCancellable:NO];
    }
    else
    {
      [self youLost];
    }
  }];
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
  CCNode *n = self.bgdContainer;
  CGPoint curPos = n.position;
  
  NSMutableArray *moves = [NSMutableArray array];
  int numTimes = 8+intensity*14;
  for (int i = 0; i < numTimes; i++) {
    float divisor = 1;
    float start = numTimes/3;
    if (i > start) {
      divisor = 1+(i-start)/5;
    }
    
    int signX = arc4random() % 2 ? 1 : -1;
    int signY = arc4random() % 2 ? 1 : -1;
    CGPoint pt = ccp(drand48()*intensity*8*signX/divisor, drand48()*intensity*8*signY/divisor);
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:0.02f position:ccpAdd(pt, curPos)];
    [moves addObject:move];
  }
  CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:0.02f position: curPos];
  [moves addObject:move];
  
  CCActionSequence *seq = [CCActionSequence actionWithArray:moves];
  
  [n runAction:[CCActionSequence actions:seq, [CCActionCallBlock actionWithBlock:^{
    n.position = curPos;
  }], nil]];
}

- (void) showHighScoreWordWithTarget:(id)target selector:(SEL)selector {
  CCSprite *phrase = nil;
  NSString *phraseFile = nil;
  BOOL isMakeItRain = NO;
  int currentScore = _myDamageDealtUnmodified*[self damageMultiplierIsEnemyAttacker:NO]/(float)[self.myPlayerObject totalAttackPower]*100.f;
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
    [self makeMyPlayerWalkOutWithBlock:^{
      [self youLost];
    }];
    self.myPlayer = nil;
    self.myPlayerObject = nil;
    [self.orbLayer disallowInput];
    [self removeButtons];
  }
}

- (void) endBattle:(BOOL)won {
  [CCBReader load:@"BattleEndView" owner:self];
  
  // Set endView's parent so that the position normalization doesn't get screwed up
  // since we're only adding it to the parent once orb layer gets removed
  self.endView.parent = self;
  
  _wonBattle = won;
  
  [self removeButtons];
  [self.hudView removeBattleScheduleView];
  [self.hudView hideSkillPopup:nil];
  self.hudView.bottomView.hidden = YES;
  
  [self setMovesLeft:0 animated:NO];
  [self.movesLeftContainer removeFromParent];
  self.movesLeftContainer = nil;
  _movesLeftHidden = YES;
  
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

- (void) pulseHealthLabelIfRequired:(BOOL)onEnemy
{
  if (onEnemy)
  {
    float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
    if (perc < PULSE_CONT_THRESH) {
      [self pulseHealthLabel:YES];
    } else {
      [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
      self.currentEnemy.healthLabel.color = [CCColor whiteColor];
    }
  }
  else
  {
    float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
    if (!_bloodSplatter || _bloodSplatter.numberOfRunningActions == 0) {
      if (perc < PULSE_CONT_THRESH) {
        [self pulseBloodContinuously];
        [self pulseHealthLabel:NO];
      } else if (perc < PULSE_ONCE_THRESH) {
        [self pulseBloodOnce];
      }
    } else if (perc > PULSE_CONT_THRESH) {
      [self stopPulsing];
    }
  }
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
  [self setMovesLeft:_movesLeft - 1 animated:YES];
  [self updateHealthBars];
  [self.hudView removeSwapButtonAnimated:YES];
  [skillManager enableSkillButton:NO];
  
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  if ((self.orbLayer.allowFreeMove && bip.battleItemType == BattleItemTypeHandSwap) ||
      (self.orbLayer.allowOrbHammer && bip.battleItemType == BattleItemTypeOrbHammer) ||
      (self.orbLayer.allowPutty && bip.battleItemType == BattleItemTypePutty)) {
    [self deductBattleItem:bip];
    _selectedBattleItem = nil;
  }
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

      // 2/24/15 - BN - Special orbs no longer count towards skill activation
      if (orb.specialOrbType == SpecialOrbTypeNone)
      {
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

- (void)checkNoPossibleMoves {
  if (![self.orbLayer.layout detectPossibleSwaps].count) {
    [self noPossibleMoves];
  }
}

- (void)noPossibleMoves {
  if (!_noMovesLabel) {
    NSString* prompt = @"No possible moves!\nUse an item to continue";
    _noMovesLabel = [CCLabelTTF labelWithString:prompt fontName:@"GothamBlack" fontSize:15];
    _noMovesLabel.horizontalAlignment = CCTextAlignmentCenter;
    _noMovesLabel.verticalAlignment = CCVerticalTextAlignmentCenter;
    _noMovesLabel.position = ccp(self.orbLayer.contentSize.width/2, self.orbLayer.contentSize.height/2);
    _noMovesLabel.opacity = 0.0;
    [self.orbLayer addChild:_noMovesLabel];
  }
  
  [_noMovesLabel runAction:[CCActionSequence actions:
                    [CCActionCallBlock actionWithBlock:^{
    [self.orbLayer.bgdLayer turnTheLightsOff]; }],
                    [CCActionFadeIn actionWithDuration:0.3],
                    nil]];
}

- (void) hideNoMovesOverlay {
  if (_noMovesLabel) {
    [_noMovesLabel runAction:[CCActionSequence actions:
                              [CCActionCallBlock actionWithBlock:^{
      [self.orbLayer.bgdLayer turnTheLightsOn]; }],
                              [CCActionFadeOut actionWithDuration:0.3],
                              nil]];
  }
}

- (void) reachedNextScene {
  
  [self.myPlayer stopWalking];
  
  if (self.enemyPlayerObject) {
    
    if (self.currentEnemy.ipadEnterBufferFlag) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
      self.currentEnemy.ipadEnterBufferFlag = NO;
      return;
    }
    
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

-(void) skillPopupClosed {
  if(_forcedSkillDialogueViewController) {
    [_forcedSkillDialogueViewController continueAndRevealSpeakers];
  }
}

#pragma mark - No Input Layer Methods

- (void) displayOrbLayer {
  const CGPoint orbLayerPosition = ccp(self.contentSize.width-self.orbLayer.contentSize.width/2-ORB_LAYER_DIST_FROM_SIDE, self.orbLayer.position.y);
  [self.orbLayer runAction:[CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:0.4f position:orbLayerPosition] rate:3]];

  if ([Globals isiPad])
    self.lootBgd.position = ccp(self.contentSize.width - self.orbLayer.contentSize.width - ORB_LAYER_BASE_DIST_FROM_SIDE - self.lootBgd.contentSize.width + 1, 85);
  else
    self.lootBgd.position = ccp(self.lootBgd.contentSize.width/2 + 10,
                              self.lootBgd.contentSize.height/2+ORB_LAYER_DIST_FROM_SIDE+self.hudView.swapView.height+7);
  [self displayLootCounter:YES];
  
  [SoundEngine puzzleOrbsSlideIn];
}

- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block {
  if (!block) {
    block = ^{};
  }
  
  CGPoint pos = ccp(self.contentSize.width+self.orbLayer.contentSize.width,
                    self.orbLayer.position.y);
  
  if (animated) {
    [self.orbLayer runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:0.3f position:pos],
      [CCActionCallBlock actionWithBlock:block], nil]];

    [self displayLootCounter:NO];
  } else {
    self.orbLayer.position = pos;
    self.lootBgd.opacity = 0.f;
    self.lootLabel.opacity = 0.f;
    block();
  }
}

- (void) displayLootCounter:(BOOL)show {
  if (show) {
    [self.lootBgd runAction:[CCActionFadeIn actionWithDuration:.5f]];
    [self.lootLabel runAction:[CCActionFadeIn actionWithDuration:.5f]];
  } else {
    [self.lootBgd runAction:[CCActionFadeOut actionWithDuration:.5f]];
    [self.lootLabel runAction:[CCActionFadeOut actionWithDuration:.5f]];
  }
}

#pragma mark - Hud views

#define BOTTOM_CENTER_X (self.contentSize.width-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE)/2
#define DEPLOY_CENTER_X roundf(MAX(BOTTOM_CENTER_X, self.hudView.deployView.width/2+5.f))

- (void) loadHudView {
  GameViewController *gvc = [GameViewController baseController];
  UIView *view = gvc.view;
  
  NSString *bundleName = ![Globals isSmallestiPhone] ? @"BattleHudView" : @"BattleHudViewSmall";
  [[NSBundle mainBundle] loadNibNamed:bundleName owner:self options:nil];
  self.hudView.frame = view.bounds;
  [view insertSubview:self.hudView aboveSubview:[CCDirector sharedDirector].view];
  
  self.hudView.battleLayerDelegate = self;
  
  // Make the bottom view flush with the board
  float bottomDist = ORB_LAYER_DIST_FROM_SIDE-2;
  self.hudView.bottomView.originY = self.hudView.bottomView.superview.height-self.hudView.bottomView.height-bottomDist;
  self.hudView.swapView.originY = self.hudView.swapView.superview.height-self.hudView.swapView.height-bottomDist;
  
  self.hudView.itemsView.originY = self.hudView.itemsView.superview.height-self.hudView.itemsView.height-bottomDist;
  if ([Globals isiPad]) {
    self.hudView.itemsView.originX = self.hudView.itemsView.superview.width-self.hudView.itemsView.width-self.orbLayer.contentSize.width * 1.5 -ORB_LAYER_DIST_FROM_SIDE-17;
  } else {
    self.hudView.itemsView.originX = self.hudView.itemsView.superview.width-self.hudView.itemsView.width-self.orbLayer.contentSize.width -ORB_LAYER_DIST_FROM_SIDE-8;
  }
  
  self.hudView.bottomView.centerX = self.hudView.swapView.width+(self.hudView.itemsView.originX-self.hudView.swapView.width)/2;
  
  if (![Globals isiPad]) {
    UIImage *img = [Globals imageNamed:@"6movesqueuebgwide.png"];
    if (BOTTOM_CENTER_X*2 >= img.size.width) {
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
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self.hudView.deployView showClanSlot];
  } else {
    [self.hudView.deployView hideClanSlot];
  }
}

- (void) removeButtons {
  [self.hudView removeButtons];
  [self.popoverViewController closeClicked:nil];
}

- (void) itemsClicked:(id)sender {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    return;
  }
  
  BOOL showFooter = !self.allowBattleItemPurchase;
  BattleItemSelectViewController *svc = [[BattleItemSelectViewController alloc] initWithShowUseButton:YES showFooterView:showFooter showItemFactory:YES];
  if (svc) {
    svc.delegate = self;
    self.popoverViewController = svc;
    
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
      if ([sender isKindOfClass:[UIButton class]])
      {
        [svc showAnchoredToInvokingView:self.hudView.itemsButton.superview
                          withDirection:ViewAnchoringPreferTopPlacement
                      inkovingViewImage:[Globals maskImage:[Globals snapShotView:self.hudView.itemsButton.superview] withColor:[UIColor whiteColor]]];
      }
    }
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
  
  [self displayLootCounter:NO];
  
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
  [self displayLootCounter:YES];
  BOOL isSwap = self.myPlayer != nil;
  if (bp && ![bp.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
    
    [self.myPlayer removeAllSkillSideEffects];
    self.myPlayerObject = bp;
    
    if (bp.isClanMonster) {
      GameState *gs = [GameState sharedGameState];
      ClanMemberTeamDonationProto *donation = [gs.clanTeamDonateUtil myTeamDonation];
      if ([donation.donatedMonster.userMonsterUuid isEqualToString:self.myPlayerObject.userMonsterUuid]) {
        [[OutgoingEventController sharedOutgoingEventController] invalidateSolicitation:donation];
      }
    }
    
    
    if (isSwap) {
      [self makeMyPlayerWalkOutWithBlock:nil];
      [self removeButtons];
    }
    
    [self createScheduleWithSwap:isSwap];
    
    [self createNextMyPlayerSprite];
    
    [self triggerSkillForPlayerCreatedWithBlock:^{
      
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

- (void) triggerSkillForPlayerCreatedWithBlock:(dispatch_block_t)block {
  
  // Skills trigger for player appeared
  SkillLogStart(@"TRIGGER STARTED: player initialized");
  [skillManager triggerSkills:SkillTriggerPointPlayerInitialized withCompletion:^(BOOL triggered, id params) {
    
    SkillLogEnd(triggered, @"  Player initialized trigger ENDED");
    
    if (block) {
      block();
    }
    
  }];
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
    
    [self removeButtons];
    
    [self.popoverViewController closeClicked:nil];
    
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
  
  if(self.forcedSkillView.superview) {
    [self.forcedSkillView removeFromSuperview];
  }
  GameViewController *gvc = [GameViewController baseController];
  self.forcedSkillView.frame = gvc.view.bounds;
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
  [_forcedSkillDialogueViewController pauseAndHideSpeakers];
  [UIView animateWithDuration:0.3f animations:^{
    self.forcedSkillView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.forcedSkillView removeFromSuperview];
  }];
}

- (IBAction)sendButtonClicked:(id)sender {
  // Do nothing
}

#pragma mark - Battle Item Select Delegate

- (void) updateItemsBadge {
  GameState *gs = [GameState sharedGameState];
  int quantity = 0;
  
  for (UserBattleItem *ubi in gs.battleItemUtil.battleItems) {
    quantity += ubi.quantity;
  }
  
  self.hudView.itemsBadge.badgeNum = quantity;
}

- (NSArray *) reloadBattleItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  BattleItemUtil *bi = gs.battleItemUtil;
  for (BattleItemProto *bip in gs.staticBattleItems.allValues) {
    UserBattleItem *ubi = [bi getUserBattleItemForBattleItemId:bip.battleItemId];
    
    if (!ubi) {
      ubi = [[UserBattleItem alloc] init];
      ubi.battleItemId = bip.battleItemId;
    }
    
    if (ubi.quantity > 0 || self.allowBattleItemPurchase) {
      [arr addObject:ubi];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserBattleItem *obj1, UserBattleItem *obj2) {
    BOOL isValid1 = [self battleItemIsValid:obj1];
    BOOL isValid2 = [self battleItemIsValid:obj2];
    BOOL hasQuant1 = obj1.quantity > 0;
    BOOL hasQuant2 = obj2.quantity > 0;
    
    if (isValid1 != isValid2) {
      return [@(isValid2) compare:@(isValid1)];
    } else if (hasQuant1 != hasQuant2) {
      return [@(hasQuant2) compare:@(hasQuant1)];
    } else {
      return [@(obj1.staticBattleItem.priority) compare:@(obj2.staticBattleItem.priority)];
    }
  }];
  
  return arr;
}

- (void) battleItemSelected:(UserBattleItem *)item viewController:(BattleItemSelectViewController *)viewController {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.popoverViewController closeClicked:nil];
    return;
  }
  
  BattleItemProto *bip = item.staticBattleItem;
  if ([self battleItemIsValid:item]) {
    _selectedBattleItem = item;
    if (item.quantity > 0) {
      [self useSelectedBattleItem];
    } else {
      NSString *desc = [NSString stringWithFormat:@"Would you like to purchase a %@ for %d Gems?", bip.name, bip.inBattleGemCost];
      NSString *title = [NSString stringWithFormat:@"Purchase %@?", bip.name];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:title gemCost:bip.inBattleGemCost target:self selector:@selector(checkUserHasGemsToPurchaseItem)];
    }
  } else {
    NSString *str = nil;
    switch (bip.battleItemType) {
      case BattleItemTypePoisonAntidote:
        str = [NSString stringWithFormat:@"Your %@ must be Poisoned to use this Antidote.", MONSTER_NAME];
        break;
        
      case BattleItemTypeChillAntidote:
        str = [NSString stringWithFormat:@"Your %@ must be Chilled to use this Antidote.", MONSTER_NAME];
        break;
        
      case BattleItemTypeHealingPotion:
        str = [NSString stringWithFormat:@"Your %@ is already at full health.", MONSTER_NAME];
        break;
        
      case BattleItemTypePutty:
        str = [NSString stringWithFormat:@"There are no holes to use %@ on.", bip.name];
        break;
        
      case BattleItemTypeBoardShuffle:
      case BattleItemTypeHandSwap:
      case BattleItemTypeOrbHammer:
      case BattleItemTypeNone:
        // Should always be valid
        break;
    }
    
    if (str) {
      [Globals addAlertNotification:str];
    }
  }
}

- (void) checkUserHasGemsToPurchaseItem {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.popoverViewController closeClicked:nil];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  
  if (bip.inBattleGemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsViewWithTarget:self selector:@selector(openGemShop)];
  } else {
    [self useSelectedBattleItem];
  }
}

- (void) useSelectedBattleItem {
  if (!self.orbLayer.swipeLayer.userInteractionEnabled) {
    [self.popoverViewController closeClicked:nil];
    return;
  }
  
  UserBattleItem *item = _selectedBattleItem;
  BattleItemProto *bip = item.staticBattleItem;
  
  NSString *instruction = nil;
  switch (bip.battleItemType) {
    case BattleItemTypeHealingPotion:
      [self useHealthPotion:bip];
      break;
      
    case BattleItemTypeBoardShuffle:
      [self useBoardShuffle:bip];
      break;
      
    case BattleItemTypeHandSwap:
      [self useHandSwap:bip];
      instruction = @"Swipe any two orbs to swap.";
      break;
      
    case BattleItemTypeOrbHammer:
      [self useOrbHammer:bip];
      instruction = @"Tap an orb to destroy it.";
      break;
      
    case BattleItemTypePutty:
      [self usePutty:bip];
      instruction = @"Tap a hole to fill it in.";
      break;
      
    case BattleItemTypeChillAntidote:
    case BattleItemTypePoisonAntidote:
      [self useSkillAntidote:bip];
      break;

	case BattleItemTypeNone:
      break;
  }
  
  // The ones that aren't done immediately get deducted in moveBegan
  if (!instruction) {
    [self deductBattleItem:bip];
    _selectedBattleItem = nil;
  } else {
    DialogueViewController *dvc = [[DialogueViewController alloc] initWithBattleItemName:bip instruction:instruction];
    dvc.delegate = self;
    GameViewController *gvc = [GameViewController baseController];
    [gvc addChildViewController:dvc];
    dvc.view.frame = gvc.view.bounds;
    
    // If the dialogue view controller gets finished, cancel the battle items.
    // Cover everything that's to the left of the board instead of whole screen
    dvc.view.width -= (self.orbLayer.contentSize.width+ORB_LAYER_DIST_FROM_SIDE);
    [gvc.view addSubview:dvc.view];
    
    self.dialogueViewController = dvc;
  }
  
  [self.popoverViewController closeClicked:nil];
}

- (void) deductBattleItem:(BattleItemProto *)bip {
  GameState *gs = [GameState sharedGameState];
  UserBattleItem *ubi = [gs.battleItemUtil getUserBattleItemForBattleItemId:bip.battleItemId];
  if (ubi.quantity > 0) {
    [[OutgoingEventController sharedOutgoingEventController] removeBattleItems:@[@(bip.battleItemId)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_REMOVED_NOTIFICATION object:nil];
    
    [self updateItemsBadge];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] updateUserCurrencyWithCashSpent:0 oilSpent:0 gemsSpent:bip.inBattleGemCost reason:[NSString stringWithFormat:@"Purchased %@ in battle.", bip.name]];
  }
  
  if (self.dialogueViewController) { 
    [self.dialogueViewController animateNext];
  }
}

- (void) dialogueViewControllerFinished:(DialogueViewController *)dvc {
  [self cancelBattleItems];
}

- (void) cancelBattleItems {
  [self.orbLayer cancelFreeMove];
  [self.orbLayer cancelOrbHammer];
  [self.orbLayer cancelPutty];
  
  //A little hacky, but this quickly tells us whether the user actually used the item (animations would be playing if they used something)
  if (self.orbLayer.swipeLayer.userInteractionEnabled)
    [self checkNoPossibleMoves];
  
  self.dialogueViewController = nil;
}

- (BOOL) battleItemIsValid:(UserBattleItem *)item {
  BattleItemProto *bip = item.staticBattleItem;
  switch (bip.battleItemType) {
    case BattleItemTypeBoardShuffle:
    case BattleItemTypeHandSwap:
    case BattleItemTypeOrbHammer:
      return YES;
      
    case BattleItemTypePutty:
    {
      // Check all the tiles for holes
      for (int i = 0; i < self.orbLayer.layout.numColumns; i++) {
        for (int j = 0; j < self.orbLayer.layout.numRows; j++) {
          BattleTile *tile = [self.orbLayer.layout tileAtColumn:i row:j];
          if (tile.isHole) {
            return YES;
          }
        }
      }
      
      return NO;
    }
      
    case BattleItemTypeHealingPotion:
      return self.myPlayerObject.curHealth < self.myPlayerObject.maxHealth;
      
    case BattleItemTypeChillAntidote:
    case BattleItemTypePoisonAntidote:
      return [skillManager useAntidote:bip execute:NO];

    case BattleItemTypeNone:
      return NO;
  }
}

- (void) battleItemSelectClosed:(id)viewController {
  self.popoverViewController = nil;
}

#pragma mark Using Battle Items

- (void) useHealthPotion:(BattleItemProto *)bip {
  [self moveBegan];
  [self healForAmount:bip.amount enemyIsHealed:NO withTarget:self andSelector:@selector(moveComplete)];
  [self sendServerUpdatedValuesVerifyDamageDealt:NO];
  [skillManager showItemPopupOverlay:bip bottomText:[NSString stringWithFormat:@"+%i HP", bip.amount]];
  [self pulseHealthLabelIfRequired:NO];
}

- (void) useBoardShuffle:(BattleItemProto *)bip {
  [self moveBegan];
  [self.orbLayer shuffleWithoutEnforcementAndCheckMatches];
}

- (void) useHandSwap:(BattleItemProto *)bip {
  [self.orbLayer allowFreeMoveForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) useOrbHammer:(BattleItemProto *)bip {
  [self.orbLayer allowOrbHammerForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) usePutty:(BattleItemProto *)bip {
  [self.orbLayer allowPuttyForSingleTurn];
  [self hideNoMovesOverlay];
}

- (void) useSkillAntidote:(BattleItemProto *)bip {
  [self moveBegan];
  [skillManager useAntidote:bip execute:YES];
}

#pragma mark - Open Shop

- (void) openGemShop {
  GameViewController *gvc = [GameViewController baseController];
  ShopViewController *svc = [[ShopViewController alloc] init];
  
  [svc displayInParentViewController:gvc];
  [svc openFundsShop];
  
  svc.mainView.originY += (svc.tabBar.superview.height-svc.tabBar.originY);
  
  [self.popoverViewController closeClicked:nil];
}

@end

#pragma clang diagnostic pop
