//
//  MiniJobsDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsDetailsViewController.h"
#import "GameState.h"
#import "Globals.h"

@implementation MiniJobsQueueFooterView

- (void) awakeFromNib {
  self.queueFullLabel.strokeColor = self.queueFullLabel.textColor;
  self.queueFullLabel.textColor = [UIColor whiteColor];
  self.queueFullLabel.strokeSize = 0.5;
}

@end

@implementation MiniJobsDetailsCell

- (void) updateForUserMonster:(UserMonster *)um requiredHp:(int)reqHp requiredAttack:(int)reqAtk {
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *mp = um.staticMonster;
  
  [self.monsterView updateForMonsterId:um.monsterId];
  
  self.nameLabel.text = mp.displayName;
  self.levelLabel.text = [NSString stringWithFormat:@"LVL. %d", um.level];
  
  int curHealth = um.curHealth, curAtk = [gl calculateTotalDamageForMonster:um];
  self.hpLabel.text = [NSString stringWithFormat:@"HP: %@", [Globals commafyNumber:curHealth]];
  self.attackLabel.text = [NSString stringWithFormat:@"ATTACK: %@", [Globals commafyNumber:curAtk]];
  
  self.hpProgressBar.percentage = curHealth/(float)reqHp;
  self.attackProgressBar.percentage = curAtk/(float)reqAtk;
  
  self.userMonster = um;
}

@end

@implementation MiniJobsMonsterView

- (void) updateForMonsterId:(int)monsterId {
  [self.monsterView updateForMonsterId:monsterId];
  self.minusButton.hidden = !monsterId;
}

@end

@implementation MiniJobsInProgressView

- (void) awakeFromNib {
  self.completeView.frame = self.finishView.frame;
}

- (void) updateForMiniJob:(UserMiniJob *)miniJob {
  self.nameLabel.text = miniJob.miniJob.name;
  self.nameLabel.textColor = [Globals colorForRarity:miniJob.miniJob.quality];
  
  if (miniJob.timeCompleted) {
    self.completeView.hidden = NO;
    self.finishView.hidden = YES;
    
    self.inProgressLabel.highlighted = YES;
    self.inProgressLabel.text = @"You must collect the reward for your\ncurrent mini job before starting another.";
  } else if (miniJob.timeStarted) {
    [self updateTimes:miniJob];
    
    self.completeView.hidden = YES;
    self.finishView.hidden = NO;
    
    self.inProgressLabel.highlighted = NO;
    self.inProgressLabel.text = @"You must finish your current mini job\nbefore starting another.";
  }
}

- (void) updateTimes:(UserMiniJob *)miniJob {
  if (miniJob.timeStarted) {
    Globals *gl = [Globals sharedGlobals];
    
    MSDate *date = miniJob.tentativeCompletionDate;
    int timeLeft = [date timeIntervalSinceNow];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    if (gemCost > 0) {
      self.gemCostLabel.text = [Globals commafyNumber:gemCost];
      [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
      
      self.gemCostLabel.superview.hidden = NO;
      self.speedupIcon.hidden = NO;
      self.freeLabel.hidden = YES;
    } else {
      self.gemCostLabel.superview.hidden = YES;
      self.speedupIcon.hidden = YES;
      self.freeLabel.hidden = NO;
    }
  }
}

@end

@implementation MiniJobsDetailsViewController

- (id) initWithMiniJob:(UserMiniJob *)miniJob {
  if ((self = [super init])) {
    self.userMiniJob = miniJob;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self stopSpinning];
  
  self.availableMonstersLabel.text = [NSString stringWithFormat:@"AVAILABLE %@S", MONSTER_NAME.uppercaseString];
  
  self.title = self.userMiniJob.miniJob.name;
  
  self.slotsAvailableLabel.strokeSize = 0.5f;
  self.slotsAvailableLabel.strokeColor = [UIColor colorWithRed:127/255.f green:168/255.f blue:39/255.f alpha:1.f];
  
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.queueView.footerClassName = @"MiniJobsQueueFooterView";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.sortOrder = MiniJobsSortOrderHpDesc;
  [self reloadTableAnimated:NO];
  [self updateBottomLabels];
  
  // Hp should be autoclicked
  _clickedButton = (UIButton *)[self.headerView viewWithTag:1];
  
  self.pickedMonsters = [NSMutableArray array];
  
  self.inProgressView.center = self.monstersTable.center;
  [self.monstersTable.superview addSubview:self.inProgressView];
}

- (void) updateLabels {
  if (self.activeMiniJob) {
    [self.inProgressView updateTimes:self.activeMiniJob];
  }
}

- (void) waitTimeComplete {
  [self reloadTableAnimated:YES];
}

- (void) setActiveMiniJob:(UserMiniJob *)activeMiniJob {
  _activeMiniJob = activeMiniJob;
  
  if (activeMiniJob) {
    self.monstersTable.hidden = YES;
    self.inProgressView.hidden = NO;
    
    [self.inProgressView updateForMiniJob:activeMiniJob];
  } else {
    self.monstersTable.hidden = NO;
    self.inProgressView.hidden = YES;
  }
}

- (void) reloadQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated listObjects:self.pickedMonsters];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && ![self.pickedMonsters containsObject:um]) {
      [arr addObject:um];
    }
  }
  
  self.monsterArray = arr;
  
  [self sortMonsterArray];
}

