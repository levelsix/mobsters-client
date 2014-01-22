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
    self = [super initWithFile:file];
  } else {
    self = [super init];
  }
  if (self) {
    _map = map;
    self.location = loc;
    self.anchorPoint = ccp(loc.size.height/(loc.size.height+loc.size.width), 0);
  }
  return self;
}

- (BOOL) isExemptFromReorder {
  return NO;
}

- (void) setLocation:(CGRect)location {
  CGSize ms = _map.mapSize;
  location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
  location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
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
  CCTintBy *tint = [RecursiveTintTo actionWithDuration:GLOW_DURATION red:amt green:amt blue:amt];
  CCTintBy *tintBack = [RecursiveTintTo actionWithDuration:GLOW_DURATION red:255 green:255 blue:255];
  CCAction *action = [CCRepeatForever actionWithAction:[CCSequence actions:tint, tintBack, nil]];
  action.tag = GLOW_ACTION_TAG;
  [self runAction:action];
  return YES;
}

- (void) unselect {
  _isSelected = NO;
  [self stopActionByTag:GLOW_ACTION_TAG];
  [self recursivelyApplyColor:ccc3(255, 255, 255)];
}

- (void) displayArrow {
  [self removeArrowAnimated:NO];
  _arrow = [CCSprite spriteWithFile:@"3darrow.png"];
  [self addChild:_arrow];
  
  _arrow.anchorPoint = ccp(0.5f, 0.f);
  _arrow.position = ccp(self.contentSize.width/2, self.contentSize.height+5.f);
  
  CCSpawn *down = [CCSpawn actions:
                   [CCEaseSineInOut actionWithAction:[CCScaleBy actionWithDuration:0.7f scaleX:1.f scaleY:0.88f]],
                   [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:0.7f position:ccp(0.f, -5.f)]],
                   nil];
  CCActionInterval *up = [down reverse];
  [_arrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:down, up, nil]]];
}

- (void) removeArrowAnimated:(BOOL)animated {
  if (_arrow) {
    if (!animated) {
      [_arrow removeFromParentAndCleanup:YES];
      _arrow = nil;
    } else {
      [_arrow runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2f], [CCCallBlock actionWithBlock:^{
        [_arrow removeFromParentAndCleanup:YES];
        _arrow = nil;
      }], nil]];
    }
  }
}

- (void) displayCheck {
  CCSprite *check = [CCSprite spriteWithFile:@"3dcheckmark.png"];
  [self addChild:check];
  check.anchorPoint = ccp(0.5, 0.f);
  check.position = ccp(self.contentSize.width/2, self.contentSize.height+5.f);
  
  [check runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:1.5f],
                    [CCSpawn actions:
                     [CCMoveBy actionWithDuration:1.5f position:ccp(0, 20.f)],
                     [CCFadeOut actionWithDuration:1.5f],
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