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

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define Y_MOVEMENT_FOR_NEW_SCENE 140
#define TIME_TO_SCROLL_PER_SCENE 3.f
#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#define BALLIN_SCORE 130
#define CANTTOUCHTHIS_SCORE 170
#define HAMMERTIME_SCORE 210
#define MAKEITRAIN_SCORE 300

#define NUM_MOVES_PER_TURN 3

#define PULSE_ONCE_THRESH 0.5
#define PULSE_CONT_THRESH 0.3
#define RED_TINT_TAG 6789

#define STRENGTH_FOR_MAX_SHOTS 300

#define NUM_CHARGING_COLORS 7
#define CHARGING_COLOR_1 ccc3(255, 255, 0)
#define CHARGING_COLOR_2 ccc3(61, 255, 0)
#define CHARGING_COLOR_3 ccc3(0, 255, 92)
#define CHARGING_COLOR_4 ccc3(0, 255, 255)
#define CHARGING_COLOR_5 ccc3(0, 25, 255)
#define CHARGING_COLOR_6 ccc3(80, 0, 255)
#define CHARGING_COLOR_7 ccc3(255, 0, 255)

#define PUZZLE_BGD_TAG 1456

#define NO_INPUT_LAYER_OPACITY 150

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
  [self runAction:[CCSequence actions:
                   [CCMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:ccp(nextBaseX, nextBaseY)],
                   [CCCallFunc actionWithTarget:self selector:@selector(removePastScenes)],
                   [CCCallFunc actionWithTarget:self.delegate selector:@selector(reachedNextScene)],
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
  CCSprite *left1 = [CCSprite spriteWithFile:@"scene1left.png"];
  CCSprite *right1 = [CCSprite spriteWithFile:@"scene1right.png"];
  
  left1.position = ccp(pos.x+left1.contentSize.width/2, pos.y+left1.contentSize.height/2);
  right1.position = ccp(left1.position.x+left1.contentSize.width/2+right1.contentSize.width/2,
                        left1.position.y);
  
  [self addChild:left1];
  [self addChild:right1];
  
  CCSprite *left2 = [CCSprite spriteWithFile:@"scene2left.png"];
  CCSprite *right2 = [CCSprite spriteWithFile:@"scene2right.png"];
  
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

- (id) initWithMyUserMonsters:(NSArray *)monsters {
  if ((self = [super init])) {
    CCSprite *s = [CCSprite spriteWithFile:@"puzzlebg.png"];
    [self addChild:s z:2 tag:PUZZLE_BGD_TAG];
    s.position = ccp(self.contentSize.width/2, s.contentSize.height/2);
    
    OrbLayer *ol = [[OrbLayer alloc] initWithContentSize:CGSizeMake(290, 180) gridSize:CGSizeMake(8, 5) numColors:5];
    ol.position = ccp(self.contentSize.width/2-ol.contentSize.width/2, 0);
    [self addChild:ol z:3];
    ol.delegate = self;
    self.orbLayer = ol;
    
    self.noInputLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, NO_INPUT_LAYER_OPACITY) width:self.orbLayer.contentSize.width height:self.orbLayer.contentSize.height];
    [self addChild:self.noInputLayer z:self.orbLayer.zOrder];
    self.noInputLayer.position = self.orbLayer.position;
    
    self.bgdLayer = [BattleBgdLayer node];
    [self addChild:self.bgdLayer z:-100];
    self.bgdLayer.position = ccp(-733+self.contentSize.width/2, 0);
    self.bgdLayer.delegate = self;
    
    [self setupHealthBars];
    
    // Different colors for the particle effect
    _numChargingColors = NUM_CHARGING_COLORS;
    _chargingColors = malloc(_numChargingColors*sizeof(ccColor3B));
    _chargingColors[0] = CHARGING_COLOR_1;
    _chargingColors[1] = CHARGING_COLOR_2;
    _chargingColors[2] = CHARGING_COLOR_3;
    _chargingColors[3] = CHARGING_COLOR_4;
    _chargingColors[4] = CHARGING_COLOR_5;
    _chargingColors[5] = CHARGING_COLOR_6;
    _chargingColors[6] = CHARGING_COLOR_7;
    
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

- (void) onEnter {
  [super onEnter];
  [self begin];
}

- (void) begin {
  [self moveToNextEnemy];
}

- (void) setupHealthBars {
  CCSprite *movesLeftBgd = [CCSprite spriteWithFile:@"movesleft.png"];
  CCSprite *puzzleBg = (CCSprite *)[self getChildByTag:PUZZLE_BGD_TAG];
  [self addChild:movesLeftBgd];
  movesLeftBgd.position = ccp(puzzleBg.position.x-self.orbLayer.contentSize.width/2+movesLeftBgd.contentSize.width/2, puzzleBg.position.y+puzzleBg.contentSize.height/2+movesLeftBgd.contentSize.height/2-17);
  
  CCLabelTTF *movesLabel = [CCLabelTTF labelWithString:@"MOVES:" fontName:[Globals font] fontSize:11];
  [movesLeftBgd addChild:movesLabel];
  movesLabel.position = ccp(22, 20);
  movesLabel.color = ccc3(150, 150, 150);
  
  _movesLeftLabel = [CCLabelTTF labelWithString:@"5" fontName:[Globals font] fontSize:21];
  [movesLeftBgd addChild:_movesLeftLabel];
  _movesLeftLabel.position = ccp(movesLeftBgd.contentSize.width-14, 24);
  _movesLeftLabel.color = ccc3(176, 223, 33);
  
  _leftDamageBgd = [CCSprite spriteWithFile:@"damagebg.png"];
  [self addChild:_leftDamageBgd z:1];
  _leftDamageBgd.position = ccpAdd(movesLeftBgd.position, ccp(0,33));
  [self reorderChild:movesLeftBgd z:1];
  
  CCSprite *topLabel = [CCSprite spriteWithFile:@"damagelabel.png"];
  [_leftDamageBgd addChild:topLabel];
  topLabel.position = ccp(_leftDamageBgd.contentSize.width/2, _leftDamageBgd.contentSize.height*2/3+4);
  
  CCNode *n = [CCNode node];
  [_leftDamageBgd addChild:n];
  n.position = ccp(35,20);
  
  _leftDamageLabel = [CCLabelBMFont labelWithString:@"100" fntFile:@"numbers.fnt"];
  _leftDamageLabel.scale = 0.7;
  [n addChild:_leftDamageLabel];
  _leftDamageLabel.anchorPoint = ccp(1, 0.5);
  _leftDamageLabel.position = ccp(4, 0);
  
  CCSprite *percentLabel = [CCSprite spriteWithFile:@"percent.png"];
  [n addChild:percentLabel];
  percentLabel.position = ccp(13, 3);
  
  _rightDamageBgd = [CCSprite spriteWithFile:@"opponentsbg.png"];
  [self addChild:_rightDamageBgd];
  _rightDamageBgd.position = ccp(puzzleBg.position.x+self.orbLayer.contentSize.width/2-_rightDamageBgd.contentSize.width/2, puzzleBg.position.y+puzzleBg.contentSize.height/2+_rightDamageBgd.contentSize.height/2-8);
  
  topLabel = [CCSprite spriteWithFile:@"damagelabel.png"];
  [_rightDamageBgd addChild:topLabel];
  topLabel.position = ccp(_rightDamageBgd.contentSize.width/2, _rightDamageBgd.contentSize.height*2/3+4);
  
  _rightDamageLabel = [CCLabelBMFont labelWithString:@"100" fntFile:@"numbers.fnt"];
  [_rightDamageBgd addChild:_rightDamageLabel];
  _rightDamageLabel.anchorPoint = ccp(1, 0.5);
  _rightDamageLabel.position = ccp(39, 15);
  _rightDamageLabel.scale = 0.7;
  
  percentLabel = [CCSprite spriteWithFile:@"percent.png"];
  [_rightDamageBgd addChild:percentLabel];
  percentLabel.position = ccp(48, 18);
  
  [_rightDamageBgd recursivelyApplyOpacity:0];
  
  CCSprite *lootBgd = [CCSprite spriteWithFile:@"lootcollect.png"];
  [self addChild:lootBgd];
  lootBgd.position = ccp(puzzleBg.position.x-puzzleBg.contentSize.width/2+lootBgd.contentSize.width/2+10,
                         puzzleBg.position.y+puzzleBg.contentSize.height/2+lootBgd.contentSize.height/2-5);
  
  _lootLabel = [CCLabelTTF labelWithString:@"0" fontName:[Globals font] fontSize:13];
  [lootBgd addChild:_lootLabel];
  _lootLabel.position = ccp(lootBgd.contentSize.width-12, lootBgd.contentSize.height/2);
  
  [self schedule:@selector(updateLabels) interval:0.05];
  _comboCount = 1;
  _currentScore = 0;
  _labelScore = 0;
  _movesLeft = NUM_MOVES_PER_TURN;
  _soundComboCount = 0;
  _curStage = -1;
}

- (void) createNextMyPlayerSprite {
  BattleSprite *mp = [[BattleSprite alloc] initWithPrefix:self.myPlayerObject.spritePrefix];
  [self addChild:mp z:0];
  mp.position = ccp(self.contentSize.width/2-15,191);
  mp.isFacingNear = NO;
  self.myPlayer = mp;
  [self updateHealthBars];
}

- (void) makeMyPlayerWalkOut {
  CGPoint startPos = self.myPlayer.position;
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  float startX = -self.myPlayer.contentSize.width;
  float xDelta = startPos.x-startX;
  CGPoint endPos = ccp(startX, startPos.y-xDelta*offsetPerScene.y/offsetPerScene.x);
  
  self.myPlayer.isFacingNear = YES;
  [self.myPlayer beginWalking];
  [self.myPlayer runAction:[CCMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED position:endPos]];
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
   [CCSequence actions:
    [CCMoveTo actionWithDuration:ccpDistance(finalPos, newPos)/MY_WALKING_SPEED position:finalPos],
    [CCCallBlock actionWithBlock:
     ^{
       float perc = ((float)self.myPlayerObject.curHealth)/self.myPlayerObject.maxHealth;
       if (perc < PULSE_CONT_THRESH) {
         [self pulseBloodContinuously];
         [self pulseHealthLabel:NO];
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
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.f], [CCCallFunc actionWithTarget:self selector:@selector(youWon)], nil]];
  }
}

- (void) spawnNextEnemy {
  [self createNextEnemyObject];
  [self createNextEnemySprite];
  
  CGPoint finalPos = ccp(self.contentSize.width/2+65,245);
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
  
  self.currentEnemy.position = newPos;
  [self.currentEnemy runAction:[CCMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos]];
  
  [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
  self.currentEnemy.healthLabel.color = ccc3(255,255,255);
}

- (void) createNextEnemySprite {
  BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:self.enemyPlayerObject.spritePrefix];
  [self addChild:bs];
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
  }}

- (void) updateLabels {
  if (!_isChargingUp) {
    int curScore = (int)roundf(_currentScore);
    if (curScore > _labelScore) {
      int diff = curScore - _labelScore;
      int change = MAX((int)(0.1*diff), 1);
      _leftDamageLabel.string = [Globals commafyNumber:_labelScore+change];
      _labelScore += change;
      
      [self pulseLabel:_leftDamageLabel.parent];
    } else if (curScore < _labelScore) {
      _leftDamageLabel.string = [Globals commafyNumber:curScore];
      _labelScore = curScore;
      
      [_leftDamageLabel.parent stopAllActions];
      _leftDamageLabel.parent.scale = 1;
    }
    
    if (_labelScore > 200) {
      [self pulseLabel:_leftDamageLabel.parent];
    }
  }
  
  _movesLeftLabel.string = [NSString stringWithFormat:@"%d", _movesLeft];
}

- (void) pulseLabel:(CCNode *)label {
  if (![label getActionByTag:924]) {
    CCScaleBy *a = [CCScaleBy actionWithDuration:0.4f scale:1.2];
    CCAction *b = [a reverse];
    CCSequence *seq = [CCEaseSineInOut actionWithAction:[CCSequence actions:a, b, nil]];
    seq.tag = 924;
    [label runAction:seq];
  }
}

#pragma mark - Turn Sequence

- (void) beginMyTurn {
  _comboCount = 1;
  _orbCount = 0;
  _currentScore = 0;
  _movesLeft = NUM_MOVES_PER_TURN;
  _scoreForThisTurn = 0;
  _labelScore = 101;
  _isChargingUp = NO;
  _soundComboCount = 0;
  
  self.leftDamageLabel.parent.scale = 1.f;
  
  [self.leftDamageBgd runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:255]];
  [self.rightDamageBgd runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0]];
  
  [self.orbLayer allowInput];
  [self removeNoInputLayer];
}