- (void) updateBottomLabels {
  Globals *gl = [Globals sharedGlobals];
  int totalHp = 0, totalAtk = 0;
  for (UserMonster *um in self.pickedMonsters) {
    totalHp += um.curHealth;
    totalAtk += [gl calculateTotalDamageForMonster:um];
  }
  
  int reqHp = self.userMiniJob.miniJob.hpRequired, reqAtk = self.userMiniJob.miniJob.atkRequired;
  self.hpLabel.text = [NSString stringWithFormat:@"REQ. HP: %@/%@", [Globals commafyNumber:totalHp], [Globals commafyNumber:reqHp]];
  self.attackLabel.text = [NSString stringWithFormat:@"REQ. ATK: %@/%@", [Globals commafyNumber:totalAtk], [Globals commafyNumber:reqAtk]];
  self.hpProgressBar.percentage = totalHp/(float)reqHp;
  self.attackProgressBar.percentage = totalAtk/(float)reqAtk;
  
  //self.hpLabel.highlighted = totalHp >= reqHp;
  //self.attackLabel.highlighted = totalAtk >= reqAtk;
  
  self.timeLabel.text = [Globals convertTimeToMediumString:self.userMiniJob.durationSeconds];
  
  int maxAllowed = self.userMiniJob.miniJob.maxNumMonstersAllowed;
  self.slotsAvailableLabel.text = [NSString stringWithFormat:@"%d Slot%@ Available", maxAllowed, maxAllowed == 1 ? @"" : @"s"];
  self.queueArrow.highlighted = self.pickedMonsters.count >= maxAllowed;
  
  [self updateOpenSlotsView];
  
  if (totalHp >= reqHp && totalAtk >= reqAtk) {
    self.engageArrow.highlighted = NO;
    [self.engageButton setImage:[Globals imageNamed:@"engagebutton.png"] forState:UIControlStateNormal];
    
    self.engageLabel.textColor = [UIColor colorWithRed:61/255.f green:114/255.f blue:1/255.f alpha:1.f];
    self.engageLabel.shadowColor = [UIColor colorWithRed:253/255.f green:255/255.f blue:95/255.f alpha:0.75];
  } else {
    self.engageArrow.highlighted = YES;
    [self.engageButton setImage:[Globals imageNamed:@"engagedisabled.png"] forState:UIControlStateNormal];
    
    self.engageLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.engageLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
  }
}

