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
#import "GameState.h"
#import "SkillSideEffect.h"

#define ANIMATION_DELAY 0.07f
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
    [self addChild:self.healthBgd z:100];
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
      [self addChild:self.rarityTag];
      self.rarityTag.opacity = 0.f;
    }
    
    self.nameLabel = [CCLabelTTF labelWithString:@"" fontName:@"GothamNarrow-Ultra" fontSize:12];
    self.nameLabel.attributedString = name;
    [self addChild:self.nameLabel];
    self.nameLabel.position = ccp(self.healthBgd.position.x, self.healthBgd.position.y-self.healthBgd.contentSize.height/2+28);
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
    
    _skillSideEffects = [NSMutableArray array];
    
    self.userInteractionEnabled = YES;
  }
  return self;
}

- (void) addSkillSideEffect:(SideEffectType)type forSkill:(NSInteger)skillId turnsAffected:(NSInteger)numTurns
   turnsAreSideEffectOwners:(BOOL)turnsAreSideEffectOwners toPlayer:(BOOL)player
{
  // Allow only unique side effect types
  for (SkillSideEffect* sideEffect in _skillSideEffects)
    if (sideEffect.type == type)
      return;
  
  // Create side effect and push it onto the stack
  SkillSideEffectProto* proto = [Globals protoForSkillSideEffectType:type];
  if (proto)
  {
    SkillSideEffect* sideEffect = [SkillSideEffect sideEffectWithProto:proto invokingSkill:skillId];
    if (sideEffect)
    {
      [sideEffect addToCharacterSprite:self zOrder:_skillSideEffects.count turnsAffected:numTurns
              turnsAreSideEffectOwners:turnsAreSideEffectOwners castOnPlayer:player];
      [_skillSideEffects addObject:sideEffect];
      
      [self updateSkillSideEffectsDisplayOrder];
    }
  }
}

- (void) resetAfftectedTurnsCount:(NSInteger)numTurns forSkillSideEffect:(SideEffectType)type
{
  for (SkillSideEffect* sideEffect in _skillSideEffects)
    if (sideEffect.type == type)
      [sideEffect resetAfftectedTurnsCount:numTurns];
}

- (void) removeSkillSideEffect:(SideEffectType)type
{
  NSMutableArray* discard = [NSMutableArray array];
  for (SkillSideEffect* sideEffect in _skillSideEffects)
    if (sideEffect.type == type)
    {
      [sideEffect removeFromCharacterSprite];
      [discard addObject:sideEffect];
    }
  
  [_skillSideEffects removeObjectsInArray:discard];
  
  if (discard.count > 0)
    [self updateSkillSideEffectsDisplayOrder];
}

- (void) removeAllSkillSideEffects
{
  for (SkillSideEffect* sideEffect in _skillSideEffects)
    [sideEffect removeFromCharacterSprite];
  [_skillSideEffects removeAllObjects];
}

- (void) updateSkillSideEffectsDisplayOrder
{
  NSMutableArray* groupA = [NSMutableArray array];
  NSMutableArray* groupB = [NSMutableArray array];
  
  for (SkillSideEffect* sideEffect in _skillSideEffects)
    [(sideEffect.positionType == SideEffectPositionTypeBelowCharacter ? groupA : groupB) addObject:sideEffect];
  
  for (int i = 0; i < groupA.count; ++i)
    [(SkillSideEffect*)[groupA objectAtIndex:i] setDisplayOrder:(groupA.count == 1) ? -1 : i totalCount:(int)groupA.count];
  for (int i = 0; i < groupB.count; ++i)
    [(SkillSideEffect*)[groupB objectAtIndex:i] setDisplayOrder:(groupB.count == 1) ? -1 : i totalCount:(int)groupB.count];
}

- (void) onExit
{
//  [self removeAllSkillSideEffects];
  
  [super onExit];
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
    
    self.rarityTag.position = ccp(self.healthBgd.position.x, self.healthBgd.position.y-self.healthBgd.contentSize.height/2+28);
  }
}

