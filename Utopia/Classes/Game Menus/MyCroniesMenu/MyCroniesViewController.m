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
  [self updateCurrentTeamAnimated:NO];
  [self updateQueueViewAnimated:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)menuCloseClicked:(id)sender {
  [super menuCloseClicked:sender];
  
  [self.recentlyHealedMonsterIds removeAllObjects];
}

- (IBAction)popCurrentViewController:(id)sender {
  [super popCurrentViewController:sender];
  
  [self.recentlyHealedMonsterIds removeAllObjects];
}

- (void) healWaitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeamAnimated:YES];
  [self updateQueueViewAnimated:YES];
}

- (void) updateLabels {
  for (MyCroniesCardCell *cell in self.inventoryTable.visibleViews) {
    [cell updateForTime];
  }
  
  [self.queueView updateTimeWithTimeLeft:self.monsterHealingQueueEndTime.timeIntervalSinceNow hospitalCount:self.numValidHospitals];
}

- (MonsterTeamSlotView *) teamSlotViewForSlotNum:(int)num {
  MonsterTeamSlotContainerView *container = (MonsterTeamSlotContainerView *)[self.teamSlotsContainer viewWithTag:num];
  return container.teamSlotView;
}

- (void) updateCurrentTeamAnimated:(BOOL)animated {
  for (MonsterTeamSlotContainerView *container in self.teamSlotsContainer.subviews) {
    if (animated) {
      [container.teamSlotView animateNewMonster:[self monsterForSlot:container.tag]];
    } else {
      [container.teamSlotView updateForMyCroniesConfiguration:[self monsterForSlot:container.tag]];
    }
    container.teamSlotView.delegate = self;
  }
}

- (void) updateQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated healingQueue:self.monsterHealingQueue userMonster:self.monsterList timeLeft:self.monsterHealingQueueEndTime.timeIntervalSinceNow hospitalCount:self.numValidHospitals];
}

#pragma mark - Potentially rewritable methods

- (NSMutableSet *) recentlyHealedMonsterIds {
  GameState *gs = [GameState sharedGameState];
  return gs.recentlyHealedMonsterIds;
}

- (NSMutableArray *) monsterHealingQueue {
  GameState *gs = [GameState sharedGameState];
  return gs.monsterHealingQueue;
}

- (UserMonster *) monsterForSlot:(NSInteger)slot {
  GameState *gs = [GameState sharedGameState];
  return [gs myMonsterWithSlotNumber:slot];
}

- (NSArray *) monsterList {
  GameState *gs = [GameState sharedGameState];
  return gs.myMonsters;
}

- (int) maxInventorySlots {
  GameState *gs = [GameState sharedGameState];
  return [gs maxInventorySlots];
}

- (MSDate *) monsterHealingQueueEndTime {
  GameState *gs = [GameState sharedGameState];
  return gs.monsterHealingQueueEndTime;
}

- (int) maxQueueSize {
  GameState *gs = [GameState sharedGameState];
  return gs.maxHospitalQueueSize;
}

- (int) numValidHospitals {
  GameState *gs = [GameState sharedGameState];
  return (int)gs.myValidHospitals.count;
}

- (BOOL) userMonsterIsUnavailable:(UserMonster *)um {
  return !um.isComplete || [um isHealing] || [um isEnhancing] || [um isSacrificing];
}

- (BOOL) addMonsterToHealingQueue:(uint64_t)umId useGems:(BOOL)useGems {
  return [[OutgoingEventController sharedOutgoingEventController] addMonsterToHealingQueue:umId useGems:useGems];
}

- (BOOL) speedupHealingQueue {
  return [[OutgoingEventController sharedOutgoingEventController] speedupHealingQueue];
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
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *recent = [NSMutableArray array];
  NSMutableArray *inj = [NSMutableArray array];
  NSMutableArray *full = [NSMutableArray array];
  NSMutableArray *unavail = [NSMutableArray array];
  
  for (UserMonster *um in self.monsterList) {
    if ([self userMonsterIsUnavailable:um]) {
      [unavail addObject:um];
    } else {
      if ([self.recentlyHealedMonsterIds containsObject:@(um.userMonsterId)]) {
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
  NSArray *rec = self.recentlyHealedMonsters, *inj = self.injuredMonsters, *full = self.healthyMonsters, *unavail = self.unavailableMonsters;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  [self reloadMonstersArray];
  
  if (animated) {
    NSInteger oldMax = rec.count+inj.count+full.count+unavail.count;
    NSInteger newMax = self.monsterList.count;
    NSArray *oldSlots = oldMax >= self.maxInventorySlots ? nil : @[@YES];
    NSArray *newSlots = newMax >= self.maxInventorySlots ? nil : @[@YES];
    
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

- (NSArray *)arrayForSection:(NSInteger)section {
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
  if (section < 4) {
    return [self arrayForSection:section].count;
  } else if (section == 4) {
    return self.maxInventorySlots > self.monsterList.count;
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
    NSInteger numEmpty = self.maxInventorySlots - self.monsterList.count;
    
    [view updateForEmptySlots:numEmpty];
  }
}

- (IBAction)headerClicked:(id)sender {
  NSInteger section = [(UIView *)sender tag];
  [self.inventoryTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - MonsterTeamSlotDelegate methods

- (void) minusClickedForTeamSlotView:(MonsterTeamSlotView *)mv {
  if (mv.monster.userMonsterId) {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromTeam:mv.monster.userMonsterId];
    
    if (success) {
      [self reloadTableAnimated:YES];
      [self updateCurrentTeamAnimated:YES];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
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
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = cell.monster.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] combineMonsterWithSpeedup:cell.monster.userMonsterId];
    if (success) {
      [self reloadTableAnimated:YES];
    }
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
  } else if (self.monsterHealingQueue.count >= self.maxQueueSize) {
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
  BOOL success = [self addMonsterToHealingQueue:um.userMonsterId useGems:allowGems];
  if (success) {
    [self reloadTableAnimated:YES];
    [self updateQueueViewAnimated:YES];
    
    if (um.teamSlot) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      
      [self updateCurrentTeamAnimated:YES];
    }
  }
}

#pragma mark - MyCroniesQueueDelegate methods

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromHealingQueue:cell.healingItem];
  if (success) {
    [self reloadTableAnimated:YES];
    [self updateQueueViewAnimated:YES];
    
    GameState *gs = [GameState sharedGameState];
    UserMonster *um = [gs myMonsterWithUserMonsterId:cell.healingItem.userMonsterId];
    if (um.teamSlot) {
      [self updateCurrentTeamAnimated:YES];
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
}

- (void) speedupButtonClicked {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.myValidHospitals.count == 0) {
    [Globals addAlertNotification:@"Your hospital is still upgrading! Finish it first."];
  } else if (gs.gold < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [self speedupHealingQueue];
    if (success) {
      [self reloadTableAnimated:YES];
      [self updateQueueViewAnimated:YES];
      
      [self updateCurrentTeamAnimated:YES];
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
    }
  }
}

@end
