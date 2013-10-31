//
//  BattleSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface BattleSprite : CCSprite

@property (nonatomic, retain) NSString *prefix;

@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;

@property (nonatomic, retain) CCAnimation *attackAnimationN;
@property (nonatomic, retain) CCAnimation *attackAnimationF;

@property (nonatomic, retain) CCAnimation *flinchAnimationN;
@property (nonatomic, retain) CCAnimation *flinchAnimationF;

@property (nonatomic, retain) CCSprite *sprite;

@property (nonatomic, assign) CCLabelTTF *healthLabel;
@property (nonatomic, assign) CCProgressTimer *healthBar;
@property (nonatomic, assign) CCSprite *healthBgd;

@property (nonatomic, assign) BOOL isFacingNear;
@property (nonatomic, assign) BOOL isWalking;

- (void) beginWalking;
- (void) stopWalking;

- (void) displayChargingFrame;
- (void) restoreStandingFrame;

- (void) performNearAttackAnimationWithTarget:(id)target selector:(SEL)selector;
- (void) performFarAttackAnimationWithStrength:(float)strength target:(id)target selector:(SEL)selector;

- (void) performNearFlinchAnimationWithStrength:(float)strength target:(id)target selector:(SEL)selector;

- (id) initWithPrefix:(NSString *)prefix;

@end
