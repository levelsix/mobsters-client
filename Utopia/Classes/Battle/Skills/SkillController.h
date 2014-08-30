//
//  SkillController.h
//  Utopia
//
//  Created by Mikhail Larionov on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Skill.pb.h"
#import "BattleOrb.h"

typedef void(^SkillControllerBlock)(void);

@protocol SkillProtocol

@optional

- (BOOL) triggerSkillAfterTurn;

@end

///////////////////////////////////////////////////////////

@interface SkillController : NSObject <SkillProtocol>
{

}

@property (readonly) SkillType            skillType;
@property (readonly) SkillActivationType  activationType;

+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color; // Factory call, can create different skill types

- (BOOL) skillIsReady;
- (void) orbDestroyed:(OrbColor)color;

- (void) activateSkillWithBlock:(SkillControllerBlock)block;

@end

///////////////////////////////////////////////////////////

@interface SkillControllerActive : SkillController
{
}

@property (readonly) OrbColor orbColor;
@property (readonly) NSInteger orbCounter;
@property (readonly) NSInteger orbRequirement;

@end