- (void) showRarityTagAndNameLabel {
  if (self.rarityTag.opacity == 0.f) {
    [self.nameLabel stopAllActions];
    [self.rarityTag stopAllActions];
    
    CCActionSequence *seq = [CCActionSequence actions:
                             [CCActionCallBlock actionWithBlock:^{ if (self.battleLayer) [self.battleLayer mobsterInfoDisplayed:YES onSprite:self]; }],
                             [CCActionFadeTo actionWithDuration:0.3 opacity:1.f],
                             [CCActionDelay actionWithDuration:2.5f],
                             [CCActionCallBlock actionWithBlock:^{ if (self.battleLayer) [self.battleLayer mobsterInfoDisplayed:NO onSprite:self]; }],
                             [CCActionFadeTo actionWithDuration:0.3 opacity:0.f],
                             nil];
    [self.nameLabel runAction:seq.copy];
    [self.rarityTag runAction:seq.copy];
    
    self.rarityTag.position = ccp(self.healthBgd.position.x, self.healthBgd.position.y-self.healthBgd.contentSize.height/2+43);
    
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
  [self.parent.parent addChild:speech z:self.parent.zOrder];
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

- (void) checkRunSpriteSheetWithCompletion:(void (^)(BOOL success))completion {
  if (!_attemptedLoadingRunSpritesheet) {
    NSString *spritesheetName = [NSString stringWithFormat:@"%@RunNF.plist", self.prefix];
    [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
      _attemptedLoadingRunSpritesheet = YES;
      _loadedRunSpritesheet = success;
      
      if (success) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
      }
      
      if (completion) {
        completion(success);
      }
    }];
  } else if (completion) {
    completion(_loadedRunSpritesheet);
  }
}

- (void) checkAttackSpriteSheetWithCompletion:(void (^)(BOOL success))completion {
  if (!_attemptedLoadingAtkSpritesheet) {
    NSString *spritesheetName = [NSString stringWithFormat:@"%@AttackNF.plist", self.prefix];
    [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
      _attemptedLoadingAtkSpritesheet = YES;
      _loadedAtkSpritesheet = success;
      
      if (success) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
      }
      
      if (completion) {
        completion(success);
      }
    }];
  } else if (completion) {
    completion(_loadedAtkSpritesheet);
  }
}

- (CCAction *) walkActionN {
  if (!_walkActionN) {
    [self checkRunSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_walkActionN) {
        NSString *p = [NSString stringWithFormat:@"%@RunN", self.prefix];
        CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
        self.walkActionN = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
        
        if (!self.isWalking) {
          [self beginWalking];
        }
      }
    }];
  }
  return _walkActionN;
}

- (CCAction *) walkActionF {
  if (!_walkActionF) {
    [self checkRunSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_walkActionF) {
        NSString *p = [NSString stringWithFormat:@"%@RunF", self.prefix];
        CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
        self.walkActionF = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
        
        if (!self.isWalking) {
          [self beginWalking];
        }
      }
    }];
  }
  return _walkActionF;
}

- (CCAnimation *) attackAnimationN {
  if (!_attackAnimationN) {
    [self checkAttackSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_attackAnimationN) {
        NSString *p = [NSString stringWithFormat:@"%@AttackN", self.prefix];
        self.attackAnimationN = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
      }
    }];
  }
  return _attackAnimationN;
}

- (CCAnimation *) attackAnimationF {
  if (!_attackAnimationF) {
    [self checkAttackSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_attackAnimationF) {
        NSString *p = [NSString stringWithFormat:@"%@AttackF", self.prefix];
        self.attackAnimationF = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
      }
    }];
  }
  return _attackAnimationF;
}

- (CCAnimation *) flinchAnimationN {
  if (!_flinchAnimationN) {
    [self checkAttackSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_flinchAnimationN) {
        NSString *p = [NSString stringWithFormat:@"%@FlinchN", self.prefix];
        self.flinchAnimationN = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
      }
    }];
  }
  return _flinchAnimationN;
}

- (CCAnimation *) flinchAnimationF {
  if (!_flinchAnimationF) {
    [self checkAttackSpriteSheetWithCompletion:^(BOOL success) {
      if (success && !_flinchAnimationF) {
        NSString *p = [NSString stringWithFormat:@"%@FlinchF", self.prefix];
        self.flinchAnimationF = [CCAnimation animationWithSpritePrefix:p delay:ANIMATION_DELAY];
      }
    }];
  }
  return _flinchAnimationF;
}

- (void) restoreStandingFrame {
  [self restoreStandingFrame:self.isFacingNear ? MapDirectionNearLeft : MapDirectionFarRight];
}

- (void) restoreStandingFrame:(MapDirection)direction {
  self.sprite.spriteFrame = nil;
  
  [self checkAttackSpriteSheetWithCompletion:^(BOOL success) {
    if (success && !self.isWalking) {
      NSString *name;
      if (direction == MapDirectionFront) name = [NSString stringWithFormat:@"%@StayN00.png", self.prefix];
      else if (direction == MapDirectionKneel) name = [NSString stringWithFormat:@"%@KneelF01.png", self.prefix];
      else name = [NSString stringWithFormat:@"%@Attack%@00.png", self.prefix, (direction == MapDirectionFarRight || direction == MapDirectionFarLeft) ? @"F" : @"N"];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
      [self.sprite setSpriteFrame:frame];
    }
  }];
  
  self.sprite.flipX = (direction == MapDirectionFarRight || direction == MapDirectionNearRight || direction == MapDirectionKneel);
}

