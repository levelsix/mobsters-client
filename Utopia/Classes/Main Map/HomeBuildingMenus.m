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
    
    self.check.position = ccp(self.check.contentSize.width-3, 0);
    self.cancel.position = ccp(-self.cancel.contentSize.width+3, 0);
  }
  return self;
}

- (BOOL) hitTestWithWorldPos:(CGPoint)pos {
  return [self.check hitTestWithWorldPos:pos] || [self.cancel hitTestWithWorldPos:pos];
}

@end

@implementation UpgradeProgressBar

- (id) initBarWithPrefix:(NSString *)prefix {
  if ((self = [super initWithImageNamed:@"overbuildingbar.png"])) {
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
    
    _timeLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:12.f];
    _timeLabel.horizontalAlignment = CCTextAlignmentCenter;
    [_timeLabel setFontColor:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
    [_timeLabel setShadowOffset:ccp(0, -1)];
    _timeLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.5f];
    [self addChild:_timeLabel];
    _timeLabel.position = ccp(self.contentSize.width/2, self.contentSize.height);
  }
  return self;
}

- (void) updateForSecsLeft:(float)secs totalSecs:(int)totalSecs {
  [self updateTimeLabel:secs];
  [self updateForPercentage:(1.f-secs/totalSecs)];
}

- (void) updateTimeLabel:(float)secs {
  _timeLabel.string = [Globals convertTimeToShortString:roundf(secs)];
}

- (void) updateForPercentage:(float)percentage {
  self.percentage = percentage;
  
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

@end
