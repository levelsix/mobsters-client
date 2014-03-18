//
//  AnimatedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"
#import "MissionMap.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "GameState.h"
#import "Globals.h"
#import "CCAnimation+SpriteLoading.h"
#import "SoundEngine.h"

@implementation CharacterSprite


@synthesize nameLabel = _nameLabel;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _nameLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:[Globals fontSize]];
    [self addChild:_nameLabel z:1];
    _nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    _nameLabel.color = [CCColor colorWithCcColor3b:ccc3(255,200,0)];
  }
  return self;
}

- (void) displayArrow {
  [super displayArrow];
  self.arrow.position = ccpAdd(self.arrow.position, ccp(0, 10.f));
}

- (void) setOpacity:(CGFloat)opacity {
  [super setOpacity:opacity];
  _nameLabel.opacity = opacity;
}

- (void) setLocation:(CGRect)location {
  [super setLocation:location];
  self.position = ccpAdd(self.position, ccp(0, VERTICAL_OFFSET));
}

@end

@implementation AnimatedSprite

-(id) initWithFile:(NSString *)prefix location:(CGRect)loc map:(GameMap *)map {
  if((self = [super initWithFile:nil location:loc map:map])) {
    self.prefix = prefix.stringByDeletingPathExtension;
    
    // So that it registers touches
    self.contentSize = CGSizeMake(40, 55);
    
    self.sprite = [CCSprite node];
    [self addChild:self.sprite];
    self.sprite.position = ccp(self.contentSize.width/2, self.contentSize.height/2-3);
    
    CCSprite *s = [CCSprite spriteWithImageNamed:@"shadow.png"];
    [self addChild:s z:-1 name:SHADOW_TAG];
    s.position = ccp(self.contentSize.width/2, 0);
    
    [self walk];
  }
  return self;
}

- (CCAction *) walkActionN {
  if (!_walkActionN) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunN", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionN = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
  }
  return _walkActionN;
}

- (CCAction *) walkActionF {
  if (!_walkActionF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunF", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionF = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]];
  }
  return _walkActionF;
}

- (void) restoreStandingFrame {
  [self restoreStandingFrame:MapDirectionNearRight];
}

- (void) restoreStandingFrame:(MapDirection)direction {
  [self stopWalking];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", self.prefix]];
  NSString *name;
  if (direction == MapDirectionFront) name = [NSString stringWithFormat:@"%@StayN00.png", self.prefix];
  else name = [NSString stringWithFormat:@"%@Attack%@00.png", self.prefix, (direction == MapDirectionFarRight || direction == MapDirectionFarLeft) ? @"F" : @"N"];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
  [self.sprite setSpriteFrame:frame];
  
  self.sprite.flipX = (direction == MapDirectionFarRight || direction == MapDirectionNearRight);
}

- (void) setColor:(CCColor *)color {
  [super setColor:color];
  [self.sprite setColor:color];
}

- (void) setContentSize:(CGSize)contentSize {
  [super setContentSize:contentSize];
  
  self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), _spriteOffset);
  
  self.nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
}

- (void) setOpacity:(CGFloat)opacity {
  [super setOpacity:opacity];
  [self.sprite setOpacity:opacity];
}

- (BOOL) select {
  BOOL select = [super select];
  [self stopWalking];
  return select;
}

- (void) unselect {
  [self walk];
  [super unselect];
}

- (void) walk {
  [self stopWalking];
  if (self.prefix) {
    _shouldWalk = YES;
    [Globals downloadAllFilesForSpritePrefixes:[NSArray arrayWithObject:self.prefix] completion:^{
      if (_shouldWalk) {
        [self walkAfterCheck];
      }
    }];
  }
}