- (void) beginWalking {
  if (!self.isWalking) {
    self.isWalking = YES;
    
    self.sprite.flipX = !self.isFacingNear;
    CCAction *action = self.isFacingNear ? self.walkActionN : self.walkActionF;
    
    if (action) {
      [self.sprite runAction:action];
    } else {
      self.isWalking = NO;
    }
  }
}

- (void) stopWalking {
  self.isWalking = NO;
  if (_walkActionF) [self.sprite stopAction:self.walkActionF];
  if (_walkActionN) [self.sprite stopAction:self.walkActionN];
  [self restoreStandingFrame];
}

- (void) performNearAttackAnimationWithEnemy:(BattleSprite *)enemy shouldReturn:(BOOL)shouldReturn shouldEvade:(BOOL)evade shouldMiss:(BOOL)miss shouldFlinch:(BOOL)flinch
                                      target:(id)target selector:(SEL)selector animCompletion:(void(^)(void))completion {
  CCAnimation *anim = self.attackAnimationN.copy;
  anim = anim ?: [CCAnimation animation];
  
  CCActionSequence *seq;
  [self stopActionByTag:924];
  
  if (!completion) {
    completion = ^{};
  }
  
  [self stopWalking];
  [self setIsFacingNear:YES];
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{
             if (evade) [enemy jumpLeftAndBack:NO delay:.4f duration:1.f distance:25.f height:25.f];
             else if (miss) self.sprite.flipX = !self.sprite.flipX;
             else if (flinch) [enemy performFarFlinchAnimationWithDelay:0.5];
           }],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallBlock actionWithBlock:^{
            if (miss) self.sprite.flipX = !self.sprite.flipX;
           }],
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
              [CCActionCallBlock actionWithBlock:^{
               if (evade) [enemy jumpLeftAndBack:NO delay:.4f duration:1.f distance:25.f height:25.f];
               else if (miss) self.sprite.flipX = !self.sprite.flipX;
               else if (flinch) [enemy performFarFlinchAnimationWithDelay:0.3];
             }],
              [CCSoundAnimate actionWithAnimation:anim],
              nil],
             [CCActionCallBlock actionWithBlock:^{
              if (miss) self.sprite.flipX = !self.sprite.flipX;
             }],
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
  [self runAction:[CCActionSequence actions:seq, [CCActionCallBlock actionWithBlock:completion], nil]];
}

- (void) performFarAttackAnimationWithStrength:(float)strength shouldEvade:(BOOL)evade shouldMiss:(BOOL)miss enemy:(BattleSprite *)enemy
                                        target:(id)target selector:(SEL)selector animCompletion:(void(^)(void))completion {
  CCAnimation *anim = self.attackAnimationF.copy;
  anim = anim ?: [CCAnimation animation];
  
  // Repeat 4-8 x times. Don't add 1 because we automatically use 1
  int numTimes = strength*(MAX_SHOTS-1);
  
  CCActionSequence *seq;
  [self stopActionByTag:924];
  
  if (!completion) {
    completion = ^{};
  }
  
  [self stopWalking];
  [self setIsFacingNear:NO];
  if (self.animationType == MonsterProto_AnimationTypeRanged) {
    [anim addSoundEffect:@"sfx_handgun.wav" atIndex:4];
    [anim repeatFrames:NSMakeRange(4, 6) numTimes:numTimes];
    
    seq = [CCActionSequence actions:
           [CCActionSpawn actions:
            [CCActionCallBlock actionWithBlock:^{
             if (evade) [enemy jumpLeftAndBack:NO delay:.4f duration:1.f distance:25.f height:25.f];
             else if (miss) self.sprite.flipX = !self.sprite.flipX;
             else if(strength >= 0) [enemy performNearFlinchAnimationWithStrength:strength delay:0.5];
           }],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallBlock actionWithBlock:^{
            if (miss) self.sprite.flipX = !self.sprite.flipX;
           }],
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
            [CCActionCallBlock actionWithBlock:^{
             if (evade) [enemy jumpLeftAndBack:NO delay:.4f duration:1.f distance:25.f height:25.f];
             else if (miss) self.sprite.flipX = !self.sprite.flipX;
             else if (strength >= 0) [enemy performNearFlinchAnimationWithStrength:strength delay:0.3];
           }],
            [CCSoundAnimate actionWithAnimation:anim],
            nil],
           [CCActionCallBlock actionWithBlock:^{
            if (miss) self.sprite.flipX = !self.sprite.flipX;
           }],
           [CCActionCallFunc actionWithTarget:target selector:selector],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceNearWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(beginWalking)],
           [CCActionMoveBy actionWithDuration:moveTime position:ccpMult(pointOffset, -moveAmount)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(faceFarWithoutUpdate)],
           [CCActionCallFunc actionWithTarget:self selector:@selector(stopWalking)],
           nil];
  }
  seq.tag = 924;
  [self runAction:[CCActionSequence actions:seq, [CCActionCallBlock actionWithBlock:completion], nil]];
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
  if (self.flinchAnimationN) {
    [self.sprite runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:delay],
      [CCActionAnimate actionWithAnimation:self.flinchAnimationN],
      nil]];
  }
  
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
  if (self.flinchAnimationF) {
    [self.sprite runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:delay],
      [CCActionAnimate actionWithAnimation:self.flinchAnimationF],
      nil]];
  }
  
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
  if (self.sprite) {
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
  } else {
    SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
                                           [target performSelector:completion];
                                           );
  }
}

