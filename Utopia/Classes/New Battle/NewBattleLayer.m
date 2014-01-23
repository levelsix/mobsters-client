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

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define Y_MOVEMENT_FOR_NEW_SCENE 140
#define TIME_TO_SCROLL_PER_SCENE 3.f
#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#define BALLIN_SCORE 230
#define CANTTOUCHTHIS_SCORE 300
#define HAMMERTIME_SCORE 420
#define MAKEITRAIN_SCORE 600

#define NUM_MOVES_PER_TURN 3

#define PULSE_ONCE_THRESH 0.5
#define PULSE_CONT_THRESH 0.3
#define RED_TINT_TAG 6789

#define STRENGTH_FOR_MAX_SHOTS MAKEITRAIN_SCORE

#define PUZZLE_BGD_TAG 1456

#define NO_INPUT_LAYER_OPACITY 0.6f

#define CENTER_OF_BATTLE ccp((self.contentSize.width-self.orbBgdLayer.contentSize.width-14)/2, self.contentSize.height/2-40)
#define PLAYER_X_DISTANCE_FROM_CENTER (CENTER_OF_BATTLE.x*0.4+4)
#define MY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(-PLAYER_X_DISTANCE_FROM_CENTER, -PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define ENEMY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(PLAYER_X_DISTANCE_FROM_CENTER, PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define BGD_LAYER_INIT_POSITION ccp(-530+(CENTER_OF_BATTLE.x-CENTER_OF_BATTLE.y*SLOPE_OF_ROAD), 0)

#define BGD_SCALE ((self.contentSize.width-480)/88.f*0.3+1.f)

#define PUZZLE_ON_LEFT_BGD_OFFSET (self.contentSize.width-2*CENTER_OF_BATTLE.x)

#define COMBO_FIRE_TAG @"ComboFire"

@implementation BattleBgdLayer

