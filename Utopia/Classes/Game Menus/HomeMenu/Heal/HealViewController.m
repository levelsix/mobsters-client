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

#import "GameViewController.h"

@implementation HealQueueFooterView

@end

@implementation HealViewController

- (id) initWithUserStructUuid:(NSString *)userStructUuid {
  if ((self = [super init])) {
    _initHospUserStructUuid = userStructUuid;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self loadNewQueueView];
  [self.view addSubview:self.queueView];
  self.queueView.originY = self.view.height-self.queueView.height;
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"HealCardCell" owner:self options:nil][0];
  self.queueCell = [[NSBundle mainBundle] loadNibNamed:@"MonsterQueueCell" owner:self options:nil][0];
  
  self.listView.cellClassName = @"HealCardCell";
  
  self.title = [NSString stringWithFormat:@"HEAL %@S", MONSTER_NAME.uppercaseString];
  self.titleImageName = @"hospitalmenuheader.png";
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no injured %@s.", MONSTER_NAME];
  
  GameState *gs = [GameState sharedGameState];
  self.hospitals = [gs myValidHospitals];
  
  // Try to prioritize hospitals that are active
  _curHospitalIndex = 0;
  for (UserStruct *hosp in self.hospitals) {
    HospitalQueue *hq = [gs hospitalQueueForUserHospitalStructUuid:hosp.userStructUuid];
    if ((_initHospUserStructUuid && [hosp.userStructUuid isEqualToString:_initHospUserStructUuid]) ||
        (!_initHospUserStructUuid &&hq.healingItems)) {
      _curHospitalIndex = (int)[self.hospitals indexOfObject:hosp];
      break;
    }
  }
  
  [self reloadQueueViewFromRight:YES animated:NO];
}

- (void) loadNewQueueView {
  [[NSBundle mainBundle] loadNibNamed:@"HealQueueView" owner:self options:nil];
  
  self.queueView.isFlipped = YES;
  self.queueView.cellClassName = @"MonsterQueueCell";
  self.queueView.footerClassName = @"HealQueueFooterView";
  
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ to heal.", MONSTER_NAME];
  
  self.buttonSpinner.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  self.queueView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadQueueViewAnimated:NO];
  [self reloadListViewAnimated:NO];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabels) name:RECEIVED_CLAN_HELP_NOTIFICATION object:nil];
  [self updateLabels];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Move the hospital switcher view to the parent view
  UIView *parentView = self.parentViewController.mainView;
  UIView *switcher = self.hospitalSwitcherView;
  if (switcher.superview) switcher.frame = [parentView convertRect:switcher.frame fromView:switcher.superview];
  [parentView addSubview:switcher];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[SocketCommunication sharedSocketCommunication] flush];
  
  [self.itemSelectViewController closeClicked:nil];
  
  [self.hospitalSwitcherView removeFromSuperview];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  [self updateLabels];
}

