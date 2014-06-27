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

#define TABLE_CELL_WIDTH 108
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
  
  self.enhancingHeader.transform = CGAffineTransformMakeRotation(-M_PI_2);
  self.myMobstersHeader.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

- (void) viewWillAppear:(BOOL)animated {
  self.updateTimer = [NSTimer timerWithTimeInterval:0.05f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enhanceWaitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enhanceWaitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enhanceWaitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enhanceWaitTimeComplete) name:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  
  [self reloadTableAnimated:NO];
  [self.queueView reloadTable];
  [self updateCurrentTeam];
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  GameState *gs = [GameState sharedGameState];
  if (gs.userEnhancement.baseMonster && gs.userEnhancement.feeders.count == 0) {
    [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
  }
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  [self.queueView updateTimes];
  [self.baseView updateForUserEnhancement:gs.userEnhancement];
}

- (void) updateCurrentTeam {
  GameState *gs = [GameState sharedGameState];
  for (MonsterTeamSlotContainerView *container in self.teamSlotsContainer.subviews) {
    [container.teamSlotView updateForEnhanceConfiguration:[gs myMonsterWithSlotNumber:container.tag]];
  }
}

- (void) enhanceWaitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeam];
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *remove = [NSMutableArray array];
  [Globals calculateDifferencesBetweenOldArray:self.queueView.enhancingQueue newArray:gs.userEnhancement.feeders removalIps:remove additionIps:nil section:0];
  if (remove.count > 0) {
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationTop];
  }
}

#pragma mark - EasyTableViewDelegate and Methods

- (void) setupInventoryTable {
  UIView *superview = self.tableContainerView;
  self.inventoryTable = [[EasyTableView alloc] initWithFrame:superview.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.inventoryTable.delegate = self;
  self.inventoryTable.tableView.separatorColor = [UIColor clearColor];
  self.inventoryTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [superview insertSubview:self.inventoryTable belowSubview:self.queueView];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable) {
      [arr addObject:um];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [obj1 compare:obj2];
  }];
  
  self.monsterArray = arr;
}

- (void) reloadTableAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  NSArray *oldArr = self.monsterArray;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  // Update baseView
  float baseX = 0;
  if (!gs.userEnhancement.baseMonster) {
    baseX = -self.baseViewContainer.frame.size.width+self.myMobstersHeader.frame.size.width;
  }
  void (^anim)(void) = ^{
    CGRect r = self.baseViewContainer.frame;
    r.origin.x = baseX;
    self.baseViewContainer.frame = r;
    
    r = self.inventoryTable.frame;
    r.origin.x = CGRectGetMaxX(self.baseViewContainer.frame);
    r.size.width = self.tableContainerView.frame.size.width-r.origin.x;
    self.inventoryTable.frame = r;
  };
  if (animated) {
    [UIView animateWithDuration:0.3f animations:anim];
  }
  
  [self reloadMonstersArray];
  
  if (animated) {
    [Globals calculateDifferencesBetweenOldArray:oldArr newArray:self.monsterArray removalIps:remove additionIps:add section:0];
    
    [self.inventoryTable.tableView beginUpdates];
    if (remove.count) {
      [self.inventoryTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationFade];
    }
    if (add.count) {
      [self.inventoryTable.tableView insertRowsAtIndexPaths:add withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.inventoryTable.tableView endUpdates];
    
    for (EnhanceCardCell *cell in self.inventoryTable.visibleViews) {
      [self easyTableView:self.inventoryTable setDataForView:cell forIndexPath:[self.inventoryTable indexPathForView:cell]];
    }
  } else {
    anim();
    [self.inventoryTable reloadData];
  }
  
  [self.baseView updateForUserEnhancement:gs.userEnhancement];
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
  [view updateForUserMonster:um withUserEnhancement:gs.userEnhancement];
}

