//
//  ProgressBar.h
//  Utopia
//
//  Created by Rob Giusti on 6/1/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import <cocos2d-ui.h>

@interface CCProgressBar : CCSprite

@property (nonatomic, retain) CCSprite *leftCap;
@property (nonatomic, retain) CCSprite *middleBar;
@property (nonatomic, retain) CCSprite *rightCap;

@property (nonatomic, assign) float percentage;

@property (nonatomic, assign) NSString *prefix;

- (id) initBarWithPrefix:(NSString *)prefix background:(NSString *)background;

- (void) updateForPercentage:(float)percentage;

@end