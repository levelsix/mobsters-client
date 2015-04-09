//
//  HomeBuildingMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "HomeBuildingMenus.h"
#import "GameState.h"
#import "Globals.h"
#import "HomeMap.h"
#import "SoundEngine.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import <cocos2d-ui.h>

@implementation PurchaseConfirmMenu

- (id) initWithCheckTarget:(id)cTarget checkSelector:(SEL)cSelector cancelTarget:(id)xTarget cancelSelector:(SEL)xSelector {
  if ((self = [super init])) {
    self.check = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"confirmbuild.png"]];
    [self.check setTarget:cTarget selector:cSelector];
    self.cancel = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"cancelbuild.png"]];
    [self.cancel setTarget:xTarget selector:xSelector];
    [self addChild:self.check];
    [self addChild:self.cancel];
    
    self.check.position = ccp(self.check.contentSize.width*0.68, 0);
    self.cancel.position = ccp(-self.cancel.contentSize.width*0.68, 0);
  }
  return self;
}

- (BOOL) hitTestWithWorldPos:(CGPoint)pos {
  return [self.check hitTestWithWorldPos:pos] || [self.cancel hitTestWithWorldPos:pos];
}

@end

@implementation UpgradeProgressBar

- (id) initBarWithPrefix:(NSString *)prefix {
  if ((self = [super initWithImageNamed:@"obtimerbg.png"])) {
    self.prefix = prefix;
    
    self.leftCap = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.rightCap = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"cap.png"]];
    self.middleBar = [CCSprite spriteWithImageNamed:[prefix stringByAppendingString:@"middle.png"]];
    
    [self addChild:self.leftCap];
    [self addChild:self.rightCap];
    [self addChild:self.middleBar];
    
    self.leftCap.anchorPoint = ccp(0, 0);
    self.rightCap.anchorPoint = ccp(0, 0);
    self.middleBar.anchorPoint = ccp(0, 0);
    
    CGRect r = self.leftCap.textureRect;
    r.size.width = 2;
    [self.leftCap setTextureRect:r rotated:NO untrimmedSize:self.leftCap.contentSize];
    
    self.rightCap.flipX = YES;
    self.rightCap.position = ccp(self.contentSize.width, 0);
    self.middleBar.position = ccp(self.leftCap.contentSize.width, 0);
    self.middleBar.scaleX = (self.contentSize.width-self.leftCap.contentSize.width-self.rightCap.contentSize.width)/self.middleBar.contentSize.width;
    
    _timeLabel = [CCLabelTTF labelWithString:@"" fontName:@"Gotham-Ultra" fontSize:12.f];
    _timeLabel.horizontalAlignment = CCTextAlignmentCenter;
    [_timeLabel setFontColor:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
    [_timeLabel setShadowOffset:ccp(0, -1)];
    _timeLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.5f];
    _timeLabel.shadowBlurRadius = 0.8f;
    [self addChild:_timeLabel];
    _timeLabel.position = ccp(self.contentSize.width/2, self.contentSize.height-2);
  }
  return self;
}

- (void) updateForSecsLeft:(float)secs totalSecs:(int)totalSecs {
  [self updateTimeLabel:secs];
  [self updateForPercentage:(1.f-secs/totalSecs)];
}

- (void) updateTimeLabel:(float)secs {
  _timeLabel.string = [[Globals convertTimeToShortString:roundf(secs)] uppercaseString];
}

- (void) updateForPercentage:(float)percentage {
  self.percentage = clampf(percentage, 0, 1);
  
  float totalWidth = _percentage*self.contentSize.width;
  CGRect r;
  
  r = self.leftCap.textureRect;
  r.size.width = MIN(totalWidth/2, self.leftCap.contentSize.width);
  [self.leftCap setTextureRect:r rotated:NO untrimmedSize:self.leftCap.contentSize];
  
  r = self.rightCap.textureRect;
  r.size.width = self.leftCap.textureRect.size.width;
  [self.rightCap setTextureRect:r rotated:NO untrimmedSize:self.rightCap.contentSize];
  
  self.middleBar.position = ccp(self.leftCap.textureRect.size.width, 0);
  self.middleBar.scaleX = MAX(0, ((self.contentSize.width*self.percentage)-self.leftCap.textureRect.size.width-self.rightCap.textureRect.size.width)/self.middleBar.contentSize.width);
  
  self.rightCap.position = ccp(self.contentSize.width*self.percentage-self.rightCap.textureRect.size.width, 0);
}

