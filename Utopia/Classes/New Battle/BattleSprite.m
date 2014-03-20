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
#import "NewBattleLayer.h"

#define ANIMATATION_DELAY 0.07f
#define MAX_SHOTS 3

@implementation BattleSprite

- (id) initWithPrefix:(NSString *)prefix nameString:(NSString *)name animationType:(MonsterProto_AnimationType)animationType isMySprite:(BOOL)isMySprite verticalOffset:(float)verticalOffset {
  if ((self = [super init])) {
    self.prefix = prefix;
    self.contentSize = CGSizeMake(40, 55);
    self.animationType = animationType;
    
    self.sprite = [CCSprite node];
    [self addChild:_sprite z:5];
    self.sprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2-3+verticalOffset);
    
    CCSprite *s = [CCSprite spriteWithImageNamed:@"shadow.png"];
    [self addChild:s];
    s.position = ccp(self.contentSize.width/2, 0);
    
    self.anchorPoint = ccp(0.5, 0);
    
    self.isFacingNear = YES;
    
    self.healthBgd = [CCSprite spriteWithImageNamed:@"minitimebg.png"];
    [self addChild:self.healthBgd z:6];
    self.healthBgd.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    
    self.healthBar = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:@"minihpbar.png"]];
    [self.healthBgd addChild:self.healthBar];
    self.healthBar.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height/2);
    self.healthBar.type = CCProgressNodeTypeBar;
    self.healthBar.midpoint = ccp(0, 0.5);
    self.healthBar.barChangeRate = ccp(1,0);
    self.healthBar.percentage = 90;
    
    self.healthLabel = [CCLabelTTF labelWithString:@"31/100" fontName:[Globals font] fontSize:12];
    [self.healthBgd addChild:self.healthLabel];
    self.healthLabel.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height);
    self.healthLabel.color = [CCColor whiteColor];
    self.healthLabel.shadowOffset = ccp(0, -1);
    self.healthLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  }
  return self;
}

#define FADE_DURATION 0.2f
#define DELAY_DURATION 5.f

- (void) initiateSpeechBubbleWithText:(NSString *)text {
  [self initiateSpeechBubbleWithText:text completion:nil];
}

- (void) initiateSpeechBubbleWithText:(NSString *)text completion:(void (^)(void))completion {
  if (!completion) {
    completion = ^{};
  }
  
  if (!text) {
    completion();
    return;
  }
  
  BattleSpeechBubble *speech = [BattleSpeechBubble speechBubbleWithText:text];
  
  // Add it to the parent's parent
  [self.parent.parent addChild:speech z:7];
  CGPoint pt = ccp(self.contentSize.width/2, self.contentSize.height-3);
  pt = [speech.parent convertToNodeSpace:[self convertToWorldSpace:pt]];
  speech.position = pt;
  
  speech.scale = 0.f;
  [speech recursivelyApplyOpacity:0.f];
  [speech runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:FADE_DURATION*1.5f],
    [CCActionSpawn actions:
     [CCActionScaleTo actionWithDuration:FADE_DURATION scale:1.f],
     [RecursiveFadeTo actionWithDuration:FADE_DURATION opacity:1.f], nil],
    [CCActionCallFunc actionWithTarget:speech selector:@selector(beginLabelAnimation)],
    [CCActionDelay actionWithDuration:DELAY_DURATION],
    [CCActionSpawn actions:
     [CCActionScaleTo actionWithDuration:FADE_DURATION scale:0.f],
     [RecursiveFadeTo actionWithDuration:FADE_DURATION opacity:0.f], nil],
    [CCActionCallBlock actionWithBlock:completion],
    [CCActionCallFunc actionWithTarget:speech selector:@selector(removeFromParent)],
    nil]];
  
  [self.healthBgd runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:FADE_DURATION opacity:0.f],
    [CCActionDelay actionWithDuration:DELAY_DURATION+3*FADE_DURATION],
    [RecursiveFadeTo actionWithDuration:FADE_DURATION opacity:1.f],
    nil]];
}

