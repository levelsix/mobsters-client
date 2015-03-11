//
//  ItemFactoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ItemFactoryViewController.h"

#import "SocketCommunication.h"
#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

@interface ItemFactoryViewController ()

@end

@implementation ItemFactoryViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.titleImageName = @"hospitalmenuheader.png";
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"ItemFactoryCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.listView.cellClassName = @"ItemFactoryCardCell";
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  
  self.buttonSpinner.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  self.queueView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [self reloadTitleView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [[SocketCommunication sharedSocketCommunication] pauseFlushTimer];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[SocketCommunication sharedSocketCommunication] flush];
  [[SocketCommunication sharedSocketCommunication] resumeFlushTimer];
  
  [self.itemSelectViewController closeClicked:nil];
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStruct;
  NSString *str = [NSString stringWithFormat:@"%@ (%d/%d POWER)", factory.structInfo.name, 0, factory.powerLimit];
  self.title = str;
}

#pragma mark - Refreshing collection view

- (void) reloadQueueViewAnimated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  [self.queueView reloadTableAnimated:animated listObjects:gs.battleItemUtil.battleItemQueue.queueObjects];
}

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.itemList];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *avail = [NSMutableArray array];
  
  for (BattleItemProto *item in gs.staticBattleItems.allValues) {
    if (_scope == ItemFactoryScopeAll ||
        (_scope == ItemFactoryScopePotions && item.battleItemCategory == BattleItemCategoryPotion) ||
        (_scope == ItemFactoryScopePotions && item.battleItemCategory == BattleItemCategoryPuzzle)) {
      [avail addObject:item];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(BattleItemProto *obj1, BattleItemProto *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  };
  [avail sortUsingComparator:comp];
  self.itemList = avail;
}


#pragma mark - MonsterListView delegate

//- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
//  BattleItemQueueObject *biq = self.itemList[indexPath.row];
//  [self addBattleItemToQueue:biq indexPath:indexPath];
//}
//
//- (void) addBattleItemToQueue:(BattleItemQueueObject *)um indexPath:(NSIndexPath*)indexPath {
//  GameState *gs = [GameState sharedGameState];
//  Globals *gl = [Globals sharedGlobals];
//  if (![um isAvailable]) {
//    [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is not available!", MONSTER_NAME]];
//  } else if (um.curHealth >= [gl calculateMaxHealthForMonster:um]) {
//    [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is already healthy!", MONSTER_NAME]];
//  } else if (self.monsterHealingQueue.count >= self.maxQueueSize) {
//    if (self.maxQueueSize > 0) {
//      [Globals addAlertNotification:@"The healing queue is already full!"];
//    } else {
//      [Globals addAlertNotification:@"You don't have an open hospital at the moment. Speed it up now!"];
//    }
//  } else {
//    int cost = [gl calculateCostToHealMonster:um];
//    int curAmount = gs.cash;
//    if (cost > curAmount) {
//      _tempMonster = um;
//      
//      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
//      if (svc) {
//        ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeCash requiredAmount:cost shouldAccumulate:YES];
//        rif.delegate = self;
//        svc.delegate = rif;
//        self.itemSelectViewController = svc;
//        self.resourceItemsFiller = rif;
//        
//        GameViewController *gvc = [GameViewController baseController];
//        svc.view.frame = gvc.view.bounds;
//        [gvc addChildViewController:svc];
//        [gvc.view addSubview:svc.view];
//        
//        _tempMonsterImageView = nil;
//        MonsterListCell* mlc = (MonsterListCell*)[self.listView.collectionView cellForItemAtIndexPath:indexPath];
//        if (mlc != nil && [mlc isKindOfClass:[MonsterListCell class]])
//          _tempMonsterImageView = mlc.cardContainer.monsterCardView.cardBgdView;
//        
//        if (_tempMonsterImageView == nil)
//        {
//          [svc showCenteredOnScreen];
//        }
//        else
//        {
//          if ([_tempMonsterImageView isKindOfClass:[UIImageView class]]) // Heal mobster
//          {
//            // I apologize in advance for the following block of code :|
//            const CGFloat contentOffsetY = self.listView.collectionView.contentOffset.y;
//            const CGFloat contentSizeHeight = self.listView.collectionView.contentSize.height;
//            const CGFloat collectionViewHeight = self.listView.collectionView.bounds.size.height;
//            const CGFloat midY = [Globals convertPointToWindowCoordinates:_tempMonsterImageView.frame.origin
//                                                      fromViewCoordinates:_tempMonsterImageView.superview].y + _tempMonsterImageView.bounds.size.height * .5f;
//            const CGFloat refY = [Globals convertPointToWindowCoordinates:self.listView.collectionView.frame.origin
//                                                      fromViewCoordinates:self.listView].y + collectionViewHeight * .5f;
//            if ((contentOffsetY < 1.f && midY < refY) ||                                            // Content at the top and cell in first row picked
//                (contentOffsetY > contentSizeHeight - collectionViewHeight - 1.f && midY > refY) || // Content at the bottom and cell in last row picked
//                (midY > refY - 10.f && midY < refY + 10.f))                                         // Cell roughly centered vertically in container
//            {
//              // UICollectionView will not scroll; force the callback
//              [self scrollViewDidEndScrollingAnimation:nil];
//            }
//            else
//            {
//              // Align the picked cell vertically in the container, then pop up the ItemSelectViewController
//              [(UIScrollView*)self.listView.collectionView setDelegate:self];
//              [self.listView.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//            }
//          }
//        }
//      }
//    } else {
//      [self sendHeal:um itemsDict:nil allowGems:NO];
//    }
//  }
//}
//
//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
//{
//  const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:_tempMonsterImageView.frame.origin fromViewCoordinates:_tempMonsterImageView.superview];
//  ViewAnchoringDirection popupDirection = invokingViewAbsolutePosition.x < [Globals screenSize].width * .5f ? ViewAnchoringPreferRightPlacement : ViewAnchoringPreferLeftPlacement;
//  [self.itemSelectViewController showAnchoredToInvokingView:_tempMonsterImageView withDirection:popupDirection inkovingViewImage:_tempMonsterImageView.image];
//  
//  [scrollView setDelegate:nil];
//}
//
//- (void) healWithItemsDict:(NSDictionary *)itemIdsToQuantity {
//  GameState *gs = [GameState sharedGameState];
//  Globals *gl = [Globals sharedGlobals];
//  
//  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
//  
//  int cost = [gl calculateCostToHealMonster:_tempMonster];
//  ResourceType resType = ResourceTypeCash;
//  
//  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
//  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
//  
//  if (allowGems && gemCost > gs.gems) {
//    [GenericPopupController displayNotEnoughGemsView];
//  } else if (allowGems || cost <= curAmount) {
//    [self sendHeal:_tempMonster itemsDict:itemIdsToQuantity allowGems:allowGems];
//    _tempMonster = nil;
//    _tempMonsterImageView = nil;
//  }
//}
//
//- (void) sendHeal:(UserMonster *)um itemsDict:(NSDictionary *)itemsDict allowGems:(BOOL)allowGems {
//  if (!_waitingForResponse) {
//    BOOL success = [self addMonsterToHealingQueue:um.userMonsterUuid itemsDict:itemsDict useGems:allowGems];
//    if (success) {
//      // Use this ordering so the new one appears in the queue, then table is reloaded after animation begins
//      [self reloadQueueViewAnimated:YES];
//      [self animateUserMonsterIntoQueue:um];
//      [self reloadListViewAnimated:YES];
//      
//      [self updateLabels];
//      
//      if (um.teamSlot) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
//      }
//    }
//  } else {
//    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
//  }
//}
//
//- (void) animateUserMonsterIntoQueue:(UserMonster *)um {
//  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
//  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
//  
//  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
//  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
//  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
//  
//  if (cardCell && queueCell) {
//    [self.queueCell updateForListObject:um];
//    [self.cardCell updateForListObject:um];
//    
//    [self.view addSubview:self.queueCell];
//    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
//    
//    [Globals animateStartView:cardCell toEndView:queueCell fakeStartView:self.cardCell fakeEndView:self.queueCell];
//  } else {
//    [self.queueView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
//  }
//}
//
//- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
//  if (!_waitingForResponse) {
//    UserMonsterHealingItem *hi = self.monsterHealingQueue[indexPath.row];
//    UserMonster *um = self.monsterList[[self.monsterList indexOfObject:hi]];
//    BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromHealingQueue:hi];
//    if (success) {
//      [self reloadListViewAnimated:YES];
//      [self animateUserMonsterOutOfQueue:um];
//      [self reloadQueueViewAnimated:YES];
//      
//      [self updateLabels];
//      
//      if (um.teamSlot) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
//      }
//    }
//  } else {
//    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
//  }
//}
//
//- (void) animateUserMonsterOutOfQueue:(UserMonster *)um {
//  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
//  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
//  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
//  
//  monsterIndex = (int)[self.queueView.listObjects indexOfObject:um];
//  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:monsterIndex inSection:0]];
//  
//  if (cardCell && queueCell) {
//    [self.queueCell updateForListObject:um];
//    [self.cardCell updateForListObject:um];
//    
//    [self.view addSubview:self.queueCell];
//    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
//    
//    [Globals animateStartView:queueCell toEndView:cardCell fakeStartView:self.queueCell fakeEndView:self.cardCell];
//  } else {
//    [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
//  }
//}


@end
