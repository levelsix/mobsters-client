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
#import "SoundEngine.h"
#import "BuildingButton.h"

#define BOUNCE_DURATION 0.1f // 1-way
#define BOUNCE_SCALE 1.1
#define BUILDING_BUTTONS_ANIM_TIME_IN .15f
#define BUILDING_BUTTONS_ANIM_TIME_OUT .1f
#define BUILDING_BUTTONS_ANIM_DELAY .05f
#define BUILDING_BUTTONS_ANIM_OFFSET 50.f

@implementation Building

@synthesize orientation;

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(GameMap *)map {
  if ((self = [super initWithFile:nil location:loc map:map])) {
    self.baseScale = 1.f;
    if (file) [self setupBuildingSprite:file];
    
    _greenSign = [[UpgradeSign alloc] initWithGreen:YES];
    _greenSign.anchorPoint = ccp(0.5, 0);
    [self addChild:_greenSign z:1];
    _greenSign.visible = NO;
    
    _redSign = [[UpgradeSign alloc] initWithGreen:NO];
    _redSign.anchorPoint = ccp(0.5, 0);
    [self addChild:_redSign z:1];
    _redSign.visible = NO;
    
    _bubble = [[BuildingBubble alloc] init];
    [self addChild:_bubble z:5];
    _bubble.anchorPoint = ccp(0.5, 0);
    _bubble.type = BuildingBubbleTypeNone;
  }
  return self;
}

- (void) setContentSize:(CGSize)contentSize {
  [super setContentSize:contentSize];
  [[self getChildByName:SHADOW_TAG recursively:NO] setPosition:ccp(self.contentSize.width/2, 1)];
}

- (void) setBaseScale:(float)baseScale {
  _baseScale = baseScale;
  [self adjustBuildingSprite];
}

- (void) setColor:(CCColor *)color {
  [super setColor:color];
  [self.buildingSprite recursivelyApplyColor:color];
}

- (BOOL) select {
  BOOL select = [super select];
  
  [self.buildingSprite stopActionByTag:BOUNCE_ACTION_TAG];
  CCActionScaleTo *scaleBig = [CCActionScaleTo actionWithDuration:BOUNCE_DURATION scale:BOUNCE_SCALE*self.baseScale];
  CCActionScaleTo *scaleBack = [CCActionScaleTo actionWithDuration:BOUNCE_DURATION scale:self.baseScale];
  CCActionInterval *bounce = [CCActionSequence actions:scaleBig, scaleBack, nil];
  bounce = [CCActionEaseInOut actionWithAction:bounce];
  bounce.tag = BOUNCE_ACTION_TAG;
  [self.buildingSprite runAction:bounce];
  
  [self removeBubble];
  
  [SoundEngine structSelected];
  
  return select;
}

- (void) unselect {
  [super unselect];
  
  [self displayBubble];
}

- (void) displayArrowWithPulsingAlpha:(BOOL)pulse {
  [super displayArrowWithPulsingAlpha:pulse];
  if(pulse) {
    [self pulseBubbleAlpha];
  } else {
    [self removeBubble];
  }
}

