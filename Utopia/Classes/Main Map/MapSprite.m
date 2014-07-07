//
//  MapSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapSprite.h"
#import "GameMap.h"
#import "Globals.h"

#define GLOW_DURATION 0.6f

@implementation MapSprite

@synthesize location = _location;

- (id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map {
  if (file) {
    self = [super initWithImageNamed:file];
  } else {
    self = [super init];
  }
  if (self) {
    _map = map;
    self.location = loc;
    self.anchorPoint = ccp(loc.size.height/(loc.size.height+loc.size.width), 0);
    self.constrainedToBoundary = YES;
  }
  return self;
}

- (BOOL) isExemptFromReorder {
  return NO;
}

- (void) setLocation:(CGRect)location {
  if (self.constrainedToBoundary) {
    CGSize ms = _map.mapSize;
    location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
    location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
  }
  _location = location;
  self.position = [_map convertTilePointToCCPoint:location.origin];
  
  [_map doReorder];
}

@end

@implementation SelectableSprite

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map{
  if ((self = [super initWithFile:file location:loc map:map])) {
    _isSelected = NO;
  }
  return self;
}

- (BOOL) select {
  [self unselect];
  _isSelected = YES;
  int amt = 135;
  CCActionTintTo *tint = [CCActionTintTo actionWithDuration:GLOW_DURATION color:[CCColor colorWithCcColor3b:ccc3(amt, amt, amt)]];
  CCActionTintTo *tintBack = [CCActionTintTo actionWithDuration:GLOW_DURATION color:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
  CCAction *action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:tint, tintBack, nil]];
  action.tag = GLOW_ACTION_TAG;
  [self runAction:action];
  return YES;
}

- (void) unselect {
  _isSelected = NO;
  [self stopActionByTag:GLOW_ACTION_TAG];
  [self recursivelyApplyColor:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
}

- (void) displayArrow {
  [self removeArrowAnimated:NO];
  _arrow = [CCSprite spriteWithImageNamed:@"arrow.png"];
  [self addChild:_arrow];
  
  _arrow.anchorPoint = ccp(0.5f, 0.f);
  _arrow.position = ccp(self.contentSize.width/2, self.contentSize.height+5.f);
  
  [Globals animateCCArrow:_arrow atAngle:-M_PI_2];
}

- (void) removeArrowAnimated:(BOOL)animated {
  if (_arrow) {
    if (!animated) {
      [_arrow removeFromParentAndCleanup:YES];
      _arrow = nil;
    } else {
      [_arrow runAction:[CCActionSequence actions:[CCActionFadeOut actionWithDuration:0.2f], [CCActionCallBlock actionWithBlock:^{
        [_arrow removeFromParentAndCleanup:YES];
        _arrow = nil;
      }], nil]];
    }
  }
}

- (void) displayCheck {
  CCSprite *check = [CCSprite spriteWithImageNamed:@"3dcheckmark.png"];
  [self addChild:check];
  check.anchorPoint = ccp(0.5, 0.f);
  check.position = ccp(self.contentSize.width/2, self.contentSize.height+5.f);
  
  [check runAction:[CCActionSequence actions:
                    [CCActionDelay actionWithDuration:1.5f],
                    [CCActionSpawn actions:
                     [CCActionMoveBy actionWithDuration:1.5f position:ccp(0, 20.f)],
                     [CCActionFadeOut actionWithDuration:1.5f],
                     nil],
                    nil]];
  
  if (_arrow) {
    [self removeArrowAnimated:YES];
  }
}

-(NSString *) description {
  return [NSString stringWithFormat:@"%@: %@", [super description], NSStringFromCGRect(self.location)];
}

@end