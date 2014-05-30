//
//  MyCroniesMonsterViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MyCroniesMonsterViews.h"
#import "Globals.h"
#import "GameState.h"

#define TABLE_CELL_WIDTH 54

@implementation MyCroniesTabBar

- (void) clickButton:(int)button {
  self.label1.highlighted = NO;
  self.label2.highlighted = NO;
  self.label3.highlighted = NO;
  
  self.icon1.highlighted = NO;
  self.icon2.highlighted = NO;
  self.icon3.highlighted = NO;
  
  UILabel *label = nil;
  UIImageView *icon = nil;
  if (button == 1) {
    label = self.label1;
    icon = self.icon1;
  } else if (button == 2) {
    label = self.label2;
    icon = self.icon2;
  }
  label.highlighted = YES;
  icon.highlighted = YES;
  
  if (button == 1) {
    self.selectedView.center = ccp(self.selectedView.center.x, self.frame.size.height*3/4);
    self.selectedView.transform = CGAffineTransformIdentity;
    self.selectedView.tag = 2;
  } else if (button == 2) {
    self.selectedView.center = ccp(self.selectedView.center.x, self.frame.size.height/4);
    self.selectedView.transform = CGAffineTransformMakeScale(1, -1);
    self.selectedView.tag = 1;
  }
}

@end

@implementation MyCroniesCardCell

- (void) awakeFromNib {
  self.combineView.center = self.cardContainer.center;
  [self.cardContainer.superview addSubview:self.combineView];
  
  self.healthBarView.frame = self.genLabelView.frame;
  [self.genLabelView.superview addSubview:self.healthBarView];
}

- (void) updateForUserMonster:(UserMonster *)monster showSellCost:(BOOL)showSellCost {
  if (!monster) {
    [self updateForEmptySlots:0];
  } else {
    self.cardContainer.monsterCardView.delegate = self;
    self.monster = monster;
    
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:monster.monsterId];
    [self.cardContainer.monsterCardView updateForMonster:monster];
    self.cardContainer.hidden = NO;
    
    self.plusButton.hidden = monster.teamSlot > 0;
    self.onTeamIcon.hidden = monster.teamSlot == 0;
    
    self.healthBarView.hidden = YES;
    self.genLabelView.hidden = NO;
    self.combineView.hidden = YES;
    self.cardContainer.monsterCardView.monsterIcon.alpha = 1.f;
    
    self.genLabel.text = [monster statusString];
    if (![monster isAvailable]) {
      if (!monster.isComplete) {
        self.plusButton.hidden = YES;
        self.cardContainer.monsterCardView.monsterIcon.alpha = 0.5f;
        if (monster.numPieces >= mp.numPuzzlePieces) {
          self.combineView.hidden = NO;
          [self updateForTime];
        }
      }
    } else {
      self.healthBarView.hidden = NO;
      self.genLabelView.hidden = YES;
      
      self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:monster.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:monster]]];
      self.healthBar.percentage = monster.curHealth/(float)[gl calculateMaxHealthForMonster:monster];
      
      if (!showSellCost) {
        BOOL isFullHealth = monster.curHealth >= [gl calculateMaxHealthForMonster:monster];
        if (isFullHealth) {
          self.healCostLabel.text = @"Healthy";
        } else {
          self.healCostLabel.text = [Globals cashStringForNumber:[gl calculateCostToHealMonster:monster]];
        }
      } else {
        self.healCostLabel.text = [Globals cashStringForNumber:monster.sellPrice];
      }
    }
  }
}

- (void) updateForEmptySlots:(NSInteger)numSlots {
  self.monster = nil;
  
  self.plusButton.hidden = YES;
  self.onTeamIcon.hidden = YES;
  self.cardContainer.hidden = NO;
  self.combineView.hidden = YES;
  self.healthBarView.hidden = YES;
  self.genLabelView.hidden = YES;
  [self.cardContainer.monsterCardView updateForNoMonsterWithLabel:[NSString stringWithFormat:@"%d Slot%@ Empty", (int)numSlots, numSlots == 1 ? @"" : @"s"]];
}

