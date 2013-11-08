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

@protocol BattleBgdLayerDelegate <NSObject>

- (void) reachedNextScene;

@end

@interface BattleBgdLayer : CCLayer {
  CGPoint _curBasePoint;
}

@property (nonatomic, assign) id<BattleBgdLayerDelegate> delegate;

- (void) scrollToNewScene;

@end

@protocol BattleLayerDelegate <NSObject>

- (void) battleComplete;

@end

@interface NewBattleLayer : CCLayer <OrbLayerDelegate, BattleBgdLayerDelegate> {
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
  
  BOOL _isLoading;
}

@property (nonatomic, assign) CCProgressTimer *powerBar;
@property (nonatomic, assign) CCSprite *movesBgd;
@property (nonatomic, assign) CCLabelTTF *movesLeftLabel;
@property (nonatomic, assign) CCLabelTTF *lootLabel;
@property (nonatomic, assign) CCSprite *comboBgd;
@property (nonatomic, assign) CCLabelTTF *comboLabel;

@property (nonatomic, assign) BattleBgdLayer *bgdLayer;
@property (nonatomic, assign) OrbLayer *orbLayer;

@property (nonatomic, assign) BattleSprite *myPlayer;
@property (nonatomic, assign) BattleSprite *currentEnemy;

@property (nonatomic, retain) BattlePlayer *myPlayerObject;
@property (nonatomic, retain) BattlePlayer *enemyPlayerObject;

@property (nonatomic, assign) CCSprite *bloodSplatter;

@property (nonatomic, assign) CCLayerColor *noInputLayer;

@property (nonatomic, retain) NSArray *myTeam;
@property (nonatomic, retain) NSArray *enemyTeam;

@property (nonatomic, assign) id<BattleLayerDelegate> delegate;

- (id) initWithMyUserMonsters:(NSArray *)monsters;

- (void) beginMyTurn;
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
