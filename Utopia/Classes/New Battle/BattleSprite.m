//
//  BattleSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleSprite.h"
#import "CCAnimation+SpriteLoading.h"
#import "cocos2d.h"

#define ANIMATATION_DELAY 0.07f

@implementation BattleSprite

- (id) initWithPrefix:(NSString *)prefix {
  if ((self = [super init])) {
    self.prefix = prefix;
    self.contentSize = CGSizeMake(40, 70);
    
    self.sprite = [CCSprite node];
    [self addChild:_sprite z:5 tag:9999];
    self.sprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    CCSprite *s = [CCSprite spriteWithFile:@"shadow.png"];
    [self addChild:s];
    s.position = ccp(self.contentSize.width/2, 0);
    
    self.anchorPoint = ccp(0.5, 0);
    
    [self restoreStandingFrame];
  }
  return self;
}

- (void) setIsFacingNear:(BOOL)isFacingNear {
  _isFacingNear = isFacingNear;
  [self restoreStandingFrame];
}

- (CCAction *) walkActionN {
  if (!_walkActionN) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunN", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
  }
  return _walkActionN;
}

- (CCAction *) walkActionF {
  if (!_walkActionF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunF", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
  }
  return _walkActionF;
}

- (CCAnimation *) attackAnimationN {
  if (!_attackAnimationN) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@AttackN", self.prefix];
    self.attackAnimationF = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
  }
  return _attackAnimationN;
}

- (CCAnimation *) attackAnimationF {
  if (!_attackAnimationF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@AttackF", self.prefix];
    self.attackAnimationF = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
  }
  return _attackAnimationF;
}

- (void) restoreStandingFrame {
  [self attackAnimationF];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Attack%@00@2x.png", self.prefix, self.isFacingNear ? @"N" : @"F"]];
  [self.sprite setDisplayFrame:frame];
}

- (void) beginWalking {
  [self.sprite runAction:self.walkActionF];
}

- (void) stopWalking {
  [self.sprite stopAction:self.walkActionF];
  [self restoreStandingFrame];
}

- (void) performNearAttackAnimation {
  [self.sprite runAction:[CCAnimate actionWithAnimation:self.attackAnimationN]];
}

- (void) performFarAttackAnimation {
  [self.sprite runAction:[CCAnimate actionWithAnimation:self.attackAnimationF]];
}

- (void) dealloc {
  self.walkActionF = nil;
  self.walkActionN = nil;
  self.attackAnimationF = nil;
  self.attackAnimationN = nil;
  self.prefix = nil;
  self.sprite = nil;
  [super dealloc];
}

@end
