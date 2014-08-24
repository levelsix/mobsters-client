//
//  OrbMainLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "CCNode.h"

#import "BattleLayout.h"

#import "OrbSwipeLayer.h"
#import "OrbBgdLayer.h"

@protocol OrbMainLayerDelegate <NSObject>

- (void) moveBegan;
- (void) newComboFound;
- (void) orbKilled:(BattleOrb *)orb;
- (void) powerupCreated:(BattleOrb *)orb;
- (void) moveComplete;
- (void) reshuffle;

@end

@interface OrbMainLayer : CCNode

// The level contains the tiles, the cookies, and most of the gameplay logic.
@property (strong, nonatomic) BattleLayout *layout;

@property (nonatomic, retain) OrbSwipeLayer *swipeLayer;
@property (nonatomic, retain) OrbBgdLayer *bgdLayer;

@property (nonatomic, assign) id<OrbMainLayerDelegate> delegate;

- (id) initWithGridSize:(CGSize)gridSize numColors:(int)numColors;

- (void) allowInput;
- (void) disallowInput;

- (id) serialize;
- (void) deserialize:(NSArray *)arr;

@end
