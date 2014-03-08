//
//  TutorialBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"

@protocol TutorialBattleLayerDelegate <BattleLayerDelegate>

- (void) battleLayerReachedEnemy;
- (void) moveMade;
- (void) moveFinished;
- (void) turnFinished;
- (void) swappedToMark;

@end

@interface TutorialBattleLayer : NewBattleLayer {
  BOOL _allowTurnBegin;
}

@property (nonatomic, retain) StartupResponseProto_TutorialConstants *constants;

@property (nonatomic, assign) id<TutorialBattleLayerDelegate> delegate;

@property (nonatomic, assign) int swappableTeamSlot;

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants;
- (void) beginFirstMove;
- (void) beginSecondMove;
- (void) beginThirdMove;
- (void) allowMove;

@end

@interface TutorialBattleOneLayer : TutorialBattleLayer

@end

@interface TutorialBattleTwoLayer : TutorialBattleLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage;

- (void) swapToMark;

@end
