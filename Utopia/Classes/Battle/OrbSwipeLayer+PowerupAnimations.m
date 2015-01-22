//
//  OrbSwipeLayer+PowerupAnimations.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "OrbSwipeLayer+PowerupAnimations.h"

#import "SoundEngine.h"
#import "Globals.h"

#define TIME_TO_TRAVEL_PER_SQUARE 0.1
#define ROCKET_END_LOCATION 15
#define MOLOTOV_PARTICLE_DURATION 0.75
#define POWERUP_Z 110

@implementation OrbSwipeLayer (PowerupAnimations)

- (void) spawnHorizontalLineWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  BattleOrb *baseOrb = chain.powerupInitiatorOrb;
  NSInteger leftIdx = -1;
  NSInteger rightIdx = chain.orbs.count;
  
  // Find the orbs that are basically in the center
  for (BattleOrb *orb in chain.orbs) {
    if (orb.column <= baseOrb.column) {
      leftIdx = [chain.orbs indexOfObject:orb];
    }
  }
  for (BattleOrb *orb in chain.orbs.reverseObjectEnumerator) {
    if (orb.column >= baseOrb.column) {
      rightIdx = [chain.orbs indexOfObject:orb];
    }
  }
  
  BOOL leftSideIsLonger = baseOrb.column > _numColumns-baseOrb.column-1;
  
  CCSprite *r = [CCSprite spriteWithImageNamed:@"rocket.png"];
  r.position = [self pointForColumn:baseOrb.column row:baseOrb.row];
  [self addChild:r z:POWERUP_Z];
  
  CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
  q.position = ccp(0,12);
  [r addChild:q z:-1];
  
  // As the rocket is passing by each square, let it destroy the square
  NSMutableArray *seq = [NSMutableArray array];
  
  // This one is travelling right
  CGPoint pt = r.position;
  for (NSInteger i = rightIdx; i < chain.orbs.count; i++) {
    BattleOrb *orb = chain.orbs[i];
    
    CGPoint oldPt = pt;
    pt = [self pointForColumn:orb.column row:orb.row];
    float dist = ccpDistance(oldPt, pt);
    [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE*dist/_tileWidth position:pt]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeHorizontalLine];
    }]];
  }
  
  float time = TIME_TO_TRAVEL_PER_SQUARE*(baseOrb.column+ROCKET_END_LOCATION-_numColumns);
  [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForColumn:baseOrb.column+ROCKET_END_LOCATION row:baseOrb.row]],
                  [CCActionFadeOut actionWithDuration:time],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     if (!leftSideIsLonger) {
                       _numPowerupsStillAnimating--;
                       [self checkIfAllOrbsAndPowerupsAreDone];
                     }
                   }], nil]];
  [seq addObject:[CCActionRemove action]];
  
  [r runAction:[CCActionSequence actionWithArray:seq]];
  
  r = [CCSprite spriteWithImageNamed:@"rocket.png"];
  r.position = [self pointForColumn:baseOrb.column row:baseOrb.row];
  r.flipX = YES;
  [self addChild:r z:POWERUP_Z];
  
  q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
  q.position = ccp(20,12);
  [r addChild:q z:-1];
  
  seq = [NSMutableArray array];
  
  // This one is travelling left
  pt = r.position;
  for (NSInteger i = leftIdx; i >= 0; i--) {
    BattleOrb *orb = chain.orbs[i];
    
    CGPoint oldPt = pt;
    pt = [self pointForColumn:orb.column row:orb.row];
    float dist = ccpDistance(oldPt, pt);
    [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE*dist/_tileWidth position:pt]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeHorizontalLine];
    }]];
  }
  
  time = TIME_TO_TRAVEL_PER_SQUARE*(baseOrb.column-ROCKET_END_LOCATION)*-1;
  [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForColumn:baseOrb.column-ROCKET_END_LOCATION row:baseOrb.row]],
                  [CCActionFadeOut actionWithDuration:time],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     if (leftSideIsLonger) {
                       _numPowerupsStillAnimating--;
                       [self checkIfAllOrbsAndPowerupsAreDone];
                     }
                   }], nil]];
  [seq addObject:[CCActionRemove action]];
  
  [r runAction:[CCActionSequence actionWithArray:seq]];
  
  _numPowerupsStillAnimating++;
  
  [SoundEngine puzzleRocketMatch];
}

