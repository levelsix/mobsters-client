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
  if ((self = [super initWithFile:@"buildingbarbg.png"])) {
    _progressBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"buildingbar.png"]];
    [self addChild:_progressBar];
    _progressBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _progressBar.type = kCCProgressTimerTypeBar;
    _progressBar.midpoint = ccp(0,0.5);
    _progressBar.barChangeRate = ccp(1, 0);
    
    _timeLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:14.f dimensions:_progressBar.contentSize hAlignment:kCCTextAlignmentCenter];
    [_timeLabel setFontFillColor:ccc3(255, 255, 255) updateImage:NO];
    [_timeLabel enableShadowWithOffset:CGSizeMake(0, -1) opacity:1.f blur:0.f updateImage:YES];
    [Globals adjustFontSizeForCCLabelTTF:_timeLabel size:12.f];
    [self addChild:_timeLabel];
    _timeLabel.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  }
  return self;
}

- (void) updateForSecsLeft:(int)secs totalSecs:(int)totalSecs {
  _timeLabel.string = [Globals convertTimeToShortString:secs];
  _progressBar.percentage = (1.f-((float)secs)/totalSecs)*100;
}

@end

@implementation UpgradeBuildingMenu

- (void) displayForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  FullStructureProto *fsp = us.fsp;
  FullStructureProto *nextFsp = us.fspForNextLevel;
  
  self.titleLabel.text = [NSString stringWithFormat:@"Upgrade To Level %d?", nextFsp.level];
  self.nameLabel.text = fsp.name;
  
  self.currentIncomeLabel.text = [NSString stringWithFormat:@"%@", [Globals cashStringForNumber:fsp.income]];
  self.upgradedIncomeLabel.text = [NSString stringWithFormat:@"%@", [Globals cashStringForNumber:nextFsp.income]];
  
  self.currentTimeLabel.text = [NSString stringWithFormat:@" EVERY %@", [Globals convertTimeToShortString:fsp.minutesToGain*60]];
  self.upgradedTimeLabel.text = [NSString stringWithFormat:@" EVERY %@", [Globals convertTimeToShortString:fsp.minutesToGain*60]];
  
  CGRect r = self.currentTimeLabel.frame;
  r.origin.x = [self.currentIncomeLabel.text sizeWithFont:self.currentIncomeLabel.font].width;
  self.currentTimeLabel.frame = r;
  
  r = self.upgradedTimeLabel.frame;
  r.origin.x = [self.upgradedIncomeLabel.text sizeWithFont:self.upgradedIncomeLabel.font].width;
  self.upgradedTimeLabel.frame = r;
  
  self.upgradeTimeLabel.text = [Globals convertTimeToShortString:nextFsp.minutesToBuild*60];
  self.upgradePriceLabel.text = nextFsp.isPremiumCurrency ? [Globals commafyNumber:nextFsp.buildPrice] : [Globals cashStringForNumber:nextFsp.buildPrice];
  
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
