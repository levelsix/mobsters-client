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
#import "AchievementUtil.h"

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
  [self reloadTitleView];
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

- (IBAction)menuBackClicked:(id)sender {
  [super menuBackClicked:sender];
  
  [self.recentlyHealedMonsterIds removeAllObjects];
}

- (void) healWaitTimeComplete {
  [self reloadTableAnimated:YES];
  [self updateCurrentTeamAnimated:YES];
  [self updateQueueViewAnimated:YES];
  [self reloadTitleView];
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
  paragrapStyle.alignment = NSTextAlignmentCenter;
  
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowColor = [UIColor colorWithWhite:0.f alpha:0.75f];
  shadow.shadowOffset = CGSizeMake(0, 1);
  
  NSString *str = [NSString stringWithFormat:@"Mobsters (%d/%d)", (int)self.monsterList.count, self.maxInventorySlots];
  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
  
  if (gs.myMonsters.count >= gs.maxInventorySlots) {
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.f green:192/255.f blue:0.f alpha:1.f] range:NSMakeRange(10, attrStr.length-11)];
  }
  self.titleLabel.attributedText = attrStr;
}

- (void) updateLabels {
  for (MyCroniesCardCell *cell in self.inventoryTable.visibleViews) {
    [cell updateForTime];
  }
  
  if (!_isInSellMode) {
    [self.queueView updateTimeWithTimeLeft:self.monsterHealingQueueEndTime.timeIntervalSinceNow hospitalCount:self.numValidHospitals];
  }
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
  if (!_isInSellMode) {
    [self.queueView reloadTableAnimated:animated healingQueue:self.monsterHealingQueue userMonster:self.monsterList timeLeft:self.monsterHealingQueueEndTime.timeIntervalSinceNow hospitalCount:self.numValidHospitals];
  } else {
    [self.queueView reloadTableAnimated:animated sellMonsters:self.sellQueue];
  }
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
  return !um.isAvailable;
}

- (BOOL) userMonsterIsUnavailableForSale:(UserMonster *)um {
  return !um.isAvailableForSelling;
}

- (BOOL) addMonsterToHealingQueue:(uint64_t)umId useGems:(BOOL)useGems {
  return [[OutgoingEventController sharedOutgoingEventController] addMonsterToHealingQueue:umId useGems:useGems];
}

- (BOOL) speedupHealingQueue {
  int queueSize = (int)self.monsterHealingQueue.count;
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupHealingQueue];
  if (success) {
    [AchievementUtil checkMonstersHealed:queueSize];
  }
  return success;
}

#pragma mark - Tab Bar delegate

- (void) button1Clicked:(id)sender {
  [self.tabBar clickButton:1];
  _isInSellMode = NO;
  [self reloadTableAnimated:NO];
  [self updateQueueViewAnimated:NO];
}

