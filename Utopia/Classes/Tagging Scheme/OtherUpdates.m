//
//  OtherUpdates.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OtherUpdates.h"
#import "GameState.h"

@implementation NoUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag {
  return [[self alloc] initWithTag:tag];
}

- (id) initWithTag:(int)t {
  if ((self = [super init])) {
    self.tag = t;
  } 
  return self;
}

@end

@implementation AddStructUpdate

@synthesize tag;
@synthesize userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us {
  return [[self alloc] initWithTag:tag userStruct:us];
}

- (id) initWithTag:(int)t userStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.tag = t;
    self.userStruct = us;
    
    GameState *gs = [GameState sharedGameState];
    [gs.myStructs addObject:us];
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs.myStructs removeObject:self.userStruct];
}

@end

@implementation SellStructUpdate

@synthesize tag;
@synthesize userStruct;

+ (id) updateWithTag:(int)tag userStruct:(UserStruct *)us {
  return [[self alloc] initWithTag:tag userStruct:us];
}

- (id) initWithTag:(int)t userStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.tag = t;
    self.userStruct = us;
    
    GameState *gs = [GameState sharedGameState];
    [gs.myStructs removeObject:us];
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  [gs.myStructs addObject:self.userStruct];
}

@end

@implementation ExpForNextLevelUpdate

@synthesize tag;

+ (id) updateWithTag:(int)tag prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel {
  return [[self alloc] initWithTag:tag prevLevel:prevLevel curLevel:curLevel nextLevel:nextLevel];
}

- (id) initWithTag:(int)t prevLevel:(int)prevLevel curLevel:(int)curLevel nextLevel:(int)nextLevel {
  if ((self = [super init])) {
    self.tag = t;
    _prevLevel = prevLevel;
    _curLevel = curLevel;
    _nextLevel = nextLevel;
    
    GameState *gs = [GameState sharedGameState];
    gs.expRequiredForCurrentLevel = _curLevel;
    gs.expRequiredForNextLevel = _nextLevel;
  }
  return self;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.expRequiredForCurrentLevel = _prevLevel;
  gs.expRequiredForNextLevel = _curLevel;
}

@end
