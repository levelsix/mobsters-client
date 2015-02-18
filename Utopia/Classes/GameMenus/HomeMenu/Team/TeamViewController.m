//
//  TeamViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TeamViewController.h"

#import "GameState.h"
#import "Globals.h"

#import "MonsterPopUpViewController.h"
#import "GameViewController.h"
#import "GenericPopupController.h"

#import "OutgoingEventController.h"
#import "SocketCommunication.h"

#define LAST_TEAM_DONATE_MSG_KEY @"LastTeamDonateMsgKey2"

@implementation TeamSlotView

- (void) awakeFromNib {
  _initSize = self.size;
  
  // Rewrite the slot label
  self.tag = self.tag;
}

- (CGSize) minimizedSize {
  return CGSizeMake(CGRectGetMaxX(self.leftView.frame), self.height);
}

- (CGSize) maximizedSize {
  return _initSize;
}

- (void) setTag:(NSInteger)tag {
  [super setTag:tag];
  
  if (tag) {
    self.slotNumLabel.text = [NSString stringWithFormat:@"%d", (int)tag];
  } else {
    // Squad Slot
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"SQUAD\nSLOT"];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.slotNumLabel.font.fontName size:10.f] range:NSMakeRange(0, 6)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.slotNumLabel.font.fontName size:12.f] range:NSMakeRange(6, 4)];
    self.slotNumLabel.attributedText = str;
  }
  self.botLabel.text = [NSString stringWithFormat:@"Tap %@ to Add", MONSTER_NAME];
}

- (void) updateLeftViewForUserMonster:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  
  if (!um) {
    self.notEmptyView.alpha = 0.f;
    self.emptyView.hidden = NO;
  } else {
    self.notEmptyView.alpha = 1.f;
    self.monsterView.alpha = [um isAvailable] ? 1.f : 0.6f;
    self.emptyView.hidden = ![um isAvailable];
    
    self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
    self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:um.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]]];
    
    [self.monsterView updateForMonsterId:um.monsterId greyscale:um.curHealth <= 0];
    self.unavailableBorder.hidden = [um isAvailable];
    
    while (self.unavailableBorder.subviews.count > 0) {
      [self.unavailableBorder.subviews[0] removeFromSuperview];
    }
    
    if (![um isAvailable]) {
      UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:um.statusImageName]];
      [self.unavailableBorder addSubview:img];
      img.center = ccp(self.unavailableBorder.frame.size.width/2, self.unavailableBorder.frame.size.height/2);
      
      [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        img.alpha = 0.6;
      } completion:nil];
    }
  }
}

- (void) updateRightViewForUserMonster:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  if (!um) {
    self.botLabel.hidden = NO;
    self.toonDetailsView.hidden = YES;
    
    self.topLabel.text = [NSString stringWithFormat:@"Slot %d Open", (int)self.tag];
    self.topLabel.highlighted = YES;
  } else {
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
    NSString *p2 = [NSString stringWithFormat:@"L%d", um.level];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
    self.topLabel.highlighted = NO;
    self.topLabel.attributedText = attr;
  }
}

- (void) updateForUserMonster:(UserMonster *)um {
  [self updateLeftViewForUserMonster:um];
  [self updateRightViewForUserMonster:um];
}

- (void) updateForClanUserMonster:(UserMonster *)um username:(NSString *)name {
  [self updateLeftViewForUserMonster:um];
  [self updateRightViewForUserMonster:um];
  
  if (!um) {
    self.rightView.hidden = YES;
  } else {
    self.tapToAddLabel.text = [NSString stringWithFormat:@"From: %@", name];
    [self.toonDetailsView setTitle:nil forState:UIControlStateNormal];
    
    self.tapToAddLabel.hidden = NO;
    self.rightView.hidden = NO;
  }
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate teamSlotMinusClicked:self];
}

- (IBAction)monsterClicked:(id)sender {
  [self.delegate teamSlotMonsterClicked:self];
}

