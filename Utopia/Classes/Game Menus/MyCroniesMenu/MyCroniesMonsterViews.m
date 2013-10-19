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

#define TABLE_CELL_WIDTH 72

@implementation MyCroniesCardCell

- (void) awakeFromNib {
  self.healingView.center = self.cardContainer.center;
  [self.cardContainer.superview addSubview:self.healingView];
  
  self.buySlotsView.center = self.cardContainer.center;
  [self.cardContainer.superview addSubview:self.buySlotsView];
  
  self.cardContainer.monsterCardView.delegate = self;
}

- (void) loadHealingMask {
  UIView *view = self.cardContainer.monsterCardView.mainView;
  UIGraphicsBeginImageContext(view.bounds.size);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.healingMask.image = [Globals maskImage:image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
  
  self.healingMask.frame = [self.healingView convertRect:self.cardContainer.monsterCardView.mainView.frame fromView:self.cardContainer.monsterCardView];
}

- (void) updateForUserMonster:(UserMonster *)monster isOnMyTeam:(BOOL)isOnMyTeam isHealing:(BOOL)isHealing {
  if (!monster) {
    [self updateForNoMonsterIsOnMyTeam:isOnMyTeam];
  } else {
    self.monster = monster;
    
    Globals *gl = [Globals sharedGlobals];
    [self.cardContainer.monsterCardView updateForMonster:monster];
    self.buySlotsView.hidden = YES;
    self.cardContainer.hidden = NO;
    
    if (isHealing) {
      [self loadHealingMask];
      self.healingView.hidden = NO;
      self.plusButton.hidden = YES;
      self.minusButton.hidden = YES;
      self.healButtonView.hidden = YES;
    } else {
      self.healingView.hidden = YES;
      self.plusButton.hidden = isOnMyTeam;
      self.minusButton.hidden = !isOnMyTeam;
      
      BOOL isFullHealth = monster.curHealth >= [gl calculateMaxHealthForMonster:monster];
      if (isFullHealth) {
        self.healButtonView.hidden = YES;
      } else {
        self.healButtonView.hidden = NO;
        self.healButtonLabel.text = [Globals cashStringForNumber:[gl calculateCostToHealMonster:monster]];
        [Globals adjustViewForCentering:self.healButtonLabel.superview withLabel:self.healButtonLabel];
      }
    }
  }
}

- (void) updateForNoMonsterIsOnMyTeam:(BOOL)isOnMyTeam {
  self.monster = nil;
  
  self.plusButton.hidden = YES;
  self.minusButton.hidden = YES;
  self.healButtonView.hidden = YES;
  self.healingView.hidden = YES;
  self.buySlotsView.hidden = YES;
  self.cardContainer.hidden = NO;
  if (isOnMyTeam) {
    [self.cardContainer.monsterCardView updateForNoMonsterWithLabel:@"Team Slot Empty"];
  } else {
    [self.cardContainer.monsterCardView updateForNoMonsterWithLabel:@"Reserve Slot Empty"];
  }
}

- (void) updateForBuySlots {
  self.monster = nil;
  
  self.buySlotsView.hidden = NO;
  self.plusButton.hidden = YES;
  self.minusButton.hidden = YES;
  self.healButtonView.hidden = YES;
  self.healingView.hidden = YES;
  self.cardContainer.hidden = YES;
}

#pragma mark - IBAction methods

- (IBAction)plusClicked:(id)sender {
  [self.delegate plusClicked:self];
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate minusClicked:self];
}

- (IBAction)healClicked:(id)sender {
  [self.delegate healClicked:self];
}

- (IBAction)buySlotsClicked:(id)sender {
  [self.delegate buySlotsClicked:self];
}

- (void) equipViewSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

@end

@implementation MyCroniesQueueCell

- (void) updateForHealingItem:(UserMonsterHealingItem *)item {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
//  [Globals loadImageForMonster:um.monsterId toView:self.monsterIcon];
//  self.timerView.hidden = YES;
  
  self.healingItem = item;
}

- (void) updateForTime {
  int timeLeft = [self.healingItem.expectedEndTime timeIntervalSinceNow];
  
  self.timeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.healthBar.percentage = self.healingItem.currentPercentageOfHealth;
  
  self.timerView.hidden = NO;
}

@end

@implementation MyCroniesQueueView

- (void) awakeFromNib {
  [self setupInventoryTable];
}

- (void) reloadTable {
  GameState *gs = [GameState sharedGameState];
  if (gs.monsterHealingQueue.count == 0) {
    self.hidden = YES;
  } else {
    self.hidden = NO;
    [self.queueTable reloadData];
    [self updateTimes];
  }
}

- (void) updateTimes {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = [gl calculateTimeLeftToHealAllMonstersInQueue];
  int speedupCost = [gl calculateCostToSpeedupHealingQueue];
  
  self.totalTimeLabel.text = [Globals convertTimeToShortString:timeLeft];
  self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
  
  MyCroniesQueueCell *cell = (MyCroniesQueueCell *)[self.queueTable viewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [cell updateForTime];
  for (MyCroniesQueueCell *cell in self.queueTable.visibleViews) {
    [cell updateForTime];
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
  self.queueTable.delegate = self;
  self.queueTable.tableView.separatorColor = [UIColor clearColor];
  self.queueTable.transform = CGAffineTransformMakeScale(-1, 1);
  self.queueTable.tableView.bounces = NO;
  [self.tableContainerView addSubview:self.queueTable];
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  return gs.monsterHealingQueue.count;
}

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"MyCroniesQueueCell" owner:self options:nil];
  self.queueCell.transform = CGAffineTransformMakeScale(-1, 1);
  return self.queueCell;
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(MyCroniesQueueCell *)view forIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  UserMonsterHealingItem *item = [gs.monsterHealingQueue objectAtIndex:indexPath.row];
  [view updateForHealingItem:item];
  
  if (indexPath.row == 0) {
    [view updateForTime];
  }
}

@end

@implementation MyCroniesHeaderView

- (void) awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
}

- (void) moveLabelToXPosition:(float)x {
  float diff = x - self.label.center.x;
  self.label.center = ccp(x, self.label.center.y);
  
  CGRect r = self.leftView1.frame;
  r.size.width += diff;
  self.leftView1.frame = r;
  
  r = self.leftView2.frame;
  r.size.width += diff;
  self.leftView2.frame = r;
  
  r = self.rightView1.frame;
  r.origin.x += diff;
  r.size.width -= diff;
  self.rightView1.frame = r;
  
  r = self.rightView2.frame;
  r.origin.x += diff;
  r.size.width -= diff;
  self.rightView2.frame = r;
}

@end
