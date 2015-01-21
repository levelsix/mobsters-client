//
//  NewBattleLayer.h
//  PadClone
//
//  Created by Ashwin Kamath on 8/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BattleSprite.h"
#import "BattlePlayer.h"
#import "BattleViews.h"
#import "OrbMainLayer.h"
#import "BattleSchedule.h"
#import "BattleScheduleView.h"
#import "BattleHudView.h"
#import "SkillBattleIndicatorView.h"
#import "DialogueViewController.h"

#define SkillLogStart(...) //NSLogYellow(__VA_ARGS__)
#define SkillLogEnd(triggered, ...) //if (triggered) { NSLogGreen(__VA_ARGS__); } else { NSLogYellow(__VA_ARGS__); }

#define Y_MOVEMENT_FOR_NEW_SCENE 160
#define TIME_TO_SCROLL_PER_SCENE 2.4f
#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#ifdef DEBUG
#define NUM_MOVES_PER_TURN 50
#else
// Don't edit this one
#define NUM_MOVES_PER_TURN 3
#endif

#define PULSE_ONCE_THRESH 0.5
#define PULSE_CONT_THRESH 0.3
#define RED_TINT_TAG 6789
#define LOOT_TAG @"Loot"

#define ORB_LAYER_DIST_FROM_SIDE ([Globals isiPhone6] ? 19.5 : 16)
#define CENTER_OF_BATTLE ccp((self.contentSize.width-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE)/2, self.contentSize.height/2-40)
#define PLAYER_X_DISTANCE_FROM_CENTER (CENTER_OF_BATTLE.x*0.4+4)
#define MY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(-PLAYER_X_DISTANCE_FROM_CENTER, -PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define ENEMY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(PLAYER_X_DISTANCE_FROM_CENTER, PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define BGD_LAYER_INIT_POSITION ccp(-440+(CENTER_OF_BATTLE.x-CENTER_OF_BATTLE.y/SLOPE_OF_ROAD), 0)

#define PUZZLE_ON_LEFT_BGD_OFFSET (self.contentSize.width-2*CENTER_OF_BATTLE.x)

@protocol BattleBgdLayerDelegate <NSObject>

- (void) reachedNextScene;

@end

@interface BattleBgdLayer : CCNode {
  CGPoint _curBasePoint;
}

@property (nonatomic, assign) id<BattleBgdLayerDelegate> delegate;
@property (nonatomic, retain) NSString *prefix;

- (id) initWithPrefix:(NSString *)prefix;
- (void) scrollToNewScene;

@end

@protocol BattleLayerDelegate <NSObject>

- (void) battleComplete:(NSDictionary *)params;

@end

@interface NewBattleLayer : CCNode <OrbMainLayerDelegate, BattleBgdLayerDelegate, BattleScheduleViewDelegate> {
  int _orbCount;
  int _comboCount;
  int _movesLeft;
  BOOL _enemyShouldAttack;
  
  int _curStage;
  int _lootCount;
  CCSprite *_lootSprite;
  
  int _soundComboCount;
  BOOL _canPlayNextComboSound;
  BOOL _canPlayNextGemPop;
  
  BOOL _puzzleIsOnLeft;
  
  BOOL _wonBattle;
  int _numTimesNotResponded;
  
  int _myDamageDealt;
  int _myDamageForThisTurn;
  
  BOOL _hasStarted;
  BOOL _isExiting;
  
  int _orbCounts[OrbColorNone];
  int _totalOrbCounts[OrbColorNone];
  int _powerupCounts[PowerupTypeEnd];
  int _totalComboCount;
  int _totalDamageTaken;
  
  CGSize _gridSize;
  
  BOOL _shouldDisplayNewSchedule;
  BOOL _displayedWaveNumber;
  BOOL _reachedNextScene;
  BOOL _firstTurn;
  
  int _enemyCounter;
  
  BoardLayoutProto *_layoutProto;
  
  DialogueViewController *_forcedSkillDialogueViewController;
}

@property (nonatomic, retain) CCSprite *movesBgd;
@property (nonatomic, retain) CCLabelTTF *movesLeftLabel;
@property (nonatomic, retain) CCLabelTTF *lootLabel;
@property (nonatomic, retain) CCSprite *lootBgd;
@property (nonatomic, retain) CCSprite *comboBgd;
@property (nonatomic, retain) CCLabelTTF *comboLabel;
@property (nonatomic, retain) CCLabelTTF *comboBotLabel;

@property (nonatomic, retain) OrbMainLayer *orbLayer;