- (IBAction)rightSideClicked:(id)sender {
  [self.delegate teamSlotRightSideClicked:self];
}

@end

@implementation TeamViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  GameState *gs = [GameState sharedGameState];
  ClanHouseProto *chp = (ClanHouseProto *)[gs.myClanHouse staticStruct];
  _showsClanDonateToonView = gs.clan != nil && chp.teamDonationPowerLimit > 0;
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"TeamCardCell" owner:self options:nil][0];
  self.cardCell.cardContainer.monsterCardView.infoButton.hidden = NO;
  
  self.teamCell = [[TeamSlotView alloc] init];
  [self.teamCell loadNib];
  [self.teamCell.rightView removeFromSuperview];
  self.teamCell.frame = CGRectMake(0, 0, self.teamCell.leftView.frame.size.width, self.teamCell.leftView.frame.size.height);
  
  self.listView.cellClassName = @"TeamCardCell";
  
  // It is already positioned in the xib, we just need to add it to the correct superview
  if (_showsClanDonateToonView) {
    [[[self.teamSlotViews firstObject] superview] addSubview:self.clanRequestView];
    [self.clanRequestSlotView.superview sendSubviewToBack:self.clanRequestSlotView];
  } else {
    [self.clanRequestView removeFromSuperview];
  }
  
  self.titleImageName = @"manageteammenuheader.png";
  
  self.unavailableLabel.text = [NSString stringWithFormat:@"You have no more available %@s.", MONSTER_NAME];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  [self updateTeamSlotViews:NO animated:NO];
  
  [self reloadTitleView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeamSlotViews) name:MY_CLAN_TEAM_DONATION_CHANGED_NOTIFICATION object:nil];
  
  [[SocketCommunication sharedSocketCommunication] pauseFlushTimer];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.donateMsgViewController close];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self.itemSelectViewController closeClicked:nil];
  
  [[SocketCommunication sharedSocketCommunication] flush];
  [[SocketCommunication sharedSocketCommunication] resumeFlushTimer];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self updateTeamSlotViews];
  [self reloadTitleView];
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  for (MonsterListCell *listCell in self.listView.collectionView.visibleCells) {
    UserMonster *um = self.userMonsters[[self.listView.collectionView indexPathForCell:listCell].row];
    [listCell updateCombineTimeForUserMonster:um];
  }
  
  if (!_combineMonster.isCombining) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  ClanMemberTeamDonationProto *myTeamDonation = [gs.clanTeamDonateUtil myTeamDonation];
  if (myTeamDonation.isFulfilled) {
    self.speedupButtonView.hidden = YES;
    self.requestButtonView.hidden = YES;
  } else {
    int timeLeft = [gs.lastTeamDonateSolicitationTime dateByAddingTimeInterval:gl.minsToResolicitTeamDonation*60].timeIntervalSinceNow;
    if (timeLeft > 0) {
      self.donateTimeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
      
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:NO];
      
      self.donateCostLabel.text = [Globals commafyNumber:gemCost];
      [Globals adjustViewForCentering:self.donateCostLabel.superview withLabel:self.donateCostLabel];
      
      self.speedupButtonView.hidden = NO;
      self.requestButtonView.hidden = YES;
    } else {
      self.speedupButtonView.hidden = YES;
      self.requestButtonView.hidden = NO;
    }
  }
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSString *str = [NSString stringWithFormat:@"TEAM (%d/%d POWER)", [gl calculateTeamCostForTeam:[gs allBattleAvailableAliveMonstersOnTeamWithClanSlot:NO]], gs.maxTeamCost];
  self.title = str;
}

// Update all slots
- (void) updateTeamSlotViews {
  [self updateTeamSlotViews:NO animated:YES];
}

