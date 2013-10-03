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

#define POINT_OFFSET_PER_SCENE ccp(512,360)
#define Y_MOVEMENT_FOR_NEW_SCENE 140
#define TIME_TO_SCROLL_PER_SCENE 3.f

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
                   [CCCallBlock actionWithBlock:
                    ^{
                      [self removePastScenes];
                      [self.delegate reachedNextScene];
                    }],
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

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	OrbLayer *layer = [NewBattleLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
  
	// return the scene
	return scene;
}

- (id) init {
  if ((self = [super init])) {
    CCSprite *s = [CCSprite spriteWithFile:@"puzzlebg.png"];
    [self addChild:s z:1 tag:1456];
    s.position = ccp(self.contentSize.width/2, s.contentSize.height/2);
    
    self.orbLayer = [[[OrbLayer alloc] initWithContentSize:CGSizeMake(290, 180)] autorelease];
    self.orbLayer.position = ccp(self.contentSize.width/2-self.orbLayer.contentSize.width/2, 0);
    [self addChild:self.orbLayer z:1];
    self.orbLayer.delegate = self;
    
    self.bgdLayer = [BattleBgdLayer node];
    [self addChild:self.bgdLayer];
    self.bgdLayer.position = ccp(-733+self.contentSize.width/2, 0);
    self.bgdLayer.delegate = self;
    
    [self setupHealthBars];
    
    BattleSprite *mp = [[[BattleSprite alloc] initWithPrefix:@"MafiaMan"] autorelease];
    [self addChild:mp z:0];
    mp.position = ccp(self.contentSize.width/2-17,191);
    mp.sprite.flipX = YES;
    self.myPlayer = mp;
    
    [self moveToNextEnemy];
  }
  return self;
}