// bgdContainer holds the bgdLayer as well as battlesprites and all animations on the ground
@property (nonatomic, retain) CCNode *bgdContainer;
@property (nonatomic, retain) BattleBgdLayer *bgdLayer;
@property (nonatomic, retain) BattleSprite *myPlayer;
@property (nonatomic, retain) BattleSprite *currentEnemy;

@property (nonatomic, retain) BattlePlayer *myPlayerObject;
@property (nonatomic, retain) BattlePlayer *enemyPlayerObject;

@property (nonatomic, retain) CCSprite *bloodSplatter;

@property (nonatomic, retain) NSArray *myTeam;
@property (nonatomic, retain) NSArray *enemyTeam;

@property (nonatomic, retain) BattleSchedule *battleSchedule;

@property (nonatomic, assign) id<BattleLayerDelegate> delegate;


@property (nonatomic, retain) BattleEndView *endView;

@property (nonatomic, retain) IBOutlet BattleHudView *hudView;

@property (nonatomic, assign) int enemyDamageDealt; // used by skillManager to set damage dealt by skills like Cake Drop

@property (nonatomic, assign) BOOL shouldShowContinueButton;
@property (nonatomic, assign) BOOL shouldShowChatLine;

@property (nonatomic, assign) int movesLeft;
@property (nonatomic, assign) BOOL shouldDisplayNewSchedule;

// Used for skills that render the drop invalid (e.g. cake kid)
@property (nonatomic, retain) NSMutableArray *droplessStageNums;

// Used for the skill explination
@property (nonatomic, retain) IBOutlet UIView *forcedSkillView;
@property (nonatomic, retain) IBOutlet UIButton *forcedSkillButton;
@property (nonatomic, retain) IBOutlet UIView *forcedSkillInnerView;

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize;
- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix;
- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix layoutProto:(BoardLayoutProto *)layoutProto;
- (void) initOrbLayer;

- (void) begin;
- (BattlePlayer *) firstMyPlayer;
- (void) beginNextTurn;
- (void) beginMyTurn;
- (void) myTurnEnded;
- (void) beginEnemyTurn:(float)delay;
- (void) checkIfAnyMovesLeft;
- (void) currentMyPlayerDied;
- (void) createNextMyPlayerSprite;
- (float) makeMyPlayerWalkOutWithBlock:(void (^)(void))completion;
- (void) makePlayer:(BattleSprite *)player walkInFromEntranceWithSelector:(SEL)selector;

- (void) createScheduleWithSwap:(BOOL)swap;
- (void) createScheduleWithSwap:(BOOL)swap forcePlayerAttackFirst:(BOOL)playerFirst;

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy;
- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector;
- (void) spawnPlaneWithTarget:(id)target selector:(SEL)selector;

- (void) updateHealthBars;
- (void) displayWaveNumber;

- (BOOL) createNextEnemyObject;
- (CCSprite *) getCurrentEnemyLoot;
- (void) dropLoot:(CCSprite *)ed;
- (void) pickUpLoot;
- (void) moveToNextEnemy;
- (void) youWon;
- (void) youLost;
- (void) youForfeited;
- (IBAction)forfeitClicked:(id)sender;
- (void) continueConfirmed;
- (void) exitFinal;
- (void) shakeScreenWithIntensity:(float)intensity;

- (void) checkMyHealth;
- (BOOL) checkEnemyHealth;
- (void) checkEnemyHealthAndStartNewTurn;

- (void) sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify;

- (void) pulseBloodOnce;
- (void) pulseBloodContinuously;
- (void) pulseHealthLabel:(BOOL)isEnemy;
- (void) stopPulsing;

- (void) displayOrbLayer;
- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block;

- (NSDictionary *) battleCompleteValues;

- (IBAction)winExitClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;


- (void) displayDeployViewAndIsCancellable:(BOOL)cancel;
- (void) deployBattleSprite:(BattlePlayer *)bp;

- (void) loadHudView;

- (void) displayEffectivenessForAttackerElement:(Element)atkElement defenderElement:(Element)defElement position:(CGPoint)position;

- (void) prepareScheduleView;

- (void) blowupBattleSprite:(BattleSprite *)sprite withBlock:(void(^)())block;

- (NSInteger) currentStageNum;
- (NSInteger) stagesLeft;
- (NSInteger) playerMobstersLeft;

- (void) processNextTurn:(float)delay;

- (BOOL) isFirstEnemy;

- (void) forceSkillClickOver:(DialogueViewController *)dvc;

@end
