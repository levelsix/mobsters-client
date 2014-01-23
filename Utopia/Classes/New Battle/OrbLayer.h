//
//  OrbLayer.h
//  PadClone
//
//  Created by Ashwin Kamath on 8/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Protocols.pb.h"

#define TIME_LIMIT 100

typedef enum {
  color_red = MonsterProto_MonsterElementFire,
  color_blue = MonsterProto_MonsterElementWater,
  color_green = MonsterProto_MonsterElementGrass,
  color_white = MonsterProto_MonsterElementLightning,
  color_purple = MonsterProto_MonsterElementDarkness,
  color_filler = MonsterProto_MonsterElementRock,
  color_all = 100
} GemColorId;

typedef enum {
  powerup_none = 0,
  powerup_horizontal_line,
  powerup_vertical_line,
  powerup_explosion,
  powerup_all_of_one_color
} PowerupId;

@interface Powerup : NSObject

@property (nonatomic, assign) PowerupId powerupId;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) GemColorId color;

@end

@interface DestroyedGem : CCSprite

@property (nonatomic, retain) CCMotionStreak *streak;
@property (nonatomic, assign) int scoreValue;

@end

@interface Gem : NSObject

@property (nonatomic, retain) CCSprite * sprite;
@property (nonatomic, assign) GemColorId color;
@property (nonatomic, assign) PowerupId powerup;

@end

@protocol OrbLayerDelegate <NSObject>

- (void) moveBegan;
- (void) newComboFound;
- (void) gemKilled:(Gem *)gem;
- (void) gemReachedFlyLocation:(Gem *)gem;
- (void) moveComplete;
- (void) reshuffle;

@end

@interface OrbLayer : CCNode {
  BOOL _allowInput;
  Gem * _dragGem;
  Gem * _realDragGem;
  Gem * _swapGem;
  CGPoint _dragOffset;
  NSMutableSet *_run, *_tempRun;
  int _gemsToProcess;
  int _numColors;
  BOOL _beganTimer;
  CGPoint _lastGridPt;
  int _currentComboCount;
  BOOL _foundMatch;
  int _gemsBouncing;
}

@property (nonatomic, readonly) CGSize gridSize;
@property (nonatomic, retain) NSMutableArray *gems;
@property (nonatomic, retain) NSMutableArray *oldGems;
@property (nonatomic, retain) NSMutableSet *destroyedGems;
@property (nonatomic, retain) NSMutableSet *reservedGems;
@property (nonatomic, retain) NSMutableArray *comboLabels;
@property (nonatomic, retain) NSMutableArray *powerups;

@property (nonatomic, assign) CGPoint orbFlyToLocation;

@property (nonatomic, assign) BOOL isTrackingTouch;

@property (nonatomic, assign) id<OrbLayerDelegate> delegate;

- (id) initWithContentSize:(CGSize)size gridSize:(CGSize)gridSize numColors:(int)numColors;
- (void) allowInput;
- (void) disallowInput;
- (CCColor *) colorForSparkle:(GemColorId)color;

- (CGPoint) pointForGridPosition:(CGPoint)pt;
- (CGPoint) coordinateOfGem:(Gem *)gem;

- (BOOL) validMoveExists;
- (void) reshuffle;

@end