- (void) updateOpenSlotsView {
  int maxQueueSize = self.userMiniJob.miniJob.maxNumMonstersAllowed;
  int curQueueSize = (int)self.pickedMonsters.count;
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

#pragma mark - IBAction responders

- (IBAction) engageClicked:(id)sender {
  [self.delegate beginMiniJob:self.userMiniJob withUserMonsters:self.pickedMonsters];
}

- (IBAction) finishClicked:(id)sender {
  [self.delegate activeMiniJobSpedUp:self.activeMiniJob];
}

- (IBAction) collectClicked:(id)sender {
  [self.delegate activeMiniJobCompleted:self.activeMiniJob];
}

- (void) beginEngageSpinning {
  self.engageLabelsView.hidden = YES;
  self.engageSpinner.hidden = NO;
  [self.engageSpinner startAnimating];
}

- (void) beginFinishSpinning {
  self.inProgressView.finishLabelsView.hidden = YES;
  self.inProgressView.finishSpinner.hidden = NO;
  [self.inProgressView.finishSpinner startAnimating];
}

- (void) beginCollectSpinning {
  self.inProgressView.completeLabelsView.hidden = YES;
  self.inProgressView.completeSpinner.hidden = NO;
  [self.inProgressView.completeSpinner startAnimating];
}

- (void) stopSpinning {
  self.engageLabelsView.hidden = NO;
  self.engageSpinner.hidden = YES;
  self.inProgressView.completeLabelsView.hidden = NO;
  self.inProgressView.completeSpinner.hidden = YES;
  self.inProgressView.finishLabelsView.hidden = NO;
  self.inProgressView.finishSpinner.hidden = YES;
}

#pragma mark - Sorting monsters

- (void) sortMonsterArray {
  [self.monsterArray sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    int pt1 = 0, pt2 = 0;
    if (self.sortOrder == MiniJobsSortOrderHpAsc) {
      pt1 = obj1.curHealth;
      pt2 = obj2.curHealth;
    } else if (self.sortOrder == MiniJobsSortOrderHpDesc) {
      pt1 = obj2.curHealth;
      pt2 = obj1.curHealth;
    } else {
      Globals *gl = [Globals sharedGlobals];
      if (self.sortOrder == MiniJobsSortOrderAtkAsc) {
        pt1 = [gl calculateTotalDamageForMonster:obj1];
        pt2 = [gl calculateTotalDamageForMonster:obj2];
      } else if (self.sortOrder == MiniJobsSortOrderAtkDesc) {
        pt1 = [gl calculateTotalDamageForMonster:obj2];
        pt2 = [gl calculateTotalDamageForMonster:obj1];
      }
    }
    if (pt1 != pt2) {
      return [@(pt1) compare:@(pt2)];
    } else {
      return [obj1 compare:obj2];
    }
  }];
}

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *before = [self.monsterArray copy];
  [self reloadMonstersArray];
  
  NSMutableArray *removedIps = [NSMutableArray array], *addedIps = [NSMutableArray array];
  NSMutableDictionary *movedIps = [NSMutableDictionary dictionary];
  
  [Globals calculateDifferencesBetweenOldArray:before newArray:self.monsterArray removalIps:removedIps additionIps:addedIps movedIps:movedIps section:0];
  
  [self.monstersTable beginUpdates];
  
  [self.monstersTable deleteRowsAtIndexPaths:removedIps withRowAnimation:UITableViewRowAnimationFade];
  
  for (NSIndexPath *ip in movedIps) {
    NSIndexPath *newIp = movedIps[ip];
    [self.monstersTable moveRowAtIndexPath:ip toIndexPath:newIp];
  }
  [self.monstersTable insertRowsAtIndexPaths:addedIps withRowAnimation:UITableViewRowAnimationFade];
  
  [self.monstersTable endUpdates];
}

- (void) clickButton:(UIButton *)button isDesc:(BOOL)isDesc {
  [_clickedButton setTitleColor:[UIColor colorWithWhite:0.f alpha:0.6f] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor colorWithWhite:51/255.f alpha:1.f] forState:UIControlStateNormal];
  _clickedButton = button;
  
  self.headerArrow.center = ccp(CGRectGetMaxX(button.frame)+5.f, self.headerArrow.center.y);
  if (isDesc) {
    self.headerArrow.transform = CGAffineTransformIdentity;
  } else {
    self.headerArrow.transform = CGAffineTransformMakeScale(1, -1);
  }
}