- (void) beginEnemyTurn {
  [self.rightDamageBgd runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:255]];
  [self.leftDamageBgd runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0]];
  
  int damage = arc4random()%300+100;
  self.rightDamageLabel.string = @"100";
  int numTimes = damage > 150 ? 20 : (damage-100)/5;
  float increment = damage > 150 ? (damage-100) / 20.f : 5;
  __block int curNum = 0;
  
  CCCallBlock *call = [CCCallBlock actionWithBlock:^{
    curNum++;
    self.rightDamageLabel.string = [NSString stringWithFormat:@"%d", (int)(100+curNum*increment)];
  }];
  CCRepeat *repeat = [CCRepeat actionWithAction:[CCSequence actions:call, [CCDelayTime actionWithDuration:0.05], nil] times:numTimes];
  [self runAction:[CCSequence actions:repeat,
                   [CCCallBlock actionWithBlock:
                    ^{
                      self.rightDamageLabel.string = [NSString stringWithFormat:@"%d", damage];
                      [self.currentEnemy performNearAttackAnimationWithTarget:self selector:@selector(dealEnemyDamage)];
                    }], nil]];
  
  _enemyDamagePercent = damage;
}

- (void) checkIfAnyMovesLeft {
  if (_movesLeft == 0) {
    [self beginChargingUpForEnemy:NO withTarget:self selector:@selector(showHighScoreWord)];
    [self displayNoInputLayer];
  } else {
    [self.orbLayer allowInput];
    _scoreForThisTurn = 0;
  }
}

