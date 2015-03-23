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
#import <cocos2d-ui.h>

#define PROGRESS_BAR_SPEED 2.f

@interface PurchaseConfirmMenu : CCNode

- (id) initWithCheckTarget:(id)cTarget checkSelector:(SEL)cSelector cancelTarget:(id)xTarget cancelSelector:(SEL)xSelector;

@property (nonatomic, retain) CCButton *check;
@property (nonatomic, retain) CCButton *cancel;

@property (nonatomic, assign) BOOL tracking;

@end

@interface UpgradeProgressBar : CCSprite {
  CCLabelTTF *_timeLabel;
  BOOL _isAnimatingFreeLabel;
}

@property (nonatomic, retain) CCSprite *leftCap;
@property (nonatomic, retain) CCSprite *middleBar;
@property (nonatomic, retain) CCSprite *rightCap;

@property (nonatomic, assign) float percentage;

@property (nonatomic, assign) NSString *prefix;

- (id) initBarWithPrefix:(NSString *)prefix;

- (void) updateForSecsLeft:(float)secs totalSecs:(int)totalSecs;
- (void) updateTimeLabel:(float)secs;
- (void) updateForPercentage:(float)percentage;

- (void) animateFreeLabel;

@end

typedef enum {
  BuildingBubbleTypeNone = 0,
  BuildingBubbleTypeEnhance,
  BuildingBubbleTypeEvolve,
  BuildingBubbleTypeFix,
  BuildingBubbleTypeFull,
  BuildingBubbleTypeHeal,
  BuildingBubbleTypeTeamRed,
  BuildingBubbleTypeTeamGreen,
  BuildingBubbleTypeSell,
  BuildingBubbleTypeMiniJob,
  BuildingBubbleTypeComplete,
  BuildingBubbleTypeClanHelp,
  BuildingBubbleTypeJoinClan,
  BuildingBubbleTypeCakeKid,
  BuildingBubbleTypeScientist,
  BuildingBubbleTypeLocked,
  BuildingBubbleTypeRenew,
  BuildingBubbleTypeCreate,
} BuildingBubbleType;

@interface BuildingBubble : CCNode {
  int _num;
}

@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, retain) CCSprite *bubbleImage;
@property (nonatomic, assign) BuildingBubbleType type;

- (void) setType:(BuildingBubbleType)type withNum:(int)num;

@end

@interface UpgradeSign : CCNode

- (id) initWithGreen:(BOOL)green;

@end

@interface MiniMonsterViewSprite : CCSprite

+ (id) spriteWithMonsterId:(int)monsterId;
+ (id) spriteWithElement:(Element)elem imageName:(NSString *)imgName;

@end
