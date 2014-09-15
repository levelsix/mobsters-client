//
//  BattleSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "BattleSpeechBubble.h"
#import "Protocols.pb.h"
#import "AnimatedSprite.h"

#define MELEE_RUN_SPEED (MY_WALKING_SPEED*2/3.f)

@interface BattleSprite : CCSprite

@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, assign) MonsterProto_AnimationType animationType;

@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;

@property (nonatomic, retain) CCAnimation *attackAnimationN;
@property (nonatomic, retain) CCAnimation *attackAnimationF;

@property (nonatomic, retain) CCAnimation *flinchAnimationN;
@property (nonatomic, retain) CCAnimation *flinchAnimationF;

@property (nonatomic, retain) CCSprite *sprite;

@property (nonatomic, retain) CCLabelTTF *healthLabel;
@property (nonatomic, retain) CCProgressNode *healthBar;
@property (nonatomic, retain) CCSprite *healthBgd;
@property (nonatomic, retain) CCLabelTTF *nameLabel;

@property (nonatomic, retain) CCSprite *rarityTag;

@property (nonatomic, assign) BOOL isFacingNear;
@property (nonatomic, assign) BOOL isWalking;

// Used for clan battle sprites
@property (nonatomic, assign) BOOL cameFromTop;

- (void) beginWalking;
- (void) stopWalking;

- (void) displayChargingFrame;
- (void) restoreStandingFrame;
- (void) restoreStandingFrame:(MapDirection)direction;

- (void) faceNearWithoutUpdate;
- (void) faceFarWithoutUpdate;

- (void) performNearAttackAnimationWithEnemy:(BattleSprite *)enemy shouldReturn:(BOOL)shouldReturn shouldFlinch:(BOOL)flinch target:(id)target selector:(SEL)selector;
- (void) performFarAttackAnimationWithStrength:(float)strength enemy:(BattleSprite *)enemy target:(id)target selector:(SEL)selector;

- (void) performNearFlinchAnimationWithStrength:(float)strength delay:(float)delay;
- (void) performFarFlinchAnimationWithDelay:(float)delay;

- (id) initWithPrefix:(NSString *)prefix nameString:(NSAttributedString *)name rarity:(Quality)rarity animationType:(MonsterProto_AnimationType)animationType isMySprite:(BOOL)isMySprite verticalOffset:(float)verticalOffset;

- (void) showRarityTag;
- (void) doRarityTagShine;

- (void) jumpNumTimes:(int)numTimes completionTarget:(id)target selector:(SEL)completion;
- (void) jumpNumTimes:(int)numTimes timePerJump:(float)dur height:(float)height completionTarget:(id)target selector:(SEL)completion;

@end