- (void) removeArrowAnimated:(BOOL)animated {
  [super removeArrowAnimated:animated];
  
  if (_bubble) {
    [self displayBubble];
  }
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

- (void) adjustBuildingSprite {
  self.buildingSprite.anchorPoint = ccp(0.5,0);
  self.buildingSprite.scale = self.baseScale;
  
  float width = (self.location.size.width+self.location.size.height)/2*_map.tileSize.width;
  //  float height = MAX((self.location.size.width+self.location.size.height)/2*_map.tileSizeInPoints.height,
  
  // Use default of 50 height if buildingSprite hasn't been loaded yet.
  float buildingHeight = _buildingSprite.contentSize.height ?: 50.f;
  float height = self.verticalOffset+buildingHeight*self.baseScale;
  self.contentSize = CGSizeMake(width, height);
  self.buildingSprite.position = ccp(self.contentSize.width/2+self.horizontalOffset, self.verticalOffset);
  self.orientation = self.orientation;
  
  _bubble.position = ccp(self.contentSize.width/2,self.contentSize.height+0.f);
  _greenSign.position = ccp(self.contentSize.width/2,1.f);
  _redSign.position = ccp(self.contentSize.width/2,1.f);

  if (self.progressBar) {
    // Redisplay progress bar
    [self displayProgressBar];
  }
}

- (void) setupBuildingSprite:(NSString *)fileName {
  if (self.buildingSprite) {
    [self.buildingSprite removeFromParent];
    self.buildingSprite = nil;
  }
  if (fileName) {
    self.buildingSprite = [CCSprite node];
    if (self.buildingSprite) [self addChild:self.buildingSprite];
    
    __block BOOL didAdjust = NO;
    [Globals imageNamed:fileName toReplaceSprite:self.buildingSprite completion:^(BOOL success) {
      if (success) {
        [self adjustBuildingSprite];
      }
      didAdjust = YES;
    }];
    
    if (!didAdjust) {
      [self adjustBuildingSprite];
    }
  }
}

- (NSString *) progressBarPrefix {
  return @"obtimeryellow";
}

- (void) displayProgressBar {
  [self removeProgressBar];
  
  UpgradeProgressBar *upgrIcon = [[UpgradeProgressBar alloc] initBarWithPrefix:[self progressBarPrefix]];
  [self addChild:upgrIcon z:5];
  upgrIcon.position = ccp(self.contentSize.width/2, self.contentSize.height);
  self.progressBar = upgrIcon;
  [self schedule:@selector(updateProgressBar) interval:0.05f];
  
  _percentage = 0;
  [self updateProgressBar];
  
  [self removeBubble];
}

- (void) updateProgressBar {
  
}

- (void) removeProgressBar {
  if (self.progressBar) {
    [self.progressBar removeFromParent];
    self.progressBar = nil;
    
    if (!_percentage) {
      [self unschedule:@selector(updateProgressBar)];
    }
    
    [self displayBubble];
  }
}

- (void) instaFinishUpgradeWithCompletionBlock:(void(^)(void))completed {
    UpgradeProgressBar *u = (UpgradeProgressBar *)self.progressBar;
    [self unschedule:@selector(updateProgressBar)];
    
    float interval = 0.015;
    float timestep = 0.02;
    _percentage = u.percentage;
    int numTimes = (1-_percentage)/interval;
    CCActionCallBlock *b = [CCActionCallBlock actionWithBlock:^{
      _percentage += interval;
      [self updateProgressBar];
    }];
    CCActionSequence *cycle = [CCActionSequence actions:b, [CCActionDelay actionWithDuration:timestep], nil];
    CCActionRepeat *r = [CCActionRepeat actionWithAction:cycle times:numTimes];
    [u runAction:
     [CCActionSequence actions:
      r,
      [CCActionCallBlock actionWithBlock:
       ^{
         _percentage = 1;
         [self updateProgressBar];
         
         [self removeProgressBar];
         if (completed) {
           completed();
         }
       }],
      nil]];
}

- (void) setBubbleType:(BuildingBubbleType)bubbleType {
  [self setBubbleType:bubbleType withNum:0];
}

- (void) setBubbleType:(BuildingBubbleType)bubbleType withNum:(int)num {
  [_bubble setType:bubbleType withNum:num];
  _bubble.visible = bubbleType != BuildingBubbleTypeNone;
}

- (void) removeBubble {
  [_bubble stopAllActions];
  [_bubble runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0.f]];
}

- (void) pulseBubbleAlpha {
  [_bubble stopAllActions];
  CCActionDelay *longDelayAction = [CCActionDelay actionWithDuration:5.f];
  CCActionDelay *shortDelayAction = [CCActionDelay actionWithDuration:3.f];
  RecursiveFadeTo *fadeOutAction = [RecursiveFadeTo actionWithDuration:0.3f opacity:0.f];
  RecursiveFadeTo *fadeInAction = [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f];
  CCActionRepeatForever *a = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:fadeOutAction, shortDelayAction, fadeInAction, longDelayAction, nil]];
  [_bubble runAction:a];
}

- (void) displayBubble {
  if (!self.progressBar && !self.arrow && !_isSelected) {
    [_bubble stopAllActions];
    [_bubble runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:1.f]];
  }
}