- (IBAction)headerClicked:(id)sender {
  if (self.monsterArray.count > 0) {
    NSInteger section = [(UIView *)sender tag];
    [self.inventoryTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
}

#pragma mark - EnhanceCellDelegate methods

- (void) infoClicked:(EnhanceCardCell *)cell {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:cell.monster allowSell:YES];
  UIViewController *parent = self.navigationController;
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

- (void) cardClicked:(EnhanceCardCell *)cell {
  GameState *gs = [GameState sharedGameState];
  if (!gs.userEnhancement) {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] setBaseEnhanceMonster:cell.monster.userMonsterId];
    if (success) {
      [self reloadTableAnimated:YES];
      [self.queueView reloadTable];
      [self updateCurrentTeam];
      
      if (cell.monster.teamSlot > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      }
    }
  } else if (cell.monster) {
    _confirmUserMonsterId = cell.monster.userMonsterId;
    [self checkUserMonsterOnTeam];
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
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStruct;
  
  if (gs.userEnhancement.feeders.count >= lab.queueSize) {
    [Globals addAlertNotification:@"The laboratory queue is already full!"];
  } else {
    EnhancementItem *newItem = [[EnhancementItem alloc] init];
    newItem.userMonsterId = _confirmUserMonsterId;
    int cost = [gl calculateOilCostForEnhancement:gs.userEnhancement.baseMonster feeder:newItem];
    int curAmount = gs.oil;
    if (cost > curAmount) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeOil amount:cost-curAmount target:self selector:@selector(useGemsForEnhance)];
    } else {
      [self sendEnhanceAllowGems:NO];
    }
  }
}

- (void) useGemsForEnhance {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  EnhancementItem *newItem = [[EnhancementItem alloc] init];
  newItem.userMonsterId = _confirmUserMonsterId;
  int cost = [gl calculateOilCostForEnhancement:gs.userEnhancement.baseMonster feeder:newItem];
  int curAmount = gs.oil;
  int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:cost-curAmount];
  
  if (gemCost > gs.gold) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [self sendEnhanceAllowGems:YES];
  }
}

- (void) sendEnhanceAllowGems:(BOOL)allowGems {
  GameState *gs = [GameState sharedGameState];
  BOOL success = NO;
  if (gs.userEnhancement.baseMonster) {
    success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToEnhancingQueue:_confirmUserMonsterId useGems:allowGems];
  }
  
  if (success) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    
    [self reloadTableAnimated:YES];
    
    GameState *gs = [GameState sharedGameState];
    if (gs.userEnhancement.feeders.count > 0) {
      NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:gs.userEnhancement.feeders.count-1 inSection:0]];
      [self.queueView.queueTable.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
      
      [self.queueView updateTimes];
    }
    
    [self updateCurrentTeam];
  }
}

#pragma mark - EnhanceQueueDelegate methods

- (void) cellRequestsRemovalFromQueue:(EnhanceQueueCell *)cell {
  BOOL success = NO;//[[OutgoingEventController sharedOutgoingEventController] removeMonsterFromEnhancingQueue:cell.enhanceItem];
  
  if (success) {
    [self reloadTableAnimated:YES];
    
    NSArray *arr = [NSArray arrayWithObject:[self.queueView.queueTable indexPathForView:cell]];
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.queueView updateTimes];
    
    [self updateCurrentTeam];
  }
}

- (void) speedupButtonClicked {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = [gl calculateTimeLeftForEnhancement:gs.userEnhancement];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupEnhancingQueue];
    
    if (success) {
      [self reloadTableAnimated:YES];
      
      NSMutableArray *arr = [NSMutableArray array];
      for (int i = 0; i < self.queueView.enhancingQueue.count; i++) {
        [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
      }
      [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
      
      [self updateCurrentTeam];
    }
  }
}

#pragma mark - EnhanceBaseView IBAction

- (IBAction) baseViewMinusClicked:(id)sender {
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
  
  if (success) {
    [self reloadTableAnimated:YES];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.queueView.enhancingQueue.count; i++) {
      [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.queueView.queueTable.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
    
    [self updateCurrentTeam];
  }
}

@end