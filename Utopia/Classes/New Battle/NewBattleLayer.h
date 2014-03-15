//
//  NewBattleLayer.h
//  PadClone
//
//  Created by Ashwin Kamath on 8/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "OrbLayer.h"
#import "BattleSprite.h"
#import "BattlePlayer.h"
#import "BattleViews.h"
#import "OrbBgdLayer.h"

#define Y_MOVEMENT_FOR_NEW_SCENE 100
#define TIME_TO_SCROLL_PER_SCENE 1.8f
#define HEALTH_BAR_SPEED 40
#define MY_WALKING_SPEED 250.f

#define NUM_MOVES_PER_TURN 3

#define PULSE_ONCE_THRESH 0.5
#define PULSE_CONT_THRESH 0.3
#define RED_TINT_TAG 6789
#define LOOT_TAG @"Loot"

#define CENTER_OF_BATTLE ccp((self.contentSize.width-self.orbBgdLayer.contentSize.width-14)/2, self.contentSize.height/2-40)
#define PLAYER_X_DISTANCE_FROM_CENTER (CENTER_OF_BATTLE.x*0.4+4)
#define MY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(-PLAYER_X_DISTANCE_FROM_CENTER, -PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define ENEMY_PLAYER_LOCATION ccpAdd(CENTER_OF_BATTLE, ccp(PLAYER_X_DISTANCE_FROM_CENTER, PLAYER_X_DISTANCE_FROM_CENTER*SLOPE_OF_ROAD))
#define BGD_LAYER_INIT_POSITION ccp(-530+(CENTER_OF_BATTLE.x-CENTER_OF_BATTLE.y*SLOPE_OF_ROAD), 0)

#define PUZZLE_ON_LEFT_BGD_OFFSET (self.contentSize.width-2*CENTER_OF_BATTLE.x)

@protocol BattleBgdLayerDelegate <NSObject>

- (void) reachedNextScene;

@end

@interface BattleBgdLayer : CCNode {
  CGPoint _curBasePoint;
}

@property (nonatomic, assign) id<BattleBgdLayerDelegate> delegate;

- (void) scrollToNewScene;

@end

@protocol BattleLayerDelegate <NSObject>

- (void) battleComplete:(NSDictionary *)params;

@end

@interface NewBattleLayer : CCNode <OrbLayerDelegate, BattleBgdLayerDelegate> {
  int _orbCount;
  int _comboCount;
  int _movesLeft;
  BOOL _enemyShouldAttack;
  
  int _curStage;
  int _lootCount;
  BOOL _lootDropped;
  
  int _soundComboCount;
  BOOL _canPlayNextComboSound;
  BOOL _canPlayNextGemPop;
  
  BOOL _puzzleIsOnLeft;
  
  BOOL _wonBattle;
  BOOL _manageWasClicked;
  int _numTimesNotResponded;
  
  int _myDamageDealt;
  int _myDamageForThisTurn;
  int _enemyDamageDealt;
  
  BOOL _hasStarted;
  BOOL _isExiting;
}

@property (nonatomic, retain) CCSprite *movesBgd;
@property (nonatomic, retain) CCLabelTTF *movesLeftLabel;
@property (nonatomic, retain) CCLabelTTF *lootLabel;
@property (nonatomic, retain) CCSprite *comboBgd;
@property (nonatomic, retain) CCLabelTTF *comboLabel;
@property (nonatomic, retain) CCLabelTTF *comboBotLabel;

@property (nonatomic, retain) OrbLayer *orbLayer;
@property (nonatomic, retain) OrbBgdLayer *orbBgdLayer;

// bgdContainer holds the bgdLayer as well as battlesprites and all animations on the ground
@property (nonatomic, retain) CCNode *bgdContainer;
@property (nonatomic, retain) BattleBgdLayer *bgdLayer;
@property (nonatomic, retain) BattleSprite *myPlayer;
@property (nonatomic, retain) BattleSprite *currentEnemy;

@property (nonatomic, retain) BattlePlayer *myPlayerObject;
@property (nonatomic, retain) BattlePlayer *enemyPlayerObject;

@property (nonatomic, retain) CCSprite *bloodSplatter;

@property (nonatomic, retain) CCNodeColor *noInputLayer;

@property (nonatomic, retain) NSArray *myTeam;
@property (nonatomic, retain) NSArray *enemyTeam;

@property (nonatomic, assign) id<BattleLayerDelegate> delegate;

- (id) initWithMyUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft;
- (void) initOrbLayer;

- (CGSize) gridSize;

- (void) begin;
- (BattlePlayer *) firstMyPlayer;
- (void) beginMyTurn;
- (void) myTurnEnded;
- (void) beginEnemyTurn;
- (void) checkIfAnyMovesLeft;
- (void) currentMyPlayerDied;
- (void) createNextMyPlayerSprite;
- (void) makeMyPlayerWalkOut;
- (void) makePlayer:(BattleSprite *)player walkInFromEntranceWithSelector:(SEL)selector;

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector;
- (void) spawnPlaneWithTarget:(id)target selector:(SEL)selector;

- (void) updateHealthBars;
- (void) displayWaveNumber;

- (void) createNextEnemyObject;
- (int) getCurrentEnemyLoot;
- (void) pickUpLoot:(CCSprite *)ed;
- (void) moveToNextEnemy;
- (void) youWon;
- (void) youLost;
- (BOOL) shouldShowContinueButton;
- (IBAction)forfeitClicked:(id)sender;
- (void) continueConfirmed;
- (void) exitFinal;

- (void) checkEnemyHealth;

- (void) sendServerUpdatedValues;

- (void) pulseBloodOnce;
- (void) pulseBloodContinuously;
- (void) pulseHealthLabel:(BOOL)isEnemy;
- (void) stopPulsing;

- (void) displayNoInputLayer;
- (void) removeNoInputLayer;

- (void) displayOrbLayer;
- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block;

- (void) displaySwapButton;

- (IBAction)winExitClicked:(id)sender;
- (IBAction)manageClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;


@property (nonatomic, retain) BattleLostView *lostView;
@property (nonatomic, retain) BattleWonView *wonView;

@property (nonatomic, retain) IBOutlet UIView *swapView;
@property (nonatomic, retain) IBOutlet UILabel *swapLabel;
@property (nonatomic, retain) IBOutlet BattleDeployView *deployView;
@property (nonatomic, retain) IBOutlet UIButton *forfeitButton;
@property (nonatomic, retain) IBOutlet UIButton *deployCancelButton;

@property (nonatomic, retain) IBOutlet UIButton *elementButton;
@property (nonatomic, retain) IBOutlet BattleElementView *elementView;

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel;
- (void) deployBattleSprite:(BattlePlayer *)bp;

- (void) loadDeployView;
- (void) removeSwapButton;
- (void) removeDeployView;

- (IBAction)elementButtonClicked:(id)sender;

- (void) displayEffectivenessForAttackerElement:(MonsterProto_MonsterElement)atkElement defenderElement:(MonsterProto_MonsterElement)defElement position:(CGPoint)position;

@end