- (void) button2Clicked:(id)sender {
  [self.tabBar clickButton:2];
  _isInSellMode = YES;
  
  self.sellQueue = [NSMutableArray array];
  [self reloadTableAnimated:NO];
  [self updateQueueViewAnimated:NO];
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
  NSMutableArray *avail = [NSMutableArray array];
  
  for (UserMonster *um in self.monsterList) {
    if (!_isInSellMode) {
      if ([self userMonsterIsUnavailable:um]) {
        [unavail addObject:um];
      } else {
        if (um.curHealth < [gl calculateMaxHealthForMonster:um]) {
          [inj addObject:um];
        } else {
          if ([self.recentlyHealedMonsterIds containsObject:@(um.userMonsterId)]) {
            [recent addObject:um];
          } else {
            [full addObject:um];
          }
        }
      }
    } else {
      if ([self userMonsterIsUnavailableForSale:um]) {
        [unavail addObject:um];
      } else {
        [avail addObject:um];
      }
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (!_isInSellMode) {
      return [obj1 compare:obj2];
    } else {
      if (!obj1.isAvailableForSelling || !obj2.isAvailableForSelling ||
          !obj1.isComplete || !obj2.isComplete) {
        return [obj1 compare:obj2];
      } else {
        return [obj2 compare:obj1];
      }
    }
  };
  
  [recent sortUsingComparator:comp];
  [inj sortUsingComparator:comp];
  [full sortUsingComparator:comp];
  [unavail sortUsingComparator:comp];
  [avail sortUsingComparator:comp];
  
  self.recentlyHealedMonsters = recent;
  self.injuredMonsters = inj;
  self.healthyMonsters = full;
  self.unavailableMonsters = unavail;
  self.availableMonsters = avail;
}

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *rec = self.recentlyHealedMonsters, *inj = self.injuredMonsters, *full = self.healthyMonsters, *unavail = self.unavailableMonsters, *avail = self.availableMonsters;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  [self reloadMonstersArray];
  
  if (animated) {
    NSInteger oldMax = rec.count+inj.count+full.count+unavail.count+avail.count;
    NSInteger newMax = self.monsterList.count;
    NSArray *oldSlots = oldMax >= self.maxInventorySlots ? nil : @[@YES];
    NSArray *newSlots = newMax >= self.maxInventorySlots ? nil : @[@YES];
    
    if (!_isInSellMode) {
      [Globals calculateDifferencesBetweenOldArray:inj newArray:self.injuredMonsters removalIps:remove additionIps:add section:0];
      [Globals calculateDifferencesBetweenOldArray:rec newArray:self.recentlyHealedMonsters removalIps:remove additionIps:add section:1];
      [Globals calculateDifferencesBetweenOldArray:full newArray:self.healthyMonsters removalIps:remove additionIps:add section:2];
      [Globals calculateDifferencesBetweenOldArray:unavail newArray:self.unavailableMonsters removalIps:remove additionIps:add section:3];
    } else {
      [Globals calculateDifferencesBetweenOldArray:avail newArray:self.availableMonsters removalIps:remove additionIps:add section:0];
      [Globals calculateDifferencesBetweenOldArray:unavail newArray:self.unavailableMonsters removalIps:remove additionIps:add section:1];
    }
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

- (NSString *) easyTableView:(EasyTableView *)easyTableView stringForVerticalHeaderInSection:(NSInteger)section {
  if (!_isInSellMode) {
    if (section == 0) {
      return @"Injured";
    } else if (section == 1) {
      return @"Recently Healed";
    } else if (section == 2) {
      return @"Healthy";
    } else if (section == 3) {
      return @"Unavailable";
    }
  } else {
    if (section == 0) {
      return @"Available For Sale";
    } else if (section == 1) {
      return @"Unavailable For Sale";
    }
  }
  return nil;
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 5;
}

- (NSArray *)arrayForSection:(NSInteger)section {
  if (!_isInSellMode) {
    if (section == 0) {
      return self.injuredMonsters;
    } else if (section == 1) {
      return self.recentlyHealedMonsters;
    } else if (section == 2) {
      return self.healthyMonsters;
    } else if (section == 3) {
      return self.unavailableMonsters;
    }
  } else {
    if (section == 0) {
      return self.availableMonsters;
    } else if (section == 1) {
      return self.unavailableMonsters;
    }
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
    [view updateForUserMonster:um showSellCost:_isInSellMode];
  } else if (indexPath.section == 4) {
    NSInteger numEmpty = self.maxInventorySlots - self.monsterList.count;
    
    [view updateForEmptySlots:numEmpty];
  }
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
  if (!_isInSellMode) {
    UserMonster *um = mv.monster;
    [self addMonsterToHealQueue:um];
  }
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
  
  if (!_isInSellMode) {
    [self addMonsterToHealQueue:um];
  } else {
    [self addMonsterToSellQueue:um];
  }
}

#pragma mark -
#pragma mark Heal Queue

- (void) addMonsterToHealQueue:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (![um isAvailable]) {
    [Globals addAlertNotification:@"This mobster is not available!"];
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
    // Use this ordering so the new one appears in the queue, then table is reloaded after animation begins
    [self updateQueueViewAnimated:YES];
    [self animateUserMonsterId:um];
    [self reloadTableAnimated:YES];
    
    if (um.teamSlot) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      
      [self updateCurrentTeamAnimated:YES];
    }
  }
}

