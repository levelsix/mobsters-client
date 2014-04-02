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

@interface AttributedTextView : UIView

@property (nonatomic, retain) NSAttributedString *attrString;

@end

@interface MyCroniesViewController : GenViewController <EasyTableViewDelegate, MyCroniesCardDelegate, MyCroniesQueueDelegate, MonsterTeamSlotDelegate> {
  float _baseMyReservesHeaderX;
  
  UserMonster *_tempMonster;
}

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UIView *leftHeaderUnderlay;

@property (nonatomic, strong) IBOutlet UIView *injuredMobstersHeaderView;
@property (nonatomic, strong) IBOutlet UIView *healthyMobstersHeaderView;
@property (nonatomic, strong) IBOutlet UIView *unavailMobstersHeaderView;
@property (nonatomic, strong) IBOutlet UIView *recentlyHealedHeaderView;

@property (nonatomic, strong) IBOutlet MyCroniesQueueView *queueView;
@property (nonatomic, strong) IBOutlet UIView *teamSlotsContainer;

@property (nonatomic, strong) IBOutlet MyCroniesCardCell *monsterCardCell;

@property (nonatomic, strong) IBOutlet AttributedTextView *titleView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSArray *recentlyHealedMonsters;
@property (nonatomic, strong) NSArray *injuredMonsters;
@property (nonatomic, strong) NSArray *healthyMonsters;
@property (nonatomic, strong) NSArray *unavailableMonsters;

@property (nonatomic, strong) NSTimer *updateTimer;

- (IBAction)headerClicked:(id)sender;

- (void) updateLabels;
- (void) speedupButtonClicked;
- (void) reloadMonstersArray;

- (MonsterTeamSlotView *) teamSlotViewForSlotNum:(int)num;
- (NSMutableSet *) recentlyHealedMonsterIds;
- (NSMutableArray *) monsterHealingQueue;
- (UserMonster *) monsterForSlot:(NSInteger)slot;
- (NSArray *) monsterList;
- (int) maxInventorySlots;
- (int) numValidHospitals;
- (BOOL) userMonsterIsUnavailable:(UserMonster *)um;
- (MSDate *) monsterHealingQueueEndTime;
- (int) maxQueueSize;

@end
