//
//  BattleMainView.m
//  Utopia
//
//  Created by Rob Giusti on 4/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleMainView.h"
#import "SoundEngine.h"
#import "GameViewController.h"
#import "CCTextureCache.h"
#import "GameState.h"
#import "CCAnimation.h"
#import "MonsterPopUpViewController.h"
#import "BattleItemSelectViewController.h"
#import "ClientProperties.h"
#import "ShopViewController.h"
#import "SkillManager.h"

// Disable for this file
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define COMBO_FIRE_TAG @"ComboFire"

@implementation BattleMainView

- (CGPoint) myPlayerLocation {
  return self.battleLayer.myPlayerLocation;
}

#pragma mark Initialization

- (id)initWithBgdPrefix:(NSString *)bgdPrefix battleLayer:(NewBattleLayer *)battleLayer{
  if ((self = [super init])) {
    self.battleLayer = battleLayer;
    
    self.contentSize = [CCDirector sharedDirector].viewSize;
    
    self.bgdContainer = [CCNode node];
    self.bgdContainer.contentSize = self.contentSize;
    [self addChild:self.bgdContainer z:0];
    
    bgdPrefix = bgdPrefix.length ? bgdPrefix : @"1";
    self.bgdLayer = [[BattleBgdLayer alloc] initWithPrefix:bgdPrefix];
    [self.bgdContainer addChild:self.bgdLayer z:-100];
    self.bgdLayer.position = self.battleLayer.bgdLayerInitPosition;
    self.bgdLayer.delegate = self.battleLayer;
    
    // Scale the bgdContainer and readjust to the center of battle
    CGPoint basePt = self.battleLayer.centerOfBattle;
    CGPoint beforeScale = [self.bgdContainer convertToNodeSpace:basePt];
    CGPoint afterScale = [self.bgdContainer convertToNodeSpace:basePt];
    CGPoint diff = ccpSub(afterScale, beforeScale);
    self.bgdContainer.position = ccpAdd(self.bgdContainer.position, ccpMult(diff, self.bgdContainer.scale));
    
    [self setupUI];
  }
  
  return self;
}

- (void) setupUI {
  
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
  
  _movesLeftHidden = YES;
  
  [self updateHealthBars];
}

- (void)onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  [self.battleLayer addChild:clip z:100];
  clip.contentSize = CGSizeMake(_comboBgd.contentSize.width*2, _comboBgd.contentSize.height*3);
  clip.anchorPoint = ccp(1, 0.5);
  clip.position = ccp(self.position.x+self.contentSize.width, self.battleLayer.orbLayerDistFromSide+54);
  clip.scale = 1.5;
  
  [clip addChild:_comboBgd];
  _comboBgd.position = ccp(clip.contentSize.width+2*_comboBgd.contentSize.width, _comboBgd.parent.contentSize.height/2);
  
  CCDrawNode *stencil = [CCDrawNode node];
  CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
  [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
  clip.stencil = stencil;
}

- (void)onExitTransitionDidStart {
  CCClippingNode *clip = (CCClippingNode *)_comboBgd.parent;
  clip.stencil = nil;
  [super onExitTransitionDidStart];
  
  [self.hudView removeFromSuperview];
  [self.forcedSkillView removeFromSuperview];
  [self.popoverViewController closeClicked:nil];
}

#pragma mark Sprite Creation

- (void)createNextMyPlayerSpriteWithBattlePlayer:(BattlePlayer *)battlePlayer {
  BattleSprite *mp = [[BattleSprite alloc] initWithPrefix:battlePlayer.spritePrefix nameString:battlePlayer.attrName rarity:battlePlayer.rarity animationType:battlePlayer.animationType isMySprite:YES verticalOffset:battlePlayer.verticalOffset];
  mp.battleLayer = self.battleLayer;
  mp.healthBar.color = [self.battleLayer.orbLayer.swipeLayer colorForSparkle:(OrbColor)battlePlayer.element];
  [self.bgdContainer addChild:mp z:1];
  mp.position = [self myPlayerLocation];
  self.myPlayer = mp;
  self.movesLeftContainer = nil;
  self.myPlayer.isFacingNear = NO;
  [self updateHealthBars];
}

