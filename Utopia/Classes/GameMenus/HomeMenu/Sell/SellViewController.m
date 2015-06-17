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
#import "AchievementUtil.h"

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
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no available %@s.", MONSTER_NAME];
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ to sell.", MONSTER_NAME];
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
  
  int cur = [gs currentlyUsedInventorySlots];
  int max = [gs maxInventorySlots];
  
  NSString *s1 = [NSString stringWithFormat:@"SELL %@S ", MONSTER_NAME.uppercaseString];
  NSString *str = [NSString stringWithFormat:@"%@(%d/%d)", s1, cur, max];
  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
  
  if (cur > max) {
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
    if ((um.isAvailable || !um.isComplete) && ![self.sellQueue containsObject:um]) {
      [avail addObject:um];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.isProtected != obj2.isProtected) {
      return [@(obj1.isProtected) compare:@(obj2.isProtected)];
    } else if (obj1.isComplete != obj2.isComplete) {
      return [@(obj1.isComplete) compare:@(obj2.isComplete)];
    } else {
      return [obj2 compare:obj1];
    }
  };
  [avail sortUsingComparator:comp];
  self.userMonsters = avail;
}

#pragma mark - Monster Card delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(UserMonster *)listObject {
  if (listView == self.listView) {
    BOOL greyscale = listObject.isProtected;
    [cell updateForListObject:listObject greyscale:greyscale];
  } else if (listView == self.queueView) {
    [cell updateForListObject:listObject];
  }
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  if (!um.isProtected) {
    // Check that he has atleast one other complete mobster
    BOOL hasCompleteMobster = NO;
    for (UserMonster *u in self.userMonsters) {
      if (u.isComplete && um != u) {
        hasCompleteMobster = YES;
      }
    }
    
    if (hasCompleteMobster) {
      if (um.teamSlot > 0) {
        if (!_confirmUserMonster) {
          _confirmUserMonster = um;
          
          NSString *description = [NSString stringWithFormat:@"This %@ is currently on your team. Continue?", MONSTER_NAME];
          [GenericPopupController displayConfirmationWithDescription:description title:@"Continue?" okayButton:@"Continue" cancelButton:@"Cancel" okTarget:self okSelector:@selector(confirmationAccepted) cancelTarget:self cancelSelector:@selector(confirmationCancelled)];
        }
      } else {
        [self confirmationAccepted:um];
      }
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"You can't sell your last complete %@!", MONSTER_NAME]];
    }
  } else {
    MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:YES];
    UIViewController *parent = [GameViewController baseController];
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (void) confirmationCancelled {
  _confirmUserMonster = nil;
}

- (void) confirmationAccepted {
  [self confirmationAccepted:_confirmUserMonster];
  _confirmUserMonster = nil;
}

- (void) confirmationAccepted:(UserMonster *)um {
  [self.sellQueue addObject:um];
  [self.userMonsters removeObject:um];
  
  [self reloadQueueViewAnimated:YES];
  [self animateUserMonsterIntoQueue:um];
  [self reloadListViewAnimated:YES];
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
    NSString *amt = queueSize != 1 ? [NSString stringWithFormat:@"these %d %@s", queueSize, MONSTER_NAME] : [NSString stringWithFormat:@"this %@", MONSTER_NAME];
    NSString *text = [NSString stringWithFormat:@"Would you like to sell %@ for %@?", amt, [Globals cashStringForNumber:sellAmt]];
    [GenericPopupController displayConfirmationWithDescription:text title:[NSString stringWithFormat:@"Sell %@s?", MONSTER_NAME] okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sell)];
  }
}

- (void) sell {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonster *um in self.sellQueue) {
    [arr addObject:um.userMonsterUuid];
  }
  
  [[OutgoingEventController sharedOutgoingEventController] sellUserMonsters:arr];
  [self.sellQueue removeAllObjects];
  [AchievementUtil checkSellMonsters:(int)arr.count];
  
  [self reloadQueueViewAnimated:YES];
  [self reloadTitleView];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
}

@end
