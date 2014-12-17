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
  TileTypeMud     = 2
  
} TileType;

@interface BattleTile : NSObject

// Note: To support different types of tiles, you can add properties here that
// indicate how this tile should behave. For example, if a cookie is matched
// that sits on a jelly tile, you'd set isJelly to NO to make it a normal tile.
//@property (assign, nonatomic) BOOL isJelly;

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) TileType typeTop;
@property (assign, nonatomic) TileType typeBottom;

-(id) initWithColumn:(NSInteger)column row:(NSInteger)row typeTop:(TileType)typeTop typeBottom:(TileType)typeBottom;

// Checks
- (BOOL) allowsDamage;

// Actions
- (void) orbRemoved;

@end
