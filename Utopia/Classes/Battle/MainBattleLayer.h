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
#import "BattleItemSelectViewController.h"
#import "ClientProperties.h"
#import "BattleMainView.h"
#import "BattleBgdLayer.h"
#import "BattleStateMachine.h"

#define SkillLogStart(...) //NSLogYellow(__VA_ARGS__)
#define SkillLogEnd(triggered, ...) //if (triggered) { NSLogGreen(__VA_ARGS__); } else { NSLogYellow(__VA_ARGS__); }

#define Y_MOVEMENT_FOR_NEW_SCENE 160
#define TIME_TO_SCROLL_PER_SCENE 2.4f
#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#ifdef DEBUG_BATTLE_MODE
#define NUM_MOVES_PER_TURN 10
#else
// Don't edit this one
#define NUM_MOVES_PER_TURN 3
#endif

#define PULSE_ONCE_THRESH 0.5
#define PULSE_CONT_THRESH 0.3
#define RED_TINT_TAG 6789
#define LOOT_TAG @"Loot"

#define ORB_LAYER_BASE_DIST_FROM_SIDE ([Globals isiPhone6] ? 19.5 : 16)
#define ORB_LAYER_DIST_FROM_SIDE (self.orbLayer.contentSize.height > (self.contentSize.height-2*ORB_LAYER_BASE_DIST_FROM_SIDE) ? (self.contentSize.height-self.orbLayer.contentSize.height)/2 : ORB_LAYER_BASE_DIST_FROM_SIDE)
#define CENTER_OF_BATTLE ccp((self.contentSize.width-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE)/2, self.contentSize.height/2-40)
#define PLAYER_X_DISTANCE_FROM_CENTER (CENTER_OF_BATTLE.x*0.4+4)
#define MY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(-PLAYER_X_DISTANCE_FROM_CENTER, -PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define ENEMY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(PLAYER_X_DISTANCE_FROM_CENTER, PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define BGD_LAYER_INIT_POSITION ccp(-440+(CENTER_OF_BATTLE.x-CENTER_OF_BATTLE.y/SLOPE_OF_ROAD), 0)

#define BOTTOM_CENTER_X (self.contentSize.width-self.orbLayer.contentSize.width-ORB_LAYER_DIST_FROM_SIDE)/2

#define DEPLOY_CENTER_X roundf(MAX(BOTTOM_CENTER_X, self.mainView.hudView.deployView.width/2+5.f))

#define PUZZLE_ON_LEFT_BGD_OFFSET (self.contentSize.width-2*CENTER_OF_BATTLE.x)

@protocol BattleLayerDelegate <NSObject>

- (void) battleComplete:(NSDictionary *)params;

@end

@interface MainBattleLayer : CCNode <OrbMainLayerDelegate, BattleBgdLayerDelegate, BattleScheduleViewDelegate, BattleLayerSkillPopupDelegate, BattleItemSelectDelegate, DialogueViewControllerDelegate> {
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
  
  BOOL _wonBattle;
  int _numTimesNotResponded;
  
  int _myDamageDealt;
  int _myDamageForThisTurn;
  int _myDamageDealtUnmodified;
  int _enemyDamageDealtUnmodified;
  
  BOOL _hasStarted;
  BOOL _isExiting;
  
  int _orbCounts[OrbColorNone];
  int _totalOrbCounts[OrbColorNone];
  int _powerupCounts[PowerupTypeEnd];
  int _totalComboCount;
  int _totalDamageTaken;
  
  CGSize _gridSize;
  
  BOOL _shouldDisplayNewSchedule;
//  BOOL _displayedWaveNumber;
  BOOL _reachedNextScene;
  BOOL _firstTurn;
  
  @protected BOOL _isResumingState;
  
  int _enemyCounter;
  
  BoardLayoutProto *_layoutProto;
  
  DialogueViewController *_forcedSkillDialogueViewController;
  
  BOOL _dungeonPlayerHitsFirst;
  
  BOOL _movesLeftHidden;
  
  UserBattleItem *_selectedBattleItem;
  
  
  CCLabelTTF *_noMovesLabel;
  
  @protected TKEvent *loadingCompleteEvent, *nextEnemyEvent, *playerSwapEvent, *playerTurnEvent, *playerMoveEvent,
  *playerAttackEvent, *enemyTurnEvent, *playerVictoryEvent, *playerDeathEvent, *playerReviveEvent, *playerRunEvent, *playerLoseEvent;
}

@property (readonly) float orbLayerDistFromSide;
@property (readonly) CGPoint centerOfBattle;
@property (readonly) float playerXDistanceFromCenter;
@property (readonly) CGPoint myPlayerLocation;
@property (readonly) CGPoint enemyLocation;
@property (readonly) CGPoint bgdLayerInitPosition;
@property (readonly) float bottomCenterX;
@property (readonly) float deployCenterX;

@property (nonatomic, retain) BattleStateMachine *battleStateMachine;

@property (readonly) BOOL displayedWaveNumber;

@property (nonatomic, retain) BattleMainView *mainView;

@property (nonatomic, retain) OrbMainLayer *orbLayer;

@property (nonatomic, retain) BattlePlayer *myPlayerObject;
@property (nonatomic, retain) BattlePlayer *enemyPlayerObject;

