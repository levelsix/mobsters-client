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

@interface AnimatedSprite : CharacterSprite
{
  CCAction *_curAction;
  
  CGPoint _spriteOffset;
  CGPoint _oldMapPos;
  BOOL _moving;
}

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCAction *walkActionN;
@property (nonatomic, retain) CCAction *walkActionF;

@property (nonatomic, retain) NSString *prefix;

- (void) walk;
- (void) stopWalking;
- (void) walkToTileCoord:(CGPoint)tileCoord withSelector:(SEL)completion speedMultiplier:(float)speedMultiplier;
- (void) restoreStandingFrame:(BOOL)facingLeft;

@end

@interface NeutralEnemy : AnimatedSprite <TaskElement> {
  CCSprite *_lockedBubble;
}

@end

@interface MoveToLocation : CCActionInterval <NSCopying> {
  CGRect startLocation_;
  CGRect endLocation_;
  CGPoint delta_;
}

+ (id) actionWithDuration: (CCTime) t location: (CGRect) p;
- (id) initWithDuration: (CCTime) t location: (CGRect) p;

@end
