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
#import "OutgoingEventController.h"

#define ACTIVE_BUTTON_TAB_COLOR @"0A9ED7"
#define INACTIVE_BUTTON_TAB_COLOR @"A2A2A2"

@interface ItemFactoryViewController ()

@end

@implementation ItemFactoryViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.titleImageName = @"itemfactorymenuheader.png";
  
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
  
  [self.popoverViewController closeClicked:nil];
}

- (BattleItemUtil *) battleItemUtil {
  GameState *gs = [GameState sharedGameState];
  return gs.battleItemUtil;
}

- (BattleItemQueue *) battleItemQueue {
  return self.battleItemUtil.battleItemQueue;
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
  NSString *str = [NSString stringWithFormat:@"%@ (%d/%d POWER)", factory.structInfo.name.uppercaseString, self.battleItemUtil.totalPowerAmount, factory.powerLimit];
  self.title = str;
  
  int quantity = 0;
  for (UserBattleItem *bi in self.battleItemUtil.battleItems) {
    quantity += bi.quantity;
  }
  self.numItemsLabel.text = [NSString stringWithFormat:@"%d", quantity];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self updateLabels];
  [self reloadTitleView];
}

- (void) updateLabels {
  BattleItemQueue *battleItemQueue = [self battleItemQueue];
  NSArray *queueObjects = battleItemQueue.queueObjects;
  int timeLeft = self.battleItemQueue.queueEndTime.timeIntervalSinceNow;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  BOOL canHelp = [gs canAskForClanHelp];
  if (canHelp) {
    canHelp = NO;
    //for (BattleItemQueueObject *biq in queueObjects) {
    BattleItemQueueObject *biq = [queueObjects firstObject];
    if (biq) {
      if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeCreateBattleItem userDataUuid:biq.battleItemQueueUuid] < 0) {
        canHelp = YES;
      }
    }
  }
  
  if (timeLeft > 0) {
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    if (speedupCost > 0) {
      self.helpView.hidden = !canHelp;
      
      self.speedupIcon.hidden = NO;
      self.freeLabel.hidden = YES;
    } else {
      self.speedupIcon.hidden = YES;
      self.freeLabel.hidden = NO;
      self.helpView.hidden = YES;
    }
  } else if (self.speedupItemsFiller) {
    [self.popoverViewController closeClicked:nil];
  }
  
  if (queueObjects.count) {
    MonsterQueueCell *cell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self updateCellForTime:cell index:0];
  }
}

- (void) updateCellForTime:(MonsterQueueCell *)cell index:(int)i {
  BattleItemQueueObject *hi = self.battleItemQueue.queueObjects[i];
  
  float timeLeft = hi.expectedEndTime.timeIntervalSinceNow;
  float totalTime = hi.totalSecondsToComplete;
  float percentage = 1.f-timeLeft/totalTime;
  [cell updateTimeWithTimeLeft:timeLeft percent:percentage];
}

#pragma mark - Refreshing collection view

- (void) reloadQueueViewAnimated:(BOOL)animated {
  [self.queueView reloadTableAnimated:animated listObjects:self.battleItemQueue.queueObjects];
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
        (_scope == ItemFactoryScopePuzzle && item.battleItemCategory == BattleItemCategoryPuzzle)) {
      [avail addObject:item];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(BattleItemProto *obj1, BattleItemProto *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  };
  [avail sortUsingComparator:comp];
  self.itemList = avail;
}

#pragma mark - Scope