- (void) animateUserMonsterId:(UserMonster *)um {
  int monsterIndex = (int)[self.injuredMonsters indexOfObject:um];
  MyCroniesCardCell *cardCell = (MyCroniesCardCell *)[self.inventoryTable viewAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  if (!cardCell) {
    return;
  }
  
  int hiIdx = -1;
  for (UserMonsterHealingItem *hi in self.monsterHealingQueue) {
    if (hi.userMonsterId == um.userMonsterId) {
      hiIdx = (int)[self.monsterHealingQueue indexOfObject:hi];
    }
  }
  MyCroniesQueueCell *queueCell = (MyCroniesQueueCell *)[self.queueView.queueTable viewAtIndexPath:[NSIndexPath indexPathForRow:hiIdx inSection:0]];
  
  [[NSBundle mainBundle] loadNibNamed:@"MonsterCardView" owner:self options:nil];
  MonsterCardView *mcv = self.monsterCardView;
  [mcv updateForMonster:um];
  [self.view addSubview:mcv];
  
  UIView *qv = [[UIView alloc] initWithFrame:CGRectZero];
  [self.view addSubview:qv];
  
  UIImageView *bgd = [[UIImageView alloc] initWithImage:queueCell.monsterView.bgdIcon.image];
  UIImageView *main = [[UIImageView alloc] initWithImage:queueCell.monsterView.monsterIcon.image];
  [qv addSubview:bgd];
  [qv addSubview:main];
  main.center = bgd.center;
  
  mcv.center = [self.view convertPoint:cardCell.cardContainer.monsterCardView.center fromView:cardCell.cardContainer.monsterCardView.superview];
  qv.frame = queueCell.monsterView.frame;
  qv.center = mcv.center;
  qv.alpha = 0.f;
  
  cardCell.hidden = YES;
  queueCell.hidden = YES;
  [UIView animateWithDuration:0.3f animations:^{
    qv.alpha = 1.f;
    qv.center = [self.view convertPoint:queueCell.monsterView.center fromView:queueCell.monsterView.superview];
    
    mcv.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    mcv.center = qv.center;
    mcv.alpha = 0.f;
  } completion:^(BOOL finished) {
    [mcv removeFromSuperview];
    [qv removeFromSuperview];
    
    cardCell.hidden = NO;
    queueCell.hidden = NO;
  }];
}

#pragma mark Sell Queue

- (void) addMonsterToSellQueue:(UserMonster *)um {
  if ([self.sellQueue containsObject:um]) {
    [Globals addAlertNotification:@"This mobster is already in the sell queue."];
  } else if (!um.isAvailableForSelling) {
    [Globals addAlertNotification:@"This mobster cannot be sold at this time."];
  } else {
    [self.sellQueue addObject:um];
    [self updateQueueViewAnimated:YES];
  }
}

#pragma mark - MyCroniesQueueDelegate methods

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  if (!_isInSellMode) {
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
  } else {
    [self.sellQueue removeObject:cell.userMonster];
    [self updateQueueViewAnimated:YES];
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

- (void) sellButtonClicked {
  if (self.sellQueue.count) {
    int sellAmt = 0;
    for (UserMonster *um in self.sellQueue) {
      sellAmt += um.sellPrice;
    }
    
    NSString *text = [NSString stringWithFormat:@"Would you like to sell these %d mobsters for %@?", (int)self.sellQueue.count, [Globals cashStringForNumber:sellAmt]];
    [GenericPopupController displayConfirmationWithDescription:text title:@"Sell Mobsters?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sell)];
  }
}

- (void) sell {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonster *um in self.sellQueue) {
    [arr addObject:@(um.userMonsterId)];
  }
  
  [[OutgoingEventController sharedOutgoingEventController] sellUserMonsters:arr];
  [self.sellQueue removeAllObjects];
  
  [self reloadTableAnimated:YES];
  [self updateQueueViewAnimated:YES];
  [self updateCurrentTeamAnimated:YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
}

@end
