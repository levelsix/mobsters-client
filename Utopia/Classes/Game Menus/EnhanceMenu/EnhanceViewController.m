//
//  EnhanceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "EnhanceViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "SocketCommunication.h"
#import "MonsterPopUpViewController.h"
#import "GenericPopupController.h"

#define TABLE_CELL_WIDTH 123
#define HEADER_OFFSET 8
#define LEFT_SIDE_OFFSET 18

@implementation EnhanceViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Lab";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupInventoryTable];
}

- (void) viewWillAppear:(BOOL)animated {
  self.updateTimer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMonstersArray) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  GameState *gs = [GameState sharedGameState];
  if (gs.userEnhancement.baseMonster && gs.userEnhancement.feeders.count == 0) {
    [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
  }
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.inventoryTable name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  [self.queueView updateTimes];
  [self.baseView updateForUserEnhancement:gs.userEnhancement];
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  UIView *superview = self.queueView.superview;
  self.inventoryTable = [[EasyTableView alloc] initWithFrame:superview.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.inventoryTable.delegate = self;
  self.inventoryTable.tableView.separatorColor = [UIColor clearColor];
  [superview insertSubview:self.inventoryTable belowSubview:self.queueView];
  
  [self reloadMonstersArray];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [gs.myMonsters mutableCopy];
  self.monsterArray = arr;
  
  [self.queueView reloadTable];
  [self.baseView updateForUserEnhancement:gs.userEnhancement];
  
  [self.inventoryTable reloadData];
  
  if (gs.userEnhancement.baseMonster) {
    self.selectBaseLabel.highlighted = YES;
    self.selectFeedersLabel.highlighted = NO;
  } else {
    self.selectBaseLabel.highlighted = NO;
    self.selectFeedersLabel.highlighted = YES;
  }
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return self.monsterArray.count;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"EnhanceCardCell" owner:self options:nil];
  return self.monsterCardCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(EnhanceCardCell *)view forIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [self.monsterArray objectAtIndex:indexPath.row];
  [view updateForUserMonster:um withBaseMonster:gs.userEnhancement.baseMonster];
}

#pragma mark - EnhanceCellDelegate methods

- (void) enhanceClicked:(EnhanceCardCell *)cell {
  _confirmUserMonsterId = cell.monster.userMonsterId;
  [self checkUserMonsterOnTeam];
}

- (void) cardClicked:(EnhanceCardCell *)cell {
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEnhancement) {
    _confirmUserMonsterId = cell.monster.userMonsterId;
    [self checkUserMonsterOnTeam];
  } else if (cell.monster) {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.monster];
    UIViewController *parent = self.navigationController;
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (void) checkUserMonsterOnTeam {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:_confirmUserMonsterId];
  if (um.teamSlot > 0) {
    NSString *description = @"Enhancing mobsters removes them from your squad. Continue?";
    [GenericPopupController displayConfirmationWithDescription:description title:@"Continue?" okayButton:@"Continue" cancelButton:@"Cancel" target:self selector:@selector(confirmationAccepted)];
  } else {
    [self confirmationAccepted];
  }
}

- (void) confirmationAccepted {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:_confirmUserMonsterId];
  
  BOOL unequipped = NO;
  if (um.teamSlot > 0) {
    unequipped = YES;
  }
  
  if (!gs.userEnhancement.baseMonster) {
    [[OutgoingEventController sharedOutgoingEventController] setBaseEnhanceMonster:_confirmUserMonsterId];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] addMonsterToEnhancingQueue:_confirmUserMonsterId];
  }
  [self reloadMonstersArray];
  
  if (unequipped) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
}

#pragma mark - EnhanceQueueDelegate methods

- (void) cellRequestsRemovalFromQueue:(EnhanceQueueCell *)cell {
  [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromEnhancingQueue:cell.enhanceItem];
  [self reloadMonstersArray];
}

- (void) speedupButtonClicked {
  [[OutgoingEventController sharedOutgoingEventController] speedupEnhancingQueue];
  [self reloadMonstersArray];
}

#pragma mark - EnhanceBaseView IBAction

- (IBAction) baseViewMinusClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
  [self reloadMonstersArray];
}

@end