- (void) updateForTime {
  if (self.monster) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = self.monster;
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    if (!um.isComplete && um.numPieces >= mp.numPuzzlePieces) {
      int timeLeft = [um timeLeftForCombining];
      self.genLabel.text = [NSString stringWithFormat:@"Combines in %@", [Globals convertTimeToShortString:timeLeft]];
      self.combineCostLabel.text = [Globals commafyNumber:[gl calculateGemSpeedupCostForTimeLeft:timeLeft]];
    }
  }
}

#pragma mark - IBAction methods

- (IBAction)plusClicked:(id)sender {
  [self.delegate plusClicked:self];
}

- (void) infoClicked:(MonsterCardView *)view {
  [self.delegate infoClicked:self];
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

- (IBAction) speedupCombineClicked:(id)sender {
  [self.delegate speedupCombineClicked:self];
}

@end

@implementation MyCroniesQueueCell

- (void) updateForHealingItem:(UserMonsterHealingItem *)item userMonster:(UserMonster *)um {
  [self.monsterView updateForMonsterId:um.monsterId];
  
  self.timerView.hidden = YES;
  
  self.healingItem = item;
  self.userMonster = um;
}

- (void) updateForSellMonster:(UserMonster *)um {
  [self.monsterView updateForMonsterId:um.monsterId];
  
  self.timerView.hidden = YES;
  self.userMonster = um;
}

- (void) updateForTime {
  float timeLeft = [self.healingItem.endTime timeIntervalSinceNow];
  self.timeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.healthBar.percentage = [self.healingItem currentPercentageWithUserMonster:self.userMonster];
  
  self.timerView.hidden = NO;
}

@end

@implementation MyCroniesQueueView

- (void) awakeFromNib {
  [self setupInventoryTable];
  
  self.sellButtonView.frame = self.healButtonView.frame;
  [self.healButtonView.superview addSubview:self.sellButtonView];
}

- (void) reloadTableAnimated:(BOOL)animated oldArr:(NSArray *)oldArr newArr:(NSArray *)newArr {
  if (animated) {
    NSMutableArray *additions = [NSMutableArray array];
    NSMutableArray *remove = [NSMutableArray array];
    [Globals calculateDifferencesBetweenOldArray:oldArr newArray:newArr removalIps:remove additionIps:additions section:0];
    
    [self.queueTable.tableView beginUpdates];
    if (remove.count > 0) {
      [self.queueTable.tableView deleteRowsAtIndexPaths:remove withRowAnimation:UITableViewRowAnimationTop];
    }
    if (additions.count > 0) {
      [self.queueTable.tableView insertRowsAtIndexPaths:additions withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.queueTable.tableView endUpdates];
  } else {
    [self.queueTable reloadData];
  }
  [self getQueueCountAndUpdateOpacitiesAnimated:animated];
}

- (void) reloadTableAnimated:(BOOL)animated healingQueue:(NSArray *)healingQueue userMonster:(NSArray *)userMonsters timeLeft:(int)timeLeft hospitalCount:(int)hospitalCount {
  self.instructionLabel.text = @"Tap an injured mobster to begin healing.";
  _isInSellMode = NO;
  
  NSArray *oldQueue = self.healingQueue;
  self.healingQueue = healingQueue.copy;
  self.userMonsters = userMonsters;
  _numHospitals = hospitalCount;
  [self updateTimeWithTimeLeft:timeLeft hospitalCount:hospitalCount];
  
  [self reloadTableAnimated:animated oldArr:oldQueue newArr:self.healingQueue];
  
  self.sellButtonView.hidden = YES;
  self.healButtonView.hidden = NO;
}

- (void) reloadTableAnimated:(BOOL)animated sellMonsters:(NSArray *)userMonsters {
  self.instructionLabel.text = @"Tap a mobster to sell.";
  _isInSellMode = YES;
  
  NSArray *oldQueue = self.sellQueue;
  self.healingQueue = nil;
  self.userMonsters = nil;
  self.sellQueue = userMonsters.copy;
  
  [self reloadTableAnimated:animated oldArr:oldQueue newArr:self.sellQueue];
  
  self.sellButtonView.hidden = NO;
  self.healButtonView.hidden = YES;
  
  int sellAmt = 0;
  for (UserMonster *um in self.sellQueue) {
    sellAmt += um.sellPrice;
  }
  self.sellCostLabel.text = [Globals cashStringForNumber:sellAmt];
}

- (void) updateTimeWithTimeLeft:(int)timeLeft hospitalCount:(int)hospitalCount {
  Globals *gl = [Globals sharedGlobals];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (hospitalCount > 0) {
    self.totalTimeLabel.text = [Globals convertTimeToShortString:timeLeft];
    self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
    
    for (int i = 0; i < hospitalCount; i++) {
      MyCroniesQueueCell *cell = (MyCroniesQueueCell *)[self.queueTable viewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
      [cell updateForTime];
    }
  } else {
    self.totalTimeLabel.text = @"N/A";
    self.speedupCostLabel.text = @"N/A";
  }
}

- (IBAction)minusClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[MyCroniesQueueCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    [self.delegate cellRequestsRemovalFromHealQueue:sender];
  }
}

- (IBAction)speedupClicked:(id)sender {
  [self.delegate speedupButtonClicked];
}

- (IBAction)sellClicked:(id)sender {
  [self.delegate sellButtonClicked];
}

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.queueTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.queueTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.queueTable.delegate = self;
  self.queueTable.tableView.separatorColor = [UIColor clearColor];
  self.queueTable.transform = CGAffineTransformMakeScale(-1, 1);
  [self.tableContainerView addSubview:self.queueTable];
}

- (int) getQueueCountAndUpdateOpacitiesAnimated:(BOOL)animated {
  NSArray *queue = !_isInSellMode ? self.healingQueue : self.sellQueue;
  if (queue.count == 0) {
    if (animated) {
      if (self.instructionLabel.alpha == 0.f) {
        [UIView animateWithDuration:0.3f animations:^{
          self.alpha = 0.f;
          self.instructionLabel.alpha = 1.f;
        }];
      } else {
        // Have to do this in case queue starts without items
        self.alpha = 0.f;
      }
    } else {
      [self.layer removeAllAnimations];
      [self.instructionLabel.layer removeAllAnimations];
      self.alpha = 0.f;
      self.instructionLabel.alpha = 1.f;
    }
  } else {
    if (animated) {
      if (self.alpha == 0.f) {
        [UIView animateWithDuration:0.3f animations:^{
          self.alpha = 1.f;
          self.instructionLabel.alpha = 0.f;
        }];
      } else if (self.instructionLabel.alpha == 1.f) {
        // Have to do this in case queue starts with items
        self.instructionLabel.alpha = 0.f;
      }
    } else {
      [self.layer removeAllAnimations];
      [self.instructionLabel.layer removeAllAnimations];
      self.alpha = 1.f;
      self.instructionLabel.alpha = 0.f;
    }
  }
  return (int)queue.count;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return [self getQueueCountAndUpdateOpacitiesAnimated:YES];
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"MyCroniesQueueCell" owner:self options:nil];
  self.queueCell.transform = CGAffineTransformMakeScale(-1, 1);
  self.queueCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.queueCell;
}

- (UserMonster *) userMonsterForId:(uint64_t)userMonsterId {
  for (UserMonster *um in self.userMonsters) {
    if (um.userMonsterId == userMonsterId) {
      return um;
    }
  }
  return nil;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(MyCroniesQueueCell *)view forIndexPath:(NSIndexPath *)indexPath {
  if (!_isInSellMode) {
    UserMonsterHealingItem *item = self.healingQueue[indexPath.row];
    [view updateForHealingItem:item userMonster:[self userMonsterForId:item.userMonsterId]];
    
    if (indexPath.row < _numHospitals) {
      [view updateForTime];
    }
  } else {
    UserMonster *um = self.sellQueue[indexPath.row];
    [view updateForSellMonster:um];
  }
}

@end