- (void) animateFreeLabel {
  if (!_isAnimatingFreeLabel) {
    CCLabelTTF *freeLabel = [CCLabelTTF labelWithString:@"FREE!" fontName:_timeLabel.fontName fontSize:_timeLabel.fontSize];
    [self addChild:freeLabel];
    freeLabel.position = _timeLabel.position;
    freeLabel.horizontalAlignment = _timeLabel.horizontalAlignment;
    freeLabel.fontColor = _timeLabel.fontColor;
    freeLabel.shadowOffset = _timeLabel.shadowOffset;
    freeLabel.shadowColor = _timeLabel.shadowColor;
    freeLabel.shadowBlurRadius = _timeLabel.shadowBlurRadius;
    
    freeLabel.opacity = 0.f;
    
    float fadeTime = 0.4f;
    // Delay time 1 is how long free is up, 2 is how long timer is up
    float delayTime1 = 1.8f;
    float delayTime2 = 1.8f;
    
    [freeLabel runAction:[CCActionRepeatForever actionWithAction:
                          [CCActionSequence actions:
                           [CCActionFadeIn actionWithDuration:fadeTime],
                           [CCActionDelay actionWithDuration:delayTime1],
                           [CCActionFadeOut actionWithDuration:fadeTime],
                           [CCActionDelay actionWithDuration:delayTime2], nil]]];
    
    [_timeLabel runAction:[CCActionRepeatForever actionWithAction:
                           [CCActionSequence actions:
                            [CCActionFadeOut actionWithDuration:fadeTime],
                            [CCActionDelay actionWithDuration:delayTime1],
                            [CCActionFadeIn actionWithDuration:fadeTime],
                            [CCActionDelay actionWithDuration:delayTime2], nil]]];
    
    _isAnimatingFreeLabel = YES;
  }
}

@end

@implementation BuildingBubble

- (id) init {
  if ((self = [super init])) {
    self.anchorPoint = ccp(0.5, 0);
  }
  return self;
}

