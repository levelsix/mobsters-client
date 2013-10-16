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
#import "CCLabelFX.h"

@implementation PurchaseConfirmMenu

- (id) initWithCheckTarget:(id)cTarget checkSelector:(SEL)cSelector cancelTarget:(id)xTarget cancelSelector:(SEL)xSelector {
  if ((self = [super init])) {
    CCMenuItemSprite *check = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"confirmbuild.png"] selectedSprite:nil target:cTarget selector:cSelector];
    CCMenuItemSprite *cancel = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"cancelbuild.png"] selectedSprite:nil target:xTarget selector:xSelector];
    CCMenu *menu = [CCMenu menuWithItems:check, cancel, nil];
    [self addChild:menu];
    
    check.position = ccp(check.contentSize.width-3, 0);
    cancel.position = ccp(-cancel.contentSize.width+3, 0);
    menu.position = ccp(0,0);
    menu.isTouchEnabled = YES;
  }
  return self;
}
@end

@implementation UpgradeProgressBar

- (id) initBar {
  if ((self = [super initWithFile:@"overbuildingbackground.png"])) {
    _progressBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"overbuildingyellow.png"]];
    [self addChild:_progressBar];
    _progressBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _progressBar.type = kCCProgressTimerTypeBar;
    _progressBar.midpoint = ccp(0,0.5);
    _progressBar.barChangeRate = ccp(1, 0);
    
    _timeLabel = [CCLabelFX labelWithString:@"" fontName:[Globals font] fontSize:22.f shadowOffset:CGSizeMake(0, -1) shadowBlur:0.f shadowColor:ccc4(0, 0, 0, 100) fillColor:ccc4(255, 255, 255, 255)];
    [Globals adjustFontSizeForCCLabelTTF:_timeLabel size:12.f];
    [self addChild:_timeLabel];
    _timeLabel.position = ccp(self.contentSize.width/2, self.contentSize.height/2+1);
  }
  return self;
}

- (void) updateForSecsLeft:(int)secs totalSecs:(int)totalSecs {
  _timeLabel.string = [Globals convertTimeToShortString:secs];
  _progressBar.percentage = (1.f-((float)secs)/totalSecs)*100;
}

@end

@implementation HomeBuildingMenu

@synthesize titleLabel, incomeLabel, rankLabel;

- (void) updateForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  titleLabel.text = fsp.name;
  incomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
  rankLabel.text = [NSString stringWithFormat:@"%d", us.level];
}

@end

@implementation HomeBuildingCollectMenu

@synthesize coinsLabel, timeLabel, progressBar;
@synthesize timer, userStruct;

- (void) updateForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  coinsLabel.text = [NSString stringWithFormat:@"%d", [gl calculateIncomeForUserStruct:us]];
  
  self.userStruct = us;
  
  [self updateMenu];
  
  NSDate *retrieveDate = [us.lastRetrieved dateByAddingTimeInterval:fsp.minutesToGain*60];
  progressBar.percentage = 1.f - retrieveDate.timeIntervalSinceNow/(fsp.minutesToGain*60);
  [UIView animateWithDuration:retrieveDate.timeIntervalSinceNow animations:^{
    progressBar.percentage = 1.f;
  }];
  
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateMenu {
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = self.userStruct;
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  NSDate *retrieveDate = [us.lastRetrieved dateByAddingTimeInterval:fsp.minutesToGain*60];
  timeLabel.text = [Globals convertTimeToString:retrieveDate.timeIntervalSinceNow withDays:YES];
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    timer = t;
  }
}

- (void) setAlpha:(CGFloat)alpha {
  [super setAlpha:alpha];
  if (alpha == 0.f) {
    [self.progressBar.layer removeAllAnimations];
    self.timer = nil;
    self.userStruct = nil;
  }
}

@end

@implementation UpgradeBuildingMenu

- (void) displayForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  self.titleLabel.text = [NSString stringWithFormat:@"Upgrade To Level %d?", us.level+1];
  self.nameLabel.text = fsp.name;
  
  if (us.state == kBuilding) {
    self.currentIncomeLabel.text = @"No Current Income";
    self.upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
  } else {
    self.currentIncomeLabel.text = [NSString stringWithFormat:@"%@", [Globals cashStringForNumber:[gl calculateIncomeForUserStruct:us]]];
    self.upgradedIncomeLabel.text = [NSString stringWithFormat:@"%@", [Globals cashStringForNumber:[gl calculateIncomeForUserStructAfterLevelUp:us]]];
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@" EVERY %@", [Globals convertTimeToShortString:fsp.minutesToGain*60]];
    self.upgradedTimeLabel.text = [NSString stringWithFormat:@" EVERY %@", [Globals convertTimeToShortString:fsp.minutesToGain*60]];
    
    CGRect r = self.currentTimeLabel.frame;
    r.origin.x = [self.currentIncomeLabel.text sizeWithFont:self.currentIncomeLabel.font].width;
    self.currentTimeLabel.frame = r;
    
    r = self.upgradedTimeLabel.frame;
    r.origin.x = [self.upgradedIncomeLabel.text sizeWithFont:self.upgradedIncomeLabel.font].width;
    self.upgradedTimeLabel.frame = r;
  }
  self.upgradeTimeLabel.text = [Globals convertTimeToShortString:[gl calculateMinutesToUpgrade:us]*60];
  self.upgradePriceLabel.text = [Globals commafyNumber:[gl calculateUpgradeCost:us]];
  
  [Globals loadImageForStruct:fsp.structId toView:self.structIcon masked:NO indicator:UIActivityIndicatorViewStyleWhiteLarge];
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self removeFromSuperview];
    }];
  }
}

@end

@implementation ExpansionView

- (void) display {
  Globals *gl = [Globals sharedGlobals];
  
  self.costLabel.text = [Globals commafyNumber:[gl calculateSilverCostForNewExpansion]];
  self.totalTimeLabel.text = [Globals convertTimeToShortString:[gl calculateNumMinutesForNewExpansion]*60];
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

@end
