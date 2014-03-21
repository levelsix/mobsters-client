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

- (id) initBar {
  if ((self = [super initWithImageNamed:@"buildingbarbg.png"])) {
    _progressBar = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:@"buildingbar.png"]];
    [self addChild:_progressBar];
    _progressBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _progressBar.type = CCProgressNodeTypeBar;
    _progressBar.midpoint = ccp(0,0.5);
    _progressBar.barChangeRate = ccp(1, 0);
    
    _timeLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:14.f dimensions:self.contentSize];
    _timeLabel.horizontalAlignment = CCTextAlignmentCenter;
    [_timeLabel setFontColor:[CCColor colorWithCcColor3b:ccc3(255, 255, 255)]];
    [_timeLabel setShadowOffset:ccp(0, -1)];
    _timeLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.5f];
    [self addChild:_timeLabel];
    _timeLabel.position = ccp(self.contentSize.width/2, self.contentSize.height/2+1);
  }
  return self;
}

- (void) updateForSecsLeft:(float)secs totalSecs:(int)totalSecs {
  _timeLabel.string = [Globals convertTimeToShortString:roundf(secs)];
  _progressBar.percentage = (1.f-secs/totalSecs)*100;
}

@end
