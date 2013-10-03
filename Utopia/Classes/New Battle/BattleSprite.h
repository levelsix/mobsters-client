//
//  BattleSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCSprite.h"

@interface BattleSprite : CCSprite

@property (nonatomic, retain) NSString *prefix;

@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;

@property (nonatomic, retain) CCAnimation *attackAnimationN;
@property (nonatomic, retain) CCAnimation *attackAnimationF;

@property (nonatomic, retain) CCSprite *sprite;

@property (nonatomic, assign) BOOL isFacingNear;

- (void) beginWalking;
- (void) stopWalking;

- (void) performNearAttackAnimation;
- (void) performFarAttackAnimation;

- (id) initWithPrefix:(NSString *)prefix;

@end
