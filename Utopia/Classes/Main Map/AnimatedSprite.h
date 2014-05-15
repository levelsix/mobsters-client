//
//  AnimatedSprite.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "MapSprite.h"
#import "Protocols.pb.h"
#import "UserData.h"

#define ABOVE_HEAD_FADE_DURATION 1.5f
#define ABOVE_HEAD_FADE_OPACITY 100
#define ANIMATATION_DELAY 0.07f
#define MOVE_DISTANCE 6.0f

#define WALKING_SPEED 75.f

#define VERTICAL_OFFSET 10.f

@class MissionMap;

@interface CharacterSprite : SelectableSprite {
  CCLabelTTF *_nameLabel;
}

@property (nonatomic, retain) CCLabelTTF *nameLabel;

@end

typedef enum {
  MapDirectionNearLeft = 1,
  MapDirectionNearRight,
  MapDirectionFarLeft,
  MapDirectionFarRight,
  MapDirectionFront,
} MapDirection;

@interface AnimatedSprite : CharacterSprite
{
  CCActionRepeatForever *_curAction;
  
  CGPoint _spriteOffset;
  CGPoint _oldMapPos;
  BOOL _shouldWalk;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCActionRepeatForever *walkActionN;
@property (nonatomic, retain) CCActionRepeatForever *walkActionF;

@property (nonatomic, retain) NSString *prefix;

- (id) initWithMonsterId:(int)monsterId map:(GameMap *)map;

- (void) walk;
- (void) stopWalking;
- (void) walkToTileCoords:(NSArray *)tileCoords completionTarget:(id)target selector:(SEL)completion speedMultiplier:(float)speedMultiplier;
- (void) walkToTileCoord:(CGPoint)tileCoord completionTarget:(id)target selector:(SEL)completion speedMultiplier:(float)speedMultiplier;
- (void) restoreStandingFrame;
- (void) restoreStandingFrame:(MapDirection)direction;
- (void) jumpNumTimes:(int)numTimes completionTarget:(id)target selector:(SEL)completion;
- (void) jumpNumTimes:(int)numTimes timePerJump:(float)dur completionTarget:(id)target selector:(SEL)completion;

@end

@interface NeutralEnemy : AnimatedSprite <TaskElement> {
  CCSprite *_lockedBubble;
}

@property (nonatomic, assign) BOOL isBoss;

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (CCTime) t location: (CGRect) p;
- (id) initWithDuration: (CCTime) t location: (CGRect) p;

@end