- (void) showHighScoreWord {
  [self showHighScoreWordWithTarget:self selector:@selector(doMyAttackAnimation)];
}

- (void) doMyAttackAnimation {
  if (_currentScore > MAKEITRAIN_SCORE) {
    [self.myPlayer restoreStandingFrame];
    [self spawnPlaneWithTarget:nil selector:nil];
  }
  
  float strength = MIN(1, (_currentScore-100)/(STRENGTH_FOR_MAX_SHOTS-100.f));
  [self.myPlayer performFarAttackAnimationWithStrength:strength target:nil selector:nil];
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:0.3],
                   [CCCallBlock actionWithBlock:
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
    self.currentEnemy.healthLabel.color = ccc3(255, 255, 255);
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
  BattlePlayer *att, *def;
  BattleSprite *attSpr, *defSpr;
  CCLabelTTF *healthLabel;
  CCProgressTimer *healthBar;
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
  int newHealth = MIN(def.maxHealth, MAX(0, curHealth-damageDone));
  float newPercent = ((float)newHealth)/def.maxHealth*100;
  float percChange = ABS(healthBar.percentage-newPercent);
  
  damageDone = damageDone < 0 ? curHealth-newHealth : damageDone;
  
  [healthBar runAction:[CCSequence actions:
                        [CCEaseSineIn actionWithAction:[CCProgressTo actionWithDuration:percChange/HEALTH_BAR_SPEED percent:newPercent]],
                        [CCCallBlock actionWithBlock:
                         ^{
                           [healthLabel stopActionByTag:1015];
                           [self updateHealthBars];
                         }],
                        [CCCallFunc actionWithTarget:self selector:selector],
                        nil]];
  
  CCRepeat *f = [CCRepeatForever actionWithAction:
                 [CCSequence actions:
                  [CCCallBlock actionWithBlock:
                   ^{
                     healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:(int)(healthBar.percentage/100.f*def.maxHealth)], [Globals commafyNumber:def.maxHealth]];
                   }],
                  [CCDelayTime actionWithDuration:0.01],
                  nil]];
  f.tag = 1015;
  [healthLabel runAction:f];
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%+d", -damageDone] fontName:[Globals font] fontSize:25];
  [self addChild:damageLabel z:defSpr.zOrder];
  damageLabel.position = ccpAdd(defSpr.position, ccp(0, defSpr.contentSize.height-15));
  damageLabel.color = ccc3(255, 0, 0);
  damageLabel.scale = 0.01;
  [damageLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.2f scale:1]],
                           [CCFadeOut actionWithDuration:1.5f],
                           [CCMoveBy actionWithDuration:1.5f position:ccp(0,25)],nil],
                          [CCCallFunc actionWithTarget:damageLabel selector:@selector(removeFromParent)], nil]];
  
  def.curHealth = newHealth;
  
  if (enemyIsAttacker) {
    [[OutgoingEventController sharedOutgoingEventController] updateMonsterHealth:def.userMonsterId curHealth:def.curHealth];
  }
}

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block {
  [sprite runAction:[CCSequence actions:[RecursiveFadeTo actionWithDuration:0.3f opacity:0],
                     [CCDelayTime actionWithDuration:0.7f],
                     [CCCallFunc actionWithTarget:sprite selector:@selector(removeFromParent)],
                     [CCCallBlock actionWithBlock:block], nil]];
  
  CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"characterdie.plist"];
  q.autoRemoveOnFinish = YES;
  q.position = ccpAdd(sprite.position, ccp(0, sprite.contentSize.height/2-5));
  [self addChild:q z:0];
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
       [self.leftDamageBgd runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0]];
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
  
  CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:self.contentSize.width height:self.contentSize.height];
  [self addChild:l];
  [l runAction:[CCSequence actions:
                [CCDelayTime actionWithDuration:initDelay],
                [CCFadeTo actionWithDuration:fadeTime opacity:180],
                [CCDelayTime actionWithDuration:delayTime],
                [CCFadeTo actionWithDuration:fadeTime opacity:0],
                [CCCallBlock actionWithBlock:
                 ^{
                   [l removeFromParentAndCleanup:YES];
                 }], nil]];
  
  CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Enemy %d/%d", _curStage+1, _numStages] fntFile:@"wavefont.fnt"];
  [self addChild:label];
  label.position = ccp(self.contentSize.width/2, 140);
  
  [label runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:initDelay],
                    [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:fadeTime position:ccp(0, 100)]],
                    [CCDelayTime actionWithDuration:delayTime],
                    [CCEaseSineIn actionWithAction:[CCMoveBy actionWithDuration:fadeTime position:ccp(0, 110)]],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [label removeFromParentAndCleanup:YES];
                     }], nil]];
}