- (float)makeMyPlayerWalkOutWithBlock:(void (^)(void))completion {
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

- (void)createNextEnemySpriteWithBattlePlayer:(BattlePlayer*)battlePlayer startPosition:(CGPoint)spawnPos endPosition:(CGPoint)endPos  {
  
  BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:battlePlayer.spritePrefix nameString:battlePlayer.attrName rarity:battlePlayer.rarity animationType:battlePlayer.animationType isMySprite:NO verticalOffset:battlePlayer.verticalOffset];
  bs.battleLayer = self.battleLayer;
  bs.healthBar.color = [self colorForHealthBar:battlePlayer.element];
  [bs showRarityTag];
  [self.bgdContainer addChild:bs];
  self.currentEnemy = bs;
  self.currentEnemy.isFacingNear = YES;
  [self updateHealthBars];
  
  self.currentEnemy.position = spawnPos;
  [self.currentEnemy runAction:[CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:endPos]];
  
  [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
  self.currentEnemy.healthLabel.color = [CCColor colorWithCcColor3b:ccc3(255,255,255)];
}

- (CCColor *) colorForHealthBar:(Element)element {
  UIColor *c = [Globals colorForElementOnDarkBackground:element];
  CGFloat r = 1.f, g = 1.f, b = 1.f, a = 1.f;
  [c getRed:&r green:&g blue:&b alpha:&a];
  return [CCColor colorWithCcColor3b:ccc3(r*255, g*255, b*255)];
}

#pragma mark Combat Flow

- (void)moveToNextEnemy{
  [self.myPlayer beginWalking];
  [self.bgdLayer scrollToNewScene];
}

- (void) pickUpLoot:(int)lootCount {
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
       
       CCActionScaleBy *scale = [CCActionScaleBy actionWithDuration:0.25 scale:1.4];
       _lootLabel.string = [Globals commafyNumber:lootCount];
       [_lootLabel runAction:
        [CCActionSequence actions:
         scale,
         scale.reverse, nil]];
       
       _lootSprite = nil;
     }],
    nil]];
}

- (void) dropLoot:(CCSprite *)ed {
  _lootSprite = ed;
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
- (void)showConfusedPopup:(BOOL)onEnemy withTarget:(id)target andSelector:(SEL)selector {
  BattleSprite *targetSprite = onEnemy ? self.currentEnemy : self.myPlayer;
  
  CCSprite* confusedPopup = [CCSprite spriteWithImageNamed:@"confusionbubble.png"];
  [confusedPopup setAnchorPoint:CGPointMake(.5f, 0.f)];
  [confusedPopup setPosition:CGPointMake(targetSprite.contentSize.width * .5f, targetSprite.contentSize.height + 13.f)];
  [confusedPopup setScale:0.f];
  [targetSprite addChild:confusedPopup];
  
  [confusedPopup runAction:[CCActionSequence actions:
                            [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:1.f]],
                            [CCActionDelay actionWithDuration:.5f],
                            [CCActionCallFunc actionWithTarget:target selector:selector],
                            [CCActionDelay actionWithDuration:1.5f],
                            [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.2f scale:0.f]],
                            [CCActionRemove action],
                            nil]];
}

#pragma mark Hud

- (IBAction)swapClicked:(id)sender {
  if ([self.battleLayer canSwap]){
    [self.hudView removeSwapButtonAnimated:YES];
    [self displayDeployViewAndIsCancellable:YES];
  }
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self displayLootCounter:NO];
  
  [self.hudView.deployView updateWithBattlePlayers:self.battleLayer.myTeam];
  
  [self.hudView displayDeployViewToCenterX:self.battleLayer.deployCenterX cancelTarget:cancel ? self : nil selector:@selector(cancelDeploy:)];
  
  [SoundEngine puzzleSwapWindow];
}

- (IBAction)cancelDeploy:(id)sender {
  [self.battleLayer cancelDeploy:sender];
}

- (IBAction)deployCardClicked:(id)sender {
  [self.battleLayer deployCardClicked:sender];
}

- (IBAction)skillClicked:(id)sender {
  [[skillManager enemySkillIndicatorView] popupOrbCounter];
  [UIView animateWithDuration:0.3f animations:^{
    self.forcedSkillView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.forcedSkillView removeFromSuperview];
  }];
  [self.battleLayer skillClicked:sender];
}

#pragma mark Moves Left Display

