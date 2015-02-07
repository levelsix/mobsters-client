//
//  SkillControllerActiveBuff.h
//  Utopia
//
//  Created by Rob Giusti on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillControllerActiveBuff : SkillControllerActive

- (BOOL) isActive;
- (void) resetDuration;
- (void) tickDuration;
- (void) onDurationStart;
- (void) onDurationReset;
- (void) onDurationEnd;

@property (readonly) NSInteger duration;
@property (readonly) NSInteger turnsLeft;

@end