- (id) init {
  if ((self = [super init])) {
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
  for (CCNode *n in self.children) {
    if (n.position.y+n.contentSize.height/2 < -1*self.position.y) {
      [n removeFromParentAndCleanup:YES];
    }
  }
}

- (void) addSceneAtBasePosition:(CGPoint)pos {
  CCSprite *left1 = [CCSprite spriteWithImageNamed:@"scene1left.png"];
  CCSprite *right1 = [CCSprite spriteWithImageNamed:@"scene1right.png"];
  
  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
  right1.position = ccp(left1.position.x+left1.contentSize.width/2+right1.contentSize.width/2,
                        left1.position.y);
  
  [self addChild:left1];
  [self addChild:right1];
  
  CCSprite *left2 = [CCSprite spriteWithImageNamed:@"scene2left.png"];
  CCSprite *right2 = [CCSprite spriteWithImageNamed:@"scene2right.png"];
  
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

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft {
  if ((self = [super init])) {
    _puzzleIsOnLeft = puzzleIsOnLeft;
    
    CGSize gridSize = CGSizeMake(8, 8);
    
    OrbBgdLayer *puzzleBg = [[OrbBgdLayer alloc] initWithGridSize:gridSize];
    [self addChild:puzzleBg z:2];
    float puzzX = puzzleIsOnLeft ? puzzleBg.contentSize.width/2+14 : self.contentSize.width-puzzleBg.contentSize.width/2-14;
    puzzleBg.position = ccp(puzzX, self.contentSize.height/2);
    self.orbBgdLayer = puzzleBg;
    
    OrbLayer *ol = [[OrbLayer alloc] initWithContentSize:puzzleBg.contentSize gridSize:gridSize numColors:6];
    ol.position = ccp(puzzleBg.contentSize.width/2, puzzleBg.contentSize.height/2);
    [self.orbBgdLayer addChild:ol z:2];
    ol.delegate = self;
    self.orbLayer = ol;
    
    self.noInputLayer = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4f:ccc4f(0, 0, 0, NO_INPUT_LAYER_OPACITY)] width:self.orbLayer.contentSize.width height:self.orbLayer.contentSize.height];
    [self.orbBgdLayer addChild:self.noInputLayer z:self.orbLayer.zOrder];
    self.noInputLayer.position = ol.position;
    
    self.bgdContainer = [CCNode node];
    [self addChild:self.bgdContainer z:0];
    
    self.bgdLayer = [BattleBgdLayer node];
    [self.bgdContainer addChild:self.bgdLayer z:-100];
    self.bgdLayer.position = BGD_LAYER_INIT_POSITION;
    if (_puzzleIsOnLeft) self.bgdLayer.position = ccpAdd(BGD_LAYER_INIT_POSITION, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
    self.bgdLayer.delegate = self;
    
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
    
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonster *um in monsters) {
      [arr addObject:[BattlePlayer playerWithMonster:um]];
    }
    self.myTeam = arr;
  }
  return self;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  [self begin];
  
  CCClippingNode *clip = (CCClippingNode *)_comboBgd.parent;
  CCDrawNode *stencil = [CCDrawNode node];
  CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
  [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
  clip.stencil = stencil;
}

- (void) onExitTransitionDidStart {
  CCClippingNode *clip = (CCClippingNode *)_comboBgd.parent;
  clip.stencil = nil;
  [super onExitTransitionDidStart];
}

- (void) begin {
  [self moveToNextEnemy];
}

- (void) setupUI {
  OrbBgdLayer *puzzleBg = self.orbBgdLayer;
  
//  CCSprite *powerBgd = [CCSprite spriteWithImageNamed:@"powermeterbg.png"];
//  [puzzleBg addChild:powerBgd z:1];
//  powerBgd.position = ccpAdd(ccp(powerBgd.contentSize.width/2, -powerBgd.contentSize.height/2), ccp(15, puzzleBg.contentSize.height-3));
//  
//  _powerBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithImageNamed:@"powermeter.png"]];
//  [powerBgd addChild:_powerBar];
//  _powerBar.position = ccp(powerBgd.contentSize.width/2-0.5, powerBgd.contentSize.height/2);
//  _powerBar.type = kCCProgressTimerTypeBar;
//  _powerBar.midpoint = ccp(0, 0.5);
//  _powerBar.barChangeRate = ccp(1,0);
//  _powerBar.percentage = 90;
//  
//  CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 150) width:1 height:powerBgd.contentSize.height];
//  [powerBgd addChild:l];
//  l.position = ccp(powerBgd.contentSize.width/3, 0);
//  l = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 150) width:1 height:powerBgd.contentSize.height];
//  [powerBgd addChild:l];
//  l.position = ccp(powerBgd.contentSize.width*2/3, 0);
  
  _movesBgd = [CCSprite spriteWithImageNamed:@"movesbg.png"];
  [puzzleBg addChild:_movesBgd z:-1];
  
  CCLabelTTF *movesLabel = [CCLabelTTF labelWithString:@"MOVES " fontName:@"GothamNarrow-UltraItalic" fontSize:10 dimensions:CGSizeMake(100, 30)];
  movesLabel.horizontalAlignment = CCTextAlignmentRight;
  [_movesBgd addChild:movesLabel];
  [movesLabel setColor:[CCColor whiteColor]];
  [movesLabel setShadowOffset:ccp(0,-1)];
  [movesLabel setOpacity:0.3f];
  [movesLabel setShadowBlurRadius:1.f];
  
  _movesLeftLabel = [CCLabelTTF labelWithString:@"5" fontName:@"GothamNarrow-UltraItalic" fontSize:19 dimensions:CGSizeMake(100, 30)];
  [_movesBgd addChild:_movesLeftLabel];
  [_movesLeftLabel setHorizontalAlignment:CCTextAlignmentRight];
  [_movesLeftLabel setColor:[CCColor whiteColor]];
  [_movesLeftLabel setShadowOffset:ccp(0,-1)];
  [_movesLeftLabel setOpacity:0.3f];
  [_movesLeftLabel setShadowBlurRadius:1.f];
  
  if (_puzzleIsOnLeft) {
    _movesBgd.anchorPoint = ccp(0, 0.5);
    movesLabel.anchorPoint = ccp(0, 0.5);
    movesLabel.anchorPoint = ccp(0, 0.5);
    
    _movesBgd.position = ccp(puzzleBg.contentSize.width, 54);
    movesLabel.position = ccp(3, 11);
    _movesLeftLabel.position = ccp(3, 27);
    
    _movesBgd.flipX = YES;
  } else {
    _movesBgd.anchorPoint = ccp(1, 0.5);
    movesLabel.anchorPoint = ccp(1, 0.5);
    _movesLeftLabel.anchorPoint = ccp(1, 0.5);
    
    _movesBgd.position = ccp(0, 54);
    movesLabel.position = ccp(62, 11);
    _movesLeftLabel.position = ccp(62, 27);
  }
  
  CCSprite *lootBgd = [CCSprite spriteWithImageNamed:@"collectioncapsule.png"];
  [self addChild:lootBgd];
  lootBgd.position = ccp(puzzleBg.position.x-puzzleBg.contentSize.width/2-lootBgd.contentSize.width/2-5,
                        36*3.5);

  _lootLabel = [CCLabelTTF labelWithString:@"0" fontName:[Globals font] fontSize:13];
  [lootBgd addChild:_lootLabel];
  _lootLabel.color = [CCColor blackColor];
  _lootLabel.rotation = -20.f;
  _lootLabel.position = ccp(lootBgd.contentSize.width-13, lootBgd.contentSize.height/2-1);
  
  _comboBgd = [CCSprite spriteWithImageNamed:@"combobg.png"];
  _comboBgd.anchorPoint = ccp(1, 0.5);
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  [self.orbBgdLayer addChild:clip z:self.orbLayer.zOrder];
  clip.contentSize = CGSizeMake(_comboBgd.contentSize.width*2, _comboBgd.contentSize.height*3);
  clip.anchorPoint = ccp(1, 0.5);
  clip.position = ccp(self.orbLayer.position.x+self.orbLayer.contentSize.width/2, 54);
  clip.scale = 1.5;
  
  [clip addChild:_comboBgd];
  _comboBgd.position = ccp(clip.contentSize.width+2*_comboBgd.contentSize.width, _comboBgd.parent.contentSize.height/2);
  
  _comboLabel = [CCLabelTTF labelWithString:@"2x" fontName:@"Gotham-UltraItalic" fontSize:23];
  _comboLabel.anchorPoint = ccp(1, 0.5);
  _comboLabel.position = ccp(_comboBgd.contentSize.width-5, 32);
  [_comboBgd addChild:_comboLabel z:1];
  
  _comboBotLabel = [CCLabelTTF labelWithString:@"COMBO" fontName:@"Gotham-Ultra" fontSize:12];
  _comboBotLabel.anchorPoint = ccp(1, 0.5);
  _comboBotLabel.position = ccp(_comboBgd.contentSize.width-5, 14);
  [_comboBgd addChild:_comboBotLabel z:1];
  
  _comboCount = 0;
  _currentScore = 0;
  _movesLeft = NUM_MOVES_PER_TURN;
  _soundComboCount = 0;
  _curStage = -1;
  
  [self updateHealthBars];
}

- (void) createNextMyPlayerSprite {
  BattleSprite *mp = [[BattleSprite alloc] initWithPrefix:self.myPlayerObject.spritePrefix nameString:self.myPlayerObject.name isMySprite:YES];
  mp.healthBar.color = [self.orbLayer colorForSparkle:self.myPlayerObject.element];
  [self.bgdContainer addChild:mp z:0];
  mp.position = MY_PLAYER_LOCATION;
  if (_puzzleIsOnLeft) mp.position = ccpAdd(MY_PLAYER_LOCATION, ccp(PUZZLE_ON_LEFT_BGD_OFFSET, 0));
  mp.isFacingNear = NO;
  self.myPlayer = mp;
  [self updateHealthBars];
  
  self.orbLayer.orbFlyToLocation = [self.orbLayer convertToNodeSpace:[self.bgdContainer convertToWorldSpace:ccpAdd(mp.position, ccp(0, mp.contentSize.height/2))]];
}

- (void) makeMyPlayerWalkOut {
  CGPoint startPos = self.myPlayer.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -self.myPlayer.contentSize.width;
  float xDelta = startPos.x-startX;
  CGPoint endPos = ccp(startX, startPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  self.myPlayer.isFacingNear = YES;
  [self.myPlayer beginWalking];
  [self.myPlayer runAction:[CCActionMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED position:endPos]];
  [self stopPulsing];
}

- (void) makeMyPlayerWalkInFromEntranceWithSelector:(SEL)selector {
  CGPoint finalPos = self.myPlayer.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -self.myPlayer.contentSize.width;
  float xDelta = finalPos.x-startX;
  CGPoint newPos = ccp(startX, finalPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  [self.myPlayer beginWalking];
  self.myPlayer.position = newPos;
  [self.myPlayer runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, newPos)/MY_WALKING_SPEED position:finalPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
       if (perc < PULSE_CONT_THRESH) {
         [self pulseBloodContinuously];
         [self pulseHealthLabel:NO];
       } else {
         [self stopPulsing];
       }
       
       [self.myPlayer stopWalking];
       [self updateHealthBars];
       [self performSelector:selector];
     }],
    nil]];
}

