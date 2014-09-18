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

#define BATTLE_SPRITE_INFO_DISPLAYED_NOTIFICATION @"BSInfoDisplayed"

@implementation BattleSprite

- (id) initWithPrefix:(NSString *)prefix nameString:(NSAttributedString *)name rarity:(Quality)rarity animationType:(MonsterProto_AnimationType)animationType isMySprite:(BOOL)isMySprite verticalOffset:(float)verticalOffset {
  if ((self = [super init])) {
    self.prefix = prefix;
    self.contentSize = CGSizeMake(40, 55);
    self.animationType = animationType;
    
    self.sprite = [CCSprite node];
    [self addChild:_sprite z:5];
    self.sprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2-3+verticalOffset);
    
    CCSprite *s = [CCSprite spriteWithImageNamed:@"shadow.png"];
    [self addChild:s z:0 name:SHADOW_TAG];
    s.position = ccp(self.contentSize.width/2, 0);
    
    self.anchorPoint = ccp(0.5, 0);
    
    self.isFacingNear = YES;
    
    self.healthBgd = [CCSprite spriteWithImageNamed:@"minitimebg.png"];
    [self addChild:self.healthBgd z:6];
    self.healthBgd.position = ccp(self.contentSize.width/2, self.contentSize.height);
    
    self.healthBar = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:@"minihpbar.png"]];
    [self.healthBgd addChild:self.healthBar];
    self.healthBar.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height/2);
    self.healthBar.type = CCProgressNodeTypeBar;
    self.healthBar.midpoint = ccp(0, 0.5);
    self.healthBar.barChangeRate = ccp(1,0);
    self.healthBar.percentage = 90;
    
    self.healthLabel = [CCLabelTTF labelWithString:@"31/100" fontName:@"GothamNarrow-Ultra" fontSize:11];
    [self.healthBgd addChild:self.healthLabel];
    self.healthLabel.position = ccp(self.healthBgd.contentSize.width/2, self.healthBgd.contentSize.height);
    self.healthLabel.color = [CCColor whiteColor];
    self.healthLabel.shadowOffset = ccp(0, -1);
    self.healthLabel.shadowBlurRadius = 1.5f;
    self.healthLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
    
    if (rarity != QualityCommon) {
      NSString *rarityStr = [@"battle" stringByAppendingString:[Globals imageNameForRarity:rarity suffix:@"tag.png"]];
      self.rarityTag = [CCSprite spriteWithImageNamed:rarityStr];
      [self.healthBgd addChild:self.rarityTag];
      self.rarityTag.opacity = 0.f;
    }
  
    self.nameLabel = [CCLabelTTF labelWithString:@"" fontName:@"GothamNarrow-Ultra" fontSize:12];
    self.nameLabel.attributedString = name;
    [self.healthBgd addChild:self.nameLabel];
    self.nameLabel.position = ccp(self.healthBgd.contentSize.width/2, 28);
    self.nameLabel.color = [CCColor whiteColor];
    self.nameLabel.shadowOffset = ccp(0, -1);
    self.nameLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
    self.nameLabel.shadowBlurRadius = 1.5f;
    self.nameLabel.opacity = 0.f;
    
    // Preload flinch stars
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"flinchstars.plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"maxParticles"];
    CCParticleSystem *q = [[CCParticleSystem alloc] initWithDictionary:dict];
    q.angle = 0;
    
    self.userInteractionEnabled = YES;
  }
  return self;
}

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceCloseRarityTagAndNameLabel:) name:BATTLE_SPRITE_INFO_DISPLAYED_NOTIFICATION object:nil];
}

- (void) onExitTransitionDidStart {
  [super onExitTransitionDidStart];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setParent:(CCNode *)parent {
  [super setParent:parent];
  
  float newScale = 1/parent.scale;
  self.healthBgd.scale = newScale;
}

- (void) recursivelyApplyOpacity:(CGFloat)opacity {
  float nameOp = self.nameLabel.opacity;
  float rarOp = self.rarityTag.opacity;
  [super recursivelyApplyOpacity:opacity];
  self.nameLabel.opacity = MIN(nameOp, self.nameLabel.opacity);
  self.rarityTag.opacity = MIN(rarOp, self.rarityTag.opacity);
}

- (void) showRarityTag {
  if (self.rarityTag.opacity == 0.f) {
    self.rarityTag.opacity = 1.f;
    [self.rarityTag runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:5.f],
      [CCActionFadeTo actionWithDuration:0.3 opacity:0.f],
      nil]];
    
    self.rarityTag.position = ccp(self.healthBgd.contentSize.width/2, 28);
  }
}