- (void) setupHealthBars {
  // Left
  CCSprite *leftBgdBar = [CCSprite spriteWithFile:@"puzztopbarbg.png"];
  [self addChild:leftBgdBar z:2];
  leftBgdBar.position = ccp(self.contentSize.width/2-140, 290);
  
  _leftHealthBar = [CCProgressTimer progressWithFile:@"puzzredbar.png"];
  [leftBgdBar addChild:_leftHealthBar];
  _leftHealthBar.position = ccp(leftBgdBar.contentSize.width/2, leftBgdBar.contentSize.height/2);
  _leftHealthBar.type = kCCProgressTimerTypeHorizontalBarLR;
  _leftHealthBar.percentage = 50;
  
  _leftHealthLabel = [CCLabelTTF labelWithString:@"31/100" fontName:@"Dirty Headline" fontSize:12];
  [leftBgdBar addChild:_leftHealthLabel];
  _leftHealthLabel.anchorPoint = ccp(1,0.5);
  _leftHealthLabel.position = ccp(leftBgdBar.contentSize.width-5, leftBgdBar.contentSize.height/2);
  
  CCLabelTTF *leftNameLabel = [CCLabelTTF labelWithString:@"TheMeepsta" fontName:@"Dirty Headline" fontSize:12];
  [leftBgdBar addChild:leftNameLabel];
  leftNameLabel.anchorPoint = ccp(0,0.5);
  leftNameLabel.position = ccp(8, leftBgdBar.contentSize.height/2);
  
  CCSprite *leftIcon = [CCSprite spriteWithFile:@"redheadtest.png"];
  leftIcon.position = ccp(-14, leftBgdBar.contentSize.height/2-3);
  [leftBgdBar addChild:leftIcon];
  
  // Right
  CCSprite *rightBgdBar = [CCSprite spriteWithFile:@"puzztopbarbg.png"];
  [self addChild:rightBgdBar z:2];
  rightBgdBar.position = ccp(self.contentSize.width/2+140, 290);
  
  _rightHealthBar = [CCProgressTimer progressWithFile:@"puzzredbar.png"];
  [rightBgdBar addChild:_rightHealthBar];
  _rightHealthBar.position = ccp(rightBgdBar.contentSize.width/2, rightBgdBar.contentSize.height/2);
  _rightHealthBar.type = kCCProgressTimerTypeHorizontalBarRL;
  _rightHealthBar.percentage = 90;
  
  _rightHealthLabel = [CCLabelTTF labelWithString:@"31/100" fontName:@"Dirty Headline" fontSize:12];
  [rightBgdBar addChild:_rightHealthLabel];
  _rightHealthLabel.anchorPoint = ccp(0,0.5);
  _rightHealthLabel.position = ccp(5, rightBgdBar.contentSize.height/2);
  
  CCLabelTTF *rightNameLabel = [CCLabelTTF labelWithString:@"TheMeepsta" fontName:@"Dirty Headline" fontSize:12];
  [rightBgdBar addChild:rightNameLabel];
  rightNameLabel.anchorPoint = ccp(1,0.5);
  rightNameLabel.position = ccp(rightBgdBar.contentSize.width-8, rightBgdBar.contentSize.height/2);
  
  CCSprite *rightIcon = [CCSprite spriteWithFile:@"redheadtest.png"];
  rightIcon.position = ccp(rightBgdBar.contentSize.width+14, rightBgdBar.contentSize.height/2-3);
  [rightBgdBar addChild:rightIcon];
  
  CCSprite *movesLeftBgd = [CCSprite spriteWithFile:@"movesleft.png"];
  CCSprite *puzzleBg = (CCSprite *)[self getChildByTag:1456];
  [self addChild:movesLeftBgd z:0];
  movesLeftBgd.position = ccp(puzzleBg.position.x-self.orbLayer.contentSize.width/2+movesLeftBgd.contentSize.width/2, puzzleBg.position.y+puzzleBg.contentSize.height/2+movesLeftBgd.contentSize.height/2-17);
  
  CCLabelTTF *movesLabel = [CCLabelTTF labelWithString:@"MOVES:" fontName:@"Dirty Headline" fontSize:11];
  [movesLeftBgd addChild:movesLabel];
  movesLabel.position = ccp(22, 20);
  movesLabel.color = ccc3(150, 150, 150);
  
  _movesLeftLabel = [CCLabelTTF labelWithString:@"5" fontName:@"Dirty Headline" fontSize:21];
  [movesLeftBgd addChild:_movesLeftLabel];
  _movesLeftLabel.position = ccp(movesLeftBgd.contentSize.width-14, 24);
  _movesLeftLabel.color = ccc3(176, 223, 33);
  
  _leftDamageBgd = [CCSprite spriteWithFile:@"damagebg.png"];
  [self addChild:_leftDamageBgd z:0];
  _leftDamageBgd.position = ccpAdd(movesLeftBgd.position, ccp(0,33));
  
  ccColor3B color = ccc3(255, 200, 0);
  
  CCLabelTTF *topLabel = [CCLabelTTF labelWithString:@"Damage:" fontName:@"Dirty Headline" fontSize:15];
  [_leftDamageBgd addChild:topLabel];
  topLabel.position = ccp(_leftDamageBgd.contentSize.width/2, _leftDamageBgd.contentSize.height*2/3+4);
  topLabel.color = color;
  
  CCNode *n = [CCNode node];
  [_leftDamageBgd addChild:n];
  n.position = ccp(32,20);
  
  _leftDamageLabel = [CCLabelTTF labelWithString:@"100" fontName:@"Dirty Headline" fontSize:21];
  _leftDamageLabel = [CCLabelBMFont labelWithString:@"100" fntFile:@"numbers.fnt"];// labelWithString:@"100" fontName:@"Dirty Headline" fontSize:21];
  [n addChild:_leftDamageLabel];
  _leftDamageLabel.anchorPoint = ccp(1, 0.5);
  _leftDamageLabel.position = ccp(4, 0);
  _leftDamageLabel.color = color;
  
  CCLabelTTF *percentLabel = [CCLabelTTF labelWithString:@"%" fontName:@"Dirty Headline" fontSize:15];
  [n addChild:percentLabel];
  percentLabel.position = ccp(13, 3);
  percentLabel.color = color;
  
  _rightDamageBgd = [CCSprite spriteWithFile:@"opponentsbg.png"];
  [self addChild:_rightDamageBgd z:0];
  _rightDamageBgd.position = ccp(puzzleBg.position.x+self.orbLayer.contentSize.width/2-_rightDamageBgd.contentSize.width/2, puzzleBg.position.y+puzzleBg.contentSize.height/2+_rightDamageBgd.contentSize.height/2-8);
  
  topLabel = [CCLabelTTF labelWithString:@"Damage:" fontName:@"Dirty Headline" fontSize:15];
  [_rightDamageBgd addChild:topLabel];
  topLabel.position = ccp(_rightDamageBgd.contentSize.width/2, _rightDamageBgd.contentSize.height*2/3+4);
  topLabel.color = color;
  
  _rightDamageLabel = [CCLabelTTF labelWithString:@"100" fontName:@"Dirty Headline" fontSize:21];
  [_rightDamageBgd addChild:_rightDamageLabel];
  _rightDamageLabel.anchorPoint = ccp(1, 0.5);
  _rightDamageLabel.position = ccp(36, 15);
  _rightDamageLabel.color = color;
  
  percentLabel = [CCLabelTTF labelWithString:@"%" fontName:@"Dirty Headline" fontSize:15];
  [_rightDamageBgd addChild:percentLabel];
  percentLabel.position = ccp(45, 18);
  percentLabel.color = color;
  
  [self schedule:@selector(updateLabels) interval:0.05];
  _comboCount = 1;
  _orbCount = 0;
  _currentScore = 100;
  _labelScore = 0;
}

