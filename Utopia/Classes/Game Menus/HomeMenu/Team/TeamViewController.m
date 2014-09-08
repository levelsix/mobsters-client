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

@implementation TeamSlotView

- (void) setTag:(NSInteger)tag {
  [super setTag:tag];
  self.slotNumLabel.text = [NSString stringWithFormat:@"%d", (int)tag];
  self.botLabel.text = [NSString stringWithFormat:@"Tap %@ to Add", MONSTER_NAME];
}

- (void) updateLeftViewForUserMonster:(UserMonster *)um {
  if (!um) {
    self.notEmptyView.alpha = 0.f;
    self.emptyView.hidden = NO;
  } else {
    self.notEmptyView.alpha = 1.f;
    self.monsterView.alpha = [um isAvailable] ? 1.f : 0.6f;
    self.emptyView.hidden = ![um isAvailable];
    
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
  Globals *gl = [Globals sharedGlobals];
  if (!um) {
    self.botLabel.hidden = NO;
    self.healthBarView.hidden = YES;
    
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
    
    if (![um isAvailable]) {
      self.botLabel.hidden = NO;
      self.healthBarView.hidden = YES;
    } else {
      self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
      self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:um.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]]];
      
      self.botLabel.hidden = YES;
      self.healthBarView.hidden = NO;
    }
  }
}

- (void) updateForUserMonster:(UserMonster *)um {
  [self updateLeftViewForUserMonster:um];
  [self updateRightViewForUserMonster:um];
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate teamSlotMinusClicked:self];
}

- (IBAction)rightSideClicked:(id)sender {
  [self.delegate teamSlotRightSideClicked:self];
}

@end

@implementation TeamViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.cardCell = [[NSBundle mainBundle] loadNibNamed:@"TeamCardCell" owner:self options:nil][0];
  self.cardCell.cardContainer.monsterCardView.infoButton.hidden = NO;
  
  self.teamCell = [[NSBundle mainBundle] loadNibNamed:@"TeamSlotView" owner:self options:nil][0];
  [self.teamCell.rightView removeFromSuperview];
  self.teamCell.frame = CGRectMake(0, 0, self.teamCell.leftView.frame.size.width, self.teamCell.leftView.frame.size.height);
  
  self.listView.cellClassName = @"TeamCardCell";
  
  NSMutableArray *realSlotViews = [NSMutableArray array];
  for (UIView *fake in self.teamSlotViews) {
    TeamSlotView *slot = [[NSBundle mainBundle] loadNibNamed:@"TeamSlotView" owner:self options:nil][0];
    slot.frame = fake.frame;
    slot.delegate = self;
    slot.tag = fake.tag;
    
    [fake.superview addSubview:slot];
    [fake removeFromSuperview];
    
    [realSlotViews addObject:slot];
  }
  self.teamSlotViews = realSlotViews;
  
  self.titleImageName = @"manageteammenuheader.png";
  
  self.unavailableLabel.text = [NSString stringWithFormat:@"You have no more available %@s.", MONSTER_NAME];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  [self updateTeamSlotViews];
  
  [self reloadTitleView];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self updateTeamSlotViews];
  [self reloadTitleView];
}

- (void) updateLabels {
  for (MonsterListCell *listCell in self.listView.collectionView.visibleCells) {
    UserMonster *um = self.userMonsters[[self.listView.collectionView indexPathForCell:listCell].row];
    [listCell updateCombineTimeForUserMonster:um];
  }
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSString *str = [NSString stringWithFormat:@"MANAGE TEAM (%d/%d)", (int)gs.allBattleAvailableAliveMonstersOnTeam.count, gl.maxTeamSize];
  self.title = str;
}

- (void) updateTeamSlotViews {
  NSUInteger nextSlot = self.teamSlotViews.count+1;
  BOOL foundAvailSlot = NO;
  for (TeamSlotView *slot in self.teamSlotViews) {
    UserMonster *um = [self monsterForSlot:slot.tag];
    [slot updateForUserMonster:um];
    
    if (!um && nextSlot > slot.tag) {
      nextSlot = slot.tag;
      foundAvailSlot = YES;
    } else if (!foundAvailSlot && ![um isAvailable] && nextSlot > slot.tag) {
      nextSlot = slot.tag;
    }
  }
  
  for (TeamSlotView *slot in self.teamSlotViews) {
    slot.tapToAddLabel.hidden = slot.tag != nextSlot;
  }
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

- (void) openInfoForUserMonster:(UserMonster *)um {
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:YES];
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
    BOOL isDead1 = obj1.curHealth <= 0;
    BOOL isDead2 = obj2.curHealth <= 0;
    
    if (isDead1 != isDead2) {
      return [@(isDead1) compare:@(isDead2)];
    } else {
      return [obj1 compare:obj2];
    }
  };
  [avail sortUsingComparator:comp];
  self.userMonsters = avail;
}