// Update only slotNum but min and max the other views
// Returns YES if the opened one was already open
- (BOOL) updateTeamSlotViews:(BOOL)onlyUpdateOpenOne animated:(BOOL)animated {
  int nextSlot = (int)self.teamSlotViews.count+1;
  BOOL foundAvailSlot = NO;
  for (TeamSlotView *slot in self.teamSlotViews) {
    UserMonster *um = [self monsterForSlot:slot.tag];
    
    if (!um && (!foundAvailSlot || nextSlot > slot.tag || _clickedSlot == slot.tag)) {
      nextSlot = (int)slot.tag;
      foundAvailSlot = YES;
    } else if (!foundAvailSlot && (![um isAvailable] || um.curHealth <= 0) && nextSlot > slot.tag) {
      nextSlot = (int)slot.tag;
    }
  }
  
  int openedSlot = _openedSlot ?: nextSlot < self.teamSlotViews.count+1 ? nextSlot : (int)self.teamSlotViews.count;
  
  for (TeamSlotView *slot in self.teamSlotViews) {
    // Should update all if the clan donate isn't being shown since we need everything to fade seemlessly
    if (!onlyUpdateOpenOne || !_showsClanDonateToonView || slot.tag == openedSlot) {
      UserMonster *um = [self monsterForSlot:slot.tag];
      [slot updateForUserMonster:um];
      
      slot.tapToAddLabel.hidden = slot.tag != nextSlot;
      slot.toonDetailsView.hidden = !slot.tapToAddLabel.hidden || !um;
    }
  }
  
  TeamSlotView *slot = self.teamSlotViews[openedSlot-1];
  BOOL wasOpen = CGSizeEqualToSize(slot.size, [slot maximizedSize]);
  
  if (_showsClanDonateToonView) {
    [UIView animateWithDuration:animated*0.3f animations:^{
      float curOrigin = [[self.teamSlotViews firstObject] originX];
      for (TeamSlotView *slot in self.teamSlotViews) {
        if (slot.tag == openedSlot) {
          slot.size = [slot maximizedSize];
        } else {
          slot.size = [slot minimizedSize];
        }
        
        slot.originX = curOrigin;
        curOrigin += slot.width;
      }
    }];
    
    GameState *gs = [GameState sharedGameState];
    ClanMemberTeamDonationProto *donation = [gs.clanTeamDonateUtil myTeamDonation];
    UserMonsterSnapshotProto *snap = [donation.donationsList firstObject];
    [self.clanRequestSlotView updateForClanUserMonster:donation.donatedMonster username:snap.user.name];
    
    if (animated) {
      CATransition *animation = [CATransition animation];
      animation.type = kCATransitionFade;
      animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      [self.clanRequestView.layer addAnimation:animation forKey:@"fade"];
    }
  }
  
  return wasOpen;
}

- (UserMonster *) monsterForSlot:(NSInteger)slot {
  GameState *gs = [GameState sharedGameState];
  return [gs myMonsterWithSlotNumber:slot];
}

- (NSArray *) monsterList {
  GameState *gs = [GameState sharedGameState];
  return gs.myMonsters;
}

- (int) maxInventorySlots {
  GameState *gs = [GameState sharedGameState];
  return gs.maxInventorySlots;
}

- (void) openInfoForUserMonster:(UserMonster *)um allowSell:(BOOL)allowSell {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:allowSell];
  UIViewController *parent = [GameViewController baseController];
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

#pragma mark - Reloading collection view

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.userMonsters];
}

