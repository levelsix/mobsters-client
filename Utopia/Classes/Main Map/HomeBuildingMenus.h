//
//  HomeBuildingMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "UserData.h"

#define PROGRESS_BAR_SPEED 2.f

@interface PurchaseConfirmMenu : CCNode

- (id) initWithCheckTarget:(id)cTarget checkSelector:(SEL)cSelector cancelTarget:(id)xTarget cancelSelector:(SEL)xSelector;

@end

@interface UpgradeProgressBar : CCSprite {
  CCLabelTTF *_timeLabel;
}

@property (nonatomic, retain) CCProgressNode *progressBar;

- (id) initBar;
- (void) updateForSecsLeft:(int)secs totalSecs:(int)totalSecs;

@end
