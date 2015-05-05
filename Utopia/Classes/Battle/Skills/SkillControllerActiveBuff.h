//
//  SkillControllerActiveBuff.h
//  Utopia
//
//  Created by Rob Giusti on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

typedef enum {
  TickTriggerAfterUserTurn = 0,
  TickTriggerAfterOpponentTurn = 1
} TickTrigger;

@interface SkillControllerActiveBuff : SkillControllerActive {
  NSMutableDictionary *_targets;
}

- (BOOL) ticksOnUserDeath;
- (TickTrigger) tickTrigger;
- (BOOL) resetDuration;
- (BOOL) tickDuration;
- (BOOL) onDurationStart;
- (BOOL) onDurationReset;
- (BOOL) onDurationEnd;
- (BOOL) endDurationNow;
- (BOOL) affectsOwner;
- (BOOL) expiresOnDeath;

- (void) addVisualEffects:(BOOL)finishSkillTrigger;
- (void) resetVisualEffects;
- (void) removeVisualEffects;

@property (readonly) NSInteger duration;

@property NSInteger turnsLeft;

@end