#pragma mark - Monster card delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(UserMonster *)listObject {
  BOOL greyscale = !listObject.isAvailable || listObject.curHealth <= 0;
  [cell updateForListObject:listObject greyscale:greyscale];
  cell.cardContainer.monsterCardView.overlayButton.userInteractionEnabled = !greyscale;
  
  // Need to do this because if monster's health is 0, it will not show the healthbar since greyscale = YES
  if (listObject.isAvailable) {
    cell.availableView.hidden = NO;
    
    cell.cardContainer.monsterCardView.overlayButton.userInteractionEnabled = YES;
  }
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  if ([um isAvailable] && um.curHealth > 0) {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] addMonsterToTeam:um.userMonsterId];
    
    if (success) {
      [self updateTeamSlotViews];
      [self animateUserMonsterIntoSlot:um];
      [self reloadListViewAnimated:YES];
      
      [self reloadTitleView];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  } else if (um.curHealth <= 0) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must heal %@ before adding to your team.", um.staticMonster.displayName]];
  }
}

- (void) animateUserMonsterIntoSlot:(UserMonster *)um {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:monsterIndex inSection:0]];
  
  TeamSlotView *slotView = self.teamSlotViews.count >= um.teamSlot ? self.teamSlotViews[um.teamSlot-1] : nil;
  
  UIView *animView = slotView.rightView;
  if (cardCell && slotView) {
    [self.teamCell updateForUserMonster:um];
    [self.cardCell updateForListObject:um];
    
    [self.view addSubview:self.teamCell];
    [self.view insertSubview:self.cardCell aboveSubview:self.listView];
    
    [Globals animateStartView:cardCell toEndView:slotView.notEmptyView fakeStartView:self.cardCell fakeEndView:self.teamCell];
  } else {
    animView = slotView;
  }
  
  CATransition *animation = [CATransition animation];
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [slotView.rightView.layer addAnimation:animation forKey:@"fade"];
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  [self openInfoForUserMonster:um];
}

- (void) listView:(ListCollectionView *)listView speedupClickedAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.userMonsters[indexPath.row];
  int timeLeft = um.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:NO];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] combineMonsterWithSpeedup:um.userMonsterId];
    if (success) {
      [self reloadListViewAnimated:YES];
      
      [QuestUtil checkAllDonateQuests];
    }
  }
}

#pragma mark - Team slot delegate

- (void) teamSlotRightSideClicked:(TeamSlotView *)sender {
  UserMonster *um = [self monsterForSlot:sender.tag];
  if (um) {
    [self openInfoForUserMonster:um];
  }
}

- (void) teamSlotMinusClicked:(TeamSlotView *)sender {
  UserMonster *um = [self monsterForSlot:sender.tag];
  if (um.teamSlot) {
    int slotNum = um.teamSlot;
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] removeMonsterFromTeam:um.userMonsterId];
    
    if (success) {
      [self reloadListViewAnimated:YES];
      [self animateUserMonsterOutOfSlot:um slotNum:slotNum];
      [self updateTeamSlotViews];
      
      [self reloadTitleView];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    }
  }
}

- (void) animateUserMonsterOutOfSlot:(UserMonster *)um slotNum:(int)slotNum {
  int monsterIndex = (int)[self.listView.listObjects indexOfObject:um];
  NSIndexPath *ip = [NSIndexPath indexPathForRow:monsterIndex inSection:0];
  MonsterListCell *cardCell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
  
  TeamSlotView *slotView = self.teamSlotViews.count >= slotNum ? self.teamSlotViews[slotNum-1] : nil;
  
  UIView *animView = slotView.rightView;
  if (cardCell && slotView) {
    [self.teamCell updateForUserMonster:um];
    [self.cardCell updateForListObject:um greyscale:![um isAvailable]];
    
    [self.view addSubview:self.teamCell];
    [self.view insertSubview:self.cardCell aboveSubview:self.listView];
    
    [Globals animateStartView:slotView.notEmptyView toEndView:cardCell fakeStartView:self.teamCell fakeEndView:self.cardCell];
  } else {
    animView = slotView;
  }
  
  CATransition *animation = [CATransition animation];
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [animView.layer addAnimation:animation forKey:@"fade"];
}

@end
