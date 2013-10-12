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

@end

@implementation GoldUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.gold += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.gold -= _change;
}

@end

@implementation SilverUpdate

- (void) update {
  GameState *gs = [GameState sharedGameState];
  gs.silver += _change;
}

- (void) undo {
  GameState *gs = [GameState sharedGameState];
  gs.silver -= _change;
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
}

@end
