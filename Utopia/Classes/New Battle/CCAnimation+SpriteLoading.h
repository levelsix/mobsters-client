//
//  CCAnimation+SpriteLoading.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "CCAnimation.h"
#import "CCSpriteFrameCache.h"

@interface CCSpriteFrameCache (FrameCheck)

- (BOOL) containsFrame:(NSString *)frameName;

@end

@interface CCAnimation (SpriteLoading)

+ (id) animationWithSpritePrefix:(NSString *)prefix delay:(float)delay;
- (id) initWithSpritePrefix:(NSString *)prefix delay:(float)delay;

@end
