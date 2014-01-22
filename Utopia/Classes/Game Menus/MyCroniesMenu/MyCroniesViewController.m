//
//  MyCroniesViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/17/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MyCroniesViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "SocketCommunication.h"
#import "MonsterPopUpViewController.h"
#import "GenericPopupController.h"

#define TABLE_CELL_WIDTH 108
#define HEADER_OFFSET 8
#define LEFT_SIDE_OFFSET 18

@implementation MyCroniesViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"My Mobsters";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupInventoryTable];
  
  self.injuredMobstersHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.healthyMobstersHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.unavailMobstersHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.recentlyHealedHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

- (void) viewWillAppear:(BOOL)animated {
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  
  [self reloadTableAnimated:NO];
  [self.queueView reloadTable];
  [self updateCurrentTeamAnimated:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)menuCloseClicked:(id)sender {
  [super menuCloseClicked:sender];
  
  GameState *gs = [GameState sharedGameState];
  [gs.recentlyHealedMonsterIds removeAllObjects];
}

- (IBAction)popCurrentViewController:(id)sender {
  [super popCurrentViewController:sender];
  
  GameState *gs = [GameState sharedGameState];
  [gs.recentlyHealedMonsterIds removeAllObjects];
}

- (void) healWaitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeamAnimated:YES];
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *remove = [NSMutableArray array];
  [Globals calculateDifferencesBetweenOldArray:self.queueView.healingQueue newArray:gs.monsterHealingQueue removalIps:remove additionIps:nil section:0];
  if (remove.count > 0) {
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationTop];
  }
}

- (void) updateLabels {
  for (MyCroniesCardCell *cell in self.inventoryTable.visibleViews) {
    [cell updateForTime];
  }
  
  [self.queueView updateTimes];
}

- (MonsterTeamSlotView *) teamSlotViewForSlotNum:(int)num {
  MonsterTeamSlotContainerView *container = (MonsterTeamSlotContainerView *)[self.teamSlotsContainer viewWithTag:num];
  return container.teamSlotView;
}

- (void) updateCurrentTeamAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  for (MonsterTeamSlotContainerView *container in self.teamSlotsContainer.subviews) {
    if (animated) {
      [container.teamSlotView animateNewMonster:[gs myMonsterWithSlotNumber:container.tag]];
    } else {
      [container.teamSlotView updateForMyCroniesConfiguration:[gs myMonsterWithSlotNumber:container.tag]];
    }
    container.teamSlotView.delegate = self;
  }
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.inventoryTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.inventoryTable.delegate = self;
  self.inventoryTable.tableView.separatorColor = [UIColor clearColor];
  self.inventoryTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.inventoryTable];
  
  [self.inventoryTable.tableView addSubview:self.leftHeaderUnderlay];
  self.inventoryTable.tableView.headerUnderlay = self.leftHeaderUnderlay;
  self.leftHeaderUnderlay.transform = CGAffineTransformMakeRotation(M_PI_2);
  [self easyTableView:self.inventoryTable scrolledToOffset:CGPointZero];
}

- (void) easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset {
  UITableView *table = easyTableView.tableView;
  // Have to do weird adjustments for rotated view
  self.leftHeaderUnderlay.center = ccp(table.frame.size.height/2, table.contentOffset.y+self.leftHeaderUnderlay.frame.size.height/2);
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *recent = [NSMutableArray array];
  NSMutableArray *inj = [NSMutableArray array];
  NSMutableArray *full = [NSMutableArray array];
  NSMutableArray *unavail = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (!um.isComplete || [um isHealing] || [um isEnhancing] || [um isSacrificing]) {
      [unavail addObject:um];
    } else {
      if ([gs.recentlyHealedMonsterIds containsObject:@(um.userMonsterId)]) {
        [recent addObject:um];
      } else {
        if (um.curHealth < [gl calculateMaxHealthForMonster:um]) {
          [inj addObject:um];
        } else {
          [full addObject:um];
        }
      }
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [obj1 compare:obj2];
  };
  
  [recent sortUsingComparator:comp];
  [inj sortUsingComparator:comp];
  [full sortUsingComparator:comp];
  [unavail sortUsingComparator:comp];
  
  self.recentlyHealedMonsters = recent;
  self.injuredMonsters = inj;
  self.healthyMonsters = full;
  self.unavailableMonsters = unavail;
}