- (void) walkAfterCheck {
  if (!_map || !_shouldWalk) {
    [self restoreStandingFrame];
    return;
  }
  
  MissionMap *missionMap = (MissionMap *)_map;
  CGPoint pt = [missionMap nextWalkablePositionFromPoint:self.location.origin prevPoint:_oldMapPos];
  if (CGPointEqualToPoint(self.location.origin, pt)) {
    CGRect r = self.location;
    r.origin = [missionMap randomWalkablePosition];
    self.location = r;
    _oldMapPos = r.origin;
    [self walkAfterCheck];
  } else {
    [self walkToTileCoord:pt completionTarget:self selector:@selector(walkAfterCheck) speedMultiplier:1.f];
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void) walkToTileCoord:(CGPoint)tileCoord completionTarget:(id)target selector:(SEL)completion speedMultiplier:(float)speedMultiplier {
  [self walkToTileCoord:tileCoord completion:^{
    [target performSelector:completion withObject:self];
  } speedMultiplier:speedMultiplier];
}

- (void) walkToTileCoords:(NSArray *)tileCoords completionTarget:(id)target selector:(SEL)completion speedMultiplier:(float)speedMultiplier {
  if (tileCoords.count > 0) {
    CGPoint tileCoord = [tileCoords[0] CGPointValue];
    [self walkToTileCoord:tileCoord completion:^{
      [self walkToTileCoords:[tileCoords subarrayWithRange:NSMakeRange(1, tileCoords.count-1)] completionTarget:target selector:completion speedMultiplier:speedMultiplier];
    } speedMultiplier:speedMultiplier];
  } else {
    [target performSelector:completion withObject:self];
  }
}
#pragma clang diagnostic pop

- (void) walkToTileCoord:(CGPoint)tileCoord completion:(void (^)(void))completion speedMultiplier:(float)speedMultiplier {
  _oldMapPos = self.location.origin;
  
  CGRect r = self.location;
  r.origin = tileCoord;
  CGPoint startPt = [_map convertTilePointToCCPoint:_oldMapPos];
  CGPoint endPt = [_map convertTilePointToCCPoint:tileCoord];
  CGFloat diff = ccpDistance(endPt, startPt);
  
  float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
  
  CCActionRepeatForever *nextAction = nil;
  if(angle <= -90 ){
    _sprite.flipX = NO;
    nextAction = self.walkActionN;
  } else if(angle <= 0){
    _sprite.flipX = YES;
    nextAction = self.walkActionN;
  } else if(angle <= 90) {
    _sprite.flipX = YES;
    nextAction = self.walkActionF;
  } else if(angle <= 180){
    _sprite.flipX = NO;
    nextAction = self.walkActionF;
  } else {
    LNLog(@"No Action");
  }
  
  
  if (_curAction != nextAction) {
    if (_curAction) {
      [self.sprite stopAction:_curAction];
    }
    _curAction = nextAction;
    if (_curAction) {
      CCActionAnimate *anim = ((CCActionAnimate *)_curAction.innerAction);
      if (anim.animation.frames.count > 0) {
        [_sprite setSpriteFrame:[anim.animation.frames[0] spriteFrame]];
        [_sprite runAction:_curAction];
      }
    }
  }
  
  CCAction *a = [CCActionSequence actions:
                 [MoveToLocation actionWithDuration:diff/WALKING_SPEED/speedMultiplier location:r],
                 [CCActionCallBlock actionWithBlock:completion],
                 nil];
  [self stopActionByTag:10];
  a.tag = 10;
  [self runAction:a];
}

- (void) jumpNumTimes:(int)numTimes completionTarget:(id)target selector:(SEL)completion {
  [self jumpNumTimes:numTimes timePerJump:0.25 completionTarget:target selector:completion];
}

- (void) jumpNumTimes:(int)numTimes timePerJump:(float)dur completionTarget:(id)target selector:(SEL)completion {
  CCActionJumpBy *jump = [CCActionJumpBy actionWithDuration:dur*numTimes position:ccp(0,0) height:14 jumps:numTimes];
  [self.sprite runAction:[CCActionSequence actions:jump,
                          [CCActionCallFunc actionWithTarget:target selector:completion], nil]];
  
  CCSprite *spr = (CCSprite *)[self getChildByName:SHADOW_TAG recursively:NO];
  [spr runAction:
   [CCActionRepeat actionWithAction:
    [CCActionSequence actions:
     [CCActionCallBlock actionWithBlock:
      ^{
        [SoundEngine spriteJump];
      }],
     [CCActionScaleTo actionWithDuration:dur/2.f scale:0.9],
     [CCActionScaleTo actionWithDuration:dur/2.f scale:1.f],
     nil]
                              times:numTimes]];
}

- (void) stopWalking {
  if (_curAction) {
    [self.sprite stopAction:_curAction];
  }
  [self stopActionByTag:10];
  _curAction = nil;
  _shouldWalk = NO;
}

@end

@implementation NeutralEnemy

@synthesize isLocked = _isLocked, ftp = _ftp;

- (BOOL) select {
  if (self.isLocked) {
    if (!_lockedBubble.numberOfRunningActions) {
      CCActionInterval *mov = [CCActionRotateBy actionWithDuration:0.04f angle:15];
      [_lockedBubble runAction:[CCActionRepeat actionWithAction:[CCActionSequence actions:mov.copy, mov.reverse, mov.reverse, mov.copy, nil] times:3]];
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
      [_lockedBubble removeFromParent];
    }
    _lockedBubble = [CCSprite spriteWithImageNamed:@"bosslock.png"];
    [self addChild:_lockedBubble];
    _lockedBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-5);
    _lockedBubble.anchorPoint = ccp(0.5, 0);
    
    int amt = 150;
    self.color = [CCColor colorWithCcColor3b:ccc3(amt, amt, amt)];
  } else {
    if (_lockedBubble) {
      // Make sure to cleanup just in case
      [_lockedBubble removeFromParent];
    }
    self.color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
  }
}

@end

@implementation MoveToLocation

+(id) actionWithDuration: (CCTime) t location: (CGRect) p
{
  return [[self alloc] initWithDuration:t location:p];
}

-(id) initWithDuration: (CCTime) t location: (CGRect) p
{
  if( (self=[super initWithDuration: t]) )
    endLocation_ = p;
  
  return self;
}

-(id) copyWithZone: (NSZone*) zone
{
  CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] location:endLocation_];
  return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
  [super startWithTarget:aTarget];
  startLocation_ = [(MapSprite*)_target location];
  delta_ = ccpSub( endLocation_.origin, startLocation_.origin );
}

-(void) update: (CCTime) t
{
  CGRect r = startLocation_;
  r.origin.x = (startLocation_.origin.x + delta_.x * t );
  r.origin.y = (startLocation_.origin.y + delta_.y * t );
  [(MapSprite *)_target setLocation: r];
}

@end