- (void) updateLabels {
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  BOOL canHelp = [gs canAskForClanHelp];
  if (canHelp) {
    canHelp = NO;
    for (UserMonsterHealingItem *hi in self.monsterHealingQueue) {
      if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeHeal userDataUuid:hi.userMonsterUuid] < 0) {
        canHelp = YES;
      }
    }
  }
  
  if (timeLeft > 0) {
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    if (speedupCost > 0) {
      self.speedupCostLabel.text = [Globals commafyNumber:speedupCost];
      [Globals adjustViewForCentering:self.speedupCostLabel.superview withLabel:self.speedupCostLabel];
      
      self.helpView.hidden = !canHelp;
      
      self.speedupCostLabel.superview.hidden = NO;
      self.speedupIcon.hidden = NO;
      self.freeLabel.hidden = YES;
    } else {
      self.speedupCostLabel.superview.hidden = YES;
      self.speedupIcon.hidden = YES;
      self.freeLabel.hidden = NO;
      self.helpView.hidden = YES;
    }
  } else if (self.speedupItemsFiller) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  if (self.monsterHealingQueue.count) {
    MonsterQueueCell *cell = (MonsterQueueCell *)[self.queueView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self updateCellForTime:cell index:0];
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

#pragma mark - Queue View movement

- (IBAction)leftArrowClicked:(id)sender {
  _curHospitalIndex = MAX(0, _curHospitalIndex-1);
  [self reloadQueueViewFromRight:NO animated:YES];
}

- (IBAction)rightArrowClicked:(id)sender {
  _curHospitalIndex = MIN((int)self.hospitals.count-1, _curHospitalIndex+1);
  [self reloadQueueViewFromRight:YES animated:YES];
}

static BOOL isAnimating = NO;
- (void) reloadQueueViewFromRight:(BOOL)fromRight animated:(BOOL)animated {
  if (animated) {
    if (isAnimating) {
      return;
    }
    
    isAnimating = YES;
    
    UIView *oldView = self.queueView;
    
    [self loadNewQueueView];
    [self.view addSubview:self.queueView];
    
    UIView *newView = self.queueView;
    float movementFactor = oldView.width*(fromRight?1:-1);
    newView.center = ccpAdd(oldView.center, ccp(movementFactor, 0));
    
    [UIView animateWithDuration:0.3f animations:^{
      newView.center = oldView.center;
      oldView.center = ccpAdd(oldView.center, ccp(-movementFactor, 0));
    } completion:^(BOOL finished) {
      isAnimating = NO;
      [oldView removeFromSuperview];
    }];
  }
  
  // Never animate this call since this method will always require the queue view to be statically updated
  [self reloadQueueViewAnimated:NO];
  
  UserStruct *hosp = [self currentHospital];
  StructureInfoProto *sip = hosp.staticStruct.structInfo;
  
  NSString *imgName = [@"Queue" stringByAppendingString:sip.imgName];
  [Globals imageNamed:imgName withView:self.hospitalIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.hospitalLevelLabel.text = [NSString stringWithFormat:@"LEVEL %d", sip.level];
  
  // Update arrows
  self.hospitalLeftArrow.hidden = _curHospitalIndex <= 0;
  self.hospitalRightArrow.hidden = _curHospitalIndex >= self.hospitals.count-1;
}

#pragma mark - Potentially rewritable methods

- (HospitalQueue *) hospitalQueue {
  if (self.fakeHospitalQueue) {
    return self.fakeHospitalQueue;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = [self currentHospital];
  return [gs hospitalQueueForUserHospitalStructUuid:us.userStructUuid];
}

- (UserStruct *) currentHospital {
  return self.hospitals[_curHospitalIndex];
}

- (NSMutableArray *) monsterHealingQueue {
  return [self hospitalQueue].healingItems;
}

- (NSArray *) monsterList {
  GameState *gs = [GameState sharedGameState];
  return gs.myMonsters;
}

- (MSDate *) monsterHealingQueueEndTime {
  return [self hospitalQueue].queueEndTime;
}

- (int) totalTimeForHealQueue {
  return [self hospitalQueue].totalTimeForHealQueue;
}

- (int) maxQueueSize {
  HospitalProto *hp = (HospitalProto *)[self currentHospital].staticStruct;
  return hp.queueSize;
}

- (BOOL) userMonsterIsAvailable:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  return um.isAvailable && um.curHealth < [gl calculateMaxHealthForMonster:um];
}

- (BOOL) addMonsterToHealingQueue:(NSString *)umUuid itemsDict:(NSDictionary *)itemsDict useGems:(BOOL)useGems {
  [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemsDict];
  return [[OutgoingEventController sharedOutgoingEventController] addMonster:umUuid toHealingQueue:[self hospitalQueue].userHospitalStructUuid useGems:useGems];
}

- (BOOL) sendSpeedupHealingQueue {
  int queueSize = (int)self.monsterHealingQueue.count;
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] speedupHealingQueue:[self hospitalQueue] delegate:self];
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
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in self.monsterList) {
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
    
    if (indexPath.row == 0) {
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
  [self addMonsterToHealQueue:um indexPath:indexPath];
}

- (void) addMonsterToHealQueue:(UserMonster *)um indexPath:(NSIndexPath*)indexPath {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (![um isAvailable]) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is not available!", MONSTER_NAME]];
  } else if (um.curHealth >= [gl calculateMaxHealthForMonster:um]) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"This %@ is already healthy!", MONSTER_NAME]];
  } else if (self.monsterHealingQueue.count >= self.maxQueueSize) {
    if (self.maxQueueSize > 0) {
      [Globals addAlertNotification:@"The healing queue is already full!"];
    } else {
      [Globals addAlertNotification:@"You don't have an open hospital at the moment. Speed it up now!"];
    }
  } else {
    int cost = [gl calculateCostToHealMonster:um];
    int curAmount = gs.cash;
    if (cost > curAmount) {
      _tempMonster = um;
      
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeCash requiredAmount:cost shouldAccumulate:YES];
        rif.delegate = self;
        svc.delegate = rif;
        self.itemSelectViewController = svc;
        self.resourceItemsFiller = rif;
        
        GameViewController *gvc = [GameViewController baseController];
        svc.view.frame = gvc.view.bounds;
        [gvc addChildViewController:svc];
        [gvc.view addSubview:svc.view];
        
        _tempMonsterImageView = nil;
        MonsterListCell* mlc = (MonsterListCell*)[self.listView.collectionView cellForItemAtIndexPath:indexPath];
        if (mlc != nil && [mlc isKindOfClass:[MonsterListCell class]])
          _tempMonsterImageView = mlc.cardContainer.monsterCardView.cardBgdView;
        
        if (_tempMonsterImageView == nil)
        {
          [svc showCenteredOnScreen];
        }
        else
        {
          if ([_tempMonsterImageView isKindOfClass:[UIImageView class]]) // Heal mobster
          {
            // I apologize in advance for the following block of code :|
            const CGFloat contentOffsetY = self.listView.collectionView.contentOffset.y;
            const CGFloat contentSizeHeight = self.listView.collectionView.contentSize.height;
            const CGFloat collectionViewHeight = self.listView.collectionView.bounds.size.height;
            const CGFloat midY = [_tempMonsterImageView.superview convertPoint:_tempMonsterImageView.frame.origin toView:nil].y + _tempMonsterImageView.bounds.size.height * .5f;
            const CGFloat refY = [self.listView convertPoint:self.listView.collectionView.frame.origin toView:nil].y + collectionViewHeight * .5f;
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
      [self sendHeal:um itemsDict:nil allowGems:NO];
    }
  }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
  const CGPoint invokingViewAbsolutePosition = [_tempMonsterImageView.superview convertPoint:_tempMonsterImageView.frame.origin toView:nil]; // Window coordinates
  ViewAnchoringDirection popupDirection = invokingViewAbsolutePosition.x < [Globals screenSize].width * .5f ? ViewAnchoringPreferRightPlacement : ViewAnchoringPreferLeftPlacement;
  [self.itemSelectViewController showAnchoredToInvokingView:_tempMonsterImageView withDirection:popupDirection inkovingViewImage:_tempMonsterImageView.image];
  
  [scrollView setDelegate:nil];
}

