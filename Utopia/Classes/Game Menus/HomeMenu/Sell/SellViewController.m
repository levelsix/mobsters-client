//
//  SellViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SellViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "MonsterPopUpViewController.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "OutgoingEventController.h"

#define NIB_NAME @"SellCardCell"

@implementation SellViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"SellCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.listView.cellClassName = @"SellCardCell";
  
  self.titleImageName = @"residencemenuheader.png";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  self.sellQueue = [NSMutableArray array];
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [self reloadTitleView];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self reloadTitleView];
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  
  NSString *s1 = @"SELL MOBSTERS ";
  NSString *str = [NSString stringWithFormat:@"%@(%d/%d)", s1, (int)gs.myMonsters.count, gs.maxInventorySlots];
  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
  
  if (gs.myMonsters.count >= gs.maxInventorySlots) {
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.f green:1/255.f blue:0.f alpha:1.f] range:NSMakeRange(s1.length, str.length-s1.length)];
  }
  self.attributedTitle = attrStr;
}

#pragma mark - Reloading collection view

- (void) reloadQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated listObjects:self.sellQueue];
  
  int sellAmt = 0;
  for (UserMonster *um in self.sellQueue) {
    sellAmt += um.sellPrice;
  }
  
  // Only set it if its > 0 because otherwise it will just fade out
  if (sellAmt > 0) {
    self.sellCostLabel.text = [Globals cashStringForNumber:sellAmt];
  }
}

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.userMonsters];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *avail = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailableForSelling && ![self.sellQueue containsObject:um]) {
      [avail addObject:um];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.isComplete != obj2.isComplete) {
      return [@(obj1.isComplete) compare:@(obj2.isComplete)];
    } else {
      return [obj2 compare:obj1];
    }
  };
  [avail sortUsingComparator:comp];
  self.userMonsters = avail;
}

#pragma mark - Monster Card delegate

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  // Check that he has atleast one other complete mobster
  BOOL hasCompleteMobster = NO;
  for (UserMonster *u in self.userMonsters) {
    if (u.isComplete && um != u) {
      hasCompleteMobster = YES;
    }
  }
  
  if (hasCompleteMobster) {
    [self.sellQueue addObject:um];
    
    [self reloadQueueViewAnimated:YES];
    [self animateUserMonsterIntoQueue:um];
    [self reloadListViewAnimated:YES];
  } else {
    [Globals addAlertNotification:@"You can't sell your last complete mobster!"];
  }
}

- (void) animateUserMonsterIntoQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.userMonsters indexOfObject:um];
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
  UserMonster *um = self.sellQueue[indexPath.row];
  [self.sellQueue removeObject:um];
  
  [self reloadListViewAnimated:YES];
  [self animateUserMonsterOutOfQueue:um];
  [self reloadQueueViewAnimated:YES];
}

- (void) animateUserMonsterOutOfQueue:(UserMonster *)um {
  int monsterIndex = (int)[self.userMonsters indexOfObject:um];
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

- (IBAction)sellClicked:(id)sender {
  if (self.sellQueue.count) {
    int sellAmt = 0;
    for (UserMonster *um in self.sellQueue) {
      sellAmt += um.sellPrice;
    }
    
    int queueSize = (int)self.sellQueue.count;
    NSString *amt = queueSize != 1 ? [NSString stringWithFormat:@"these %d mobsters", queueSize] : @"this mobster";
    NSString *text = [NSString stringWithFormat:@"Would you like to sell %@ for %@?", amt, [Globals cashStringForNumber:sellAmt]];
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
  
  [self reloadQueueViewAnimated:YES];
  [self reloadTitleView];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
}

@end
