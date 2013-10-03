//
//  OrbLayer.h
//  PadClone
//
//  Created by Ashwin Kamath on 8/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define NUM_COLORS 5
#define TIME_LIMIT 100

typedef enum {
  color_purple = 1,
  color_green,
  color_blue,
  color_red,
  color_white,
  color_all = 10
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

@interface Gem : NSObject

@property (nonatomic, retain) CCSprite * sprite;
@property (nonatomic, assign) GemColorId color;
@property (nonatomic, assign) PowerupId powerup;

@end

@protocol OrbLayerDelegate <NSObject>

- (void) newComboFound;
- (void) orbKilled;
- (void) turnComplete;

@end

@interface OrbLayer : CCLayer <CCTargetedTouchDelegate> {
  BOOL _allowInput;
  Gem * _dragGem;
  Gem * _realDragGem;
  Gem * _swapGem;
  CGPoint _dragOffset;
  NSMutableSet *_run, *_tempRun;
  int _gemsToProcess;
  BOOL _beganTimer;
  CGPoint _lastGridPt;
  int _currentComboCount;
  BOOL _foundMatch;
  int _gemsBouncing;
}

@property (nonatomic, readonly) CGSize gridSize;
@property (nonatomic, retain) NSMutableArray *gems;
@property (nonatomic, retain) NSMutableArray *oldGems;
@property (nonatomic, retain) NSMutableArray *destroyedGems;
@property (nonatomic, retain) NSMutableArray *comboLabels;
@property (nonatomic, retain) NSMutableArray *powerups;

@property (nonatomic, assign) id<OrbLayerDelegate> delegate;

- (id) initWithContentSize:(CGSize)size;

@end
