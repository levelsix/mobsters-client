//
//  TutorialBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "MiniTutorialBattleLayer.h"

@protocol TutorialBattleLayerDelegate <MiniTutorialBattleLayerDelegate>

@optional
- (void) enemyJumpedAndShot;
- (void) enemyTwoHitEnemy;
- (void) enemyBossStomped;
- (void) enemiesRanOut;

- (void) swappedToMark;

@end

@interface TutorialBattleLayer : MiniTutorialBattleLayer

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, assign) id<TutorialBattleLayerDelegate> delegate;

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants;

@end

@interface TutorialBattleOneLayer : TutorialBattleLayer {
  BOOL _hasSpawnedEnemyTeam;
}

@property (nonatomic, retain) IBOutlet NSArray *enemyTeamSprites;

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage;

- (void) enemyJumpAndShoot;
- (void) enemyTwoLookAtEnemy;
- (void) enemyTwoAttackEnemy;
- (void) enemyBossStomp;
- (void) enemyTwoAndBossRunOut;
- (void) enemyBossWalkOut;
- (void) friendKneel;

- (void) swapToMark;

@end