- (void) reloadTableAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  NSArray *rec = self.recentlyHealedMonsters, *inj = self.injuredMonsters, *full = self.healthyMonsters, *unavail = self.unavailableMonsters;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  [self reloadMonstersArray];
  
  if (animated) {
    int oldMax = rec.count+inj.count+full.count+unavail.count;
    int newMax = gs.myMonsters.count;
    NSArray *oldSlots = oldMax >= gs.maxInventorySlots ? nil : @[@YES];
    NSArray *newSlots = newMax >= gs.maxInventorySlots ? nil : @[@YES];
    
    [Globals calculateDifferencesBetweenOldArray:inj newArray:self.injuredMonsters removalIps:remove additionIps:add section:0];
    [Globals calculateDifferencesBetweenOldArray:rec newArray:self.recentlyHealedMonsters removalIps:remove additionIps:add section:1];
    [Globals calculateDifferencesBetweenOldArray:full newArray:self.healthyMonsters removalIps:remove additionIps:add section:2];
    [Globals calculateDifferencesBetweenOldArray:unavail newArray:self.unavailableMonsters removalIps:remove additionIps:add section:3];
    [Globals calculateDifferencesBetweenOldArray:oldSlots newArray:newSlots removalIps:remove additionIps:add section:4];
    
    [self.inventoryTable.tableView beginUpdates];
    if (remove.count) {
      [self.inventoryTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationFade];
    }
    if (add.count) {
      [self.inventoryTable.tableView insertRowsAtIndexPaths:add withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.inventoryTable.tableView endUpdates];
    
    for (MyCroniesCardCell *cell in self.inventoryTable.visibleViews) {
      [self easyTableView:self.inventoryTable setDataForView:cell forIndexPath:[self.inventoryTable indexPathForView:cell]];
    }
  } else {
    [self.inventoryTable reloadData];
  }
  [self easyTableView:self.inventoryTable scrolledToOffset:self.inventoryTable.contentOffset];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return self.injuredMobstersHeaderView;
  } else if (section == 1) {
    return self.recentlyHealedHeaderView;
  } else if (section == 2) {
    return self.healthyMobstersHeaderView;
  } else if (section == 3) {
    return self.unavailMobstersHeaderView;
  }
  return nil;
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 5;
}

- (NSArray *)arrayForSection:(int)section {
  if (section == 0) {
    return self.injuredMonsters;
  } else if (section == 1) {
    return self.recentlyHealedMonsters;
  } else if (section == 2) {
    return self.healthyMonsters;
  } else if (section == 3) {
    return self.unavailableMonsters;
  }
  return nil;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  if (section < 4) {
    return [self arrayForSection:section].count;
  } else if (section == 4) {
    return gs.maxInventorySlots > gs.myMonsters.count;
  }
  return 0;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"MyCroniesCardCell" owner:self options:nil];
  return self.monsterCardCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(MyCroniesCardCell *)view forIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section < 4) {
    NSArray *arr = [self arrayForSection:indexPath.section];
    UserMonster *um = indexPath.row < arr.count ? [arr objectAtIndex:indexPath.row] : nil;
    [view updateForUserMonster:um];
  } else if (indexPath.section == 4) {
    GameState *gs = [GameState sharedGameState];
    int numEmpty = gs.maxInventorySlots - gs.myMonsters.count;
    
    [view updateForEmptySlots:numEmpty];
  }
}

