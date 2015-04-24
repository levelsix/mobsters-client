//
//  OrbMainLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "CCNode.h"

#import "BattleOrbLayout.h"

#import "OrbSwipeLayer.h"
#import "OrbBgdLayer.h"

@protocol OrbMainLayerDelegate <NSObject>

- (void) moveBegan;
- (void) newComboFound;
- (void) orbKilled:(BattleOrb *)orb;
- (void) powerupCreated:(BattleOrb *)orb;
- (void) moveComplete;
- (void) reshuffleWithPrompt:(NSString*)prompt;

@end

@interface OrbMainLayer : CCNode {
  BOOL _isPulseScheduled;
}

// The level contains the tiles, the cookies, and most of the gameplay logic.
@property (strong, nonatomic) BattleOrbLayout *layout;

@property (nonatomic, retain) OrbSwipeLayer *swipeLayer;
@property (nonatomic, retain) OrbBgdLayer *bgdLayer;
@property (nonatomic, retain) OrbBgdLayer *clipBgdLayer;

@property (nonatomic, assign) BOOL allowFreeMove;
@property (nonatomic, assign) BOOL allowOrbHammer;
@property (nonatomic, assign) BOOL allowPutty;

@property (nonatomic, weak) id<OrbMainLayerDelegate> delegate;

- (id) initWithLayoutProto:(BoardLayoutProto *)proto;
- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors;
- (id) initWithGridSize:(CGSize)gridSize userBoardObstacles:(NSArray *)userBoardObstacles;
- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors layout:(BattleOrbLayout *)layout;

- (void) checkSwap:(BattleSwap *)swap;

- (void) pulseValidMove;
- (void) schedulePulse;
- (void) allowInput;
- (void) disallowInput;
- (void) shuffleWithCompletion:(void(^)())completion;
- (void) shuffleWithoutEnforcementAndCheckMatches;

- (void) allowFreeMoveForSingleTurn;
- (void) cancelFreeMove;

- (void) allowOrbHammerForSingleTurn;
- (void) cancelOrbHammer;

- (void) allowPuttyForSingleTurn;
- (void) cancelPutty;

- (void) toggleArrows:(BOOL)on;

- (id) serialize;
- (void) deserialize:(NSArray *)arr;

@end
