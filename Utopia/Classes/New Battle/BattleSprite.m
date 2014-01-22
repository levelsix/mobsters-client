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
#import "Globals.h"
#import "CCSoundAnimation.h"
#import "SoundEngine.h"
#import "Downloader.h"
#import "CCFileUtils.h"

#define ANIMATATION_DELAY 0.07f
#define MAX_SHOTS 5

@implementation BattleSprite

- (id) initWithPrefix:(NSString *)prefix nameString:(NSString *)name isMySprite:(BOOL)isMySprite {
  if ((self = [super init])) {
    self.prefix = prefix;
    self.contentSize = CGSizeMake(40, 55);
    
    self.sprite = [CCSprite node];
    [self addChild:_sprite z:5 tag:9999];
    self.sprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2-3);
    
    CCSprite *s = [CCSprite spriteWithFile:@"shadow.png"];
    [self addChild:s];
    s.position = ccp(self.contentSize.width/2, 0);
    
    self.anchorPoint = ccp(0.5, 0);
    
    self.isFacingNear = YES;
    
    self.healthBgd = [CCSprite spriteWithFile:@"minitimebg.png"];
    [self addChild:self.healthBgd z:6];
    self.healthBgd.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    
    self.healthBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"minihpbar.png"]];
    [self.healthBgd addChild:self.healthBar];
    self.healthBar.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height/2);
    self.healthBar.type = kCCProgressTimerTypeBar;
    self.healthBar.midpoint = ccp(0, 0.5);
    self.healthBar.barChangeRate = ccp(1,0);
    self.healthBar.percentage = 90;
    
    self.healthLabel = [CCLabelTTF labelWithString:@"31/100" fontName:[Globals font] fontSize:12];
    [self.healthBgd addChild:self.healthLabel];
    self.healthLabel.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height);
    [self.healthLabel enableShadowWithOffset:CGSizeMake(0, -1) opacity:0.3f blur:1.f updateImage:NO];
    [self.healthLabel setFontFillColor:ccc3(255, 255, 255) updateImage:YES];
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
    self.attackAnimationN = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
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

- (CCAnimation *) flinchAnimationN {
  if (!_flinchAnimationN) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@FlinchN", self.prefix];
    self.flinchAnimationN = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
  }
  return _flinchAnimationN;
}

- (void) restoreStandingFrame {
  [self attackAnimationN];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Attack%@00.png", self.prefix, self.isFacingNear ? @"N" : @"F"]];
  [self.sprite setDisplayFrame:frame];
  
  self.sprite.flipX = !self.isFacingNear;
}

- (void) beginWalking {
  if (!self.isWalking) {
    self.sprite.flipX = !self.isFacingNear;
    [self.sprite runAction:self.isFacingNear ? self.walkActionN : self.walkActionF];
    self.isWalking = YES;
    
    CCSequence *seq = [CCSequence actions:
                       [CCCallBlock actionWithBlock:
                        ^{
                          [[SoundEngine sharedSoundEngine] puzzleWalking];
                        }],
                       [CCDelayTime actionWithDuration:0.9], nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:seq];
    r.tag = 7654;
    [self runAction:r];
  }
}

- (void) stopWalking {
  self.isWalking = NO;
  [self.sprite stopAction:self.walkActionF];
  [self restoreStandingFrame];
  
  [self stopActionByTag:7654];
  [[SoundEngine sharedSoundEngine] puzzleStopWalking];
}

- (void) performNearAttackAnimationWithTarget:(id)target selector:(SEL)selector {
  self.sprite.flipX = NO;
  [self.sprite runAction:
   [CCSequence actions:
    [CCAnimate actionWithAnimation:self.attackAnimationN],
    [CCCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
    [CCCallFunc actionWithTarget:target selector:selector],
    nil]];
}

- (void) performFarAttackAnimationWithStrength:(float)strength target:(id)target selector:(SEL)selector {
  CCAnimation *anim = self.attackAnimationF.copy;
  
  self.sprite.flipX = YES;
  
  // Repeat 4-8 x times
  int numTimes = strength*(MAX_SHOTS-1);
  
  [anim addSoundEffect:@"pistol.aif" atIndex:5];
  [anim repeatFrames:NSMakeRange(4, 6) numTimes:numTimes];
  
  [self.sprite runAction:
   [CCSequence actions:
    [CCSoundAnimate actionWithAnimation:anim],
    [CCCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
    [CCCallFunc actionWithTarget:target selector:selector],
    nil]];
}

- (void) displayChargingFrame {
  [self attackAnimationN];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Charge.png", self.prefix]];
  [self.sprite setDisplayFrame:frame];
  self.sprite.flipX = NO;
}

- (void) performNearFlinchAnimationWithStrength:(float)strength target:(id)target selector:(SEL)selector {
  CGPoint pointOffset = POINT_OFFSET_PER_SCENE;
  CGPoint startPos = self.position;
  [self.sprite runAction:
    [CCAnimate actionWithAnimation:self.flinchAnimationN]];
  
  float moveTime = 0.15f;
  float moveAmount = 0.006;
  float delayTime = 0.2f;
  int numTimes = strength*(MAX_SHOTS-1)+1;
  
  [self runAction:
   [CCSequence actions:
    [CCDelayTime actionWithDuration:0.2],
    [CCRepeat actionWithAction:
     [CCSequence actions:
      [CCCallBlock actionWithBlock:
       ^{
         int totalParticles = 40+strength*40;
         
         NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"flinchstars.plist"];
         NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
         [dict setObject:[NSNumber numberWithInt:totalParticles] forKey:@"maxParticles"];
         
         CCParticleSystemQuad *q = [[CCParticleSystemQuad alloc] initWithDictionary:dict];
         q.autoRemoveOnFinish = YES;
         q.position = ccpAdd(self.position, ccp(0, self.contentSize.height/2-5));
         q.speedVar = 40+strength*15;
         q.endSizeVar = 5+strength*10;
         [self.parent addChild:q];
       }],
      [CCMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
      [CCDelayTime actionWithDuration:delayTime], nil] times:numTimes],
    [CCMoveTo actionWithDuration:0.1f position:startPos],
    [CCCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
    [CCCallFunc actionWithTarget:target selector:selector],
    nil]];
}

@end
