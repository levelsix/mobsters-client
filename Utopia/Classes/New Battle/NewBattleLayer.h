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

@end
