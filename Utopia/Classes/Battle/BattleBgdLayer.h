//
//  BattleBgdLayer.h
//  Utopia
//
//  Created by Rob Giusti on 4/13/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol BattleBgdLayerDelegate <NSObject>

- (void) reachedNextScene;

@end

@interface BattleBgdLayer : CCNode {
  CGPoint _curBasePoint;
}

@property (nonatomic, assign) id<BattleBgdLayerDelegate> delegate;
@property (nonatomic, retain) NSString *prefix;

- (id) initWithPrefix:(NSString *)prefix;
- (void) scrollToNewScene;

@end