- (void) setIsFacingNear:(BOOL)isFacingNear {
  _isFacingNear = isFacingNear;
  [self restoreStandingFrame];
}

- (void) faceNearWithoutUpdate {
  _isFacingNear = YES;
}

- (void) faceFarWithoutUpdate {
  _isFacingNear = NO;
}

- (void) setSpriteFrame:(CCSpriteFrame *)spriteFrame {
  // We do this so that CCActionAnimate can be used on self as a part of a sequence
  self.sprite.spriteFrame = spriteFrame;
}

- (CCAction *) walkActionN {
  if (!_walkActionN) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunN", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionN = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
  }
  return _walkActionN;
}

- (CCAction *) walkActionF {
  if (!_walkActionF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunF", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionF = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
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

- (CCAnimation *) flinchAnimationF {
  if (!_flinchAnimationF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@FlinchF", self.prefix];
    self.flinchAnimationF = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
  }
  return _flinchAnimationF;
}

- (void) restoreStandingFrame {
  [self attackAnimationN];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Attack%@00.png", self.prefix, self.isFacingNear ? @"N" : @"F"]];
  if (!frame) frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Attack%@00.tga", self.prefix, self.isFacingNear ? @"N" : @"F"]];
  [self.sprite setSpriteFrame:frame];
  
  self.sprite.flipX = !self.isFacingNear;
}

- (void) beginWalking {
  if (!self.isWalking) {
    self.sprite.flipX = !self.isFacingNear;
    [self.sprite runAction:self.isFacingNear ? self.walkActionN : self.walkActionF];
    self.isWalking = YES;
    
    CCActionSequence *seq = [CCActionSequence actions:
                             [CCActionCallBlock actionWithBlock:
                              ^{
//                                [[SoundEngine sharedSoundEngine] puzzleWalking];
                              }],
                             [CCActionDelay actionWithDuration:0.9], nil];
    CCActionRepeatForever *r = [CCActionRepeatForever actionWithAction:seq];
    r.tag = 7654;
    [self runAction:r];
  }
}

- (void) stopWalking {
  self.isWalking = NO;
  if (self.walkActionF) [self.sprite stopAction:self.walkActionF];
  if (self.walkActionN) [self.sprite stopAction:self.walkActionN];
  [self restoreStandingFrame];
  
  [self stopActionByTag:7654];
//  [[SoundEngine sharedSoundEngine] puzzleStopWalking];
}

- (void) performNearAttackAnimationWithEnemy:(BattleSprite *)enemy target:(id)target selector:(SEL)selector {
  CCAnimation *anim = self.attackAnimationN.copy;
  
  CCActionSequence *seq;
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ [enemy performFarFlinchAnimationWithDelay:0.5];}],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
           [CCActionCallFunc actionWithTarget:target selector:selector],
           nil];
  } else if (self.animationType == MonsterProto_AnimationTypeMelee) {
    [anim addSoundEffect:@"sfx_muckerburg_hit_luchador.mp3" atIndex:2];
    
    CGPoint enemyPos = enemy.position;
    CGPoint pointOffset = POINT_OFFSET_PER_SCENE;
    float distToTravel = ccpDistance(self.position, enemyPos)-50.f;
    float moveTime = distToTravel/MELEE_RUN_SPEED;
    float moveAmount = -distToTravel/ccpLength(pointOffset);
    
    seq = [CCActionSequence actions:
           [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
           [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ [enemy performFarFlinchAnimationWithDelay:0.3]; }],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallFunc actionWithTarget:target selector:selector],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceFarWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
           [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, -moveAmount)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceNearWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
           nil];
  }
  [self runAction:seq];
}