- (void) healWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = [gl calculateCostToHealMonster:_tempMonster];
  ResourceType resType = ResourceTypeCash;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendHeal:_tempMonster itemsDict:itemIdsToQuantity allowGems:allowGems];
    _tempMonster = nil;
    _tempMonsterImageView = nil;
  }
}

- (void) sendHeal:(UserMonster *)um itemsDict:(NSDictionary *)itemsDict allowGems:(BOOL)allowGems {
  if (!_waitingForResponse) {
    BOOL success = [self addMonsterToHealingQueue:um.userMonsterUuid itemsDict:itemsDict useGems:allowGems];
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
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
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
  if (!_waitingForResponse) {
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
  } else {
    [Globals addAlertNotification:@"Hold on, we are still processing your previous request."];
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
  if (!_waitingForResponse) {
    Globals *gl = [Globals sharedGlobals];
    
    int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (gemCost <= 0) {
      [self speedupHealingQueue];
    } else {
      ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
      if (svc) {
        SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] init];
        sif.delegate = self;
        svc.delegate = sif;
        self.speedupItemsFiller = sif;
        self.itemSelectViewController = svc;
        
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
          if ([sender isKindOfClass:[UIButton class]]) // Speed up evolving mobster
          {
            UIButton* invokingButton = (UIButton*)sender;
            [svc showAnchoredToInvokingView:invokingButton
                              withDirection:ViewAnchoringPreferTopPlacement
                          inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
          }
        }
      }
    }
  }
}

- (void) speedupHealingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [self sendSpeedupHealingQueue];
    if (success) {
      self.buttonLabelsView.hidden = YES;
      self.buttonSpinner.hidden = NO;
      [self.buttonSpinner startAnimating];
      
      _waitingForResponse = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_QUEUE_CHANGED_NOTIFICATION object:self];
    }
  }
}

#pragma mark - Speedup Items Filler

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupHealingQueue];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId healingQueue:[self hospitalQueue]];
      
      [self updateLabels];
    }
    
    int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  return timeLeft;
}

- (int) totalSecondsRequired {
  return self.totalTimeForHealQueue;
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self healWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

#pragma mark - Get Help

- (IBAction) getHelpClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] solicitHealHelp:[self hospitalQueue]];
  [self updateLabels];
}

- (void) handleHealMonsterResponseProto:(FullEvent *)fe {
  self.buttonLabelsView.hidden = NO;
  self.buttonSpinner.hidden = YES;
  
  [self reloadListViewAnimated:YES];
  [self reloadQueueViewAnimated:YES];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_QUEUE_CHANGED_NOTIFICATION object:self];
  
  _waitingForResponse = NO;
}

@end
