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
#import "BuySlotsViewController.h"

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
  
  self.availMobstersHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.unavailMobstersHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.recentlyHealedHeaderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

- (void) viewWillAppear:(BOOL)animated {
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healWaitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
  
  [self reloadTableAnimated:NO];
  [self.queueView reloadTable];
  [self updateCurrentTeamAnimated:NO];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.inventoryTable];
}

- (void) didMoveToParentViewController:(UIViewController *)parent {
  if (parent == nil) {
    GameState *gs = [GameState sharedGameState];
    [gs.recentlyHealedMonsterIds removeAllObjects];
  }
}

- (void) healWaitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeamAnimated:YES];
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *remove = [NSMutableArray array];
  [Globals calculateDifferencesBetweenOldArray:self.queueView.healingQueue newArray:gs.monsterHealingQueue removalIps:remove additionIps:nil section:0];
  [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationTop];
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
  NSMutableArray *recent = [NSMutableArray array];
  NSMutableArray *reg = [NSMutableArray array];
  NSMutableArray *unavail = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (!um.isComplete || [um isHealing] || [um isEnhancing] || [um isSacrificing]) {
      [unavail addObject:um];
    } else {
      if ([gs.recentlyHealedMonsterIds containsObject:@(um.userMonsterId)]) {
        [recent addObject:um];
      } else {
        [reg addObject:um];
      }
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [obj1 compare:obj2];
  };
  
  [recent sortUsingComparator:comp];
  [reg sortUsingComparator:comp];
  [unavail sortUsingComparator:comp];
  
  self.recentlyHealedMonsters = recent;
  self.availableMonsters = reg;
  self.unavailableMonsters = unavail;
}

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *rec = self.recentlyHealedMonsters, *avail = self.availableMonsters, *unavail = self.unavailableMonsters;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  [self reloadMonstersArray];
  
  if (animated) {
    [Globals calculateDifferencesBetweenOldArray:rec newArray:self.recentlyHealedMonsters removalIps:remove additionIps:add section:0];
    [Globals calculateDifferencesBetweenOldArray:avail newArray:self.availableMonsters removalIps:remove additionIps:add section:1];
    [Globals calculateDifferencesBetweenOldArray:unavail newArray:self.unavailableMonsters removalIps:remove additionIps:add section:2];
    
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
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return self.recentlyHealedHeaderView;
  } else if (section == 1) {
    return self.availMobstersHeaderView;
  } else if (section == 2) {
    return self.unavailMobstersHeaderView;
  }
  return nil;
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 4;
}

- (NSArray *)arrayForSection:(int)section {
  if (section == 0) {
    return self.recentlyHealedMonsters;
  } else if (section == 1) {
    return self.availableMonsters;
  } else if (section == 2) {
    return self.unavailableMonsters;
  }
  return nil;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  if (section < 3) {
    return [self arrayForSection:section].count;
  } else if (section == 3) {
    return (gl.baseInventorySize + gs.numAdditionalMonsterSlots > gs.myMonsters.count) + 1;
  }
  return 0;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"MyCroniesCardCell" owner:self options:nil];
  return self.monsterCardCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(MyCroniesCardCell *)view forIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section < 3) {
    NSArray *arr = [self arrayForSection:indexPath.section];
    UserMonster *um = indexPath.row < arr.count ? [arr objectAtIndex:indexPath.row] : nil;
    [view updateForUserMonster:um];
  } else if (indexPath.section == 3) {
    Globals *gl = [Globals sharedGlobals];
    GameState *gs = [GameState sharedGameState];
    int numEmpty = gl.baseInventorySize + gs.numAdditionalMonsterSlots - gs.myMonsters.count;
    
    if (numEmpty > 0 && indexPath.row == 0) {
      [view updateForEmptySlots:numEmpty];
    } else {
      [view updateForBuySlots];
    }
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

#pragma mark - MyCroniesCellDelegate methods

- (void) plusClicked:(MyCroniesCardCell *)cell {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToTeam:cell.monster.userMonsterId];
  
  if (success) {
    [self reloadTableAnimated:YES];
    [self updateCurrentTeamAnimated:YES];
  }
}

- (void) buySlotsClicked:(MyCroniesCardCell *)cell {
  BuySlotsViewController *mpvc = [[BuySlotsViewController alloc] init];
  mpvc.delegate = self;
  UIViewController *parent = self.navigationController;
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

- (void) slotsPurchased {
  [self reloadTableAnimated:NO];
}

- (void) infoClicked:(MyCroniesCardCell *)cell {
  if (cell.monster) {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.monster];
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
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToHealingQueue:cell.monster.userMonsterId];
  if (success) {
    [self reloadTableAnimated:YES];
    
    GameState *gs = [GameState sharedGameState];
    NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:gs.monsterHealingQueue.count-1 inSection:0]];
    [self.queueView.queueTable.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.queueView updateTimes];
    
    if (cell.monster.teamSlot) {
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
