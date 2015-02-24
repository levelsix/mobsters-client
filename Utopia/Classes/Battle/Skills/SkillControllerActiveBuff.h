//
//  SkillControllerActiveBuff.h
//  Utopia
//
//  Created by Rob Giusti on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillControllerActiveBuff : SkillControllerActive

- (NSInteger) getDuration;
- (BOOL) resetDuration;
- (void) tickDuration;
- (BOOL) onDurationStart;
- (BOOL) onDurationReset;
- (BOOL) onDurationEnd;
- (void) endDurationNow;

- (void) addVisualEffects:(BOOL)finishSkillTrigger;
- (void) removeVisualEffects;

@property (readonly) NSInteger duration;
@property (readonly) NSInteger turnsLeft;

@end