- (void) dropLoot:(int)equipId {
  CCSprite *ed = [CCSprite spriteWithFile:@"itemcrate.png"];
  [self addChild:ed z:-1];
  ed.position = ccpAdd(self.currentEnemy.position, ccp(0,self.currentEnemy.contentSize.height/2));
  ed.scale = 0.01;
  ed.opacity = 5;
  
  float scale = 35.f/ed.contentSize.width;
  float distScale = 0.12f;
  
  ccBezierConfig bezier;
  bezier.controlPoint_1 = ccp(239,265); // control point 1
  bezier.controlPoint_2 = ccp(138,265); // control point 2
  bezier.endPosition = self.lootLabel.parent.position;
  id bezierForward = [CCBezierTo actionWithDuration:0.3 bezier:bezier];
  
  [ed runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:scale],
                 [CCRotateBy actionWithDuration:SILVER_STACK_BOUNCE_DURATION angle:DROP_ROTATION],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,20)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-5-self.currentEnemy.contentSize.height/2)]],
                  [CCMoveBy actionWithDuration:TIME_TO_SCROLL_PER_SCENE*distScale*POINT_OFFSET_PER_SCENE.y/Y_MOVEMENT_FOR_NEW_SCENE
                                      position:ccpMult(POINT_OFFSET_PER_SCENE, -distScale)],
                  [CCSpawn actions:bezierForward,
                   [CCScaleBy actionWithDuration:0.3 scale:0.3], nil],
                  [CCCallBlock actionWithBlock:
                   ^{
                     [ed removeFromParentAndCleanup:YES];
                     
                     _lootCount++;
                     CCScaleBy *scale = [CCScaleBy actionWithDuration:0.25 scale:1.8];
                     _lootLabel.string = [Globals commafyNumber:_lootCount];
                     [_lootLabel runAction:
                      [CCSequence actions:
                       scale,
                       scale.reverse, nil]];
                   }],
                  nil],
                 nil]];
}