- (void) moveToNextEnemy {
  _curStage++;
  [self.myPlayer beginWalking];
  [self.bgdLayer scrollToNewScene];
  
  if (_curStage < _numStages) {
    [self spawnNextEnemy];
    [self displayWaveNumber];
  } else {
    [self runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:2.f], [CCActionCallFunc actionWithTarget:self selector:@selector(youWon)], nil]];
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
  BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:self.enemyPlayerObject.spritePrefix nameString:self.enemyPlayerObject.name isMySprite:NO];
  bs.healthBar.color = [self.orbLayer colorForSparkle:self.enemyPlayerObject.element];
  [self.bgdContainer addChild:bs];
  self.currentEnemy = bs;
  self.currentEnemy.isFacingNear = YES;
  [self updateHealthBars];
}

- (void) createNextEnemyObject {
  if (self.enemyTeam.count > _curStage) {
    self.enemyPlayerObject = [self.enemyTeam objectAtIndex:_curStage];
  } else {
    self.enemyPlayerObject = nil;
  }
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
  
  [self.powerBar stopAllActions];
  _powerBar.percentage = ((float)_currentScore)/MAKEITRAIN_SCORE*100;
}

- (void) updatePowerBar {
  float newPerc = ((float)_currentScore)/MAKEITRAIN_SCORE*100;
  float diff = newPerc-self.powerBar.percentage;
  CCAction *a = [CCActionProgressTo actionWithDuration:diff/50.f percent:newPerc];
  a.tag = 18302;
  [self.powerBar stopActionByTag:a.tag];
  [self.powerBar runAction:a];
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

- (void) checkForReshuffle {
  
}

- (void) beginMyTurn {
  _comboCount = 0;
  _orbCount = 0;
  _currentScore = 0;
  _movesLeft = NUM_MOVES_PER_TURN;
  _scoreForThisTurn = 0;
  _soundComboCount = 0;
  
  [self updateHealthBars];
  [self removeNoInputLayer];
  [self.orbLayer allowInput];
}

- (void) beginEnemyTurn {
  int damage = arc4random()%300+100;
  
  _enemyDamagePercent = damage;
  
  [self.currentEnemy performNearAttackAnimationWithTarget:self selector:@selector(dealEnemyDamage)];
}

- (void) checkIfAnyMovesLeft {
  if (_movesLeft == 0) {
    [self myTurnEnded];
  } else {
    [self.orbLayer allowInput];
    _scoreForThisTurn = 0;
  }
}

- (void) myTurnEnded {
  [self showHighScoreWord];
  [self displayNoInputLayer];
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(doMyAttackAnimation)];
}

