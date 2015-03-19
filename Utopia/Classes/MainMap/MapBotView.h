//
//  MapBotView.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Protocols.pb.h"
#import "NibUtils.h"

@class MapBotView;

typedef enum {
  MapBotViewButtonSell = 1,
  MapBotViewButtonUpgrade,
  MapBotViewButtonBonusSlots,
  MapBotViewButtonHeal,
  MapBotViewButtonEnhance,
  MapBotViewButtonEvolve,
  MapBotViewButtonResearch,
  MapBotViewButtonTeam,
  MapBotViewButtonMiniJob,
  MapBotViewButtonSpeedup,
  MapBotViewButtonInfo,
  MapBotViewButtonRemove,
  MapBotViewButtonFix,
  MapBotViewButtonJoinClan,
  MapBotViewButtonClanHelp,
  MapBotViewButtonPvpBoard,
  MapBotViewButtonItemFactory,
} MapBotViewButtonConfig;

@protocol MapBotViewButtonDelegate <NSObject>

- (void) mapBotViewButtonSelected:(id)button;

@end

@interface MapBotViewButton : UIView

@property (nonatomic, retain) IBOutlet THLabel *topLabel;
@property (nonatomic, retain) IBOutlet THLabel *actionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *actionIcon;
@property (nonatomic, retain) IBOutlet UIImageView *cashIcon;
@property (nonatomic, retain) IBOutlet UIImageView *oilIcon;
@property (nonatomic, retain) IBOutlet UIButton *bgdButton;

// Only used for gems
@property (nonatomic, retain) IBOutlet THLabel *freeLabel;

@property (nonatomic, assign) MapBotViewButtonConfig config;

@property (nonatomic, assign) id<MapBotViewButtonDelegate> delegate;

+ (id) button;
+ (id) sellButton;
+ (id) bonusSlotsButton;
+ (id) healButton;
+ (id) enhanceButton;
+ (id) evolveButton;
+ (id) researchButton;
+ (id) teamButton;
+ (id) miniJobsButton;
+ (id) infoButton;
+ (id) joinClanButton;
+ (id) clanHelpButton;
+ (id) pvpBoardButton;
+ (id) itemFactoryButton;
+ (id) upgradeButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost;
+ (id) fixButtonWithResourceType:(ResourceType)type buildCost:(int)buildCost;
+ (id) fixButtonWithIapString:(NSString *)str;
+ (id) removeButtonWithResourceType:(ResourceType)type removeCost:(int)removeCost;
+ (id) speedupButtonWithGemCost:(int)gemCost;

@end

@protocol MapBotViewDelegate <NSObject>

- (void) updateMapBotView:(MapBotView *)botView;

@end

@interface MapBotView : UIView

@property (nonatomic, assign) IBOutlet id<MapBotViewDelegate> delegate;

@property (nonatomic, assign) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *animateViews;

@property (nonatomic, retain) IBOutlet UIView *containerView;

- (void) update;
- (void) animateIn:(void(^)())block;
- (void) animateOut:(void(^)())block;

- (void) addAnimateViewsToContainerView:(NSArray *)views;

@end