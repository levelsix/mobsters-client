//
//  MyTeamSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/24/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"

@interface ShortestPathStep : NSObject

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end

@interface MyTeamSprite : AnimatedSprite {
  SEL _destinationSelector;
}

@property (nonatomic, retain) NSMutableArray *spOpenSteps;
@property (nonatomic, retain) NSMutableArray *spClosedSteps;
@property (nonatomic, retain) NSMutableArray *shortestPath;

- (void) moveToward:(CGPoint)target withCompletionSelector:(SEL)comp;

@end
