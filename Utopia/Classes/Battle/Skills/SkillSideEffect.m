//
//  SkillSideEffect.m
//  Utopia
//
//  Created by Behrouz N. on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillSideEffect.h"
#import "SkillSideEffectBuff.h"
#import "SkillSideEffectNerf.h"
#import "Globals.h"
#import "BattleSprite.h"
#import "CCAnimation+SpriteLoading.h"
#import "GameState.h"
#import "SkillManager.h"
#import "NewBattleLayer.h"

#define SIDE_EFFECT_ANIM_DELAY_PER_FRAME  .07f
#define SIDE_EFFECT_VFX_FADE_DURATION     .2f
#define SIDE_EFFECT_VFX_DISPLAY_DURATION  2.f
#define SIDE_EFFECT_VFX_DISPLAY_INTERVAL  (SIDE_EFFECT_VFX_DISPLAY_DURATION + SIDE_EFFECT_VFX_FADE_DURATION * 2.f)
#define SIDE_EFFECT_VFX_APPEAR_DURATION   .4f
#define SIDE_EFFECT_VFX_SCALE_MODIFIER    1.f
#define SIDE_EFFECT_PFX_SCALE_MODIFIER    .5f // Retina display
#define SIDE_EFFECT_TOP_MOST_Z_ORDER      1000
#define SIDE_EFFECT_DISPLAY_ACTION_TAG    881039

@implementation SkillSideEffect

+ (instancetype)sideEffectWithProto:(SkillSideEffectProto*)proto invokingSkill:(NSInteger)skillId
{
  switch (proto.traitType)
  {
    case SideEffectTraitTypeBuff:
      return [[SkillSideEffectBuff alloc] initWithProto:proto invokingSkill:skillId];
      break;
    case SideEffectTraitTypeNerf:
      return [[SkillSideEffectNerf alloc] initWithProto:proto invokingSkill:skillId];
      break;
      
    case SideEffectTraitTypeNoTrait:
    default:
      return nil;
  }
}

- (instancetype)initWithProto:(SkillSideEffectProto*)proto invokingSkill:(NSInteger)skillId
{
  if (self = [super init])
  {
    if (proto)
    {
      _name = proto.name;
      _desc = proto.desc;
      _type = proto.type;
      _traitType = proto.traitType;
      _imageName = proto.imgName;
      _imagePixelOffset = CGPointMake(proto.imgPixelOffsetX, proto.imgPixelOffsetY);
      _iconImageName = proto.iconImgName;
      _pfxName = proto.pfxName;
      _pfxColor = [CCColor colorWithUIColor:[UIColor colorWithHexString:proto.pfxColor]];
      _pfxPixelOffset = CGPointMake(proto.pfxPixelOffsetX, proto.pfxPixelOffsetY);
      _positionType = proto.positionType;
      _blendMode = proto.blendMode;
      
      // Use invoking skill's icon if none provided
      if (_iconImageName || [_iconImageName isEqualToString:@""])
      {
        SkillProto* skillProto = [[GameState sharedGameState].staticSkills objectForKey:[NSNumber numberWithInteger:skillId]];
        if (skillProto)
          _iconImageName = [skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix];
      }
    }
    
    _vfx = nil;
    _pfx = nil;
    _characterSprite = nil;
  }
  
  return self;
}