- (void) showRarityTagAndNameLabel {
  if (self.rarityTag.opacity == 0.f) {
    [self.nameLabel stopAllActions];
    [self.rarityTag stopAllActions];
    
    CCActionSequence *seq = [CCActionSequence actions:
                             [CCActionFadeTo actionWithDuration:0.3 opacity:1.f],
                             [CCActionDelay actionWithDuration:2.5f],
                             [CCActionFadeTo actionWithDuration:0.3 opacity:0.f],
                             nil];
    [self.nameLabel runAction:seq.copy];
    [self.rarityTag runAction:seq.copy];
    
    self.rarityTag.position = ccp(self.healthBgd.contentSize.width/2, 43);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_SPRITE_INFO_DISPLAYED_NOTIFICATION object:self];
  }
}

- (void) forceCloseRarityTagAndNameLabel:(NSNotification *)notification {
  BattleSprite *bs = notification.object;
  if (bs != self && bs.isFacingNear == self.isFacingNear && ![self.rarityTag getActionByTag:1423]) {
    [self.nameLabel stopAllActions];
    [self.rarityTag stopAllActions];
    
    CCAction *act = [CCActionFadeTo actionWithDuration:0.3 opacity:0.f];
    [self.nameLabel runAction:act.copy];
    [self.rarityTag runAction:act.copy];
    act.tag = 1423;
  }
}

- (void) doRarityTagShine {
  if (self.rarityTag) {
//    CCSprite *stencil = [CCSprite spriteWithSpriteFrame:self.rarityTag.spriteFrame];
    
//    CGSize size = self.rarityTag.contentSize;
//    CCDrawNode *stencil = [CCDrawNode node];
//    CGPoint rectangle[] = {{0, 0}, {size.width, 0}, {size.width, size.height}, {0, size.height}};
//    [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
//    
//    CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
//    clip.contentSize = size;
//    stencil.position = ccp(size.width/2, size.height/2);
//    
//    CCSprite *lines = [CCSprite spriteWithImageNamed:@"tagshine.png"];
//    [clip addChild:lines];
//    lines.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
//    lines.position = ccp(-lines.contentSize.width/2, clip.contentSize.height/2);
//    lines.opacity = 0.5f;
//    
//    [lines runAction:
//     [CCActionSequence actions:
//      [CCActionDelay actionWithDuration:0.3],
//      [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.45f position:ccp(clip.contentSize.width+lines.contentSize.width/2, clip.contentSize.height/2)]
//                                  rate:5.f],
//      [CCActionCallBlock actionWithBlock:^{ [clip removeFromParent]; }], nil]];
//    
//    [self.rarityTag addChild:clip];
  }
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  [self showRarityTagAndNameLabel];
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
  [self restoreStandingFrame:self.isFacingNear?MapDirectionNearLeft:MapDirectionFarRight];
}