- (void) moveToNextEnemy {
  if ([[CCActionManager sharedManager] numberOfRunningActionsInTarget:self.myPlayer.sprite] == 0) {
    [self.myPlayer beginWalking];
    [self.bgdLayer scrollToNewScene];
    [self spawnNextEnemy];
  }
}

- (void) spawnNextEnemy {
  [self.currentEnemy removeFromParentAndCleanup:YES];
  self.currentEnemy = [[[BattleSprite alloc] initWithPrefix:@"MafiaWoman"] autorelease];
  self.currentEnemy.isFacingNear = YES;
  
  CGPoint finalPos = ccp(self.contentSize.width/2+60,235);
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
  
  [self addChild:self.currentEnemy];
  self.currentEnemy.position = newPos;
  [self.currentEnemy runAction:[CCMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos]];
}

- (void) updateLabels {
  if (_currentScore > _labelScore) {
    int diff = _currentScore - _labelScore;
    int change = MAX((int)(0.1*diff), 1);
    _leftDamageLabel.string = [Globals commafyNumber:_labelScore+change];
    _labelScore += change;
    
    [self pulseLabel:_leftDamageLabel.parent];
  } else if (_currentScore < _labelScore) {
    _leftDamageLabel.string = [Globals commafyNumber:_currentScore];
    _labelScore = _currentScore;
  }
  
  if (_labelScore > 200) {
    [self pulseLabel:_leftDamageLabel.parent];
  }
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

#pragma  mark - Delegate Methods

- (void) newComboFound {
  _comboCount++;
}

- (void) orbKilled {
  _orbCount++;
  _currentScore += _comboCount;
  _leftDamageLabel.string = [Globals commafyNumber:_currentScore];
}

- (void) turnComplete {
  if (_orbCount == 0) {
    return;
  }
  
  [self moveToNextEnemy];
  return;
  
  CCLayerColor *l = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:self.contentSize.width height:self.contentSize.height];
  [self addChild:l];
  [l runAction:[CCSequence actions:
               [CCFadeTo actionWithDuration:0.3 opacity:180],
                [CCDelayTime actionWithDuration:1.1],
                [CCFadeTo actionWithDuration:0.3 opacity:0],
               [CCCallBlock actionWithBlock:
                ^{
                  [l removeFromParentAndCleanup:YES];
                }], nil]];
  
  CCSprite *ballin;
  
  if (arc4random() %4 == 0) {
    NSArray *arr = [NSArray arrayWithObjects:@"ballin.png", @"canttouchthis.png", @"hammertime.png", nil];
    ballin = [CCSprite spriteWithFile:[arr objectAtIndex:arc4random() %3]];
    [self addChild:ballin];
  } else {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"makeitrain.plist"];
    CCAnimation *anim = [CCAnimation animation];
    anim.delay = 0.1f;
    [anim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir1.png"]];
    [anim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir2.png"]];
    [anim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mir3.png"]];
    ballin = [CCSprite spriteWithSpriteFrame:[anim.frames objectAtIndex:0]];
    [self addChild:ballin];
    [ballin runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]]];
  }
  
  ballin.position = ccp(-ballin.contentSize.width/2, 240);
  CCSequence *seq =
  [CCSequence actions:
   [CCMoveBy actionWithDuration:0.2 position:ccp(ballin.contentSize.width+self.contentSize.width/5, 0)],
   [CCMoveBy actionWithDuration:1.1 position:ccp(self.contentSize.width*3/5-ballin.contentSize.width, 0)],
   [CCMoveBy actionWithDuration:0.2 position:ccp(ballin.contentSize.width+self.contentSize.width/5, 0)],
   [CCCallBlock actionWithBlock:
    ^{
      [ballin removeFromParentAndCleanup:YES];
    }],
   nil];
  [ballin runAction:seq];
}

- (void) reachedNextScene {
  [self.myPlayer stopWalking];
  [self.myPlayer performFarAttackAnimation];
  
//  _comboCount = 1;
//  _orbCount = 0;
//  _currentScore = 100;
}

@end