- (IBAction) scopeTabClicked:(id)sender {
  float pointSize = self.allItemsTabButton.titleLabel.font.pointSize;
  
  UIFont *regFont = [UIFont fontWithName:@"Gotham-Medium" size:pointSize];
  self.allItemsTabButton.titleLabel.font = regFont;
  self.potionsTabButton.titleLabel.font = regFont;
  self.puzzleTabButton.titleLabel.font = regFont;
  
  [self.allItemsTabButton setTitleColor:[UIColor colorWithHexString:INACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
  [self.potionsTabButton setTitleColor:[UIColor colorWithHexString:INACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
  [self.puzzleTabButton setTitleColor:[UIColor colorWithHexString:INACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
  
  UIButton *senderButton = (UIButton*)sender;
  
  UIFont *highlightedFont = [UIFont fontWithName:@"Gotham-Bold" size:pointSize];
  switch (senderButton.tag) {
    case 1:
      _scope = ItemFactoryScopeAll;
      self.allItemsTabButton.titleLabel.font = highlightedFont;
      [self.allItemsTabButton setTitleColor:[UIColor colorWithHexString:ACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
      break;
    case 2:
      _scope = ItemFactoryScopePotions;
      self.potionsTabButton.titleLabel.font = highlightedFont;
      [self.potionsTabButton setTitleColor:[UIColor colorWithHexString:ACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
      break;
    case 3:
      _scope = ItemFactoryScopePuzzle;
      self.puzzleTabButton.titleLabel.font = highlightedFont;
      [self.puzzleTabButton setTitleColor:[UIColor colorWithHexString:ACTIVE_BUTTON_TAB_COLOR] forState:UIControlStateNormal];
      break;
      
    default:
      break;
  }
  
  [self reloadListViewAnimated:YES];
}

#pragma mark - MonsterListView delegate

- (void) listView:(ListCollectionView *)listView updateCell:(ItemFactoryCardCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(BattleItemProto *)listObject {
  if (listView == self.listView) {
    GameState *gs = [GameState sharedGameState];
    BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
    int totalPower = self.battleItemUtil.totalPowerAmount;
    int powerLimit = factory.powerLimit;
    BOOL lowEnoughPower = listObject.powerAmount+totalPower <= powerLimit;
    BOOL isLocked = ![listObject satisfiesAllPrerequisites];
    BOOL greyscale = isLocked || !lowEnoughPower;
    
    [cell updateForListObject:listObject greyscale:greyscale];
    
    if (isLocked) {
      cell.statusLabel.text = @"Locked";
    } else if (!lowEnoughPower) {
      NSString *str1 = @"Power: ";
      NSString *str2 = [Globals commafyNumber:listObject.powerAmount];
      NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"ff9494"] range:NSMakeRange(str1.length, str2.length)];
      
      cell.statusLabel.attributedText = as;
    }
  } else {
    // Queue view
    [cell updateForListObject:listObject];
  }
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  BattleItemProto *bip = self.itemList[indexPath.row];
  
  GameState *gs = [GameState sharedGameState];
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
  int totalPower = self.battleItemUtil.totalPowerAmount;
  int powerLimit = factory.powerLimit;
  BOOL lowEnoughPower = bip.powerAmount+totalPower <= powerLimit;
  BOOL isLocked = ![bip satisfiesAllPrerequisites];
  
  if (isLocked) {
    PrereqProto *pre = [bip.incompletePrerequisites firstObject];
    [Globals addAlertNotification:[NSString stringWithFormat:@"Research %@ to unlock this Item!", [pre prereqString]]];
  } else if (!lowEnoughPower) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You need a higher Power Limit to add %@. Upgrade your %@!", bip.name, factory.structInfo.name]];
  } else {
    [self addBattleItemToQueue:bip indexPath:indexPath];
  }
}

- (void) addBattleItemToQueue:(BattleItemProto *)bip indexPath:(NSIndexPath*)indexPath {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Check if item is below power limit
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
  int totalPower = self.battleItemUtil.totalPowerAmount;
  int powerLimit = factory.powerLimit;
  if (bip.powerAmount+totalPower > powerLimit) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You need a higher Power Limit to create %@. Upgrade your %@!", bip.name, factory.structInfo.name]];
    return;
  }
  
  int cost = [gl calculateCostToCreateBattleItem:bip];
  int curAmount = bip.createResourceType == ResourceTypeCash ? gs.cash : gs.oil;
  if (cost > curAmount) {
    _tempBattleItem = bip;
    
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeCash requiredAmount:cost shouldAccumulate:YES];
      rif.delegate = self;
      svc.delegate = rif;
      self.popoverViewController = svc;
      self.resourceItemsFiller = rif;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      _tempBgdImageView = nil;
      ItemFactoryCardCell* mlc = (ItemFactoryCardCell *)[self.listView.collectionView cellForItemAtIndexPath:indexPath];
      if (mlc != nil && [mlc isKindOfClass:[ItemFactoryCardCell class]])
        _tempBgdImageView = mlc.bgdIcon;
      
      if (_tempBgdImageView == nil)
      {
        [svc showCenteredOnScreen];
      }
      else
      {
        if ([_tempBgdImageView isKindOfClass:[UIImageView class]]) // Heal mobster
        {
          // I apologize in advance for the following block of code :|
          const CGFloat contentOffsetY = self.listView.collectionView.contentOffset.y;
          const CGFloat contentSizeHeight = self.listView.collectionView.contentSize.height;
          const CGFloat collectionViewHeight = self.listView.collectionView.bounds.size.height;
          const CGFloat midY = [Globals convertPointToWindowCoordinates:_tempBgdImageView.frame.origin
                                                    fromViewCoordinates:_tempBgdImageView.superview].y + _tempBgdImageView.bounds.size.height * .5f;
          const CGFloat refY = [Globals convertPointToWindowCoordinates:self.listView.collectionView.frame.origin
                                                    fromViewCoordinates:self.listView].y + collectionViewHeight * .5f;
          if ((contentOffsetY < 1.f && midY < refY) ||                                            // Content at the top and cell in first row picked
              (contentOffsetY > contentSizeHeight - collectionViewHeight - 1.f && midY > refY) || // Content at the bottom and cell in last row picked
              (midY > refY - 10.f && midY < refY + 10.f))                                         // Cell roughly centered vertically in container
          {
            // UICollectionView will not scroll; force the callback
            [self scrollViewDidEndScrollingAnimation:nil];
          }
          else
          {
            // Align the picked cell vertically in the container, then pop up the ItemSelectViewController
            [(UIScrollView*)self.listView.collectionView setDelegate:self];
            [self.listView.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
          }
        }
      }
    }
  } else {
    [self sendCreate:bip itemsDict:nil allowGems:NO];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
  const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:_tempBgdImageView.frame.origin fromViewCoordinates:_tempBgdImageView.superview];
  ViewAnchoringDirection popupDirection = invokingViewAbsolutePosition.x < [Globals screenSize].width * .5f ? ViewAnchoringPreferRightPlacement : ViewAnchoringPreferLeftPlacement;
  [self.popoverViewController showAnchoredToInvokingView:_tempBgdImageView withDirection:popupDirection inkovingViewImage:_tempBgdImageView.image];
  
  [scrollView setDelegate:nil];
}

- (void) createWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = [gl calculateCostToCreateBattleItem:_tempBattleItem];
  ResourceType resType = _tempBattleItem.createResourceType;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendCreate:_tempBattleItem itemsDict:itemIdsToQuantity allowGems:allowGems];
    _tempBattleItem = nil;
    _tempBgdImageView = nil;
  }
}

- (void) sendCreate:(BattleItemProto *)bip itemsDict:(NSDictionary *)itemsDict allowGems:(BOOL)allowGems {
  if (!_waitingForResponse) {
    [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemsDict];
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] addBattleItem:bip toBattleItemQueue:[self battleItemQueue] useGems:allowGems];
    
    if (success) {
      // Use this ordering so the new one appears in the queue, then table is reloaded after animation begins
      [self reloadQueueViewAnimated:YES];
      [self animateBattleItemIntoQueue:bip];
      [self reloadListViewAnimated:YES];
      
      [self updateLabels];
      [self reloadTitleView];
    }
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
  }
}

- (void) animateBattleItemIntoQueue:(BattleItemProto *)bip {
  NSInteger monsterIndex = [self.listView.listObjects indexOfObject:bip];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  monsterIndex = self.queueView.listObjects.count-1;
  BattleItemQueueObject *item = self.queueView.listObjects[monsterIndex];
  NSIndexPath *ip = [NSIndexPath indexPathForItem:monsterIndex inSection:0];
  MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:ip];
  
  if (cardCell && queueCell) {
    [self.queueCell updateForListObject:item];
    [self.cardCell updateForListObject:bip greyscale:NO];
    
    [self.view addSubview:self.queueCell];
    [self.view insertSubview:self.cardCell belowSubview:self.queueView];
    
    [Globals animateStartView:cardCell toEndView:queueCell fakeStartView:self.cardCell fakeEndView:self.queueCell hideStartView:NO hideEndView:YES completion:nil];
  } else {
    [self.queueView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
  }
}

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  if (!_waitingForResponse) {
    BattleItemQueue *biq = [self battleItemQueue];
    BattleItemQueueObject *item = biq.queueObjects[indexPath.row];
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeBattleQueueObject:item fromQueue:biq];
    if (success) {
      [self reloadListViewAnimated:YES];
      [self animateBattleItemOutOfQueue:item];
      [self reloadQueueViewAnimated:YES];
      
      [self updateLabels];
      [self reloadTitleView];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_REMOVED_NOTIFICATION object:nil];
    }
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
  }
}

