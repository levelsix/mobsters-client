//
//  HealViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HealViewController.h"

#import "GameState.h"
#import "Globals.h"

#import "OutgoingEventController.h"
#import "SocketCommunication.h"

#import "AchievementUtil.h"

@implementation HealQueueFooterView

@end

@implementation HealViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"HealCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.queueView.footerClassName = @"HealQueueFooterView";
  self.listView.cellClassName = @"HealCardCell";
  
  self.title = @"HEAL MOBSTERS";
  self.titleImageName = @"";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  self.queueView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [self updateLabels];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[SocketCommunication sharedSocketCommunication] flush];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
}

- (void) updateLabels {
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int hospitalCount = self.numValidHospitals;
  
  Globals *gl = [Globals sharedGlobals];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (hospitalCount > 0) {
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
    [Globals adjustViewForCentering:self.speedupCostLabel.superview withLabel:self.speedupCostLabel];
    
    for (int i = 0; i < hospitalCount && i < self.monsterHealingQueue.count; i++) {
      MonsterQueueCell *cell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
      [self updateCellForTime:cell index:i];
    }
  } else {
    self.timeLabel.text = @"N/A";
    self.speedupCostLabel.text = @"N/A";
  }
  
  [self updateOpenSlotsView];
}

- (void) updateCellForTime:(MonsterQueueCell *)cell index:(int)i {
  UserMonsterHealingItem *hi = self.monsterHealingQueue[i];
  [cell updateTimeWithTimeLeft:hi.endTime.timeIntervalSinceNow percent:hi.currentPercentage];
}

- (void) updateOpenSlotsView {
  int maxQueueSize = self.maxQueueSize;
  int curQueueSize = (int)self.monsterHealingQueue.count;
  int openSlots = maxQueueSize-curQueueSize;
  
  if (openSlots > 0) {
    _footerView.openSlotsLabel.text = [NSString stringWithFormat:@"%d SLOT%@ OPEN", openSlots, openSlots == 1 ? @"" : @"S"];
    
    _footerView.openSlotsLabel.hidden = NO;
    _footerView.openSlotsBorder.hidden = NO;
    _footerView.queueFullLabel.hidden = YES;
  } else {
    _footerView.openSlotsLabel.hidden = YES;
    _footerView.openSlotsBorder.hidden = YES;
    _footerView.queueFullLabel.hidden = NO;
  }
}

#pragma mark - Potentially rewritable methods

- (NSMutableArray *) monsterHealingQueue {
  GameState *gs = [GameState sharedGameState];
  return gs.monsterHealingQueue;
}

- (NSArray *) monsterList {
  GameState *gs = [GameState sharedGameState];
  return gs.myMonsters;
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

- (BOOL) userMonsterIsAvailable:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  return um.isAvailable && um.curHealth < [gl calculateMaxHealthForMonster:um];
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

#pragma mark - Refreshing collection view

- (void) reloadQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated listObjects:self.monsterHealingQueue];
  
  if (self.monsterHealingQueue.count >= self.maxQueueSize) {
    self.queueArrow.highlighted = YES;
  } else {
    self.queueArrow.highlighted = NO;
  }
}

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.userMonsters];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if ([self userMonsterIsAvailable:um]) {
      [arr addObject:um];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [obj1 compare:obj2];
  }];
  
  self.userMonsters = arr;
}

#pragma mark - MonsterListView delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id)listObject {
  if (listView == self.listView) {
    [cell updateForListObject:listObject];
  } else if (listView == self.queueView) {
    // Grab the user monster for this healing item
    UserMonster *um = self.monsterList[[self.monsterList indexOfObject:listObject]];
    [cell updateForListObject:um];
    
    if (indexPath.row < self.numValidHospitals) {
      [self updateCellForTime:(MonsterQueueCell *)cell index:(int)indexPath.row];
    }
  }
}

- (void) listView:(ListCollectionView *)listView updateFooterView:(HealQueueFooterView *)footerView {
  _footerView = footerView;
  [self updateOpenSlotsView];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  [self addMonsterToHealQueue:um];
}

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
    [self reloadQueueViewAnimated:YES];
    [self animateUserMonsterIntoQueue:um];
    [self reloadListViewAnimated:YES];
    
    [self updateLabels];
    
    if (um.teamSlot) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
}

- (void) animateUserMonsterIntoQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
  
  if (cardCell && queueCell) {
    [self.queueCell updateForListObject:um];
    [self.cardCell updateForListObject:um];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
    
    [Globals animateStartView:cardCell toEndView:queueCell fakeStartView:self.cardCell fakeEndView:self.queueCell];
  } else {
    [self.queueView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonsterHealingItem *hi = self.monsterHealingQueue[indexPath.row];
  UserMonster *um = self.monsterList[[self.monsterList indexOfObject:hi]];
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromHealingQueue:hi];
  if (success) {
    [self reloadListViewAnimated:YES];
    [self animateUserMonsterOutOfQueue:um];
    [self reloadQueueViewAnimated:YES];
    
    [self updateLabels];
    
    if (um.teamSlot) {
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
}

- (void) animateUserMonsterOutOfQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:monsterIndex inSection:0]];
  
  if (cardCell && queueCell) {
    [self.queueCell updateForListObject:um];
    [self.cardCell updateForListObject:um];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
    
    [Globals animateStartView:queueCell toEndView:cardCell fakeStartView:self.queueCell fakeEndView:self.cardCell];
  } else {
    [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

- (IBAction) speedupButtonClicked:(id)sender {
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
      [self reloadListViewAnimated:YES];
      [self reloadQueueViewAnimated:YES];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
    }
  }
}

@end
