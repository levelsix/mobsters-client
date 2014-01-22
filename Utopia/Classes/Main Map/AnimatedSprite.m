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

@implementation CharacterSprite


@synthesize nameLabel = _nameLabel;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _nameLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:[Globals fontSize]];
    [self addChild:_nameLabel z:1];
    _nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
    _nameLabel.color = ccc3(255,200,0);
  }
  return self;
}

- (void) displayArrow {
  [super displayArrow];
  self.arrow.position = ccpAdd(self.arrow.position, ccp(0, 10.f));
}

- (void) setOpacity:(GLubyte)opacity {
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
    
    CCSprite *s = [CCSprite spriteWithFile:@"shadow.png"];
    [self addChild:s z:-1];
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
    self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
  }
  return _walkActionN;
}

- (CCAction *) walkActionF {
  if (!_walkActionF) {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@RunNF.plist", self.prefix]];
    NSString *p = [NSString stringWithFormat:@"%@RunF", self.prefix];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:p delay:ANIMATATION_DELAY];
    self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]];
  }
  return _walkActionF;
}

- (void) restoreStandingFrame:(BOOL)facingLeft {
  [self stopWalking];
  [self walkActionN];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@RunN00.png", self.prefix]];
  [self.sprite setDisplayFrame:frame];
  
  self.sprite.flipX = facingLeft;
}

- (void) setColor:(ccColor3B)color {
  [super setColor:color];
  [self.sprite setColor:color];
}

- (void) setContentSize:(CGSize)contentSize {
  [super setContentSize:contentSize];
  
  self.sprite.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), _spriteOffset);
  
  self.nameLabel.position = ccp(self.contentSize.width/2, self.contentSize.height+3);
}

- (void) setOpacity:(GLubyte)opacity {
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
  if (self.prefix) {
    [Globals downloadAllFilesForSpritePrefixes:[NSArray arrayWithObject:self.prefix] completion:^{
      [self walkAfterCheck];
    }];
  }
}

- (void) walkAfterCheck {
  if (!_map) {
    [self restoreStandingFrame:NO];
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
    [self walkToTileCoord:pt withSelector:@selector(walkAfterCheck) speedMultiplier:1.f];
  }
}

- (void) walkToTileCoord:(CGPoint)tileCoord withSelector:(SEL)completion speedMultiplier:(float)speedMultiplier {
  _oldMapPos = self.location.origin;
  
  CGRect r = self.location;
  r.origin = tileCoord;
  CGPoint startPt = [_map convertTilePointToCCPoint:_oldMapPos];
  CGPoint endPt = [_map convertTilePointToCCPoint:tileCoord];
  CGFloat diff = ccpDistance(endPt, startPt);
  
  float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
  
  CCAction *nextAction = nil;
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
    _curAction = nextAction;
    [_sprite stopAllActions];
    if (_curAction) {
      [_sprite runAction:_curAction];
    }
  }
  
  CCAction *a = [CCSequence actions:
                 [MoveToLocation actionWithDuration:diff/WALKING_SPEED/speedMultiplier location:r],
                 [CCCallFunc actionWithTarget:self selector:completion],
                 nil
                 ];
  a.tag = 10;
  [self stopActionByTag:10];
  [self runAction:a];
}

- (void) stopWalking {
  [self.sprite stopAllActions];
  [self stopAllActions];
  _curAction = nil;
}

@end

@implementation NeutralEnemy

@synthesize isLocked = _isLocked, name = _name, ftp = _ftp;

- (BOOL) select {
  if (self.isLocked) {
    if (!_lockedBubble.numberOfRunningActions) {
      CCActionInterval *mov = [CCRotateBy actionWithDuration:0.04f angle:15];
      [_lockedBubble runAction:[CCRepeat actionWithAction:[CCSequence actions:mov.copy, mov.reverse, mov.reverse, mov.copy, nil]
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
    _lockedBubble = [CCSprite spriteWithFile:@"bosslock.png"];
    [self addChild:_lockedBubble];
    _lockedBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-5);
    _lockedBubble.anchorPoint = ccp(0.5, 0);
    
    int amt = 150;
    self.color = ccc3(amt, amt, amt);
  } else {
    if (_lockedBubble) {
      // Make sure to cleanup just in case
      [self removeChild:_lockedBubble cleanup:YES];
    }
    self.color = ccc3(255, 255, 255);
  }
}

@end

@implementation MoveToLocation

+(id) actionWithDuration: (ccTime) t location: (CGRect) p
{
  return [[self alloc] initWithDuration:t location:p];
}

-(id) initWithDuration: (ccTime) t location: (CGRect) p
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

-(void) update: (ccTime) t
{
  CGRect r = startLocation_;
  r.origin.x = (startLocation_.origin.x + delta_.x * t );
  r.origin.y = (startLocation_.origin.y + delta_.y * t );
  [(MapSprite *)_target setLocation: r];
}

@end