- (void) displayBuildingButtons:(NSArray*)buttons targetSelector:(SEL)selector animate:(BOOL)animate
{
  if (!_buildingButtons) {
    _buildingButtons = [CCNode node];
    _buildingButtons.scale = 1.f / MAX_ZOOM; // Button assets are built with correct size at max zoom level
    _buildingButtons.zOrder = 1000; // Need them to be in front of all sibling buildings and obstacles
    
    [self.parent addChild:_buildingButtons];
  }
  _buildingButtons.position = [self.parent convertToNodeSpace:[self convertToWorldSpace:ccp(self.contentSize.width * .5f, 0.f)]];
  
  [self removeBuildingButtons:NO];
  
  if (buttons.count) {
    CCNode* belt = [CCSprite spriteWithImageNamed:@"roundbuildingoval.png"];
    belt.name = @"ButtonsBelt";
    [_buildingButtons addChild:belt];

    if (animate) {
      // Fade in
      [belt runAction:[CCActionFadeIn actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_IN]];
    }
  }
  
  const NSInteger c = buttons.count;
  for (int i = 0; i < c; ++i) {
    BuildingButton* button = buttons[i];
    
    const float dx = i - (float)(c - 1) * .5f;
    const float dy = ABS(dx);
    button.anchorPoint = ccp(.5f, 1.f);
    button.position = CGPointMake(dx * 115.f, -16.f + dy * 25.f);
    
    [button setTarget:self selector:selector];
    [_buildingButtons addChild:button];
    
    if (animate) {
      // Animate in
      button.position = ccpAdd(button.position, ccp(0.f, BUILDING_BUTTONS_ANIM_OFFSET));
      [button recursivelyApplyOpacity:0.f];
      [button runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:i * BUILDING_BUTTONS_ANIM_DELAY],
                         [CCActionSpawn actions:
                          [CCActionMoveBy actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_IN position:ccp(0.f, -BUILDING_BUTTONS_ANIM_OFFSET)],
                          [RecursiveFadeTo actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_IN opacity:1.f], nil], nil]];
    }
  }
}

- (void) removeBuildingButtons:(BOOL)animate
{
  if (_buildingButtons) {
    if (animate) {
      int i = 0;
      for (CCNode* node in _buildingButtons.children) {
        [node stopAllActions];
        
        if ([node.name isEqualToString:@"ButtonsBelt"]) {
          // Fade out and remove
          [node runAction:[CCActionSequence actions:
                           [CCActionFadeOut actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_OUT],
                           [CCActionRemove action], nil]];
        }
        else {
          // Animate out and remove
          [node runAction:[CCActionSequence actions:
                           [CCActionDelay actionWithDuration:i++ * BUILDING_BUTTONS_ANIM_DELAY],
                           [CCActionSpawn actions:
                            [CCActionMoveBy actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_OUT position:ccp(0.f, BUILDING_BUTTONS_ANIM_OFFSET)],
                            [RecursiveFadeTo actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_OUT opacity:0.f], nil],
                           [CCActionRemove action], nil]];
        }
      }
    }
    else {
      [_buildingButtons.children makeObjectsPerformSelector:@selector(stopAllActions)];
      [_buildingButtons removeAllChildren];
    }
  }
}

- (void) displayBuildingTitle:(NSString*)title subtitle:(NSString*)subtitle animate:(BOOL)animate
{
  if (!_buildingTitle) {
    _buildingTitle = [CCNode node];
    _buildingTitle.anchorPoint = ccp(.5f, 0.f);
    _buildingTitle.zOrder = 1000; // Need them to be in front of all sibling buildings and obstacles
    
    [self.parent addChild:_buildingTitle];
  }
  _buildingTitle.position = [self.parent convertToNodeSpace:[self convertToWorldSpace:ccp(self.contentSize.width * .5f, self.contentSize.height + 8.f)]];
  
  [self removeBuildingTitle:NO];
  
  CCLabelTTF* subtitleLabel = [BuildingButton styledLabelWithString:subtitle fontSize:16.f];
  subtitleLabel.anchorPoint = ccp(.5f, 0.f);
  
  CCLabelTTF* titleLabel = [BuildingButton styledLabelWithString:title fontSize:16.f];
  titleLabel.anchorPoint = ccp(.5f, 0.f);
  titleLabel.position = ccp(0.f, subtitleLabel.contentSize.height - 8.f);
  
  [_buildingTitle addChild:titleLabel];
  [_buildingTitle addChild:subtitleLabel];
  
  if (animate) {
    // Fade in
    [titleLabel runAction:[CCActionFadeIn actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_IN]];
    [subtitleLabel runAction:[CCActionFadeIn actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_IN]];
  }
}

