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

@implementation MyCroniesCardCell

- (void) awakeFromNib {
  self.combineView.center = self.cardContainer.center;
  [self.cardContainer.superview addSubview:self.combineView];
  
  self.healthBarView.frame = self.genLabelView.frame;
  [self.genLabelView.superview addSubview:self.healthBarView];
}

- (void) updateForUserMonster:(UserMonster *)monster {
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
    if ([monster isHealing]) {
      self.genLabel.text = @"Healing";
    } else if ([monster isEnhancing] || [monster isSacrificing]) {
      self.genLabel.text = @"Enhancing";
    } else if (!monster.isComplete) {
      self.plusButton.hidden = YES;
      self.cardContainer.monsterCardView.monsterIcon.alpha = 0.5f;
      if (monster.numPieces < mp.numPuzzlePieces) {
        self.genLabel.text = [NSString stringWithFormat:@"Pieces: %d/%d", monster.numPieces, mp.numPuzzlePieces];
      } else {
        self.combineView.hidden = NO;
        [self updateForTime];
      }
    } else {
      self.healthBarView.hidden = NO;
      self.genLabelView.hidden = YES;
      
      self.healthBar.image = [Globals imageNamed:@"earthcardhealthbar.png"];
      self.healthBar.percentage = monster.curHealth/(float)[gl calculateMaxHealthForMonster:monster];
      
      BOOL isFullHealth = monster.curHealth >= [gl calculateMaxHealthForMonster:monster];
      if (isFullHealth) {
        self.healCostLabel.text = @"Healthy";
      } else {
        self.healCostLabel.text = [Globals cashStringForNumber:[gl calculateCostToHealMonster:monster]];
      }
    }
  }
}

- (void) updateForEmptySlots:(int)numSlots {
  self.monster = nil;
  
  self.plusButton.hidden = YES;
  self.onTeamIcon.hidden = YES;
  self.cardContainer.hidden = NO;
  self.combineView.hidden = YES;
  self.healthBarView.hidden = YES;
  self.genLabelView.hidden = YES;
  [self.cardContainer.monsterCardView updateForNoMonsterWithLabel:[NSString stringWithFormat:@"%d Slot%@ Empty", numSlots, numSlots == 1 ? @"" : @"s"]];
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
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  fileName = [Globals imageNameForElement:mp.monsterElement suffix:@"team.png"];
  [Globals imageNamed:fileName withView:self.bgdIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.timerView.hidden = YES;
  
  self.healingItem = item;
  self.userMonster = um;
}

- (float) totalSeconds {
  float secs = 0;
  for (int i = 0; i < self.healingItem.timeDistribution.count; i += 2) {
    secs += [self.healingItem.timeDistribution[i] floatValue];
  }
  return secs;
}

- (void) updateForTime {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.userMonster;
  float totalSecs = [self totalSeconds];
  float timeLeft = [self.healingItem.endTime timeIntervalSinceNow];
  float timeCompleted = MAX(totalSecs-timeLeft, 0);
  float healthToHeal = [gl calculateMaxHealthForMonster:um]-um.curHealth;
  
  self.timeLabel.text = [Globals convertTimeToShortString:timeLeft];
  
  float percentage = self.healingItem.healthProgress/healthToHeal;
  
  for (int i = 0; i < self.healingItem.timeDistribution.count; i += 2) {
    float secs = [self.healingItem.timeDistribution[i] floatValue];
    float health = [self.healingItem.timeDistribution[i+1] floatValue];
    
    if (timeCompleted > secs) {
      timeCompleted -= secs;
      percentage += health/healthToHeal;
    } else {
      percentage += health/healthToHeal*timeCompleted/secs;
      break;
    }
  }
  
  self.healthBar.percentage = percentage;
  
  self.timerView.hidden = NO;
}

@end

@implementation MyCroniesQueueView

- (void) awakeFromNib {
  [self setupInventoryTable];
}

- (void) reloadTableWithHealingQueue:(NSArray *)healingQueue userMonster:(NSArray *)userMonsters timeLeft:(int)timeLeft hospitalCount:(int)hospitalCount {
  self.healingQueue = healingQueue;
  self.userMonsters = userMonsters;
  _numHospitals = hospitalCount;
  [self.queueTable reloadData];
  [self updateTimeWithTimeLeft:timeLeft hospitalCount:hospitalCount];
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

#pragma mark - EasyTableViewDelegate and Methods

- (void)setupInventoryTable {
  self.queueTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.queueTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  self.queueTable.delegate = self;
  self.queueTable.tableView.separatorColor = [UIColor clearColor];
  self.queueTable.transform = CGAffineTransformMakeScale(-1, 1);
  [self.tableContainerView addSubview:self.queueTable];
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  if (self.healingQueue.count == 0) {
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
    if (self.alpha == 0.f) {
      [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
        self.instructionLabel.alpha = 0.f;
      }];
    } else if (self.instructionLabel.alpha == 1.f) {
      // Have to do this in case queue starts with items
      self.instructionLabel.alpha = 0.f;
    }
  }
  return self.healingQueue.count;
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
  UserMonsterHealingItem *item = [self.healingQueue objectAtIndex:indexPath.row];
  [view updateForHealingItem:item userMonster:[self userMonsterForId:item.userMonsterId]];
  
  if (indexPath.row < _numHospitals) {
    [view updateForTime];
  }
}

@end