- (void) setMovesLeft:(int)movesLeft animated:(BOOL)animated {
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
}

- (void) hideMovesLeft:(BOOL)hide withCompletion:(void(^)())completion {
  if (self.movesLeftContainer)
  {
    for (CCNode* child in self.movesLeftContainer.children)
      [self hideMovesLeft:hide node:child withCompletion:^{}];
    [self hideMovesLeft:hide node:self.movesLeftContainer withCompletion:completion];
  }
  else
    completion();
}

- (void) hideMovesLeft:(BOOL)hide node:(CCNode*)node withCompletion:(void(^)())completion {
  if ((hide && node.opacity == 1.f) || (!hide && node.opacity == 0.f))
  {
    [node runAction:[CCActionSequence actions:
                     hide ? [CCActionFadeOut actionWithDuration:.3f] : [CCActionFadeIn actionWithDuration:.3f],
                     [CCActionCallBlock actionWithBlock:completion], nil]];
  }
  else
    completion();
}

- (void) mobsterInfoDisplayed:(BOOL)displayed onSprite:(BattleSprite*)sprite {
  if (sprite == self.myPlayer && !_movesLeftHidden)
  {
    [self hideMovesLeft:displayed withCompletion:^{}];
  }
}

#pragma mark Blood Splatter

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

- (void) pulseHealthLabelIfRequired:(BOOL)onEnemy forBattlePlayer:(BattlePlayer*)player{
  float perc = ((float)player.curHealth/player.maxHealth);
  
  if (onEnemy)
  {
    if (perc < PULSE_CONT_THRESH) {
      [self pulseHealthLabel:YES];
    } else {
      [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
      self.currentEnemy.healthLabel.color = [CCColor whiteColor];
    }
  }
  else
  {
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

#pragma mark Utils

- (void) showHighScoreWordWithScore:(int)currentScore target:(id)target selector:(SEL)selector {
  CCSprite *phrase = nil;
  NSString *phraseFile = nil;
  BOOL isMakeItRain = NO;
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
    [self.battleLayer addChild:l z:3];  // was 1, changed by Mikhail to darken skill indicators
    [l runAction:[CCActionSequence actions:
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0.6f],
                  [CCActionDelay actionWithDuration:1.1],
                  [CCActionFadeTo actionWithDuration:0.3 opacity:0],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     [l removeFromParentAndCleanup:YES];
                   }], nil]];
    
    [self.battleLayer addChild:phrase z:4]; // was 3, see above
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

- (void) removeButtons {
  [self.hudView removeButtons];
  [self.popoverViewController closeClicked:nil];
}

- (void) updateComboCount:(int)comboCount {
  // Update combo count label but do it somewhat slowly
  __block int base = MAX(2, [_comboLabel.string intValue]);
  if (base < comboCount) {
    CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
      base += 1;
      _comboLabel.string = [NSString stringWithFormat:@"%dx", base];
    }];
    CCActionRepeat *rep = [CCActionRepeat actionWithAction:[CCActionSequence actions:block, [CCActionDelay actionWithDuration:0.15f], nil] times:comboCount-base];
    rep.tag = 83239;
    [_comboLabel stopActionByTag:rep.tag];
    [_comboLabel runAction:rep];
  } else {
    _comboLabel.string = [NSString stringWithFormat:@"%dx", comboCount];
  }
  
#if !(TARGET_IPHONE_SIMULATOR)
  
  if (comboCount == 2) {
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
  if (comboCount == 5 && ![_comboBgd getChildByName:COMBO_FIRE_TAG recursively:NO]) {
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
}

- (void) moveOutComboCounter {
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

- (void) updateHealthBars {
  [self updateHealthBarsForPlayer:self.battleLayer.myPlayerObject andEnemy:self.battleLayer.enemyPlayerObject];
}

- (void) updateHealthBarsForPlayer:(BattlePlayer*)myPlayer andEnemy:(BattlePlayer*)enemyPlayer {
  if (enemyPlayer) {
    self.currentEnemy.healthBar.percentage = ((float)enemyPlayer.curHealth)/enemyPlayer.maxHealth*100;
    self.currentEnemy.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:enemyPlayer.curHealth], [Globals commafyNumber:enemyPlayer.maxHealth]];
    
    self.currentEnemy.healthBar.parent.visible = YES;
  } else {
    self.currentEnemy.healthBar.parent.visible = NO;
  }
  
  if (myPlayer) {
    self.myPlayer.healthBar.percentage = ((float)myPlayer.curHealth)/myPlayer.maxHealth*100;
    self.myPlayer.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:myPlayer.curHealth], [Globals commafyNumber:myPlayer.maxHealth]];
    
    self.myPlayer.healthBar.parent.visible = YES;
  } else {
    self.myPlayer.healthBar.parent.visible = NO;
  }
}

