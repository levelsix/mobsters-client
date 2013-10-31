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
    
    [Globals downloadAllFilesForSpritePrefixes:[NSArray arrayWithObject:self.prefix] completion:^{
      [self walk];
    }];
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

- (void) setIsSelected:(BOOL)isSelected {
  [self stopWalking];
  if (!isSelected) {
    [self walk];
  }
  [super setIsSelected:isSelected];
}

- (void) walk {
  MissionMap *missionMap = (MissionMap *)_map;
  CGPoint pt = [missionMap nextWalkablePositionFromPoint:self.location.origin prevPoint:_oldMapPos];
  if (CGPointEqualToPoint(self.location.origin, pt)) {
    CGRect r = self.location;
    r.origin = [missionMap randomWalkablePosition];
    self.location = r;
    _oldMapPos = r.origin;
    [self walk];
  } else {
    [self walkToTileCoord:pt withSelector:@selector(walk) speedMultiplier:1.f];
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

@synthesize ftp, numTimesActedForTask, numTimesActedForQuest, name, partOfQuest;

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    [Analytics taskViewed:ftp.taskId];
  } else {
    [Analytics taskClosed:ftp.taskId];
  }
}

- (void) setName:(NSString *)n {
  if (name != n) {
    name = n;
    _nameLabel.string = name;
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
