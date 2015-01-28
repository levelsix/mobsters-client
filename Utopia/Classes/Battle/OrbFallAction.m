//
//  OrbFallAction.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "OrbFallAction.h"

@interface CCActionEaseAcceleration : CCActionEase {
  float _acceleration;
  float _initialVelocity;
  float _displacement;
}

@end

@implementation CCActionEaseAcceleration

+ (id) actionWithAction:(CCActionInterval *)action acceleration:(float)accel initialVelocity:(float)initialVelocity displacement:(float)displacement {
  return [[self alloc] initWithAction:action acceleration:accel initialVelocity:initialVelocity displacement:displacement];
}

- (id) initWithAction:(CCActionInterval *)action acceleration:(float)accel initialVelocity:(float)vel displacement:(float)displ {
  // Quadratic equation: displ needs to be negative since it starts at the right side of equation
  float duration = (- vel + sqrt ( powf(vel, 2) - 2 * accel * -displ ) ) / accel;
  
  if ((self = [super initWithDuration:duration])) {
    _inner = action;
    _acceleration = accel;
    _initialVelocity = vel;
    _displacement = displ;
  }
  
  return self;
}

-(void) update: (CCTime) t
{
  float dur = t * _duration;
  float interpolated = (_acceleration * powf(dur,2) / 2 + _initialVelocity * dur) / _displacement;
  [_inner update: interpolated];
}

@end

@implementation OrbFallAction

+ (id) actionWithOrbPath:(BattleOrbPath *)orbPath orb:(OrbSprite *)orbLayer swipeLayer:(OrbSwipeLayer *)swipeLayer isBottomFeeder:(BOOL)isBottomFeeder {
  NSMutableArray *actions = [NSMutableArray array];
  CGPoint prevPoint = CGPointZero;
  
  float accel = 60;
  float vel = 0;
  BOOL shouldBounce = YES; // To determine if there should be a bounce at the end
  NSMutableArray *moveTos = [NSMutableArray array];
  int displ = 0.f;
  int curTimeSlot = 0;
  
  float (^quad)(float) = ^float (float displ) {
    return (- vel + sqrt ( powf(vel, 2) - 2 * accel * -displ ) ) / accel;
  };
  
  for (id val in orbPath.path) {
    if ([val isKindOfClass:[NSNumber class]]) {
      // Add all the moveTos
      if (displ) {
        // Give it the velocity of the other moving parts so they move as one unit
        float initialTime = quad(curTimeSlot-displ);
        
        CCActionSequence *seq = [CCActionSequence actionWithArray:moveTos];
        // Use accel*2 since integral returns gt^2/2
        [actions addObject:[CCActionEaseAcceleration actionWithAction:seq acceleration:accel initialVelocity:vel+initialTime*accel displacement:displ]];
        
        moveTos = [NSMutableArray array];
        displ = 0.f;
      }
      
      float timeTillThisPoint = quad(curTimeSlot);
      
      int delay = [val intValue];
      curTimeSlot += delay;
      
      float timeAfterThisPoint = quad(curTimeSlot);
      
      [actions addObject:[CCActionDelay actionWithDuration:timeAfterThisPoint-timeTillThisPoint]];
    } else if ([val isKindOfClass:[NSValue class]]) {
      CGPoint nextPoint = [val CGPointValue];
      if (CGPointEqualToPoint(prevPoint, CGPointZero)) {
        orbLayer.position = [swipeLayer pointForColumn:nextPoint.x row:nextPoint.y];
      } else {
        int numSquares = MAX(1, (prevPoint.y-nextPoint.y));
        displ += numSquares;
        curTimeSlot += numSquares;
        CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:numSquares position:[swipeLayer pointForColumn:nextPoint.x row:nextPoint.y]];
        [moveTos addObject:moveTo];
        
        if (prevPoint.x != nextPoint.x) {
          shouldBounce = NO;
        }
      }
      prevPoint = nextPoint;
    }
  }
  
  // Add all the moveTos
  if (displ) {
    // Give it the velocity of the other moving parts so they move as one unit
    float initialTime = quad(curTimeSlot-displ);
    
    CCActionSequence *seq = [CCActionSequence actionWithArray:moveTos];
    [actions addObject:[CCActionEaseAcceleration actionWithAction:seq acceleration:accel initialVelocity:vel+initialTime*accel displacement:displ]];
  }
  
  if (shouldBounce && !isBottomFeeder) {
    float time = quad(curTimeSlot);
    float initialVel = vel + accel*time;
    float dist;
    
    do {
      initialVel /= 2; // Add dampening to velocity
      time = initialVel/accel; // vertex of the parabola
      
      dist = -accel * time * time / 2 + initialVel * time; // Flip the sign of acceleration since we are now bouncing in the opposite direction
      
      CCActionJumpBy *jump = [CCActionJumpBy actionWithDuration:2*time position:ccp(0, 0) height:dist*swipeLayer.tileHeight jumps:1];
      [actions addObject:jump];
    } while (dist > 0.01);
  }
  
  CCActionSequence *seq = [CCActionSequence actionWithArray:actions];
  return seq;
}

@end
