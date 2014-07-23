//
//  FullUserUpdates.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FullUserUpdates.h"

@implementation FullUserUpdate

@synthesize tag;

+ (id) updateWithTag:(int)t change:(int)change {
  return [[self alloc] initWithTag:t change:change];
}

- (id) initWithTag:(int)t change:(int)change {
  if ((self = [super init])) {
    tag = t;
    _change = change;
  }
  return self;
}

- (void) undo {
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

@end

@implementation GoldUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.gems += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.gems -= _change;
  
  [super undo];
}

@end

@implementation SilverUpdate

- (id) initWithTag:(int)t change:(int)change {
  GameState *gs = [GameState sharedGameState];
  change = MIN(change, MAX(0, gs.maxCash-gs.cash));
  return [super initWithTag:t change:change];
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.cash += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.cash -= _change;
  
  [super undo];
}

@end

@implementation OilUpdate

- (id) initWithTag:(int)t change:(int)change {
  GameState *gs = [GameState sharedGameState];
  change = MIN(change, MAX(0, gs.maxOil-gs.oil));
  return [super initWithTag:t change:change];
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.oil += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.oil -= _change;
  
  [super undo];
}

@end

@implementation LevelUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.level += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.level -= _change;
  
  [super undo];
}

@end

@implementation ExperienceUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.experience += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.experience -= _change;
  
  [super undo];
}

@end
