//
//  Building.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "GameMap.h"
#import "HomeMap.h"
#import "GameState.h"
#import "Globals.h"

#define BOUNCE_DURATION 0.1f // 1-way
#define BOUNCE_SCALE 1.1

@implementation Building

@synthesize orientation;
@synthesize verticalOffset;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:nil location:loc map:map])) {
    if (file) self.buildingSprite = [CCSprite spriteWithImageNamed:file];
    if (self.buildingSprite) [self addChild:self.buildingSprite];
    self.buildingSprite.anchorPoint = ccp(0.5,0);
    self.buildingSprite.position = ccp(self.buildingSprite.contentSize.width/2, 0);
    
    CCSprite *shadow = [CCSprite spriteWithImageNamed:@"3x3base.png"];
    [self addChild:shadow z:-1 name:SHADOW_TAG];
    shadow.anchorPoint = ccp(0.5, 0);
    
    self.contentSize = self.buildingSprite.contentSize;
    
    self.baseScale = 1.f;
  }
  return self;
}

- (void) setContentSize:(CGSize)contentSize {
  [super setContentSize:contentSize];
  [[self getChildByName:SHADOW_TAG recursively:NO] setPosition:ccp(self.contentSize.width/2, 3)];
}

- (void) setBaseScale:(float)baseScale {
  _baseScale = baseScale;
  self.buildingSprite.scale = baseScale;
}

- (void) setColor:(CCColor *)color {
  [super setColor:color];
  [self.buildingSprite setColor:color];
}

- (BOOL) select {
  BOOL select = [super select];
  
  [self.buildingSprite stopActionByTag:BOUNCE_ACTION_TAG];
  CCActionScaleTo *scaleBig = [CCActionScaleTo actionWithDuration:BOUNCE_DURATION scale:BOUNCE_SCALE*self.baseScale];
  CCActionScaleTo *scaleBack = [CCActionScaleTo actionWithDuration:BOUNCE_DURATION scale:self.baseScale];
  CCAction *bounce = [CCActionEaseInOut actionWithAction:[CCActionSequence actions:scaleBig, scaleBack, nil]];
  bounce.tag = BOUNCE_ACTION_TAG;
  [self.buildingSprite runAction:bounce];
  
  return select;
}

- (void) setOrientation:(StructOrientation)o {
  orientation = o;
  switch (orientation) {
    case StructOrientationPosition1:
      self.buildingSprite.flipX = NO;
      break;
      
    case StructOrientationPosition2:
      self.buildingSprite.flipX = YES;
      break;
      
    default:
      break;
  }
}

- (void) setLocation:(CGRect)location {
  [super setLocation:location];
  self.position = ccpAdd(self.position, ccp(0,self.verticalOffset));
}

- (void) setVerticalOffset:(float)v {
  if (v != verticalOffset) {
    verticalOffset = v;
    self.location = self.location;
  }
}

- (void) displayProgressBar {
  if (![self getChildByName:UPGRADING_TAG recursively:NO]) {
    UpgradeProgressBar *upgrIcon = [[UpgradeProgressBar alloc] initBar];
    [self addChild:upgrIcon z:5 name:UPGRADING_TAG];
    upgrIcon.position = ccp(self.contentSize.width/2, self.contentSize.height);
    [self schedule:@selector(updateUpgradeBar) interval:1.f];
  }
  _percentage = 0;
  [self updateUpgradeBar];
}

- (void) updateUpgradeBar {
  
}

- (void) removeProgressBar {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n) {
    [n removeFromParent];
    [self unschedule:@selector(updateUpgradeBar)];
  }
}

- (void) instaFinishUpgradeWithCompletionBlock:(void(^)(void))completed {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *u = (UpgradeProgressBar *)n;
    [self unschedule:@selector(updateUpgradeBar)];
    
    float interval = 1;
    float timestep = 0.02;
    _percentage = u.progressBar.percentage;
    int numTimes = (100-_percentage)/interval;
    CCActionCallBlock *b = [CCActionCallBlock actionWithBlock:^{
      _percentage += interval;
      [self updateUpgradeBar];
    }];
    CCActionSequence *cycle = [CCActionSequence actions:b, [CCActionDelay actionWithDuration:timestep], nil];
    CCActionRepeat *r = [CCActionRepeat actionWithAction:cycle times:numTimes];
    [u runAction:
     [CCActionSequence actions:
      r,
      [CCActionCallBlock actionWithBlock:
       ^{
         _percentage = 100;
         [self updateUpgradeBar];
         
         [self removeProgressBar];
         if (completed) {
           completed();
         }
       }],
      nil]];
  }
}

@end

@implementation MissionBuilding

@synthesize isLocked = _isLocked, ftp = _ftp;

- (BOOL) select {
  if (self.isLocked) {
    if (!_lockedBubble.numberOfRunningActions) {
      CCActionInterval *mov = [CCActionRotateBy actionWithDuration:0.04f angle:15];
      [_lockedBubble runAction:[CCActionRepeat actionWithAction:[CCActionSequence actions:mov.copy, mov.reverse, mov.reverse, mov.copy, nil]
                                                    times:3]];
    }
    return NO;
  } else {
    return [super select];
  }
}

- (void) setIsLocked:(BOOL)isLocked {
  _isLocked = isLocked;
  if (isLocked) {
    if (_lockedBubble) {
      // Make sure to cleanup just in case
      [self removeChild:_lockedBubble cleanup:YES];
    }
    _lockedBubble = [CCSprite spriteWithImageNamed:@"lockedup.png"];
    [self addChild:_lockedBubble];
    _lockedBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET-_lockedBubble.contentSize.height/2);
    _lockedBubble.anchorPoint = ccp(0.5, 0);
    
    int amt = 150;
    self.color = [CCColor colorWithCcColor3b:ccc3(amt, amt, amt)];
  } else {
    if (_lockedBubble) {
      // Make sure to cleanup just in case
      [self removeChild:_lockedBubble cleanup:YES];
    }
    self.color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
  }
}

@end