- (void) spawnPlaneWithTarget:(id)target selector:(SEL)selector {
  CGPoint pt = POINT_OFFSET_PER_SCENE;
  
  CCSprite *plane = [CCSprite spriteWithFile:@"airplane.png"];
  [self addChild:plane];
  plane.position = ccp(-plane.contentSize.width/2,
                       self.currentEnemy.position.y+5-(self.currentEnemy.position.x+plane.contentSize.width/2)*pt.y/pt.x);
  
  [plane runAction:
   [CCSequence actions:
    [CCMoveTo actionWithDuration:1.f position:ccpAdd(self.currentEnemy.position, ccp(0,5))],
    [CCDelayTime actionWithDuration:0.01f],
    [CCMoveBy actionWithDuration:0.5f position:ccpMult(pt, 0.4)],
    [CCCallBlock actionWithBlock:
     ^{
       [plane removeFromParentAndCleanup:YES];
     }],
    nil]];
  
  int end = 5;
  for (int i = 0; i <= end; i++) {
    CCSprite *bomb = [CCSprite spriteWithFile:@"bomb.png"];
    [self addChild:bomb];
    bomb.scale = 0.3;
    
    CGPoint endPos = ccpAdd(self.currentEnemy.position, ccp(5,10));
    endPos = ccpAdd(endPos, ccpMult(POINT_OFFSET_PER_SCENE, 0.02*(i-2)));
    
    CGPoint offset = ccpMult(POINT_OFFSET_PER_SCENE, 0.02);
    offset = ccp((i%2==0?-1:1)*offset.y,(i%2==1?-1:1)*offset.x);
    //    endPos = ccpAdd(endPos, offset);
    
    bomb.position = ccp(endPos.x, endPos.y+120);
    
    [bomb runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:0.85f+0.1*i],
      [CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:0.7f position:endPos]],
      [CCCallBlock actionWithBlock:
       ^{
         [[CCTextureCache sharedTextureCache] addImage:@"bombdrop.png"];
         CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"bombdrop.plist"];
         q.autoRemoveOnFinish = YES;
         q.position = bomb.position;
         [self addChild:q];
         
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
  CCMoveBy *move = [CCMoveBy actionWithDuration:0.02f position:ccp(3*intensity, 0)];
  CCSequence *seq = [CCSequence actions:move, move.reverse, move.reverse, move, nil];
  CCRepeat *repeat = [CCRepeat actionWithAction:seq times:5+(intensity*3)];
  
  // Dont shake curEnemy because it messes with it coming back after flinch
  NSArray *arr = [NSArray arrayWithObjects:self.bgdLayer, self.myPlayer, nil];
  for (CCNode *n in arr) {
    CGPoint curPos = n.position;
    [n runAction:[CCSequence actions:repeat.copy, [CCCallBlock actionWithBlock:^{
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
    phrase = [CCSprite spriteWithSpriteFrameName:@"mir1.png"];
    [phrase runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]]];
  } else {
    if (phraseFile) {
      phrase = [CCSprite spriteWithFile:phraseFile];
    }
  }
  
  if (phrase) {
    CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:self.contentSize.width height:self.contentSize.height];
    [self addChild:l z:1];
    [l runAction:[CCSequence actions:
                  [CCFadeTo actionWithDuration:0.3 opacity:180],
                  [CCDelayTime actionWithDuration:1.1],
                  [CCFadeTo actionWithDuration:0.3 opacity:0],
                  [CCCallBlock actionWithBlock:
                   ^{
                     [l removeFromParentAndCleanup:YES];
                   }], nil]];
    
    [self addChild:phrase z:3];
    phrase.position = ccp(-phrase.contentSize.width/2, 240);
    CCSequence *seq =
    [CCSequence actions:
     [CCMoveBy actionWithDuration:0.15 position:ccp(phrase.contentSize.width+self.contentSize.width/5, 0)],
     [CCMoveBy actionWithDuration:1.1 position:ccp(self.contentSize.width*3/5-phrase.contentSize.width, 0)],
     [CCMoveBy actionWithDuration:0.15 position:ccp(phrase.contentSize.width+self.contentSize.width/5, 0)],
     [CCCallBlock actionWithBlock:
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
    CCSprite *s = [CCSprite spriteWithFile:@"bloodsplatter.png"];
    [self addChild:s z:1];
    s.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _bloodSplatter = s;
  }
  return _bloodSplatter;
}

- (void) pulseBloodOnce {
  CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.5f opacity:255];
  CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.5f opacity:0];
  self.bloodSplatter.opacity = 0;
  [self.bloodSplatter runAction:
   [CCSequence actions:fadeIn, fadeOut, nil]];
}

- (void) pulseBloodContinuously {
  [self stopAllActions];
  CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:1.f opacity:255];
  CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:1.f opacity:140];
  self.bloodSplatter.opacity = 0;
  [self.bloodSplatter runAction:
   [CCRepeatForever actionWithAction:
    [CCSequence actions:fadeIn, fadeOut, nil]]];
}