- (void) doMyAttackAnimation {
  if (_currentScore > MAKEITRAIN_SCORE) {
    [self.myPlayer restoreStandingFrame];
    [self spawnPlaneWithTarget:nil selector:nil];
  }
  
  float strength = MIN(1, _currentScore/STRENGTH_FOR_MAX_SHOTS);
  [self.myPlayer performFarAttackAnimationWithStrength:strength target:nil selector:nil];
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.3],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [self.currentEnemy performNearFlinchAnimationWithStrength:strength target:self selector:@selector(dealMyDamage)];
                    }],
                   nil]];
}

- (void) dealMyDamage {
  [self dealDamageWithPercent:_currentScore enemyIsAttacker:NO withSelector:@selector(checkEnemyHealth)];
  
  float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
  if (perc < PULSE_CONT_THRESH) {
    [self pulseHealthLabel:YES];
  } else {
    [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
    self.currentEnemy.healthLabel.color = [CCColor whiteColor];
  }
}

- (void) dealEnemyDamage {
  [self dealDamageWithPercent:_enemyDamagePercent enemyIsAttacker:YES withSelector:@selector(checkMyHealth)];
  
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

- (void) dealDamageWithPercent:(int)percent enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector {
  Globals *gl = [Globals sharedGlobals];
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
  int damageDone = [att totalAttackPower]*percent/100.f;
  damageDone = damageDone*[gl calculateDamageMultiplierForAttackElement:att.element defenseElement:def.element];
  int newHealth = MIN(def.maxHealth, MAX(0, curHealth-damageDone));
  float newPercent = ((float)newHealth)/def.maxHealth*100;
  float percChange = ABS(healthBar.percentage-newPercent);
  
  damageDone = damageDone < 0 ? curHealth-newHealth : damageDone;
  
  [healthBar runAction:[CCActionSequence actions:
                        [CCActionEaseIn actionWithAction:[CCActionProgressTo actionWithDuration:percChange/HEALTH_BAR_SPEED percent:newPercent]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           
                           _currentScore = 0;
                           [self updateHealthBars];
                         }],
                        [CCActionCallFunc actionWithTarget:self selector:selector],
                        nil]];
  
  CCActionRepeat *f = [CCActionRepeatForever actionWithAction:
                 [CCActionSequence actions:
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:(int)(healthBar.percentage/100.f*def.maxHealth)], [Globals commafyNumber:def.maxHealth]];
                   }],
                  [CCActionDelay actionWithDuration:0.01],
                  nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"-%@", [Globals commafyNumber:damageDone]] fontName:[Globals font] fontSize:25];
  [self.bgdContainer addChild:damageLabel z:defSpr.zOrder];
  damageLabel.position = ccpAdd(defSpr.position, ccp(0, defSpr.contentSize.height-15));
  damageLabel.color = [CCColor colorWithCcColor3b:ccc3(255, 0, 0)];
  damageLabel.scale = 0.01;
  [damageLabel runAction:[CCActionSequence actions:
                          [CCActionSpawn actions:
                           [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                           [CCActionFadeOut actionWithDuration:1.5f],
                           [CCActionMoveBy actionWithDuration:1.5f position:ccp(0,25)],nil],
                          [CCActionCallFunc actionWithTarget:damageLabel selector:@selector(removeFromParent)], nil]];
  
  def.curHealth = newHealth;
  
  if (enemyIsAttacker) {
    [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:def.userMonsterId curHealth:def.curHealth];
  }
}

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block {
  [sprite runAction:[CCActionSequence actions:[RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                     [CCActionDelay actionWithDuration:0.7f],
                     [CCActionCallFunc actionWithTarget:sprite selector:@selector(removeFromParent)],
                     [CCActionCallBlock actionWithBlock:block], nil]];
  
  CCParticleSystemBase *q = [CCParticleSystemBase particleWithFile:@"characterdie.plist"];
  q.autoRemoveOnFinish = YES;
  q.position = ccpAdd(sprite.position, ccp(0, sprite.contentSize.height/2-5));
  [self.bgdContainer addChild:q z:0];
}

- (void) checkEnemyHealth {
  if (self.enemyPlayerObject.curHealth <= 0) {
    int loot = [self getCurrentEnemyLoot];
    if (loot) {
      [self dropLoot:loot];
    }
    
    [self blowupBattleSprite:self.currentEnemy withBlock:
     ^{
       self.enemyPlayerObject = nil;
       [self updateHealthBars];
       [self moveToNextEnemy];
     }];
    self.currentEnemy = nil;
  } else {
    [self beginEnemyTurn];
  }
}

- (int) getCurrentEnemyLoot {
  // Should be implemented
  return 0;
}

- (void) checkMyHealth {
  if (self.myPlayerObject.curHealth <= 0) {
    [self stopPulsing];
    
    [self blowupBattleSprite:self.myPlayer withBlock:^{
      self.myPlayerObject = nil;
      [self updateHealthBars];
      
      [self currentMyPlayerDied];
    }];
    self.myPlayer = nil;
  } else {
    [self beginMyTurn];
  }
}

- (void) currentMyPlayerDied {
  // Overwrite this
  if (self.myPlayerObject) {
    [self createNextMyPlayerSprite];
    [self makeMyPlayerWalkInFromEntranceWithSelector:@selector(beginMyTurn)];
  } else {
    [self youLost];
  }
}

- (void) displayWaveNumber {
  float initDelay = 1.4;
  float fadeTime = 0.2;
  float delayTime = 1.05;
  
  CCNodeColor *l = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(0, 0, 0, 0)] width:self.contentSize.width height:self.contentSize.height];
  [self addChild:l];
  [l runAction:[CCActionSequence actions:
                [CCActionDelay actionWithDuration:initDelay],
                [CCActionFadeTo actionWithDuration:fadeTime opacity:180],
                [CCActionDelay actionWithDuration:delayTime],
                [CCActionFadeTo actionWithDuration:fadeTime opacity:0],
                [CCActionCallBlock actionWithBlock:
                 ^{
                   [l removeFromParentAndCleanup:YES];
                 }], nil]];
  
  CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Enemy %d/%d", _curStage+1, _numStages] fntFile:@"wavefont.fnt"];
  [self addChild:label];
  label.position = ccp(CENTER_OF_BATTLE.x, -label.contentSize.height/2);
  
  [label runAction:[CCActionSequence actions:
                    [CCActionDelay actionWithDuration:initDelay],
                    [CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:fadeTime position:ccp(label.position.x, self.contentSize.height/2)]],
                    [CCActionDelay actionWithDuration:delayTime],
                    [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:fadeTime position:ccp(label.position.x, self.contentSize.height+label.contentSize.height)]],
                    [CCActionCallBlock actionWithBlock:
                     ^{
                       [label removeFromParentAndCleanup:YES];
                     }], nil]];
}