- (void) animateBattleItemOutOfQueue:(BattleItemQueueObject *)item {
  BattleItemProto *bip = item.staticBattleItem;
  NSInteger monsterIndex = [self.listView.listObjects indexOfObject:bip];
  if (monsterIndex != NSNotFound) {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
    MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
    
    monsterIndex = (int)[self.queueView.listObjects indexOfObject:item];
    MonsterQueueCell *queueCell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:monsterIndex inSection:0]];
    
    if (cardCell && queueCell) {
      [self.queueCell updateForListObject:item];
      [self.cardCell updateForListObject:bip greyscale:NO];
      
      [self.view addSubview:self.queueCell];
      [self.view insertSubview:self.cardCell belowSubview:self.queueView];
      
      [Globals animateStartView:queueCell toEndView:cardCell fakeStartView:self.queueCell fakeEndView:self.cardCell hideStartView:YES hideEndView:NO completion:nil];
    } else  {
      [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
  }
}

- (IBAction) speedupButtonClicked:(id)sender {
  if (!_waitingForResponse) {
    Globals *gl = [Globals sharedGlobals];
    
    int timeLeft = self.battleItemQueue.queueEndTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (gemCost <= 0) {
      [self speedupBattleItemQueue];
    } else {
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] initWithGameActionType:GameActionTypeCreateBattleItem];
        sif.delegate = self;
        svc.delegate = sif;
        self.speedupItemsFiller = sif;
        self.popoverViewController = svc;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        if (sender == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
          {
            UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
            const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
          else if ([sender isKindOfClass:[UIButton class]]) // Speed up healing mobster
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:ViewAnchoringPreferLeftPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
        }
      }
    }
  }
}

