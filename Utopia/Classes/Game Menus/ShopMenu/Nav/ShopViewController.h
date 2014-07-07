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

@interface ShopViewController : PopupNavViewController <TabBarDelegate> 

@property (nonatomic, retain) BuildingViewController *buildingViewController;
@property (nonatomic, retain) FundsViewController *fundsViewController;
@property (nonatomic, retain) GachaChooserViewController *gachaViewController;

@property (nonatomic, retain) IBOutlet ButtonTabBar *tabBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *buildingsBadge;

- (void) initializeSubViewControllers;

- (void) openBuildingsShop;
- (void) openFundsShop;
- (void) openGachaShop;

@end