- (void) dropLoot:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:equipId];
  NSString *fileName = [Globals imageNameForRarity:mp.quality suffix:@"piece.png"];
  CCSprite *ed = [CCSprite spriteWithImageNamed:fileName];
  [self.bgdContainer addChild:ed z:-1];
  ed.position = ccpAdd(self.currentEnemy.position, ccp(0,self.currentEnemy.contentSize.height/2));
  ed.scale = 0.01;
  ed.opacity = 0.1f;
  
  float scale = 25.f/ed.contentSize.width;
  float distScale = 0.2f;
  
  ccBezierConfig bezier;
  bezier.endPosition = [self.bgdContainer convertToNodeSpace:[self.lootLabel.parent.parent convertToWorldSpace:self.lootLabel.parent.position]];
  bezier.controlPoint_1 = ccp(ed.position.x+(bezier.endPosition.x-ed.position.x)/3,bezier.endPosition.y+(ed.position.y-bezier.endPosition.y)/2+10);
  bezier.controlPoint_2 = ccp(ed.position.x+(bezier.endPosition.x-ed.position.x)*2/3,bezier.endPosition.y+(ed.position.y-bezier.endPosition.y)/2+10);
  CCActionBezierTo *bezierForward = [CCActionBezierTo actionWithDuration:0.3f bezier:bezier];
  
  [ed runAction:[CCActionSpawn actions:
                 [CCActionFadeIn actionWithDuration:0.1],
                 [CCActionScaleTo actionWithDuration:0.1 scale:scale],
                 [CCActionSequence actions:
                  [CCActionMoveBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,20)],
                  [CCActionEaseBounceOut actionWithAction:
                   [CCActionMoveBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-15-self.currentEnemy.contentSize.height/2)]],
                  [CCActionMoveBy actionWithDuration:TIME_TO_SCROLL_PER_SCENE*distScale*POINT_OFFSET_PER_SCENE.y/Y_MOVEMENT_FOR_NEW_SCENE position:ccpMult(POINT_OFFSET_PER_SCENE, -distScale)],
                  [CCActionSpawn actions:bezierForward,
                   [CCActionScaleBy actionWithDuration:bezierForward.duration scale:0.3], nil],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [ed removeFromParentAndCleanup:YES];
                     
                     _lootCount++;
                     CCActionScaleBy *scale = [CCActionScaleBy actionWithDuration:0.25 scale:1.4];
                     _lootLabel.string = [Globals commafyNumber:_lootCount];
                     [_lootLabel runAction:
                      [CCActionSequence actions:
                       scale,
                       scale.reverse, nil]];
                   }],
                  nil],
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
    
    //CGPoint offset = ccpMult(POINT_OFFSET_PER_SCENE, 0.02);
    //offset = ccp((i%2==0?-1:1)*offset.y,(i%2==1?-1:1)*offset.x);
    //endPos = ccpAdd(endPos, offset);
    
    bomb.position = ccp(endPos.x, endPos.y+130);
    
    [bomb runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:0.85f+0.1*i],
      [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.7f position:endPos]],
      [CCActionCallBlock actionWithBlock:
       ^{
         [[CCTextureCache sharedTextureCache] addImage:@"bombdrop.png"];
         CCParticleSystemBase *q = [CCParticleSystemBase particleWithFile:@"bombdrop.plist"];
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
  
  [[SoundEngine sharedSoundEngine] puzzlePlane];
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
  if (_currentScore > MAKEITRAIN_SCORE) {
    isMakeItRain = YES;
  } else if (_currentScore > HAMMERTIME_SCORE) {
    phraseFile = @"hammertime.png";
  } else if (_currentScore > CANTTOUCHTHIS_SCORE) {
    phraseFile = @"canttouchthis.png";
  } else if (_currentScore > BALLIN_SCORE) {
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
                  [CCActionFadeTo actionWithDuration:0.3 opacity:180],
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
  } else {
    [target performSelector:selector];
  }
}

- (void) youWon {
}

- (void) youLost {
}

#pragma mark - Blood Splatter

- (CCSprite *) bloodSplatter {
  if (!_bloodSplatter) {
    CCSprite *s = [CCSprite spriteWithImageNamed:@"bloodsplatter.png"];
    [self addChild:s z:1];
    s.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _bloodSplatter = s;
  }
  return _bloodSplatter;
}

- (void) pulseBloodOnce {
  CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:0.5f opacity:255];
  CCActionFadeTo *fadeOut = [CCActionFadeTo actionWithDuration:0.5f opacity:0];
  self.bloodSplatter.opacity = 0;
  [self.bloodSplatter runAction:
   [CCActionSequence actions:fadeIn, fadeOut, nil]];
}