- (void) displayWaveNumber:(int)waveNumber totalWaves:(int)totalWaves andEnemy:(BattlePlayer *)enemyPlayer {
  float initDelay = TIME_TO_SCROLL_PER_SCENE-2.2;
  float fadeTime = 0.35;
  float delayTime = 2.1;
  int z = 2;
  
  CCNodeColor *bgd = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(0, 0, 0, 0)] width:self.contentSize.width height:self.contentSize.height];
  [self.battleLayer addChild:bgd z:z];
  
  CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Enemy %d/%d", waveNumber, totalWaves] fontName:@"Ziggurat-HTF-Black" fontSize:21];
  [self.battleLayer addChild:label z:z];
  label.position = ccp(24, self.contentSize.height/2+29);
  label.anchorPoint = ccp(0, 0.5);
  label.color = [CCColor colorWithRed:255/255.f green:204/255.f blue:0.f];
  label.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  label.shadowOffset = ccp(0, -1);
  label.shadowBlurRadius = 1.3;
  
  CCSprite *spr = [CCSprite spriteWithImageNamed:@"enemydivider.png"];
  [self.battleLayer addChild:spr z:z];
  spr.scaleX = MIN(label.position.x+label.contentSize.width+20, self.contentSize.width-label.position.x*2-self.battleLayer.orbLayer.contentSize.width-self.battleLayer.orbLayerDistFromSide*2);
  spr.anchorPoint = ccp(0, 0.5);
  spr.position = ccpAdd(label.position, ccp(0, -label.contentSize.height/2-8));
  
  
  CCSprite *bgdIcon = [CCSprite spriteWithImageNamed:@"youwonitembg.png"];
  [self.battleLayer addChild:bgdIcon z:z];
  bgdIcon.anchorPoint = ccp(0, 0.5);
  bgdIcon.position = ccpAdd(label.position, ccp(0, -58));
  
  if (enemyPlayer.spritePrefix.length) {
    CCSprite *inside = [CCSprite node];
    [bgdIcon addChild:inside];
    inside.position = ccp(bgdIcon.contentSize.width/2, bgdIcon.contentSize.height/2);
    
    NSString *fileName = [enemyPlayer.spritePrefix stringByAppendingString:@"Card.png"];
    [Globals imageNamed:fileName toReplaceSprite:inside completion:^(BOOL success) {
      inside.scale = bgdIcon.contentSize.height/inside.contentSize.height;
    }];
    
    if (enemyPlayer.evoLevel > 1)
    {
      CCSprite *evo = [CCSprite node];
      [bgdIcon addChild:evo];
      
      [Globals imageNamed:@"evobadge2.png" toReplaceSprite:evo];
      evo.position = ccp(evo.contentSize.width-1, evo.contentSize.height-1);
      
      CCLabelTTF *evoLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", enemyPlayer.evoLevel] fontName:@"Gotham-Ultra" fontSize:8];
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
  nameLabel.attributedString = enemyPlayer.attrName;
  [bgdIcon addChild:nameLabel];
  nameLabel.color = [CCColor whiteColor];
  nameLabel.shadowOffset = ccp(0, -1);
  nameLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  nameLabel.shadowBlurRadius = 1.5f;
  nameLabel.anchorPoint = ccp(0, 0.5);
  
  CCSprite *elem = [CCSprite spriteWithImageNamed:[Globals imageNameForElement:enemyPlayer.element suffix:@"orb.png"]];
  elem.scale = 0.5;
  elem.anchorPoint = ccp(0, 0.5);
  [nameLabel addChild:elem];
  elem.position = ccp(-elem.contentSize.width*elem.scale-3, nameLabel.contentSize.height/2);
  
  
  
  if (enemyPlayer.monsterType != TaskStageMonsterProto_MonsterTypeRegular) {
    NSString *newText = enemyPlayer.monsterType == TaskStageMonsterProto_MonsterTypeMiniBoss ? @"Mini Boss" : @"Boss";
    label.string = newText;
    label.color = [CCColor whiteColor];
    [label runAction:[CCActionRepeatForever actionWithAction:
                      [CCActionSequence actions:
                       [CCActionTintTo actionWithDuration:0.25 color:[CCColor colorWithRed:1.f green:84/255.f blue:0.f]],
                       [CCActionTintTo actionWithDuration:0.25 color:[CCColor whiteColor]], nil]]];
    
    delayTime = 3;
  }
  
  
  if (enemyPlayer.rarity != QualityCommon) {
    NSString *rarityStr = [@"battle" stringByAppendingString:[Globals imageNameForRarity:enemyPlayer.rarity suffix:@"tag.png"]];
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
                     [self.battleLayer beginNextTurn];
                   }],
                  nil]];
  
  self.hudView.waveNumLabel.text = [NSString stringWithFormat:@"ENEMY %d/%d", waveNumber, totalWaves];
  
  [UIView animateWithDuration:fadeTime delay:initDelay options:UIViewAnimationOptionCurveLinear animations:^{
    self.hudView.waveNumLabel.alpha = 0.3f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:fadeTime delay:delayTime options:UIViewAnimationOptionCurveLinear animations:^{
      self.hudView.waveNumLabel.alpha = 1.f;
    } completion:nil];
  }];
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

