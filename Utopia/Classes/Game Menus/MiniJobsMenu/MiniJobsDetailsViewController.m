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
    
    MSDate *date = [miniJob.timeStarted dateByAddingTimeInterval:miniJob.durationMinutes*60];
    int timeLeft = [date timeIntervalSinceNow];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    self.gemCostLabel.text = [Globals commafyNumber:gemCost];
    [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
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
  [self stopSpinning];
  
  self.availableMonstersLabel.text = [NSString stringWithFormat:@"AVAILABLE %@S", MONSTER_NAME.uppercaseString];
  self.tapMobsterLabel.text = [NSString stringWithFormat:@"Tap a %@ to fill slot", MONSTER_NAME];
}

- (void) viewWillAppear:(BOOL)animated {
  self.sortOrder = MiniJobsSortOrderHpDesc;
  [self reloadTable];
  
  // Hp should be autoclicked
  _clickedButton = (UIButton *)[self.headerView viewWithTag:1];
  
  for (MiniJobsMonsterView *mv in self.monsterViews) {
    [mv updateForMonsterId:0];
  }
  
  self.pickedMonsters = [NSMutableArray array];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  self.inProgressView.frame = self.monstersTable.frame;
  [self.monstersTable.superview addSubview:self.inProgressView];
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.updateTimer invalidate];
}

- (void) updateLabels {
  if (self.activeMiniJob) {
    [self.inProgressView updateTimes:self.activeMiniJob];
  }
}

- (void) setActiveMiniJob:(UserMiniJob *)activeMiniJob {
  _activeMiniJob = activeMiniJob;
  
  if (activeMiniJob) {
    self.monstersTable.hidden = YES;
    self.inProgressView.hidden = NO;
    self.tapCharView.hidden = YES;
    
    [self.inProgressView updateForMiniJob:activeMiniJob];
  } else {
    self.monstersTable.hidden = NO;
    self.inProgressView.hidden = YES;
    self.tapCharView.hidden = NO;
  }
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

- (void) reloadTable {
  [self reloadMonstersArray];
  [self.monstersTable reloadData];
  [self updateBottomLabels];
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
  
  NSString *time = [[Globals convertTimeToShortString:self.userMiniJob.durationMinutes*60] uppercaseString];
  if ([time rangeOfString:@" "].length == 0) {
    time = [Globals convertTimeToLongString:self.userMiniJob.durationMinutes*60];
  }
  self.timeLabel.text = time;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.tapCharView.alpha = self.pickedMonsters.count ? 0.f : 1.f;
  }];
  
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

- (void) animateTableReload:(NSArray *)before {
//  NSArray *after = self.monsterArray;
//  [self.monstersTable beginUpdates];
//  for (int i = 0; i < before.count; i++) {
//    id object = [before objectAtIndex:i];
//    NSInteger newIndex = [after indexOfObject:object];
//    if (newIndex != NSNotFound) {
//      [self.monstersTable moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
//    } else {
//      [self.monstersTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    }
//  }
//  
//  for (int i = 0; i < after.count; i++) {
//    id object = [after objectAtIndex:i];
//    if (![before containsObject:object]) {
//      [self.monstersTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    }
//  }
//  [self.monstersTable endUpdates];
  [self.monstersTable reloadData];
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
  NSArray *oldArr = [self.monsterArray copy];
  [self sortMonsterArray];
  [self animateTableReload:oldArr];
  
  [self clickButton:sender isDesc:self.sortOrder == MiniJobsSortOrderHpDesc];
}

- (IBAction) atkOrderClicked:(id)sender {
  if (self.sortOrder == MiniJobsSortOrderAtkDesc) {
    self.sortOrder = MiniJobsSortOrderAtkAsc;
  } else {
    self.sortOrder = MiniJobsSortOrderAtkDesc;
  }
  NSArray *oldArr = [self.monsterArray copy];
  [self sortMonsterArray];
  [self animateTableReload:oldArr];
  
  [self clickButton:sender isDesc:self.sortOrder == MiniJobsSortOrderAtkDesc];
}

#pragma mark - Picking and unpicking monsters

- (void) pickMonsterAtRow:(int)row {
  if (self.pickedMonsters.count < self.monsterViews.count) {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
    UserMonster *um = self.monsterArray[row];
    MiniJobsDetailsCell *cell = (MiniJobsDetailsCell *)[self.monstersTable cellForRowAtIndexPath:ip];
    
    if (um.curHealth <= 0) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is not healthy enough to go on this mini job.", MONSTER_NAME]];
    } else {
      [self.pickedMonsters addObject:um];
      [self.monsterArray removeObjectAtIndex:row];
      
      cell.monsterView.alpha = 0.f;
      [self.animMonsterView updateForMonsterId:um.monsterId];
      [self.view addSubview:self.animMonsterView];
      self.animMonsterView.frame = [self.view convertRect:cell.monsterView.frame fromView:cell.monsterView.superview];
      
      NSUInteger idx = [self.pickedMonsters indexOfObject:um];
      MiniJobsMonsterView *mv = [self.monsterViews objectAtIndex:idx];
      [UIView animateWithDuration:0.3f animations:^{
        self.animMonsterView.frame = [self.view convertRect:mv.monsterView.frame fromView:mv.monsterView.superview];
      } completion:^(BOOL finished) {
        [mv updateForMonsterId:um.monsterId];
        if (finished) {
          [self.animMonsterView removeFromSuperview];
        }
      }];
      
      [self.monstersTable deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
      
      [self updateBottomLabels];
    }
  } else {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You can't send any more %@s on this mini job.", MONSTER_NAME]];
  }
}

- (IBAction) minusButtonClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsMonsterView class]]) {
    sender = [sender superview];
  }
  
  MiniJobsMonsterView *mv = (MiniJobsMonsterView *)sender;
  if (mv) {
    mv.minusButton.hidden = YES;
    
    UIImage *img = [Globals snapShotView:mv];
    UIImageView *iv = [[UIImageView alloc] initWithImage:img];
    [mv addSubview:iv];
    [mv updateForMonsterId:0];
    
    [UIView animateWithDuration:0.3f animations:^{
      iv.alpha = 0.f;
    }];
    
    NSUInteger idx = [self.monsterViews indexOfObject:mv];
    UserMonster *um = self.pickedMonsters[idx];
    [self.monsterArray addObject:um];
    [self.pickedMonsters removeObject:um];
    
    [self sortMonsterArray];
    idx = [self.monsterArray indexOfObject:um];
    [self.monstersTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    // Reorder monster views so that they match up with pickedMonsters array
    [self.monsterViews removeObject:mv];
    int newIdx = -1;
    for (int i = 0; i < self.monsterViews.count; i++) {
      MiniJobsMonsterView *test = self.monsterViews[i];
      if (!test.monsterView.monsterId && test.tag > mv.tag) {
        newIdx = i;
        break;
      }
    }
    
    if (newIdx >= 0) {
      [self.monsterViews insertObject:mv atIndex:newIdx];
    } else {
      [self.monsterViews addObject:mv];
    }
    
    [self updateBottomLabels];
  }
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