- (void) pulseBloodContinuously {
  [self stopAllActions];
  CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:1.f opacity:255];
  CCActionFadeTo *fadeOut = [CCActionFadeTo actionWithDuration:1.f opacity:140];
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
  _bloodSplatter.opacity = 0;
  [self.myPlayer.healthLabel stopActionByTag:RED_TINT_TAG];
  self.myPlayer.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
}

#pragma mark - Delegate Methods

- (void) moveBegan {
  
}

- (void) newComboFound {
  _comboCount++;
  
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
  
  if (_comboCount == 2) {
    [_comboBgd stopAllActions];
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
    CCParticleSystemBase *q = [CCParticleSystemBase particleWithFile:@"ComboFire4.plist"];
    q.autoRemoveOnFinish = YES;
    q.position = ccp(_comboBgd.contentSize.width/2+15, _comboBgd.contentSize.height/2+5);
    q.positionType = CCPositionTypeNormalized;
    [_comboBgd addChild:q z:0 name:COMBO_FIRE_TAG];
    
    _comboLabel.color = [CCColor blackColor];
    _comboBotLabel.color = [CCColor blackColor];
  }
  
  if (_canPlayNextComboSound) {
    _soundComboCount++;
    [[SoundEngine sharedSoundEngine] puzzleComboSound:_soundComboCount];
    _canPlayNextComboSound = NO;
    [self schedule:@selector(allowComboSound) interval:0.02];
  }
}