- (void)addToCharacterSprite:(BattleSprite*)sprite zOrder:(NSInteger)zOrder turnsAffected:(NSInteger)numTurns castOnPlayer:(BOOL)player
{
  if (_characterSprite)
    [self removeFromCharacterSprite];
  
  if (sprite)
  {
    _characterSprite = sprite;
    _castOnPlayer = player;
    
    // If no _imageName is provided or the corresponding
    // asset is missing, nothing will be displayed
    if (_imageName && ![_imageName isEqualToString:@""])
    {
      const BOOL belowCharacter = (_positionType == SideEffectPositionTypeBelowCharacter);
      
      if ([_imageName rangeOfString:@".plist"].location == NSNotFound)
      {
        // Display static image
        _vfx = [CCSprite spriteWithImageNamed:_imageName];
        if (_vfx)
        {
          _vfx.position = ccpAdd(ccp(sprite.contentSize.width * .5f, belowCharacter ? 0.f : sprite.contentSize.height), _imagePixelOffset);
          _vfx.zOrder = belowCharacter ? zOrder : SIDE_EFFECT_TOP_MOST_Z_ORDER + zOrder;
          _vfx.scale = 0.f;
          
          [_vfx runAction:[CCActionSpawn actions:
                           [CCActionEaseBounceOut actionWithAction:
                            [CCActionScaleTo actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION scale:SIDE_EFFECT_VFX_SCALE_MODIFIER]],
                           [CCActionFadeIn actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION], nil]];
          
          [sprite addChild:_vfx z:_vfx.zOrder];
        }
      }
      else
      {
        // Display spritesheet animation
        [self loadSpriteSheet:_imageName withCompletion:^(BOOL success) {
          if (success)
          {
            _vfx = [CCSprite node];
            _vfx.position = ccpAdd(ccp(sprite.contentSize.width * .5f, belowCharacter ? 0.f : sprite.contentSize.height), _imagePixelOffset);
            _vfx.zOrder = belowCharacter ? zOrder : SIDE_EFFECT_TOP_MOST_Z_ORDER + zOrder;
            _vfx.scale = 0.f;
            [self setSpriteBlendMode:_vfx];
            
            NSString* prefix = [_imageName stringByDeletingPathExtension]; // DO NOT CHANGE - Naming convention that the assets follow
            CCAnimation* anim = [CCAnimation animationWithSpritePrefix:prefix delay:SIDE_EFFECT_ANIM_DELAY_PER_FRAME];
            CCAction* action = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
            [_vfx runAction:action];

            [_vfx runAction:[CCActionSpawn actions:
                             [CCActionEaseBounceOut actionWithAction:
                              [CCActionScaleTo actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION scale:SIDE_EFFECT_VFX_SCALE_MODIFIER]],
                             [CCActionFadeIn actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION], nil]];
            
            [sprite addChild:_vfx z:_vfx.zOrder];
          }
        }];
      }
    }
    
    if (_pfxName && ![_pfxName isEqualToString:@""])
    {
      _pfx = [CCParticleSystem particleWithFile:_pfxName];
      if (_pfx)
      {
        _pfx.position = ccpAdd(ccp(sprite.contentSize.width * .5f, 0.f), _pfxPixelOffset);
        _pfx.startColor = [CCColor colorWithRed:_pfxColor.red green:_pfxColor.green blue:_pfxColor.blue alpha:_pfx.startColor.alpha];
        _pfx.endColor = [CCColor colorWithRed:_pfxColor.red green:_pfxColor.green blue:_pfxColor.blue alpha:_pfx.endColor.alpha];
        _pfx.zOrder = SIDE_EFFECT_TOP_MOST_Z_ORDER;
        _pfx.scale = SIDE_EFFECT_PFX_SCALE_MODIFIER;
        [sprite addChild:_pfx z:_pfx.zOrder];
      }
    }
    
    // Display side effect symbol on turn indicators for the affected turns
    [[[[skillManager battleLayer] hudView] battleScheduleView] displaySideEffectIcon:_iconImageName
                                                                             withKey:_name
                                                                     onUpcomingTurns:numTurns
                                                                           forPlayer:player];
  }
}