- (void) reloadMonstersArray {
  NSMutableArray *avail = [NSMutableArray array];
  
  for (UserMonster *um in self.monsterList) {
    // All monsters that aren't currently on your team
    if (!um.teamSlot) {
      [avail addObject:um];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    BOOL isNotAddable1 = !obj1.isAvailable || obj1.curHealth <= 0;
    BOOL isNotAddable2 = !obj2.isAvailable || obj2.curHealth <= 0;
    
    if (isNotAddable1 != isNotAddable2) {
      return [@(isNotAddable1) compare:@(isNotAddable2)];
    } else {
      return [obj1 compare:obj2];
    }
  };
  [avail sortUsingComparator:comp];
  self.userMonsters = avail;
}

#pragma mark - Monster card delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(UserMonster *)listObject {
  Globals *gl = [Globals sharedGlobals];
  BOOL lowEnoughCost = [gl currentBattleReadyTeamHasCostFor:listObject];
  BOOL available = listObject.isAvailable;
  BOOL isDead = listObject.curHealth <= 0;
  BOOL battleReady = available && !isDead;
  BOOL greyscale = !lowEnoughCost || !battleReady;
  
  [cell updateForListObject:listObject greyscale:greyscale];
  cell.cardContainer.monsterCardView.overlayButton.userInteractionEnabled = !greyscale;
  
  // Need to do this because if monster's health is 0, it will not show the healthbar since greyscale = YES
  if (available) {
    if (isDead) {
      cell.availableView.hidden = NO;
      
      // Hide status label in case it is locked
      cell.statusLabel.hidden = YES;
    } else if (!lowEnoughCost) {
      NSString *str1 = @"Power: ";
      NSString *str2 = [Globals commafyNumber:[listObject teamCost]];
      NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
      [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"ff9494"] range:NSMakeRange(str1.length, str2.length)];
      
      cell.statusLabel.attributedText = as;
    }
    cell.cardContainer.monsterCardView.overlayButton.userInteractionEnabled = YES;
  }
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.userMonsters[indexPath.row];
  BOOL lowEnoughCost = [gl currentBattleReadyTeamHasCostFor:um];
  
  if ([um isAvailable] && um.curHealth > 0 && lowEnoughCost) {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToTeam:um.userMonsterUuid preferableSlot:_clickedSlot];
    _openedSlot = [gs allBattleAvailableAliveMonstersOnTeamWithClanSlot:NO].count >= gl.maxTeamSize ? um.teamSlot : 0;
    _clickedSlot = 0;
    
    if (success) {
      BOOL shouldFade = [self updateTeamSlotViews:YES animated:YES];
      [self animateUserMonsterIntoSlot:um shouldFade:shouldFade || !_showsClanDonateToonView completion:^{
        [self updateTeamSlotViews];
      }];
      [self reloadListViewAnimated:YES];
      
      [self reloadTitleView];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  } else if (um.curHealth <= 0) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must heal %@ before adding to your team.", um.staticMonster.displayName]];
  } else if (!lowEnoughCost) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You need a higher Power Limit to add %@. Upgrade your %@!", um.staticMonster.monsterName, gs.myTeamCenter.staticStruct.structInfo.name]];
  }
}

- (void) animateUserMonsterIntoSlot:(UserMonster *)um shouldFade:(BOOL)shouldFade completion:(dispatch_block_t)completion {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  TeamSlotView *slotView = self.teamSlotViews.count >= um.teamSlot ? self.teamSlotViews[um.teamSlot-1] : nil;
  
  UIView *animView = slotView.rightView;
  if (cardCell && slotView) {
    [self.teamCell updateForUserMonster:um];
    [self.cardCell updateForListObject:um];
    
    [self.view addSubview:self.teamCell];
    [self.view insertSubview:self.cardCell aboveSubview:self.listView];
    
    [Globals animateStartView:cardCell toEndView:slotView.notEmptyView fakeStartView:self.cardCell fakeEndView:self.teamCell completion:completion];
  } else {
    animView = slotView;
  }
  
  if (shouldFade) {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animView.layer addAnimation:animation forKey:@"fade"];
  }
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  [self openInfoForUserMonster:um allowSell:YES];
}

- (void) listView:(ListCollectionView *)listView speedupClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  UIView* invokingView = nil;
  MonsterListCell* mlc = (MonsterListCell*)[self.listView.collectionView cellForItemAtIndexPath:indexPath];
  if (mlc != nil && [mlc isKindOfClass:[MonsterListCell class]])
    invokingView = mlc.cardContainer.monsterCardView.cardBgdView;
  [self speedupClicked:um invokingView:invokingView indexPath:indexPath];
}