- (void) allowComboSound {
  [self unschedule:@selector(allowComboSound)];
  _canPlayNextComboSound = YES;
}

- (void) gemKilled:(Gem *)gem {
  _orbCount++;
  
  int dmg = [self.myPlayerObject damageForColor:gem.color];
  float percDamageIncrease = 100.f*dmg/[self.myPlayerObject totalAttackPower];
  _currentScore += percDamageIncrease;
  _scoreForThisTurn += percDamageIncrease;
  
  if (MonsterProto_MonsterElementIsValidValue((MonsterProto_MonsterElement)gem.color)) {
    NSString *dmgStr = [NSString stringWithFormat:@"%@", [Globals commafyNumber:dmg]];
    NSString *fntFile = [Globals imageNameForElement:(MonsterProto_MonsterElement)gem.color suffix:@"pointsfont.fnt"];
    fntFile = fntFile ? fntFile : @"nightpointsfont.fnt";
    if (fntFile) {
      CCLabelBMFont *dmgLabel = [CCLabelBMFont labelWithString:dmgStr fntFile:fntFile];
      dmgLabel.position = [self.orbLayer pointForGridPosition:[self.orbLayer coordinateOfGem:gem]];
      [self.orbLayer addChild:dmgLabel z:101];
      
      dmgLabel.scale = 0.25;
      [dmgLabel runAction:[CCActionSequence actions:
                           [CCActionScaleTo actionWithDuration:0.2f scale:1],
                           [CCActionSpawn actions:
                            [CCActionFadeOut actionWithDuration:0.5f],
                            [CCActionMoveBy actionWithDuration:0.5f position:ccp(0,10)],nil],
                           [CCActionCallFunc actionWithTarget:dmgLabel selector:@selector(removeFromParent)], nil]];
    }
  }
  
  [self updatePowerBar];
  if (_canPlayNextGemPop) {
    [[SoundEngine sharedSoundEngine] puzzleGemPop];
    _canPlayNextGemPop = NO;
    [self schedule:@selector(allowGemPop) interval:0.02];
  }
}