- (IBAction) hpOrderClicked:(id)sender {
  if (self.sortOrder == MiniJobsSortOrderHpDesc) {
    self.sortOrder = MiniJobsSortOrderHpAsc;
  } else {
    self.sortOrder = MiniJobsSortOrderHpDesc;
  }
  [self reloadTableAnimated:YES];
  
  [self clickButton:sender isDesc:self.sortOrder == MiniJobsSortOrderHpDesc];
}

- (IBAction) atkOrderClicked:(id)sender {
  if (self.sortOrder == MiniJobsSortOrderAtkDesc) {
    self.sortOrder = MiniJobsSortOrderAtkAsc;
  } else {
    self.sortOrder = MiniJobsSortOrderAtkDesc;
  }
  [self reloadTableAnimated:YES];
  
  [self clickButton:sender isDesc:self.sortOrder == MiniJobsSortOrderAtkDesc];
}

#pragma mark - Picking and unpicking monsters

- (void) pickMonsterAtRow:(int)row {
  if (self.pickedMonsters.count < self.userMiniJob.miniJob.maxNumMonstersAllowed) {
    UserMonster *um = self.monsterArray[row];
    
    if (um.curHealth <= 0) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is not healthy enough to go on this mini job.", MONSTER_NAME]];
    } else {
      [self.pickedMonsters addObject:um];
      
      [self reloadQueueViewAnimated:YES];
      [self animateIntoQueue:um];
      [self reloadTableAnimated:YES];
      
      [self updateBottomLabels];
    }
  } else {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You can't send any more %@s on this mini job.", MONSTER_NAME]];
  }
}

- (void) animateIntoQueue:(UserMonster *)um {
  NSInteger monsterIndex = [self.monsterArray indexOfObject:um];
  MiniJobsDetailsCell *listCell = (MiniJobsDetailsCell *)[self.monstersTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  MiniMonsterView *listMonsterView = listCell.monsterView;
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
  
  if (listMonsterView && queueCell) {
    [self.queueCell updateForListObject:um];
    [self.animMonsterView updateForMonsterId:um.monsterId];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.animMonsterView aboveSubview:self.monstersTable];
    
    [Globals animateStartView:listMonsterView toEndView:queueCell fakeStartView:self.animMonsterView fakeEndView:self.queueCell];
  } else {
    [self.queueView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.pickedMonsters[indexPath.row];
  
  [self.pickedMonsters removeObject:um];
  
  [self reloadTableAnimated:YES];
  [self animateOutOfQueue:um];
  [self reloadQueueViewAnimated:YES];
  
  [self updateBottomLabels];
}

- (void) animateOutOfQueue:(UserMonster *)um {
  NSInteger monsterIndex = [self.monsterArray indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
  MiniJobsDetailsCell *listCell = (MiniJobsDetailsCell *)[self.monstersTable cellForRowAtIndexPath:ip];
  MiniMonsterView *listMonsterView = listCell.monsterView;
  
  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:monsterIndex inSection:0]];
  
  if (listMonsterView && queueCell) {
    [self.queueCell updateForListObject:um];
    [self.animMonsterView updateForMonsterId:um.monsterId];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.animMonsterView aboveSubview:self.monstersTable];
    
    [Globals animateStartView:queueCell toEndView:listMonsterView fakeStartView:self.queueCell fakeEndView:self.animMonsterView];
  } else {
    [self.monstersTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
  }
}

- (void) listView:(ListCollectionView *)listView updateFooterView:(id)footerView {
  _footerView = footerView;
  [self updateOpenSlotsView];
}

#pragma mark - UITableView dataSource/delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.monsterArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MiniJobsDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiniJobsDetailsCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsDetailsCell" owner:self options:nil];
    cell = self.detailsCell;
  }
  
  UserMonster *um = self.monsterArray[indexPath.row];
  int reqHp = self.userMiniJob.miniJob.hpRequired, reqAtk = self.userMiniJob.miniJob.atkRequired;
  [cell updateForUserMonster:um requiredHp:reqHp requiredAttack:reqAtk];
  
  // In case this row was just animated out
  cell.monsterView.alpha = 1.f;
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  [self pickMonsterAtRow:(int)indexPath.row];
}

@end
