//
//  RWTTile.h
//  CookieCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  
  TileTypeNormal  = 0,
  TileTypeJelly   = 1,
  TileTypeMud     = 2,
  
} TileType;

@interface BattleTile : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) TileType typeTop;
@property (assign, nonatomic) TileType typeBottom;

// Some holes may be allowed to pass through even if they are a hole
@property (assign, nonatomic) BOOL isHole;
@property (assign, nonatomic) BOOL canPassThrough;

@property (assign, nonatomic) BOOL canSpawnOrbs;

@property (assign, nonatomic) BOOL shouldSpawnInitialSkill;

-(id) initWithColumn:(NSInteger)column row:(NSInteger)row typeTop:(TileType)typeTop typeBottom:(TileType)typeBottom isHole:(BOOL)isHole canPassThrough:(BOOL)canPassThrough canSpawnOrbs:(BOOL)canSpawnOrbs shouldSpawnInitialSkill:(BOOL)shouldSpawnInitialSkill;

// Checks
- (BOOL) allowsDamage;

// Actions
- (void) orbRemoved;

- (BOOL) isBlocked;

@end
