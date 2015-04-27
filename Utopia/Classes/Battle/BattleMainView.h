//
//  BattleMainView.h
//  Utopia
//
//  Created by Rob Giusti on 4/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BattleSprite.h"
#import "BattlePlayer.h"
#import "BattleViews.h"
#import "BattleHudView.h"
#import "SkillBattleIndicatorView.h"
#import "DialogueViewController.h"
#import "BattleItemSelectViewController.h"
#import "BattleBgdLayer.h"
#import "Globals.h"

#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#define BALLIN_SCORE 400
#define CANTTOUCHTHIS_SCORE 540
#define HAMMERTIME_SCORE 720
#define MAKEITRAIN_SCORE 900

@interface BattleMainView : CCNode {
  
  CCSprite *_lootSprite;
  
  BOOL _movesLeftHidden;
  BOOL _reachedNextScene;
  
}

@property (nonatomic, assign) BOOL displayedWaveNumber;

@property (nonatomic, retain) CCSprite* movesLeftContainer;
@property (nonatomic, retain) CCSprite* movesLeftLabel;
@property (nonatomic, retain) CCSprite* movesLeftCounter;
@property (nonatomic, retain) CCLabelTTF *lootLabel;
@property (nonatomic, retain) CCSprite *lootBgd;
@property (nonatomic, retain) CCSprite *comboBgd;
@property (nonatomic, retain) CCLabelTTF *comboLabel;
@property (nonatomic, retain) CCLabelTTF *comboBotLabel;

// bgdContainer holds the bgdLayer as well as battlesprites and all animations on the ground
@property (nonatomic, retain) CCNode *bgdContainer;
@property (nonatomic, retain) BattleBgdLayer *bgdLayer;
@property (nonatomic, retain) BattleSprite *myPlayer;
@property (nonatomic, retain) BattleSprite *currentEnemy;

@property (nonatomic, retain) CCSprite *bloodSplatter;

@property (nonatomic, retain) IBOutlet BattleHudView *hudView;

@property (nonatomic, retain) PopoverViewController *popoverViewController;

@property (nonatomic, retain) DialogueViewController *dialogueViewController;

@property (nonatomic, retain) MainBattleLayer *battleLayer;

// Used for the skill explination
@property (nonatomic, retain) IBOutlet UIView *forcedSkillView;
@property (nonatomic, retain) IBOutlet UIButton *forcedSkillButton;
@property (nonatomic, retain) IBOutlet UIView *forcedSkillInnerView;

- (id) initWithBgdPrefix:(NSString*)bgdPrefix battleLayer:(MainBattleLayer*)battleLayer;

- (void)createNextMyPlayerSpriteWithBattlePlayer:(BattlePlayer *)battlePlayer;
- (float)makeMyPlayerWalkOutWithBlock:(void (^)(void))completion;
- (void) createNextEnemySpriteWithBattlePlayer:(BattlePlayer *)battlePlayer startPosition:(CGPoint)spawnPos endPosition:(CGPoint)endPos;

- (void) moveToNextEnemy;
- (void) pickUpLoot:(int)lootCount;
- (void) dropLoot:(CCSprite *)ed;

- (void)showConfusedPopup:(BOOL)onEnemy withTarget:(id)target andSelector:(SEL)selector;

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel;

- (void) mobsterInfoDisplayed:(BOOL)displayed onSprite:(BattleSprite*)sprite;

- (void) spawnPlaneWithTarget:(id)target selector:(SEL)selector;

- (void) updateHealthBarsForPlayer:(BattlePlayer*)myPlayer andEnemy:(BattlePlayer*)enemyPlayer ;
- (void) displayWaveNumber:(int)waveNumber totalWaves:(int)totalWaves andEnemy:(BattlePlayer*)enemyPlayer;

- (void) shakeScreenWithIntensity:(float)intensity;

- (void) pulseBloodOnce;
- (void) pulseBloodContinuously;
- (void) pulseHealthLabelIfRequired:(BOOL)onEnemy forBattlePlayer:(BattlePlayer*)player;
- (void) pulseHealthLabel:(BOOL)isEnemy;
- (void) stopPulsing;

- (void) showHighScoreWordWithScore:(int)currentScore target:(id)target selector:(SEL)selector;

- (void) loadHudView;

- (void) displayLootCounter:(BOOL)show;

- (void) removeButtons;

- (void) updateComboCount:(int)combo;
- (void) moveOutComboCounter;

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block;

- (void) setMovesLeft:(int)movesLeft animated:(BOOL)animated;

- (void) animateDamageLabel:(BOOL)forPlayer initialDamage:(int)initialDamage modifiedDamage:(int)modifiedDamage withCompletion:(void(^)())completion;

- (void) forceSkillClickOver;

@end