- (void) jumpLeftAndBack:(BOOL)left delay:(float)delay duration:(float)duration distance:(float)distance height:(float)height
{
  if (left) distance = -distance;
  CGPoint movement = ccp(distance, -distance * SLOPE_OF_ROAD);
  CGPoint movementBack = ccp(-distance, distance * SLOPE_OF_ROAD);
  
  CCActionFiniteTime* delayAction = [CCActionDelay actionWithDuration:delay];
  CCActionFiniteTime* pauseAction = [CCActionDelay actionWithDuration:duration * .6f];
  
  CCActionFiniteTime* jumpAndMoveAction = [CCActionJumpBy actionWithDuration:duration * .2f position:movement height:height jumps:1];
  CCActionFiniteTime* jumpAndMoveBackAction = [CCActionJumpBy actionWithDuration:duration * .2f position:movementBack height:height jumps:1];
  [self.sprite runAction:[CCActionSequence actions:
                          [delayAction copy],
                          [jumpAndMoveAction copy],
                          [pauseAction copy],
                          [jumpAndMoveBackAction copy],
                          nil]];
  
  CCActionFiniteTime* jumpSoundAction = [CCActionCallBlock actionWithBlock:^{ [SoundEngine spriteJump]; }];
  CCActionFiniteTime* shadowScaleAction = [CCActionSequence actions:
                                           [CCActionScaleTo actionWithDuration:duration * .1f scale:.7f],
                                           [CCActionScaleTo actionWithDuration:duration * .1f scale:1.f],
                                           nil];
  CCActionFiniteTime* shadowScaleAndMoveAction = [CCActionSpawn actions:[CCActionMoveBy actionWithDuration:duration * .2f position:movement], [shadowScaleAction copy], nil];
  CCActionFiniteTime* shadowScaleAndMoveBackAction = [CCActionSpawn actions:[CCActionMoveBy actionWithDuration:duration * .2f position:movementBack], [shadowScaleAction copy], nil];
  
  // Animate and move character shadow with the sprite
  CCSprite* shadow = (CCSprite*)[self getChildByName:SHADOW_TAG recursively:NO];
  [shadow runAction:[CCActionSequence actions:
                     [delayAction copy],
                     [jumpSoundAction copy],
                     [shadowScaleAndMoveAction copy],
                     [pauseAction copy],
                     [jumpSoundAction copy],
                     [shadowScaleAndMoveBackAction copy],
                     nil]];
  
  // Animate and move any side effect visuals or particle effects with the sprite
  for (SkillSideEffect* sideEffect in _skillSideEffects)
  {
    if (sideEffect.vfx)
      [sideEffect.vfx runAction:[CCActionSequence actions:[delayAction copy], [shadowScaleAndMoveAction copy], [pauseAction copy], [shadowScaleAndMoveBackAction copy], nil]];
    if (sideEffect.pfx)
      [sideEffect.pfx runAction:[CCActionSequence actions:[delayAction copy], [shadowScaleAndMoveAction copy], [pauseAction copy], [shadowScaleAndMoveBackAction copy], nil]];
  }
}

- (void) setScale:(float)scale
{
  [super setScale:scale];
  [self.healthBgd setScale:1.0/scale];
  [self.nameLabel setScale:1.0/scale];
  if (self.movesCounter)
    [self.movesCounter setScale:1.0/scale];
}

@end