- (void) speedupClicked:(UserMonster *)um invokingView:(UIView*)sender indexPath:(NSIndexPath*)indexPath {
  Globals *gl = [Globals sharedGlobals];
  _combineMonster = um;
  _combineMonsterImageView = nil;
  
  int timeLeft = um.timeLeftForCombining;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gemCost <= 0) {
    [self speedupCombineMonster];
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
        if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
        {
          UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
          const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
          [svc showAnchoredToInvokingView:invokingButton
                            withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                        inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
        }
        else if ([sender isKindOfClass:[UIImageView class]]) // Heal mobster
        {
          _combineMonsterImageView = (UIImageView*)sender;
          
          // I apologize in advance for the following block of code :|
          const CGFloat contentOffsetY = self.listView.collectionView.contentOffset.y;
          const CGFloat contentSizeHeight = self.listView.collectionView.contentSize.height;
          const CGFloat collectionViewHeight = self.listView.collectionView.bounds.size.height;
          const CGFloat midY = [Globals convertPointToWindowCoordinates:_combineMonsterImageView.frame.origin
                                                    fromViewCoordinates:_combineMonsterImageView.superview].y + _combineMonsterImageView.bounds.size.height * .5f;
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
  }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView
{
  const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:_combineMonsterImageView.frame.origin fromViewCoordinates:_combineMonsterImageView.superview];
  ViewAnchoringDirection popupDirection = invokingViewAbsolutePosition.x < [Globals screenSize].width * .5f ? ViewAnchoringPreferRightPlacement : ViewAnchoringPreferLeftPlacement;
  [self.itemSelectViewController showAnchoredToInvokingView:_combineMonsterImageView withDirection:popupDirection inkovingViewImage:_combineMonsterImageView.image];
  
  [scrollView setDelegate:nil];
}

- (void) speedupCombineMonster {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = _combineMonster;
  
  int timeLeft = um.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] combineMonsterWithSpeedup:um.userMonsterUuid];
    if (success) {
      [self reloadListViewAnimated:YES];
      [self updateLabels];
      
      [QuestUtil checkAllDonateQuests];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:COMBINE_WAIT_COMPLETE_NOTIFICATION object:self];
    }
  }
}

#pragma mark - Team slot delegate

- (void) teamSlotRightSideClicked:(TeamSlotView *)sender {
  int tag = (int)sender.tag;
  if (tag) {
    UserMonster *um = [self monsterForSlot:tag];
    if (um) {
      [self openInfoForUserMonster:um allowSell:YES];
    }
  } else {
    GameState *gs = [GameState sharedGameState];
    ClanMemberTeamDonationProto *donation = [gs.clanTeamDonateUtil myTeamDonation];
    UserMonster *um = donation.donatedMonster;
    if (um) {
      [self openInfoForUserMonster:um allowSell:NO];
    }
  }
}

- (void) teamSlotMonsterClicked:(TeamSlotView *)sender {
  int tag = (int)sender.tag;
  if (tag) {
    UserMonster *um = [self monsterForSlot:sender.tag];
    if (!um) {
      _clickedSlot = (int)sender.tag;
      _openedSlot = (int)sender.tag;
      [self updateTeamSlotViews];
    } else if (_showsClanDonateToonView && _openedSlot != tag) {
      _openedSlot = (int)sender.tag;
      [self updateTeamSlotViews];
    } else {
      [self teamSlotRightSideClicked:sender];
    }
  } else {
    [self teamSlotRightSideClicked:sender];
  }
}

