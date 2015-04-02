//
//  SkillControllerActive.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillController.h"

@interface SkillControllerActive : SkillController

@property NSInteger orbCounter;
@property (readonly) NSInteger orbRequirement;

- (void) resetOrbCounter;

- (BOOL) doesRefresh;
- (BOOL) isActive;
- (BOOL) doesStack;

- (BOOL) activate;


@end