- (void) pulseHealthLabel:(BOOL)isEnemy {
  CCLabelTTF *label = isEnemy ? self.currentEnemy.healthLabel : self.myPlayer.healthLabel;
  
  if (![label getActionByTag:RED_TINT_TAG]) {
    CCFadeTo *tintRed = [CCTintTo actionWithDuration:1.f red:255 green:0 blue:0];
    CCFadeTo *tintWhite = [CCTintTo actionWithDuration:1.f red:255 green:255 blue:255];
    CCSequence *seq = [CCSequence actions:tintRed, tintWhite, nil];
    CCRepeatForever *rep = [CCRepeatForever actionWithAction:seq];
    rep.tag = RED_TINT_TAG;
    [label runAction:rep];
  }
}

- (void) stopPulsing {
  [_bloodSplatter stopAllActions];
  _bloodSplatter.opacity = 0;
  [self.myPlayer.healthLabel stopActionByTag:RED_TINT_TAG];
  self.myPlayer.healthLabel.color = ccc3(255, 255, 255);
}

#pragma mark - Delegate Methods

- (void) turnBegan {
  
}

- (void) newComboFound {
  _comboCount++;
  
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

- (void) orbKilled:(GemColorId)color {
  _orbCount++;
  
  float percDamageIncrease = 100.f*[self.myPlayerObject damageForColor:color]/[self.myPlayerObject totalAttackPower];
  _currentScore += percDamageIncrease;
  _scoreForThisTurn += percDamageIncrease;
  
  if (_canPlayNextGemPop) {
    [[SoundEngine sharedSoundEngine] puzzleGemPop];
    _canPlayNextGemPop = NO;
    [self schedule:@selector(allowGemPop) interval:0.02];
  }
}

- (void) allowGemPop {
  [self unschedule:@selector(allowGemPop)];
  _canPlayNextGemPop = YES;
}

- (void) turnComplete {
  if (_scoreForThisTurn == 0) {
    [self.orbLayer allowInput];
    return;
  }
  
  _comboCount = 1;
  _movesLeft--;
  _soundComboCount = 0;
  
  [self checkIfAnyMovesLeft];
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
  BattleSprite *spr = isEnemy ? self.currentEnemy : self.myPlayer;
  CCLabelTTF *label = isEnemy ? self.rightDamageLabel : self.leftDamageLabel;
  
  //  [spr displayChargingFrame];
  
  CCParticleSystemQuad *q = [CCParticleSystemQuad particleWithFile:@"charging.plist"];
  q.position = ccpAdd(spr.position, ccp(-12, spr.contentSize.height/2+16));
  //  [self addChild:q];
  self.chargingEffect = q;
  [self updateChargingForCurrentVal:0];
  
  float interval = 0.02;
  float increment = _currentScore > 7*(10.f/interval) ? _currentScore / (10.f/interval) : 7;
  int numTimes = _currentScore / increment + 1;
  __block float curNum = 0;
  
  CCCallBlock *call = [CCCallBlock actionWithBlock:^{
    curNum += increment;
    label.string = [NSString stringWithFormat:@"%d", (int)MAX(0, _currentScore-curNum)];
    [self updateChargingForCurrentVal:curNum];
  }];
  CCRepeat *repeat = [CCRepeat actionWithAction:[CCSequence actions:call, [CCDelayTime actionWithDuration:interval], nil] times:numTimes];
  [self runAction:[CCSequence actions:
                   repeat,
                   [CCCallBlock actionWithBlock:
                    ^{
                      label.string = @"0";
                      
                      [self.chargingEffect stopSystem];
                      self.chargingEffect.autoRemoveOnFinish = YES;
                      
                      [[SoundEngine sharedSoundEngine] puzzleStopPowerUp];
                    }],
                   [CCDelayTime actionWithDuration:self.chargingEffect.life/2],
                   [CCCallFunc actionWithTarget:target selector:selector],
                   nil]];
  
  [label.parent runAction:[CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:1.f scale:1.3]]];
  
  [[SoundEngine sharedSoundEngine] puzzlePowerUp];
  
  _isChargingUp = YES;
  _labelScore = 0;
}