- (void) teamSlotMinusClicked:(TeamSlotView *)sender {
  if (sender.tag) {
    UserMonster *um = [self monsterForSlot:sender.tag];
    if (um.teamSlot) {
      int slotNum = um.teamSlot;
      BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromTeam:um.userMonsterUuid];
      _openedSlot = 0;
      
      if (success) {
        [self reloadListViewAnimated:YES];
        [self animateUserMonsterOutOfSlot:um slotNum:slotNum shouldFade:YES completion:^{
          [self updateTeamSlotViews];
        }];
        [self updateTeamSlotViews:YES animated:YES];
        
        [self reloadTitleView];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
      }
    }
  } else {
    // Clan monster
    NSString *desc = [NSString stringWithFormat:@"Would you like to remove your clan donated %@?", MONSTER_NAME];
    [GenericPopupController displayConfirmationWithDescription:desc title:[NSString stringWithFormat:@"Remove %@?", MONSTER_NAME] okayButton:@"Remove" cancelButton:@"Cancel" target:self selector:@selector(removeDonatedMonster)];
  }
}

- (void) removeDonatedMonster {
  GameState *gs = [GameState sharedGameState];
  ClanMemberTeamDonationProto *donation = [gs.clanTeamDonateUtil myTeamDonation];
  [[OutgoingEventController sharedOutgoingEventController] invalidateSolicitation:donation];
  
  [self updateTeamSlotViews];
}

- (void) animateUserMonsterOutOfSlot:(UserMonster *)um slotNum:(int)slotNum shouldFade:(BOOL)shouldFade completion:(dispatch_block_t)completion {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
  
  TeamSlotView *slotView = self.teamSlotViews.count >= slotNum ? self.teamSlotViews[slotNum-1] : nil;
  
  UIView *animView = slotView.rightView;
  if (cardCell && slotView) {
    [self.teamCell updateForUserMonster:um];
    [self listView:self.listView updateCell:self.cardCell forIndexPath:ip listObject:um];
    
    [self.view addSubview:self.teamCell];
    [self.view insertSubview:self.cardCell aboveSubview:self.listView];
    
    [Globals animateStartView:slotView.notEmptyView toEndView:cardCell fakeStartView:self.teamCell fakeEndView:self.cardCell completion:completion];
  } else {
    animView = slotView;
  }
  
  if (shouldFade) {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [animView.layer addAnimation:animation forKey:@"fade"];
  }
}

#pragma mark - Speedup Items Filler

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = _combineMonster.timeLeftForCombining;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  return gemCost;
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupCombineMonster];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId combineUserMonster:_combineMonster];
      
      [self updateLabels];
    }
    
    int timeLeft = _combineMonster.timeLeftForCombining;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) timeLeftForSpeedup {
  return _combineMonster.timeLeftForCombining;
}

- (int) totalSecondsRequired {
  return _combineMonster.staticMonster.minutesToCombinePieces*60;
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
  _combineMonster = nil;
  _combineMonsterImageView = nil;
}

#pragma mark - Clan Donate

- (IBAction)requestClicked:(UIView *)sender {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *msg = [ud stringForKey:LAST_TEAM_DONATE_MSG_KEY];
  
  if (!msg.length) {
    msg = [NSString stringWithFormat:@"Requests a %@", MONSTER_NAME];
  }
  
  _useGemsForDonate = (BOOL)[sender tag];
  
  DonateMsgViewController *dmvc = [[DonateMsgViewController alloc] initWithInitialMessage:msg];
  dmvc.delegate = self;
  self.donateMsgViewController = dmvc;
  GameViewController *gvc = [GameViewController baseController];
  dmvc.view.frame = gvc.view.bounds;
  [gvc addChildViewController:dmvc];
  
  [gvc.view addSubview:dmvc.view];
}

- (void) sendClickedWithMessage:(NSString *)message {
  message = message.length ? message : [NSString stringWithFormat:@"Requests a %@", MONSTER_NAME];
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud setObject:message forKey:LAST_TEAM_DONATE_MSG_KEY];
  
  [[OutgoingEventController sharedOutgoingEventController] solicitClanTeamDonation:message useGems:_useGemsForDonate];
  
  [self updateTeamSlotViews];
}

- (void) cancelClicked {
  
}

@end
