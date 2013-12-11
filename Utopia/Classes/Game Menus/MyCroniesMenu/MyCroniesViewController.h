//
//  MyCroniesViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/17/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "MyCroniesMonsterViews.h"
#import "MonsterTeamSlotView.h"
#import "CoinBar.h"

@interface MyCroniesViewController : GenViewController <EasyTableViewDelegate, MyCroniesCardDelegate, MyCroniesQueueDelegate, MonsterTeamSlotDelegate> {
  float _baseMyReservesHeaderX;
}

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *leftHeaderUnderlay;

@property (nonatomic, strong) IBOutlet UIView *availMobstersHeaderView;
@property (nonatomic, strong) IBOutlet UIView *unavailMobstersHeaderView;
@property (nonatomic, strong) IBOutlet UIView *recentlyHealedHeaderView;

@property (nonatomic, strong) IBOutlet MyCroniesQueueView *queueView;
@property (nonatomic, strong) IBOutlet UIView *teamSlotsContainer;

@property (nonatomic, strong) IBOutlet MyCroniesCardCell *monsterCardCell;

@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSArray *recentlyHealedMonsters;
@property (nonatomic, strong) NSArray *availableMonsters;
@property (nonatomic, strong) NSArray *unavailableMonsters;

@property (nonatomic, strong) NSTimer *updateTimer;

- (IBAction)headerClicked:(id)sender;

@end
