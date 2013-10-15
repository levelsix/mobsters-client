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
  prefix = [[prefix.lastPathComponent stringByReplacingOccurrencesOfString:prefix.pathExtension withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  if((self = [super initWithFile:nil location:loc map:map])) {
    self.prefix = @"MafiaMan";
    [self schedule:@selector(setUpAnimations)];
    
    self.sprite = [CCSprite node];
    
    // So that it registers touches
    self.contentSize = CGSizeMake(40, 70);
  }
  return self;
}

BOOL _loading = NO;

- (void) setUpAnimations {
  if (_loading) {
    return;
  }
  
  if (_curNum == 1) {
    [self unschedule:@selector(setUpAnimations)];
    return;
  }
  
  _loading = YES;
  
  CGRect loc = self.location;
  NSString *prefix = _prefix;
  
  NSString *plist = [NSString stringWithFormat:@"%@Run.plist",prefix];
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
  
  //create the animation for Near
  NSMutableArray *walkAnimN = [NSMutableArray array];
  for(int i = 0; true; i++) {
    NSString *file = [NSString stringWithFormat:@"%@RunN%02d.png",prefix, i];
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
  
  //create the animation for Far
  NSMutableArray *walkAnimF = [NSMutableArray array];
  for(int i = 0; true; i++) {
    NSString *file = [NSString stringWithFormat:@"%@RunF%02d.png",prefix, i];
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
  
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@RunN00.png",prefix]];
  [self.sprite setDisplayFrame:frame];
  [self addChild:_sprite];
  
  _oldMapPos = loc.origin;
  
  [self walk];
  
  CoordinateProto *cp = [[Globals sharedGlobals].animatingSpriteOffsets objectForKey:prefix];
  _spriteOffset = ccp(cp.x, cp.y);
  
  _curNum = 1;
  
  _loading = NO;
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
  [self.sprite stopAllActions];
  [self stopAllActions];
  _curAction = nil;
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
    _oldMapPos = self.location.origin;
    
    CGRect r = self.location;
    r.origin = pt;
    CGPoint startPt = [_map convertTilePointToCCPoint:_oldMapPos];
    CGPoint endPt = [_map convertTilePointToCCPoint:pt];
    CGFloat diff = ccpDistance(endPt, startPt);
    
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(endPt, startPt)));
    
    CCAction *nextAction = nil;
    if(angle <= -90 ){
      _sprite.flipX = NO;
      nextAction = _walkActionN;
    } else if(angle <= 0){
      _sprite.flipX = YES;
      nextAction = _walkActionN;
    } else if(angle <= 90) {
      _sprite.flipX = YES;
      nextAction = _walkActionF;
    } else if(angle <= 180){
      _sprite.flipX = NO;
      nextAction = _walkActionF;
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
                   [MoveToLocation actionWithDuration:diff/WALKING_SPEED location:r],
                   [CCCallFunc actionWithTarget:self selector:@selector(walk)],
                   nil
                   ];
    a.tag = 10;
    [self stopActionByTag:10];
    [self runAction:a];
  }
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}

@end

@implementation QuestGiver

@synthesize quest, questGiverState, name;

- (id) initWithQuest:(FullQuestProto *)fqp questGiverState:(QuestGiverState)qgs file:(NSString *)file map:(GameMap *)map location:(CGRect)location {
  // No more quest givers
  return [super init];
//  if ((self = [super initWithFile:file location:location map:map])) {
//    self.quest = fqp;
//    self.questGiverState = qgs;
//  }
//  return self;
}

- (void) setName:(NSString *)n {
  if (name != n) {
    name = n;
    _nameLabel.string = name;
  }
}

- (void) setIsSelected:(BOOL)isSelected {
//  if (isSelected) {
//    if (quest) {
//      if (questGiverState == kInProgress) {
//        [[QuestLogController sharedQuestLogController] loadQuest:quest];
//      } else if (questGiverState == kAvailable) {
//        [[ConvoMenuController sharedConvoMenuController] displayQuestConversationForQuest:self.quest];
//      } else if (questGiverState == kCompleted) {
//        [[QuestLogController sharedQuestLogController] loadQuestRedeemScreen:quest];
//      }
//    }
//    [_map setSelected:nil];
//  }
}

- (void) displayArrow {
  [super displayArrow];
  self.arrow.position = ccpAdd(self.arrow.position, ccp(0, _aboveHeadMark.contentSize.height));
}

- (void) setQuestGiverState:(QuestGiverState)i {
  questGiverState = i;
  return;
  
  [self removeChild:_aboveHeadMark cleanup:YES];
  _aboveHeadMark = nil;
  if (questGiverState == kInProgress) {
    _aboveHeadMark = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"questinprogress.png"]];
    ((CCProgressTimer *) _aboveHeadMark).type = kCCProgressTimerTypeRadial;
    [self removeArrowAnimated:YES];
  } else if (questGiverState == kAvailable) {
    _aboveHeadMark = [CCSprite spriteWithFile:@"questnew.png"];
    [self displayArrow];
  } else if (questGiverState == kCompleted) {
    _aboveHeadMark = [CCSprite spriteWithFile:@"questcomplete.png"];
    [self displayArrow];
  } else {
    [self removeArrowAnimated:YES];
  }
  
  if (_aboveHeadMark) {
    [self addChild:_aboveHeadMark];
  }
  _aboveHeadMark.anchorPoint = ccp(0.5, 0.2f);
  _aboveHeadMark.position = ccpAdd(_nameLabel.position, ccp(0, 7+_aboveHeadMark.contentSize.height*_aboveHeadMark.anchorPoint.y));
  
  if (questGiverState == kAvailable || questGiverState == kCompleted) {
    CCRotateBy *right1 = [CCRotateTo actionWithDuration:0.03f angle:3];
    CCActionInterval *left = [CCRotateTo actionWithDuration:0.06f angle:-3];
    CCRotateBy *right2 = [CCRotateTo actionWithDuration:0.03f angle:0];
    _aboveHeadMark.rotation = -3;
    CCRepeat *ring = [CCRepeat actionWithAction:[CCSequence actions:right1, left, right2, nil] times:5];
    [_aboveHeadMark runAction:[CCRepeatForever actionWithAction:
                               [CCSequence actions:
                                ring,
                                [CCDelayTime actionWithDuration:1.f],
                                nil]]];
  } else {
    CCProgressTimer *pt = (CCProgressTimer *)_aboveHeadMark;
    pt.percentage = 0;
    [_aboveHeadMark runAction:
     [CCRepeatForever actionWithAction:
      [CCSequence actions:
       [CCCallBlock actionWithBlock:
        ^{
          if (pt.percentage > 99.f) {
            pt.percentage = 0.f;
          } else {
            pt.percentage += 100.f/3;
          }
        }],
       [CCDelayTime actionWithDuration:1.f],
       nil]]];
  }
}

@end

@implementation TutorialGirl

- (id) initWithLocation:(CGRect)loc map:(GameMap *)map {
  NSString *prefix = @"TutorialGuide";
  
  if ((self = [super initWithQuest:nil questGiverState:kNoQuest file:prefix map:map location:loc])) {
    self.name = [Globals homeQuestGiverName];
  }
  return self;
}

- (void) dealloc {
  [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
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
