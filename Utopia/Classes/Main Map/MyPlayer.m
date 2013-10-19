//
//  MyPlayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MyPlayer.h"
#import "GameState.h"
#import "Globals.h"
#import "SoundEngine.h"
#import "AnimatedSprite.h"
#import "CCAnimation+SpriteLoading.h"

@implementation MyPlayer

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:nil location:loc map:map])) {
    NSString *prefix = @"Rapper1AK";
    
//    [self schedule:@selector(incrementalLoad) interval:0.1f];
    
    // Create sprite
    self.contentSize = CGSizeMake(40, 70);
    
    self.sprite = [CCSprite node];
    
    CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
    self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(cp.x, cp.y+5));
    
    [self addChild:_sprite z:5 tag:9999];
    
    CCSprite *s = [CCSprite spriteWithFile:@"shadow.png"];
    [self addChild:s];
    s.position = ccp(self.contentSize.width/2, 10);
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Rapper1AKRunNF.plist"];
    [self setUpAnimations:prefix];
  }
  return self;
}

- (void) incrementalLoad {
  if (_isDownloading) {
    return;
  }
  _isDownloading = YES;
  switch (_incrementalLoadCounter) {
    case 0:
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Rapper1AKRunNF.plist"];
      break;
      
    case 1:
      [self setUpAnimations:@"Rapper1AK"];
      break;
      
    case 2:
      [self unschedule:@selector(incrementalLoad)];
      
    default:
      break;
  }
  _incrementalLoadCounter++;
  _isDownloading = NO;
}

- (void) setUpAnimations:(NSString *)prefix {
  //Creating animation for Near
  NSMutableArray *walkAnimN= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    NSString *file = [NSString stringWithFormat:@"Rapper1AKRunN%02d.png", i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      [walkAnimN addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationN = [CCAnimation animationWithSpriteFrames:walkAnimN delay:ANIMATATION_DELAY];
  walkAnimationN.restoreOriginalFrame = NO;
  self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN]];
  
  //Creating animation for far
  NSMutableArray *walkAnimF= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    NSString *file = [NSString stringWithFormat:@"Rapper1AKRunF%02d.png", i];
    BOOL exists = [[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file];
    if (exists) {
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
      [walkAnimF addObject:frame];
    } else {
      break;
    }
  }
  CCAnimation *walkAnimationF = [CCAnimation animationWithSpriteFrames:walkAnimF delay:ANIMATATION_DELAY];
  walkAnimationF.restoreOriginalFrame = NO;
  self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF]];
  
  NSString *name1 = @"Rapper1AKRunN00.png";
  CCSpriteFrame *frame = nil;
  if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:name1]) {
    frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name1];
  }
  
  if (frame) {
    [self.sprite setDisplayFrame:frame];
  }
}

- (void) performAttackAnimation {
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Rapper1AKAttackNF.plist"];
  
  //create animation for left and right
  NSMutableArray *agArray = [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Rapper1AKAttackF%02d.png", i]];
    if (frame) {
      [agArray addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *anim = [CCAnimation animationWithSpriteFrames:agArray delay:ANIMATATION_DELAY];
  anim.restoreOriginalFrame = NO;
  [self.sprite runAction:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:anim] times:3]];
}

- (void) stopWalking {
  [self stopAllActions];
  [self.sprite stopAllActions];
}

- (void) stopPerformingAnimation {
  _shouldContinueAnimation = NO;
}

- (void) moveToLocation:(CGRect)loc {
  NSString *prefix = @"Rapper1AK";
  
  CGPoint startPt = [_map convertTilePointToCCPoint:self.location.origin];
  CGPoint endPt = [_map convertTilePointToCCPoint:loc.origin];
  CGFloat distance = ccpDistance(endPt, startPt);
  float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
  
  int boolValue = 0;
  
  if (loc.origin.x < _map.walkableData.count) {
    NSArray *a = [_map.walkableData objectAtIndex:loc.origin.x];
    if (loc.origin.y < a.count) {
      boolValue = [[a objectAtIndex:loc.origin.y] boolValue];
    }
  }
  
  if(boolValue == 0){
    return;
  }
  
  if(distance <=100){
    CCAction *newAction = nil;
    
    if (angle <= 180 && angle >= 90) {
      self.sprite.flipX = NO;
      newAction = self.walkActionF;
    } else if (angle >= 0) {
      self.sprite.flipX = YES;
      newAction = self.walkActionF;
    } else if (angle >= -90) {
      self.sprite.flipX = YES;
      newAction = self.walkActionN;
    } else {
      self.sprite.flipX = NO;
      newAction = self.walkActionN;
    }
    
    if (!newAction) {
      return;
    }
    
    if (self.currentAction != newAction) {
      // Only restart animation if it is different from the current one
      self.currentAction = newAction;
      [self.sprite stopAllActions];
      [self.sprite runAction:self.currentAction];
    }
    
    [self stopAllActions];
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:distance/MY_WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist",prefix]];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@RunN00.png",prefix]];
      [self.sprite setDisplayFrame:frame];
      self.currentAction = nil;
    }], nil]];
    
  } else {
    CGRect startingLocation = CGRectMake(loc.origin.x-2, loc.origin.y-2,loc.size.width,loc.size.height);
    int num = [[[_map.walkableData objectAtIndex:startingLocation.origin.x]objectAtIndex:startingLocation.origin.y]boolValue];
    if(num == 0){
      startingLocation= CGRectMake(loc.origin.x-1, loc.origin.y-1,loc.size.width,loc.size.height);
      int temp = [[[_map.walkableData objectAtIndex:startingLocation.origin.x]objectAtIndex:startingLocation.origin.y]boolValue];
      if(temp == 0){
        startingLocation = CGRectMake(loc.origin.x, loc.origin.y,loc.size.width,loc.size.height);
      }
    }
    CGRect startingPosition = startingLocation;
    
    if (!self.walkActionF) {
      return;
    }
    
    [self setLocation:startingPosition];
    [self.sprite stopAllActions];
    [self stopAllActions];
    [self.sprite runAction:self.walkActionF];
    
    float dist = ccpDistance([_map convertTilePointToCCPoint:startingPosition.origin], [_map convertTilePointToCCPoint:loc.origin]);
    [self runAction:[CCSequence actions:[MoveToLocation actionWithDuration:dist/MY_WALKING_SPEED location:loc], [CCCallBlock actionWithBlock:^{
      [self.sprite stopAllActions];
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist",prefix]];
      CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@RunN00.png",prefix]];
      [self.sprite setDisplayFrame:frame];
    }], nil]];
  }
}

@end