- (void) performFarAttackAnimationWithStrength:(float)strength enemy:(BattleSprite *)enemy target:(id)target selector:(SEL)selector {
  CCAnimation *anim = self.attackAnimationF.copy;
  
  // Repeat 4-8 x times
  int numTimes = strength*(MAX_SHOTS-1);
  
  CCActionSequence *seq;
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    [anim repeatFrames:NSMakeRange(4, 6) numTimes:numTimes];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ [enemy performNearFlinchAnimationWithStrength:strength delay:0.5];}],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
           [CCActionCallFunc actionWithTarget:target selector:selector],
           nil];
  } else if (self.animationType == MonsterProto_AnimationTypeMelee) {
    [anim addSoundEffect:@"sfx_muckerburg_hit_luchador.mp3" atIndex:2];
    [anim repeatFrames:NSMakeRange(2, 5) numTimes:numTimes];
    
    CGPoint enemyPos = enemy.position;
    CGPoint pointOffset = POINT_OFFSET_PER_SCENE;
    // Subtract the range from the distance
    float distToTravel = ccpDistance(self.position, enemyPos)-50.f;
    float moveTime = distToTravel/MELEE_RUN_SPEED;
    float moveAmount = distToTravel/ccpLength(pointOffset);
    
    seq = [CCActionSequence actions:
           [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
           [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ [enemy performNearFlinchAnimationWithStrength:strength delay:0.3];}],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallFunc actionWithTarget:target selector:selector],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceNearWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
           [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, -moveAmount)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceFarWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
           nil];
  }
  [self runAction:seq];
}

- (void) displayChargingFrame {
  [self attackAnimationN];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Charge.png", self.prefix]];
  if (!frame) frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@Charge.tga", self.prefix]];
  [self.sprite setSpriteFrame:frame];
  self.sprite.flipX = NO;
}

- (void) performNearFlinchAnimationWithStrength:(float)strength delay:(float)delay {
  CGPoint pointOffset = POINT_OFFSET_PER_SCENE;
  CGPoint startPos = self.position;
  [self.sprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionAnimate actionWithAnimation:self.flinchAnimationN],
    nil]];
  
  float moveTime = 0.15f;
  float moveAmount = 0.006;
  float delayTime = 0.2f;
  int numTimes = strength*(MAX_SHOTS-1)+1;
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionRepeat actionWithAction:
     [CCActionSequence actions:
      [CCActionCallBlock actionWithBlock:
       ^{
         int totalParticles = 40+strength*40;
         
         NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"flinchstars.plist"];
         NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
         [dict setObject:[NSNumber numberWithInt:totalParticles] forKey:@"maxParticles"];
         
         CCParticleSystem *q = [[CCParticleSystem alloc] initWithDictionary:dict];
         q.autoRemoveOnFinish = YES;
         q.position = ccpAdd(self.position, ccp(0, self.contentSize.height/2-5));
         q.speedVar = 40+strength*15;
         q.endSizeVar = 5+strength*10;
         [self.parent addChild:q];
       }],
      [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
      [CCActionDelay actionWithDuration:delayTime], nil] times:numTimes],
    [CCActionMoveTo actionWithDuration:0.1f position:startPos],
    [CCActionCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
    nil]];
}

- (void) performFarFlinchAnimationWithDelay:(float)delay {
  CGPoint pointOffset = POINT_OFFSET_PER_SCENE;
  CGPoint startPos = self.position;
  [self.sprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionAnimate actionWithAnimation:self.flinchAnimationF],
    nil]];
  
  float moveTime = 0.15f;
  float moveAmount = -0.006;
  float delayTime = 0.2f;
  float strength = 1/(MAX_SHOTS-1)-0.01;
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:
     ^{
       int totalParticles = 40+strength*40;
       
       NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"flinchstars.plist"];
       NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
       [dict setObject:[NSNumber numberWithInt:totalParticles] forKey:@"maxParticles"];
       
       CCParticleSystem *q = [[CCParticleSystem alloc] initWithDictionary:dict];
       q.autoRemoveOnFinish = YES;
       q.position = ccpAdd(self.position, ccp(0, self.contentSize.height/2-5));
       q.speedVar = 40+strength*15;
       q.endSizeVar = 5+strength*10;
       [self.parent addChild:q];
     }],
    [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
    [CCActionDelay actionWithDuration:delayTime],
    [CCActionMoveTo actionWithDuration:0.1f position:startPos],
    [CCActionCallFunc actionWithTarget:self selector:@selector(restoreStandingFrame)],
    nil]];
}

@end