@property (nonatomic, retain) NSArray *myTeam;
@property (nonatomic, retain) NSArray *enemyTeam;

@property (nonatomic, retain) BattleSchedule *battleSchedule;

@property (nonatomic, weak) id<BattleLayerDelegate> delegate;

@property (nonatomic, retain) BattleEndView *endView;

@property (nonatomic, assign) int enemyDamageDealt; // used by skillManager to set damage dealt by skills like Cake Drop

@property (nonatomic, assign) BOOL shouldShowContinueButton;
@property (nonatomic, assign) BOOL shouldShowChatLine;

@property (nonatomic, assign) int movesLeft;
@property (nonatomic, assign) BOOL shouldDisplayNewSchedule;

@property (nonatomic, assign) BOOL allowBattleItemPurchase;

// Used for skills that render the drop invalid (e.g. cake kid)
@property (nonatomic, retain) NSMutableArray *droplessStageNums;

// Team snapshots used for replays
@property (nonatomic, retain) NSArray *playerTeamSnapshot;
@property (nonatomic, retain) NSArray *enemyTeamSnapshot;

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize;
- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix;
- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft gridSize:(CGSize)gridSize bgdPrefix:(NSString *)bgdPrefix layoutProto:(BoardLayoutProto *)layoutProto;
- (void) initOrbLayer;

- (CombatReplayMonsterSnapshot*) monsterSnapshot:(UserMonster*)um isOffensive:(BOOL)isOffensive;

- (void) setupStateMachine;

- (void) begin;
- (BattlePlayer *) firstMyPlayer;
- (void) beginNextTurn;
- (void) beginMyTurn;
- (void) endMyTurnAfterDelay:(NSTimeInterval)delay;
- (void) myTurnEnded;
- (void) doMyAttackAnimation;
- (int) calculateUnmodifiedEnemyDamage;
- (int) calculateModifiedEnemyDamage:(int)unmodifiedDamage;
- (void) beginEnemyTurn:(float)delay;
- (void) checkIfAnyMovesLeft;
- (void) startMyMove;
- (void) currentMyPlayerDied;
- (void) makePlayer:(BattleSprite *)player walkInFromEntranceWithSelector:(SEL)selector;

- (void) setMovesLeft:(int)movesLeft animated:(BOOL)animated;

- (void) createScheduleWithSwap:(BOOL)swap;
- (void) createScheduleWithSwap:(BOOL)swap playerHitsFirst:(BOOL)playerFirst;

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy;
- (void) dealDamageToSelf:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withTarget:(id)target andSelector:(SEL)selector;
- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector;
- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility showDamageLabel:(BOOL)showLabel withTarget:(id)target withSelector:(SEL)selector;
- (void) healForAmount:(int)heal enemyIsHealed:(BOOL)enemyIsHealed withTarget:(id)target andSelector:(SEL)selector;
- (void) instantSetHealthForEnemy:(BOOL)enemy to:(int)health withTarget:(id)target andSelector:(SEL)selector;

- (void) updateHealthBars;

- (BOOL) spawnNextEnemy;
- (BOOL) createNextEnemyObject;
- (void) triggerSkillForEnemyCreatedWithBlock:(dispatch_block_t)block;

- (CCSprite *) getCurrentEnemyLoot;
- (void) pickUpLoot;
- (void) moveToNextEnemy;
- (void) moveToNextEnemyWithPlayerFirst:(BOOL)playerHitsFirst;
- (void) youWon;
- (void) youLost;
- (void) youForfeited;
- (void) forfeit;
- (IBAction)forfeitClicked:(id)sender;
- (IBAction)cancelDeploy:(id)sender;
- (IBAction)deployCardClicked:(id)sender;
- (void) continueConfirmed;
- (void) exitFinal;

- (void) fireWinEvent;
- (void) fireLoseEvent;
- (void) fireEvent:(TKEvent*)event userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error;

- (void) buildReplay;
- (CombatReplayProto*) createReplayWithBuilder:(CombatReplayProto_Builder*)builder;

- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;

- (void) checkMyHealth;
- (BOOL) checkEnemyHealth;
- (void) checkEnemyHealthAndStartNewTurn;

- (void) sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify;

- (void) displayOrbLayer;
- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block;

- (void) useHealthPotion:(BattleItemProto *)bip;
- (void) useBoardShuffle:(BattleItemProto *)bip;
- (void) useHandSwap:(BattleItemProto *)bip;
- (void) useOrbHammer:(BattleItemProto *)bip;
- (void) usePutty:(BattleItemProto *)bip;
- (void) useSkillAntidote:(BattleItemProto *)bip;

- (NSDictionary *) battleCompleteValues;

- (IBAction)winExitClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;

- (BOOL) canSwap;

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel;
- (void) deployBattleSprite:(BattlePlayer *)bp;
- (void) triggerSkillForPlayerCreatedWithBlock:(dispatch_block_t)block;

- (void) prepareScheduleView;

- (NSInteger) currentStageNum;
- (NSInteger) stagesLeft;
- (NSInteger) playerMobstersLeft;

- (void) processNextTurn:(float)delay;

- (BOOL) isFirstEnemy;

- (void) forceSkillClickOver:(DialogueViewController *)dvc;
- (IBAction)skillClicked:(id)sender;

- (void) openGemShop;

@end
