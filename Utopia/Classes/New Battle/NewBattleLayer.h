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
  float _currentScore;
  int _movesLeft;
  int _numStages;
  
  float _scoreForThisTurn;
  
  int _enemyDamagePercent;
  
  int _curStage;
  int _lootCount;
  
  int _soundComboCount;
  BOOL _canPlayNextComboSound;
  BOOL _canPlayNextGemPop;
  
  BOOL _puzzleIsOnLeft;
  
  BOOL _isLoading;
}

@property (nonatomic, retain) CCProgressNode *powerBar;
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

- (void) beginMyTurn;
- (void) myTurnEnded;
- (void) beginEnemyTurn;
- (void) currentMyPlayerDied;
- (void) createNextMyPlayerSprite;
- (void) makeMyPlayerWalkOut;
- (void) makeMyPlayerWalkInFromEntranceWithSelector:(SEL)selector;

- (void) createNextEnemyObject;
- (int) getCurrentEnemyLoot;
- (void) moveToNextEnemy;
- (void) youWon;
- (void) youLost;

- (void) displayNoInputLayer;
- (void) removeNoInputLayer;

- (void) displayOrbLayer;
- (void) removeOrbLayerAnimated:(BOOL)animated withBlock:(void(^)())block;

@end
