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

#define TABLE_CELL_WIDTH 118
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
}

- (void) viewWillAppear:(BOOL)animated {
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  
  [[NSNotificationCenter defaultCenter] addObserver:self.inventoryTable selector:@selector(reloadData) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.inventoryTable name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) updateLabels {
  [self.queueView updateTimes];
}

- (void) initHeaders {
  int numCells = [self numberOfCellsForEasyTableView:self.inventoryTable inSection:0];
  CGRect r = self.myTeamHeaderView.frame;
  r.origin.x = LEFT_SIDE_OFFSET+HEADER_OFFSET;
  r.size.width = numCells*TABLE_CELL_WIDTH-HEADER_OFFSET*2;
  self.myTeamHeaderView.frame = r;
  
  [self.myTeamHeaderView moveLabelToXPosition:numCells*TABLE_CELL_WIDTH/2-HEADER_OFFSET];
  
  int baseOffset = LEFT_SIDE_OFFSET+numCells*TABLE_CELL_WIDTH;
  baseOffset += [self easyTableView:self.inventoryTable heightOrWidthForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
  numCells = [self numberOfCellsForEasyTableView:self.inventoryTable inSection:2];
  r = self.myReservesHeaderView.frame;
  r.origin.x = baseOffset+HEADER_OFFSET;
  r.size.width = numCells*TABLE_CELL_WIDTH-HEADER_OFFSET*2;
  self.myReservesHeaderView.frame = r;
  
  _baseMyReservesHeaderX = 1.5*TABLE_CELL_WIDTH-HEADER_OFFSET;
  
  [self easyTableView:self.inventoryTable scrolledToOffset:self.inventoryTable.contentOffset];
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.inventoryTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.inventoryTable.delegate = self;
  self.inventoryTable.tableView.separatorColor = [UIColor clearColor];
  [self.tableContainerView addSubview:self.inventoryTable];
  
  self.headerContainerView = [[UIView alloc] initWithFrame:CGRectZero];
  [self.inventoryTable addSubview:self.headerContainerView];
  [self.headerContainerView addSubview:self.myTeamHeaderView];
  [self.headerContainerView addSubview:self.myReservesHeaderView];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [gs.myMonsters mutableCopy];
  [arr removeObjectsInArray:[gs allMonstersOnMyTeam]];
  self.monstersNotOnTeam = arr;
  
  [self.queueView reloadTable];
  
  [self initHeaders];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEFT_SIDE_OFFSET, 0)];
  }
  return nil;
}

- (void) easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset {
  self.headerContainerView.frame = CGRectMake(-contentOffset.x, 0, 0, 0);
  float mid = [self.view convertPoint:ccp(self.view.frame.size.width/2, 0) toView:self.myReservesHeaderView].x;
  [self.myReservesHeaderView moveLabelToXPosition:MIN(MAX(mid, _baseMyReservesHeaderX), self.myReservesHeaderView.frame.size.width-_baseMyReservesHeaderX)];
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  [self reloadMonstersArray];
  return 3;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  if (section == 0) {
    return gl.maxTeamSize;
  } else if (section == 2) {
    return MAX(gl.baseInventorySize + gs.numAdditionalMonsterSlots, self.monstersNotOnTeam.count) + 1;
  } else {
    return 1;
  }
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"MyCroniesCardCell" owner:self options:nil];
  return self.monsterCardCell;
}

- (float) easyTableView:(EasyTableView *)easyTableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != 1) {
    return TABLE_CELL_WIDTH;
  } else {
    return self.tableSeperatorView.frame.size.width;
  }
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(MyCroniesCardCell *)view forIndexPath:(NSIndexPath *)indexPath {
  if (self.tableSeperatorView.superview == view) {
    [self.tableSeperatorView removeFromSuperview];
    view.mainView.hidden = NO;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (indexPath.section == 0) {
    UserMonster *um = [gs myMonsterWithSlotNumber:indexPath.row+1];
    [view updateForUserMonster:um isOnMyTeam:YES];
  } else if (indexPath.section == 2) {
    int numCells = [self numberOfCellsForEasyTableView:easyTableView inSection:indexPath.section];
    if (indexPath.row < numCells-1) {
      UserMonster *um = indexPath.row < self.monstersNotOnTeam.count ? [self.monstersNotOnTeam objectAtIndex:indexPath.row] : nil;
      [view updateForUserMonster:um isOnMyTeam:NO];
    } else {
      // Buy slots cell
      [view updateForBuySlots];
    }
  } else {
    view.mainView.hidden = YES;
    [view addSubview:self.tableSeperatorView];
  }
}

#pragma mark - MyCroniesCellDelegate methods

- (void) minusClicked:(MyCroniesCardCell *)cell {
  [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromTeam:cell.monster.userMonsterId];
  [self.inventoryTable reloadData];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

- (void) plusClicked:(MyCroniesCardCell *)cell {
  [[OutgoingEventController sharedOutgoingEventController] addMonsterToTeam:cell.monster.userMonsterId];
  [self.inventoryTable reloadData];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

- (void) buySlotsClicked:(MyCroniesCardCell *)cell {
  [[OutgoingEventController sharedOutgoingEventController] buyInventorySlots];
  [self.inventoryTable reloadData];
}

- (void) healClicked:(MyCroniesCardCell *)cell {
  BOOL unequipped = NO;
  if (cell.monster.teamSlot > 0) {
    unequipped = YES;
  }
  [[OutgoingEventController sharedOutgoingEventController] addMonsterToHealingQueue:cell.monster.userMonsterId];
  [self.inventoryTable reloadData];
  
  if (unequipped) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) cardClicked:(MyCroniesCardCell *)cell {
  if (cell.monster) {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.monster];
    UIViewController *parent = self.navigationController;
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (void) speedupCombineClicked:(MyCroniesCardCell *)cell {
  [self.inventoryTable reloadData];
}

#pragma mark - MyCroniesQueueDelegate methods

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromHealingQueue:cell.healingItem];
  [self.inventoryTable reloadData];
}

- (void) speedupButtonClicked {
  [[OutgoingEventController sharedOutgoingEventController] speedupHealingQueue];
  [self.inventoryTable reloadData];
}

@end
