//
//  MainMenuViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupNavViewController.h"

#import "NibUtils.h"
#import "BuildingViewController.h"
#import "FundsViewController.h"
#import "GachaChooserViewController.h"
#import "SalesViewController.h"

@protocol ShopViewDelegate <NSObject>

- (void) sendShopViewUnderCoinBars:(id)svc;
- (void) sendShopViewAboveCoinBars:(id)svc;

@end

@interface ShopViewController : PopupNavViewController <TabBarDelegate> 

@property (nonatomic, retain) BuildingViewController *buildingViewController;
@property (nonatomic, retain) FundsViewController *fundsViewController;
@property (nonatomic, retain) GachaChooserViewController *gachaViewController;
@property (nonatomic, retain) SalesViewController *salesViewController;

@property (nonatomic, retain) IBOutlet ButtonTabBar *tabBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *buildingsBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *gachasBadge;

@property (nonatomic, weak) id<ShopViewDelegate> delegate;

- (void) initializeSubViewControllers;

- (void) adjustContainerViewForSubViewController:(UIViewController *)uvc;

- (void) openBuildingsShop;
- (void) openFundsShop;
- (void) openGachaShop;

@end