- (void) spawnVerticalLineWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  BattleOrb *baseOrb = chain.powerupInitiatorOrb;
  NSInteger downIdx = -1;
  NSInteger upIdx = chain.orbs.count;
  
  // Find the orbs that are basically in the center
  for (BattleOrb *orb in chain.orbs) {
    if (orb.row <= baseOrb.row) {
      downIdx = [chain.orbs indexOfObject:orb];
    }
  }
  for (BattleOrb *orb in chain.orbs.reverseObjectEnumerator) {
    if (orb.row >= baseOrb.row) {
      upIdx = [chain.orbs indexOfObject:orb];
    }
  }
  
  BOOL botSideIsLonger = baseOrb.row > _numRows-baseOrb.row-1;
  
  // Have to do this due to rotation issues
  CCSprite *r = [CCSprite spriteWithImageNamed:@"rocket.png"];
  r.opacity = 0;
  r.position = [self pointForColumn:baseOrb.column row:baseOrb.row];
  [self addChild:r z:POWERUP_Z];
  
  CCSprite *n = [CCSprite spriteWithImageNamed:@"rocket.png"];
  n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
  n.rotation = -90;
  [r addChild:n];
  
  CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
  q.position = ccpAdd(n.position, ccp(0, 10));
  [r addChild:q z:-1];
  
  
  
  // As the rocket is passing by each square, let it destroy the square
  NSMutableArray *seq = [NSMutableArray array];
  
  // This one is travelling up
  CGPoint pt = r.position;
  for (NSInteger i = upIdx; i < chain.orbs.count; i++) {
    BattleOrb *orb = chain.orbs[i];
    
    CGPoint oldPt = pt;
    pt = [self pointForColumn:orb.column row:orb.row];
    float dist = ccpDistance(oldPt, pt);
    [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE*dist/_tileHeight position:pt]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeHorizontalLine];
    }]];
  }
  
  float time = TIME_TO_TRAVEL_PER_SQUARE*(baseOrb.row+ROCKET_END_LOCATION-_numRows);
  [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForColumn:baseOrb.column row:baseOrb.row+ROCKET_END_LOCATION]],
                  [CCActionFadeOut actionWithDuration:time],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     if (!botSideIsLonger) {
                       _numPowerupsStillAnimating--;
                       [self checkIfAllOrbsAndPowerupsAreDone];
                     }
                   }], nil]];
  [seq addObject:[CCActionRemove action]];
  
  [r runAction:[CCActionSequence actionWithArray:seq]];
  
  
  
  r = [CCSprite spriteWithImageNamed:@"rocket.png"];
  r.opacity = 0;
  r.position = [self pointForColumn:baseOrb.column row:baseOrb.row];
  [self addChild:r z:POWERUP_Z];
  
  n = [CCSprite spriteWithImageNamed:@"rocket.png"];
  n.position = ccp(r.contentSize.width/2, r.contentSize.height/2);
  n.rotation = 90;
  [r addChild:n];
  
  q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
  q.position = ccpAdd(n.position, ccp(0, -10));
  [r addChild:q z:-1];
  
  seq = [NSMutableArray array];
  
  // This one is travelling left
  pt = r.position;
  for (NSInteger i = downIdx; i >= 0; i--) {
    BattleOrb *orb = chain.orbs[i];
    
    CGPoint oldPt = pt;
    pt = [self pointForColumn:orb.column row:orb.row];
    float dist = ccpDistance(oldPt, pt);
    [seq addObject:[CCActionMoveTo actionWithDuration:TIME_TO_TRAVEL_PER_SQUARE*dist/_tileWidth position:pt]];
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeHorizontalLine];
    }]];
  }
  
  time = TIME_TO_TRAVEL_PER_SQUARE*(baseOrb.column-ROCKET_END_LOCATION)*-1;
  [seq addObject:[CCActionSpawn actions:[CCActionMoveTo actionWithDuration:time position:[self pointForColumn:baseOrb.column row:baseOrb.row-ROCKET_END_LOCATION]],
                  [CCActionFadeOut actionWithDuration:time],
                  [CCActionCallBlock actionWithBlock:
                   ^{
                     if (botSideIsLonger) {
                       _numPowerupsStillAnimating--;
                       [self checkIfAllOrbsAndPowerupsAreDone];
                     }
                   }], nil]];
  [seq addObject:[CCActionRemove action]];
  
  [r runAction:[CCActionSequence actionWithArray:seq]];
  
  _numPowerupsStillAnimating++;
  
  [SoundEngine puzzleRocketMatch];
}

- (void) spawnExplosionWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  _numPowerupsStillAnimating++;
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.05],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      _numPowerupsStillAnimating--;
                      for (BattleOrb *orb in chain.orbs) {
                        [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeExplosion];
                      }
                      [self checkIfAllOrbsAndPowerupsAreDone];
                      
                      CCParticleSystem *x = [CCParticleSystem particleWithFile:@"grenade1.plist"];
                      [self addChild:x z:POWERUP_Z];
                      x.position = [self pointForColumn:chain.powerupInitiatorOrb.column row:chain.powerupInitiatorOrb.row];
                      x.autoRemoveOnFinish = YES;
                    }],
                   nil]];
}