- (void) setType:(BuildingBubbleType)type withNum:(int)num {
  if (_type != type || _num != num) {
    _type = type;
    _num = num;
    
    NSString *suffix = num > 9 || num < 0 ? @"exclamation" : [NSString stringWithFormat:@"%d", num];
    NSString *imgName;
    switch (type) {
      case BuildingBubbleTypeEnhance:
        imgName = @"enhancebubble.png";
        break;
      case BuildingBubbleTypeEvolve:
        imgName = @"evolvebubble.png";
        break;
      case BuildingBubbleTypeFix:
        imgName = @"fixbubble1.png";
        break;
      case BuildingBubbleTypeFull:
        imgName = @"fullbubble.png";
        break;
      case BuildingBubbleTypeComplete:
        imgName = @"completebubble1.png";
        break;
      case BuildingBubbleTypeJoinClan:
        imgName = @"joinbubble1.png";
        break;
      case BuildingBubbleTypeHeal:
        imgName = [NSString stringWithFormat:@"healredbubble%@.png", suffix];
        break;
      case BuildingBubbleTypeTeamRed:
        imgName = [NSString stringWithFormat:@"teambubble%@.png", suffix];
        break;
      case BuildingBubbleTypeTeamGreen:
        imgName = [NSString stringWithFormat:@"teambubble%@green.png", suffix];
        break;
      case BuildingBubbleTypeSell:
        imgName = [NSString stringWithFormat:@"sellbubble%@.png", suffix];
        break;
      case BuildingBubbleTypeMiniJob:
        imgName = [NSString stringWithFormat:@"minijobsredbubble%@.png", suffix];
        break;
      case BuildingBubbleTypeClanHelp:
        imgName = [NSString stringWithFormat:@"helpredbubble%@.png", suffix];
        break;
      case BuildingBubbleTypeCakeKid:
        imgName = [Globals imageNameForElement:num suffix:@"cakeeventlive.png"];
        break;
      case BuildingBubbleTypeScientist:
        imgName = [Globals imageNameForElement:num suffix:@"scientisteventlive.png"];
        break;
      case BuildingBubbleTypeLocked:
        imgName = [NSString stringWithFormat:@"lockedbubble.png"];
        break;
      case BuildingBubbleTypeRenew:
        imgName = [NSString stringWithFormat:@"renewbubble.png"];
        break;
      case BuildingBubbleTypeCreate:
        imgName = [NSString stringWithFormat:@"createbubble.png"];
        break;
      case BuildingBubbleTypeResearch:
        imgName = [NSString stringWithFormat:@"researchbubble.png"];
        break;
        
      case BuildingBubbleTypeNone:
        break;
    }
    
    [self.bubbleImage removeFromParent];
    if (imgName) {
      CCSprite *bubble = [CCSprite spriteWithImageNamed:imgName];
      [self addChild:bubble];
      self.contentSize = bubble.contentSize;
      
      bubble.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
      bubble.opacity = self.opacity;
      
      self.bubbleImage = bubble;
    }
  }
}

@end

@implementation UpgradeSign

- (id) initWithGreen:(BOOL)green {
  if ((self = [super init])) {
    self.anchorPoint = ccp(0.5, 0);
    
    CCSprite *sign = [CCSprite spriteWithImageNamed:green ? @"greenarrow.png" : @"redarrow.png"];
    [self addChild:sign];
    self.contentSize = sign.contentSize;
    sign.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  }
  return self;
}

@end

@implementation MiniMonsterViewSprite

+ (id) spriteWithMonsterId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  NSString *file = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  return [self spriteWithElement:mp.monsterElement imageName:file];
}

+ (id) spriteWithElement:(Element)elem imageName:(NSString *)imgName {
  
  MiniMonsterViewSprite *s = [MiniMonsterViewSprite node];
  s.contentSize = CGSizeMake(15, 15);
  
  NSString *file = [Globals imageNameForElement:elem suffix:@"smallsquare.png"];
  CCSprite *bgd = [CCSprite spriteWithImageNamed:file];
  bgd.scale = s.contentSize.height/bgd.contentSize.height;
  
  CCSprite *thumb = [CCSprite node];
  [Globals imageNamed:imgName toReplaceSprite:thumb completion:^(BOOL success) {
    thumb.scale = s.contentSize.height/thumb.contentSize.height;
  }];
  
  [s addChild:bgd];
  [s addChild:thumb];
  bgd.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
  thumb.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
  
  return s;
}

@end

@implementation MiniResearchViewSprite

+ (id) spriteWithResearchProto:(ResearchProto *)proto {
//  GameState *gs = [GameState sharedGameState];
  
  MiniResearchViewSprite *s = [MiniMonsterViewSprite node];
  s.contentSize = CGSizeMake(20, 20);
  
//  NSString *file = [Globals imageNameForElement:mp.monsterElement suffix:@"smallsquare.png"];
//  CCSprite *bgd = [CCSprite spriteWithImageNamed:file];
//  bgd.scale = s.contentSize.height/bgd.contentSize.height;
  
  CCSprite *thumb = [CCSprite node];
  [Globals imageNamed:proto.iconImgName toReplaceSprite:thumb completion:^(BOOL success) {
    thumb.scale = s.contentSize.height/thumb.contentSize.height;
  }];
  
//  [s addChild:bgd];
  [s addChild:thumb];
//  bgd.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
  thumb.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
  
  return s;
}

@end