- (void) loadHudView {
  GameViewController *gvc = [GameViewController baseController];
  UIView *view = gvc.view;
  
  NSString *bundleName = ![Globals isSmallestiPhone] ? @"BattleHudView" : @"BattleHudViewSmall";
  [[NSBundle mainBundle] loadNibNamed:bundleName owner:self options:nil];
  self.hudView.frame = view.bounds;
  [view insertSubview:self.hudView aboveSubview:[CCDirector sharedDirector].view];
  
  self.hudView.battleLayerDelegate = self.battleLayer;
  
  // Make the bottom view flush with the board
  float bottomDist = self.battleLayer.orbLayerDistFromSide-2;
  self.hudView.bottomView.originY = self.hudView.bottomView.superview.height-self.hudView.bottomView.height-bottomDist;
  self.hudView.swapView.originY = self.hudView.swapView.superview.height-self.hudView.swapView.height-bottomDist;
  
  self.hudView.itemsView.originY = self.hudView.itemsView.superview.height-self.hudView.itemsView.height-bottomDist;
  self.hudView.itemsView.originX = self.hudView.itemsView.superview.width-self.hudView.itemsView.width-self.battleLayer.orbLayer.contentSize.width-self.battleLayer.orbLayerDistFromSide-8;
  
  self.hudView.bottomView.centerX = self.hudView.swapView.width+(self.hudView.itemsView.originX-self.hudView.swapView.width)/2;
  
  UIImage *img = [Globals imageNamed:@"6movesqueuebgwide.png"];
  if (self.battleLayer.bottomCenterX*2 >= img.size.width) {
    self.hudView.battleScheduleView.bgdView.image = img;
    self.hudView.battleScheduleView.width = img.size.width;
  }
  
  // Move schedule up in case board is too close to the edge so that it is flush with top of the board
  if (self.hudView.battleScheduleView.containerView.originY > bottomDist) {
    self.hudView.battleScheduleView.originX = bottomDist;
    self.hudView.battleScheduleView.originY = bottomDist-self.hudView.battleScheduleView.containerView.originY;
    
    self.hudView.elementButton.originY = self.hudView.battleScheduleView.originY+self.hudView.battleScheduleView.height-12;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self.hudView.deployView showClanSlot];
  } else {
    [self.hudView.deployView hideClanSlot];
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

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void (^)())block {
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

- (void) animateDamageLabel:(BOOL)forPlayer initialDamage:(int)initialDamage modifiedDamage:(int)modifiedDamage withCompletion:(void(^)())completion {
  BattleSprite *targetSprite = forPlayer ? self.myPlayer : self.currentEnemy;
  
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

- (void) forceSkillClickOver {
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

- (IBAction)forfeitClicked:(id)sender {
  [self.battleLayer forfeitClicked:sender];
}

@end