- (void) spawnRainbowWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  NSMutableArray *orbs = [chain.orbs mutableCopy];
  [orbs shuffle];
  
  _numPowerupsStillAnimating++;
  
  __block int projectileCount = 0;
  for (int i = 0; i < orbs.count; i++) {
    BattleOrb *orb = orbs[i];
    OrbSprite *orbLayer = [self spriteForOrb:orb];
    
    if (orbLayer) {
      CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
      q.particlePositionType = CCParticleSystemPositionTypeFree;
      [self addChild:q z:POWERUP_Z];
      q.position = [self pointForColumn:chain.powerupInitiatorOrb.column row:chain.powerupInitiatorOrb.row];
      
      projectileCount++;
      
      [q runAction:
       [CCActionSequence actions:
        [CCActionDelay actionWithDuration:i*0.1],
        [CCActionMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:orbLayer.position],
        [CCActionCallBlock actionWithBlock:
         ^{
           [q removeFromParentAndCleanup:YES];
           
           [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeAllOfOneColor];
           
           projectileCount--;
           if (projectileCount == 0) {
             _numPowerupsStillAnimating--;
             [self checkIfAllOrbsAndPowerupsAreDone];
           }
         }],
        nil]];
    }
  }
  
  if (!projectileCount) {
    _numPowerupsStillAnimating--;
    [self checkIfAllOrbsAndPowerupsAreDone];
  }
}

- (void) spawnRainbowLineOrExplosionWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  BattleOrb *baseOrb = chain.powerupInitiatorOrb;
  
  _numPowerupsStillAnimating++;
  
  NSMutableArray *toDestroy = [NSMutableArray array];
  for (BattleOrb *orb in chain.orbs) {
    OrbSprite *orbLayer = [self spriteForOrb:orb];
    
    if (orbLayer) {
      CCParticleSystem *q = [CCParticleSystem particleWithFile:@"rockettail.plist"];
      [self addChild:q z:10];
      q.position = [self pointForColumn:baseOrb.column row:baseOrb.row];
      [q runAction:[CCActionMoveTo actionWithDuration:MOLOTOV_PARTICLE_DURATION position:orbLayer.position]];
      q.duration = MOLOTOV_PARTICLE_DURATION;
      q.autoRemoveOnFinish = YES;
      
      [toDestroy addObject:orb];
    }
  }
  
  [toDestroy shuffle];
  
  // First action just delays everything, then we replace and fire off rockets
  NSMutableArray *seq = [NSMutableArray array];
  
  [seq addObject:[CCActionDelay actionWithDuration:MOLOTOV_PARTICLE_DURATION-0.1]];
  
  [seq addObject:[CCActionCallBlock actionWithBlock:^{
    
    NSMutableArray *seq = [NSMutableArray array];
    
    [seq addObject:[CCActionDelay actionWithDuration:0.2]];
    
    for (BattleOrb *orb in toDestroy) {
      OrbSprite *oldSprite = [self spriteForOrb:orb];
      [oldSprite removeFromParent];
      
      // Since the orb should already be updated by the model we can just create a new one
      // and it will show the stripes.
      [self createOrbSpriteForOrb:orb];
      
      if (orb.isLocked) {
        [self destroyLock:orb];
      }
      
      [seq addObject:[CCActionDelay actionWithDuration:0.2]];
      [seq addObject:[CCActionCallBlock actionWithBlock:^{
        [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeNone];
      }]];
    }
    
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      _numPowerupsStillAnimating--;
      [self checkIfAllOrbsAndPowerupsAreDone];
    }]];
    
    [self runAction:[CCActionSequence actionWithArray:seq]];
  }]];
  
  [self runAction:[CCActionSequence actionWithArray:seq]];
}

- (void) spawnDoubleRainbowWithChain:(BattleChain *)chain otherChains:(NSSet *)otherChains {
  NSMutableArray *seq = [NSMutableArray array];
  
  for (BattleOrb *orb in chain.orbs) {
    [seq addObject:[CCActionCallBlock actionWithBlock:^{
      [self performOrbChange:orb chains:otherChains fromPowerup:PowerupTypeAllOfOneColor];
    }]];
    [seq addObject:[CCActionDelay actionWithDuration:0.08]];
  }
  
  _numPowerupsStillAnimating++;
  [seq addObject:[CCActionCallBlock actionWithBlock:^{
    _numPowerupsStillAnimating--;
    [self checkIfAllOrbsAndPowerupsAreDone];
  }]];
  
  [self runAction:[CCActionSequence actionWithArray:seq]];
}

@end