- (void) restoreStandingFrame:(MapDirection)direction {
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
  NSString *name;
  if (direction == MapDirectionFront) name = [NSString stringWithFormat:@"%@StayN00.png", self.prefix];
  else if (direction == MapDirectionKneel) name = [NSString stringWithFormat:@"%@KneelF00.png", self.prefix];
  else name = [NSString stringWithFormat:@"%@Attack%@00.png", self.prefix, (direction == MapDirectionFarRight || direction == MapDirectionFarLeft) ? @"F" : @"N"];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
  [self.sprite setSpriteFrame:frame];
  
  self.sprite.flipX = (direction == MapDirectionFarRight || direction == MapDirectionNearRight || direction == MapDirectionKneel);
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

- (void) performNearAttackAnimationWithEnemy:(BattleSprite *)enemy shouldReturn:(BOOL)shouldReturn shouldFlinch:(BOOL)flinch target:(id)target selector:(SEL)selector {
  CCAnimation *anim = self.attackAnimationN.copy;
  
  CCActionSequence *seq;
  [self stopActionByTag:924];
  
  [self stopWalking];
  [self setIsFacingNear:YES];
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ if (flinch) [enemy performFarFlinchAnimationWithDelay:0.5];}],
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
    
    CCActionSequence* seqAttack = [CCActionSequence actions:
                                  [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
                                  [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
                                  nil];
    if (shouldReturn)
      seq = [CCActionSequence actions:seqAttack,
             [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
             [CCActionSpawn actions:
              [CCActionCallBlock actionWithBlock:^{ if (flinch) [enemy performFarFlinchAnimationWithDelay:0.3]; }],
              [CCSoundAnimate actionWithAnimation:anim],
              nil],
             [CCActionCallFunc actionWithTarget:target selector:selector],
             [CCActionCallFunc actionWithTarget:self selector:@selector(faceFarWithoutUpdate)],
             [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
             [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, -moveAmount)],
             [CCActionCallFunc actionWithTarget:self selector:@selector(faceNearWithoutUpdate)],
             [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
             nil];
    else
      seq = [CCActionSequence actions:seqAttack,
             [CCActionCallFunc actionWithTarget:target selector:selector],
             nil];
  }
  seq.tag = 924;
  [self runAction:seq];
}

- (void) performFarAttackAnimationWithStrength:(float)strength enemy:(BattleSprite *)enemy target:(id)target selector:(SEL)selector {
  CCAnimation *anim = self.attackAnimationF.copy;
  
  // Repeat 4-8 x times
  int numTimes = strength*(MAX_SHOTS-1);
  
  CCActionSequence *seq;
  [self stopActionByTag:924];
  [self stopWalking];
  [self setIsFacingNear:NO];
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    [anim repeatFrames:NSMakeRange(4, 6) numTimes:numTimes];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{ if(strength>0) [enemy performNearFlinchAnimationWithStrength:strength delay:0.5];}],
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
            [CCActionCallBlock actionWithBlock:^{ if (strength>0) [enemy performNearFlinchAnimationWithStrength:strength delay:0.3];}],
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
  seq.tag = 924;
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
  
  // For tutorial.. actually check which direction he's facing
  pointOffset = self.sprite.flipX ? pointOffset : ccp(-pointOffset.x, pointOffset.y);
  MapDirection dir = self.sprite.flipX ? MapDirectionFarRight : MapDirectionFarLeft;
  
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
       [self.parent addChild:q z:self.zOrder+1];
     }],
    [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, moveAmount)],
    [CCActionDelay actionWithDuration:delayTime],
    [CCActionMoveTo actionWithDuration:0.1f position:startPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self restoreStandingFrame:dir];
     }],
    nil]];
}



- (void) jumpNumTimes:(int)numTimes completionTarget:(id)target selector:(SEL)completion {
  [self jumpNumTimes:numTimes timePerJump:0.25 height:14 completionTarget:target selector:completion];
}

- (void) jumpNumTimes:(int)numTimes timePerJump:(float)dur height:(float)height completionTarget:(id)target selector:(SEL)completion {
  CCActionJumpBy *jump = [CCActionJumpBy actionWithDuration:dur*numTimes position:ccp(0,0) height:height jumps:numTimes];
  [self.sprite runAction:[CCActionSequence actions:jump,
                          [CCActionCallFunc actionWithTarget:target selector:completion], nil]];
  
  CCSprite *spr = (CCSprite *)[self getChildByName:SHADOW_TAG recursively:NO];
  [spr runAction:
   [CCActionRepeat actionWithAction:
    [CCActionSequence actions:
     [CCActionCallBlock actionWithBlock:
      ^{
        [SoundEngine spriteJump];
      }],
     [CCActionScaleTo actionWithDuration:dur/2.f scale:0.9],
     [CCActionScaleTo actionWithDuration:dur/2.f scale:1.f],
     nil]
                              times:numTimes]];
}

@end
