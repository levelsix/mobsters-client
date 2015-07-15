//
//  BuildingButton.h
//  Utopia
//
//  Created by Behrouz N. on 7/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "cocos2d-ui.h"
#import "MapBotView.h"

typedef enum
{
  ArrowPlacementTop,
  ArrowPlacementRight,
  ArrowPlacementBottom,
  ArrowPlacementLeft
} ArrowPlacement;

@interface BuildingButton : CCButton

+ (instancetype) buttonSell;
+ (instancetype) buttonBonusSlots;
+ (instancetype) buttonHeal;
+ (instancetype) buttonEnhance;
+ (instancetype) buttonEvolve;
+ (instancetype) buttonResearch;
+ (instancetype) buttonTeam;
+ (instancetype) buttonMiniJobs;
+ (instancetype) buttonInfo;
+ (instancetype) buttonJoinClan;
+ (instancetype) buttonPvPBoard;
+ (instancetype) buttonItemFactory;
+ (instancetype) buttonLeaderboard;
+ (instancetype) buttonClanHelp;
+ (instancetype) buttonRemoveWithResourceType:(ResourceType)resource cost:(int)cost;
+ (instancetype) buttonUpgradeWithResourceType:(ResourceType)resource cost:(int)cost;
+ (instancetype) buttonFixWithResourceType:(ResourceType)resource cost:(int)cost;
+ (instancetype) buttonFixWithIAPString:(NSString*)cost;
+ (instancetype) buttonSpeedup:(BOOL)free;

- (void) displayArrow:(ArrowPlacement)placement;
- (void) removeArrow;

+ (CCLabelTTF*) styledLabelWithString:(NSString*)string fontSize:(CGFloat)size;

@property (nonatomic, readonly) MapBotViewButtonConfig buttonConfig;

@end