- (void) gemReachedFlyLocation:(Gem *)gem {
}

- (void) allowGemPop {
  [self unschedule:@selector(allowGemPop)];
  _canPlayNextGemPop = YES;
}

- (void) moveComplete {
  if (_scoreForThisTurn == 0) {
    [self.orbLayer allowInput];
    return;
  }
  
  _movesLeft--;
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
  [self checkIfAnyMovesLeft];
  
  _comboCount = 0;
}

- (void) reshuffle {
  CCLabelTTF *label = [CCLabelTTF labelWithString:@"No more moves!\nShuffling..." fontName:[Globals font] fontSize:25];
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
  [self.myPlayer stopWalking];
  
  if (self.enemyPlayerObject) {
    [self beginMyTurn];
    [self updateHealthBars];
  }
}

#pragma mark - Charging

- (void) beginChargingUpForEnemy:(BOOL)isEnemy withTarget:(id)target selector:(SEL)selector {
  // isEnemy no longer works
  CCProgressNode *prog = self.powerBar;
  
  [prog runAction:[CCActionSequence actions:
                   [CCActionProgressTo actionWithDuration:prog.percentage*0.015 percent:0],
                   [CCActionCallFunc actionWithTarget:target selector:selector],
                   nil]];
  
  [[SoundEngine sharedSoundEngine] puzzlePowerUp];
}

#pragma mark - No Input Layer Methods

- (void) displayNoInputLayer {
  [self.noInputLayer runAction:[CCActionFadeTo actionWithDuration:0.3 opacity:NO_INPUT_LAYER_OPACITY]];
}

- (void) removeNoInputLayer {
  [self.noInputLayer runAction:[CCActionFadeTo actionWithDuration:0.3 opacity:0]];
}

@end

#pragma clang diagnostic pop
