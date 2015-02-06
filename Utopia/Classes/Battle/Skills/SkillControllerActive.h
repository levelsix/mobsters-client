//
//  SkillControllerActive.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillController.h"

@interface SkillControllerActive : SkillController

@property (readonly) NSInteger orbCounter;
@property (readonly) NSInteger orbRequirement;

@property (readonly) NSInteger duration;
@property (readonly) NSInteger turnsLeft;

- (void) resetOrbCounter;
- (BOOL) isActive;
- (void) resetDuration;
- (void) tickDuration;

@end