- (void) updateChargingForCurrentVal:(int)val {
  int curStep = val / 100;
  float remainder = (val % 100) / 100.f;
  
  // Get 3 colors in the array starting from index curStep and interleave between
  ccColor3B startColor = _chargingColors[MIN(curStep, _numChargingColors-1)];
  ccColor3B midColor = _chargingColors[MIN(curStep+1, _numChargingColors-1)];
  ccColor3B endColor = _chargingColors[MIN(curStep+2, _numChargingColors-1)];
  
  ccColor3B insideColor = ccc3(startColor.r+(midColor.r-startColor.r)*remainder,
                               startColor.g+(midColor.g-startColor.g)*remainder,
                               startColor.b+(midColor.b-startColor.b)*remainder);
  
  ccColor3B outsideColor = ccc3(midColor.r+(endColor.r-midColor.r)*remainder,
                                midColor.g+(endColor.g-midColor.g)*remainder,
                                midColor.b+(endColor.b-midColor.b)*remainder);
  
  self.chargingEffect.startColor = ccc4FFromccc3B(outsideColor);
  self.chargingEffect.endColor = ccc4FFromccc3B(insideColor);
  self.chargingEffect.life = MAX(0.15, 0.7-0.2*val/100.f);
  self.chargingEffect.lifeVar = MAX(0.2, 0.5-0.05*val/100.f);
  self.chargingEffect.totalParticles = MIN(200, 30+5*val/100.f);
}

#pragma mark - No Input Layer Methods

- (void) displayNoInputLayer {
  [self.noInputLayer runAction:[CCFadeTo actionWithDuration:0.3 opacity:NO_INPUT_LAYER_OPACITY]];
}

- (void) removeNoInputLayer {
  [self.noInputLayer runAction:[CCFadeTo actionWithDuration:0.3 opacity:0]];
}

- (void) dealloc {
  free(_chargingColors);
}

@end

#pragma clang diagnostic pop