- (IBAction)headerClicked:(id)sender {
  int section = [(UIView *)sender tag];
  [self.inventoryTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - MonsterTeamSlotDelegate methods

- (void) minusClickedForTeamSlotView:(MonsterTeamSlotView *)mv {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromTeam:mv.monster.userMonsterId];
  
  if (success) {
    [self reloadTableAnimated:YES];
    [self updateCurrentTeamAnimated:YES];
  }
}

- (void) healAreaClicked:(MonsterTeamSlotView *)mv {
  UserMonster *um = mv.monster;
  [self addMonsterToQueue:um];
}

#pragma mark - MyCroniesCellDelegate methods

- (void) plusClicked:(MyCroniesCardCell *)cell {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToTeam:cell.monster.userMonsterId];
  
  if (success) {
    [self reloadTableAnimated:YES];
    [self updateCurrentTeamAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) buySlotsClicked:(MyCroniesCardCell *)cell {
  //  BuySlotsViewController *mpvc = [[BuySlotsViewController alloc] init];
  //  mpvc.delegate = self;
  //  UIViewController *parent = self.navigationController;
  //  mpvc.view.frame = parent.view.bounds;
  //  [parent.view addSubview:mpvc.view];
  //  [parent addChildViewController:mpvc];
}

- (void) slotsPurchased {
  [self reloadTableAnimated:NO];
}

- (void) infoClicked:(MyCroniesCardCell *)cell {
  if (cell.monster) {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.monster allowSell:YES];
    UIViewController *parent = self.navigationController;
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (void) speedupCombineClicked:(MyCroniesCardCell *)cell {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] combineMonsterWithSpeedup:cell.monster.userMonsterId];
  if (success) {
    [self reloadTableAnimated:YES];
  }
}

- (void) cardClicked:(MyCroniesCardCell *)cell {
  UserMonster *um = cell.monster;
  [self addMonsterToQueue:um];
}

- (void) addMonsterToQueue:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if ([um isHealing]) {
    [Globals addAlertNotification:@"This mobster is already healing!"];
  } else if ([um isEnhancing] || [um isSacrificing]) {
    [Globals addAlertNotification:@"This mobster is currently enhancing!"];
  } else if (!um.isComplete) {
    [Globals addAlertNotification:@"This mobster is not yet complete!"];
  } else if (um.curHealth >= [gl calculateMaxHealthForMonster:um]) {
    [Globals addAlertNotification:@"This mobster is already healthy!"];
  } else if (gs.monsterHealingQueue.count >= gs.maxHospitalQueueSize) {
    [Globals addAlertNotification:@"The hospital queue is already full!"];
  } else {
    int cost = [gl calculateCostToHealMonster:um];
    int curAmount = gs.silver;
    if (cost > curAmount) {
      _tempMonster = um;
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeCash amount:cost-curAmount target:self selector:@selector(useGemsForHeal)];
    } else {
      [self sendHeal:um allowGems:NO];
    }
  }
}

- (void) useGemsForHeal {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int cost = [gl calculateCostToHealMonster:_tempMonster];
  int curAmount = gs.silver;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendHeal:_tempMonster allowGems:YES];
    _tempMonster = nil;
  }
}

- (void) sendHeal:(UserMonster *)um allowGems:(BOOL)allowGems {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToHealingQueue:um.userMonsterId useGems:allowGems];
  if (success) {
    [self reloadTableAnimated:YES];
    
    GameState *gs = [GameState sharedGameState];
    NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:gs.monsterHealingQueue.count-1 inSection:0]];
    [self.queueView.queueTable.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.queueView updateTimes];
    
    if (um.teamSlot) {
      [self updateCurrentTeamAnimated:YES];
    }
  }
}

#pragma mark - MyCroniesQueueDelegate methods

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromHealingQueue:cell.healingItem];
  if (success) {
    [self reloadTableAnimated:YES];
    
    NSArray *arr = [NSArray arrayWithObject:[self.queueView.queueTable indexPathForView:cell]];
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.queueView updateTimes];
    
    GameState *gs = [GameState sharedGameState];
    UserMonster *um = [gs myMonsterWithUserMonsterId:cell.healingItem.userMonsterId];
    if (um.teamSlot) {
      [self updateCurrentTeamAnimated:YES];
    }
  }
}

- (void) speedupButtonClicked {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupHealingQueue];
  if (success) {
    [self reloadTableAnimated:YES];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.queueView.healingQueue.count; i++) {
      [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
    
    [self updateCurrentTeamAnimated:YES];
  }
}

@end
