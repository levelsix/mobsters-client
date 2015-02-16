//
//  SkillSideEffect.h
//  Utopia
//
//  Created by Behrouz N. on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Skill.pb.h"
#import "cocos2d.h"

@class BattleSprite;

@interface SkillSideEffect : NSObject
{
  NSString* _imageName;
  CGPoint   _imagePixelOffset;
  NSString* _iconImageName;
  NSString* _pfxName;
  CCColor*  _pfxColor;
  CGPoint   _pfxPixelOffset;
  SideEffectBlendMode _blendMode;
  
  CCSprite* _vfx;
  CCParticleSystem* _pfx;
}

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* desc;
@property (nonatomic, readonly) SideEffectType type;
@property (nonatomic, readonly) SideEffectTraitType traitType;
@property (nonatomic, readonly) SideEffectPositionType positionType;

@property (nonatomic, readonly) BattleSprite* characterSprite;

+ (instancetype)sideEffectWithProto:(SkillSideEffectProto*)proto;

- (instancetype)initWithProto:(SkillSideEffectProto*)proto;

- (void)addToCharacterSprite:(BattleSprite*)sprite zOrder:(NSInteger)zOrder;
- (void)removeFromCharacterSprite;
- (void)setDisplayOrder:(int)order totalCount:(int)total;

@end