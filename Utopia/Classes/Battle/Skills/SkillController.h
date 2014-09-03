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
#import "BattlePlayer.h"
#import "BattleSprite.h"

typedef void(^SkillControllerBlock)(BOOL enemyKilled);

@class NewBattleLayer;

typedef enum {
  SkillTriggerPointEnemyAppeared    = 1,
  SkillTriggerPointEndOfPlayerMove  = 2,
  SkillTriggerPointStartOfEnemyTurn = 3,
} SkillTriggerPoint;

@interface SkillController : NSObject //<SkillProtocol>
{
  SkillControllerBlock  _callbackBlock;
}

@property (readonly) SkillType            skillType;
@property (readonly) SkillActivationType  activationType;

@property (weak, nonatomic) NewBattleLayer  *battleLayer;
@property (weak, nonatomic) BattlePlayer    *player;
@property (weak, nonatomic) BattlePlayer    *enemy;
@property (weak, nonatomic) BattleSprite    *playerSprite;
@property (weak, nonatomic) BattleSprite    *enemySprite;

@property (readonly) OrbColor orbColor;

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color;
+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color; // Factory call, can create different skill types

// External callers
- (BOOL) skillIsReady;
- (void) orbDestroyed:(OrbColor)color;
- (void) triggerSkillWithBlock:(SkillControllerBlock)block andTrigger:(SkillTriggerPoint)trigger;

// To be overriden by specific skills
- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger;
- (void) skillTriggerFinished;
- (void) setDefaultValues;
- (void) setValue:(float)value forProperty:(NSString*)property;

@end