- (void)removeFromCharacterSprite
{
  // Remove side effect symbol from turn indicators
  [[[[skillManager battleLayer] hudView] battleScheduleView] removeSideEffectIconWithKey:_name
                                                             onAllUpcomingTurnsForPlayer:_castOnPlayer];
  
  if (_vfx && [_vfx getActionByTag:SIDE_EFFECT_DISPLAY_ACTION_TAG] == nil)
    [_vfx runAction:[CCActionSequence actions:
                     [CCActionSpawn actions:
                      [CCActionScaleTo actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION scale:0.f],
                      [CCActionFadeOut actionWithDuration:SIDE_EFFECT_VFX_APPEAR_DURATION], nil],
                     [CCActionCallFunc actionWithTarget:self selector:@selector(removeFromCharacterSpriteInternal)]
                     , nil]];
  else
    [self removeFromCharacterSpriteInternal];
}

- (void)removeFromCharacterSpriteInternal
{
  if (_characterSprite)
  {
    if (_vfx)
    {
      [_vfx stopAllActions];
      [_characterSprite removeChild:_vfx];
      _vfx = nil;
    }
    if (_pfx)
    {
      [_pfx stopSystem];
      [_characterSprite removeChild:_pfx];
      _pfx = nil;
    }
    
    _characterSprite = nil;
  }
}

- (void)setDisplayOrder:(int)order totalCount:(int)total
{
  [_vfx stopActionByTag:SIDE_EFFECT_DISPLAY_ACTION_TAG];
  [_pfx stopActionByTag:SIDE_EFFECT_DISPLAY_ACTION_TAG];
  
  if (order < 0)
  {
    [self setSpriteBlendMode:_vfx]; // Using setSpriteBlendMode to restore the original opacity
    [_pfx resetSystem];
  }
  else
  {
    _vfx.opacity = 0.f;
    CCAction* action = [CCActionRepeatForever actionWithAction:
                        [CCActionSequence actions:
                         [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_INTERVAL * order],
                         [CCActionFadeIn  actionWithDuration:SIDE_EFFECT_VFX_FADE_DURATION],
                         [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_DURATION],
                         [CCActionFadeOut actionWithDuration:SIDE_EFFECT_VFX_FADE_DURATION],
                         [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_INTERVAL * (total - order - 1)]
                         , nil]];
    action.tag = SIDE_EFFECT_DISPLAY_ACTION_TAG;
    [_vfx runAction:action];
    
    [_pfx stopSystem];
    action = [CCActionRepeatForever actionWithAction:
              [CCActionSequence actions:
               [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_INTERVAL * order],
               [CCActionCallFunc actionWithTarget:_pfx selector:@selector(resetSystem)],
               [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_INTERVAL],
               [CCActionCallFunc actionWithTarget:_pfx selector:@selector(stopSystem)],
               [CCActionDelay   actionWithDuration:SIDE_EFFECT_VFX_DISPLAY_INTERVAL * (total - order - 1)]
               , nil]];
    action.tag = SIDE_EFFECT_DISPLAY_ACTION_TAG;
    [_pfx runAction:action];
  }
}

- (void)resetAfftectedTurnsCount:(NSInteger)numTurns
{
  // Display side effect symbol on turn indicators for the affected turns
  [[[[skillManager battleLayer] hudView] battleScheduleView] displaySideEffectIcon:_iconImageName
                                                                           withKey:_name
                                                                   onUpcomingTurns:numTurns
                                                                         forPlayer:_castOnPlayer];
}

- (void)loadSpriteSheet:(NSString*)spriteSheet withCompletion:(void(^)(BOOL success))completion
{
  [Globals checkAndLoadSpriteSheet:spriteSheet completion:^(BOOL success) {
    if (success)
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheet];
    if (completion)
      completion(success);
  }];
}

- (void)setSpriteBlendMode:(CCSprite*)sprite
{
  switch (_blendMode) {
    case SideEffectBlendModeNormalFullOpacity:
    default:
      sprite.opacity = 1.f;
      sprite.blendMode = [CCBlendMode blendModeWithOptions:@{ CCBlendFuncSrcColor:@( GL_SRC_ALPHA ),
                                                              CCBlendFuncDstColor:@( GL_ONE_MINUS_SRC_ALPHA ) }];
      break;
  }
}

@end