- (void) removeBuildingTitle:(BOOL)animate
{
  if (_buildingTitle) {
    if (animate) {
      for (CCNode* node in _buildingTitle.children) {
        [node stopAllActions];
        
        // Fade out and remove
        [node runAction:[CCActionSequence actions:
                         [CCActionFadeOut actionWithDuration:BUILDING_BUTTONS_ANIM_TIME_OUT],
                         [CCActionRemove action], nil]];
      }
    }
    else {
      [_buildingTitle.children makeObjectsPerformSelector:@selector(stopAllActions)];
      [_buildingTitle removeAllChildren];
    }
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
      [_lockedBubble removeFromParent];
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
      [_lockedBubble removeFromParent];
    }
    self.color = [CCColor colorWithCcColor3b:ccc3(255, 255, 255)];
  }
}

@end

@implementation ObstacleSprite

- (id) initWithObstacle:(UserObstacle *)obstacle map:(HomeMap *)map {
  ObstacleProto *op = obstacle.staticObstacle;
  NSString *file = op.imgName;
  CGRect loc = CGRectMake(obstacle.coordinates.x, obstacle.coordinates.y, op.width, op.height);
  if ((self = [self initWithFile:file location:loc map:map])) {
    self.obstacle = obstacle;
    
    self.verticalOffset = op.imgVerticalPixelOffset;
    [self adjustBuildingSprite];
    
    NSString *fileName = [NSString stringWithFormat:@"%dx%ddark.png", (int)loc.size.width, (int)loc.size.height];
    CCSprite *shadow = [CCSprite spriteWithImageNamed:fileName];
    [self addChild:shadow z:-1 name:SHADOW_TAG];
    shadow.anchorPoint = ccp(0.5, 0);
    
    CCSprite *dark = [CCSprite spriteWithImageNamed:@"minishadow.png"];
    [shadow addChild:dark z:-1 name:SHADOW_TAG];
    dark.position = ccp(shadow.contentSize.width/3, shadow.contentSize.height/2);
    
    // Reassign the content size
    self.contentSize = self.contentSize;
    
    [map changeTiles:self.location toBuildable:NO];
  }
  return self;
}

- (void) updateProgressBar {
    UpgradeProgressBar *bar = self.progressBar;
    
    NSTimeInterval time = self.obstacle.endTime.timeIntervalSinceNow;
    int totalTime = self.obstacle.staticObstacle.secondsToRemove;
    
    if (_percentage) {
      time = totalTime*(1.f-_percentage);
    }
    
    [bar updateForSecsLeft:time totalSecs:totalTime];
}

- (void) disappear {
  [self runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:0.5f opacity:0.f],
    [CCActionRemove action],
    nil]];
  [(HomeMap *)_map changeTiles:self.location toBuildable:YES];
}

- (BOOL) select {
  BOOL select = [super select];
  [self displayBuildingInfo:YES];
  return select;
}

- (void) unselect {
  [super unselect];
  [self removeBuildingInfo:YES];
}

- (void) displayBuildingInfo:(BOOL)animate {
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *buildingButtons = [NSMutableArray array];
  
  UserObstacle *ue = self.obstacle;
  ObstacleProto *op = ue.staticObstacle;
  
  [self displayBuildingTitle:op.name subtitle:@"" animate:animate];
  
  if (!ue.removalTime) {
    [buildingButtons addObject:[BuildingButton buttonRemoveWithResourceType:op.removalCostType cost:op.cost]];
  } else {
    int timeLeft = [(HomeMap *)_map timeLeftForConstructionBuildingOrObstacle:self];
    [buildingButtons addObject:[BuildingButton buttonSpeedup:![gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:NO]]];
  }
  
  [self displayBuildingButtons:buildingButtons targetSelector:@selector(buildingButtonTapped:) animate:animate];
}

- (void) removeBuildingInfo:(BOOL)animate {
  [self removeBuildingButtons:animate];
  [self removeBuildingTitle:animate];
}

- (void) buildingButtonTapped:(BuildingButton*)sender {
  // Create a fake button to carry the message up the chain
  MapBotViewButton* button = [[MapBotViewButton alloc] init];
  button.config = sender.buttonConfig;
  [(HomeMap *)_map mapBotViewButtonSelected:button];
}

@end