- (void) speedupBattleItemQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (self.speedupItemsFiller) {
    [self.popoverViewController closeClicked:nil];
  }
  
  BattleItemQueue *biq = [self battleItemQueue];
  int timeLeft = biq.queueEndTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupBattleItemQueue:biq delegate:self];
    if (success) {
      self.buttonLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      [self.buttonSpinner startAnimating];
      
      _waitingForResponse = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_QUEUE_CHANGED_NOTIFICATION object:self];
    }
  }
}

#pragma mark - Speedup Items Filler

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = self.battleItemQueue.queueEndTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupBattleItemQueue];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    BattleItemQueue *biq = [self battleItemQueue];
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId battleItemQueue:biq];
      
      [self updateLabels];
    }
    
    int timeLeft = biq.queueEndTime.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  BattleItemQueue *biq = [self battleItemQueue];
  int timeLeft = biq.queueEndTime.timeIntervalSinceNow;
  return timeLeft;
}

- (int) totalSecondsRequired {
  BattleItemQueue *biq = [self battleItemQueue];
  return biq.totalTimeForQueue;
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self createWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.popoverViewController = nil;
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

#pragma mark - Battle Item delegate

- (IBAction) bagClicked:(id)sender {
  BattleItemSelectViewController *svc = [[BattleItemSelectViewController alloc] initWithShowUseButton:NO showFooterView:YES showItemFactory:NO];
  if (svc) {
    svc.delegate = self;
    self.popoverViewController = svc;
    
    GameViewController *gvc = [GameViewController baseController];
    svc.view.frame = gvc.view.bounds;
    [gvc addChildViewController:svc];
    [gvc.view addSubview:svc.view];
    
    if (sender == nil)
    {
      [svc showCenteredOnScreen];
    }
    else
    {
      if ([sender isKindOfClass:[UIButton class]])
      {
        UIButton* invokingButton = (UIButton*)sender;
        [svc showAnchoredToInvokingView:invokingButton
                          withDirection:ViewAnchoringPreferLeftPlacement
                      inkovingViewImage:[invokingButton imageForState:invokingButton.state]];
      }
    }
  }
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  BattleItemProto *bip = self.itemList[indexPath.row];
  UserBattleItem *ubi = [self.battleItemUtil getUserBattleItemForBattleItemId:bip.battleItemId];
  
  if (!ubi) {
    ubi = [[UserBattleItem alloc] init];
    ubi.battleItemId = bip.battleItemId;
  }
  
  ItemFactoryCardCell *cell = (ItemFactoryCardCell *)[listView.collectionView cellForItemAtIndexPath:indexPath];
  id sender = [cell infoButton];
  
  BattleItemSelectViewController *svc = [[BattleItemSelectViewController alloc] initWithShowUseButton:NO showFooterView:YES showItemFactory:NO];
  [svc loadInfoViewForBattleItem:ubi animated:NO];
  if (svc) {
    svc.delegate = self;
    self.popoverViewController = svc;
    
    GameViewController *gvc = [GameViewController baseController];
    svc.view.frame = gvc.view.bounds;
    [gvc addChildViewController:svc];
    [gvc.view addSubview:svc.view];
    
    if (sender == nil)
    {
      [svc showCenteredOnScreen];
    }
    else
    {
      if ([sender isKindOfClass:[UIButton class]])
      {
        UIButton* invokingButton = (UIButton*)sender;
        const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
        ViewAnchoringDirection popupDirection = invokingViewAbsolutePosition.x < [Globals screenSize].width * .5f ? ViewAnchoringPreferRightPlacement : ViewAnchoringPreferLeftPlacement;
        [svc showAnchoredToInvokingView:invokingButton
                          withDirection:popupDirection
                      inkovingViewImage:[Globals maskImage:[invokingButton imageForState:UIControlStateNormal] withColor:[UIColor whiteColor]]];
      }
    }
  }
}

- (NSArray *) reloadBattleItemsArray {
  // Don't send used ones
  NSMutableArray *arr = [NSMutableArray array];
  for (UserBattleItem *ubi in self.battleItemUtil.battleItems) {
    if (ubi.quantity > 0) {
      [arr addObject:ubi];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserBattleItem *obj1, UserBattleItem *obj2) {
    return [@(obj1.staticBattleItem.priority) compare:@(obj2.staticBattleItem.priority)];
  }];
  
  return arr;
}

- (float) progressBarPercent {
  GameState *gs = [GameState sharedGameState];
  
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
  return self.battleItemUtil.currentPowerAmountFromCreatedItems/(float)factory.powerLimit;
}

- (NSString *) progressBarText {
  GameState *gs = [GameState sharedGameState];
  
  BattleItemFactoryProto *factory = (BattleItemFactoryProto *)gs.myBattleItemFactory.staticStructForCurrentConstructionLevel;
  return [NSString stringWithFormat:@"%d/%d POWER", self.battleItemUtil.currentPowerAmountFromCreatedItems, factory.powerLimit];
}

- (void) battleItemDiscarded:(UserBattleItem *)item {
  [self reloadTitleView];
}

- (void) battleItemSelectClosed:(id)viewController {
  self.popoverViewController = nil;
}

#pragma mark - Get Help

- (IBAction) getHelpClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] solicitBattleItemHelp:[self battleItemQueue]];
  [self updateLabels];
}

- (void) handleCompleteBattleItemResponseProto:(FullEvent *)fe {
  self.buttonLabelsView.hidden = NO;
  self.buttonSpinner.hidden = YES;
  
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  
  [self reloadTitleView];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_QUEUE_CHANGED_NOTIFICATION object:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_WAIT_COMPLETE_NOTIFICATION object:self];
  
  _waitingForResponse = NO;
}

@end
