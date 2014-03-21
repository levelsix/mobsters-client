//
//  TutorialMyCroniesViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialMyCroniesViewController.h"
#import "Globals.h"
#import "GameState.h"

@interface RectHoleView : UIView

@property (nonatomic, assign) CGRect holeRect;
@property (nonatomic, retain) UIColor *surroundingColor;

@end

@implementation RectHoleView

- (id) initWithFrame:(CGRect)frame holeRect:(CGRect)hole {
  if ((self = [super initWithFrame:frame])) {
    self.holeRect = hole;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
  }
  return self;
}

- (void) drawRect:(CGRect)rect {
  [self.surroundingColor setFill];
  UIRectFill(rect);
  
  CGRect intersection = CGRectIntersection(self.holeRect, rect);
  
  [[UIColor clearColor] setFill];
  UIRectFill(intersection);
}

@end

@interface TutorialMyCroniesViewController ()

@property (nonatomic, retain) RectHoleView *holeView;
@property (nonatomic, retain) UIView *darkenedTopBarView;

@end

@implementation TutorialMyCroniesViewController

- (id) init {
  if ((self = [super initWithNibName:@"MyCroniesViewController" bundle:nil])) {
    GameState *gs = [GameState sharedGameState];
    self.myMonsters = gs.myMonsters;
  }
  return self;
}

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants damageDealt:(int)damageDealt hospitalHealSpeed:(float)hospSpeed {
  if ((self = [super initWithNibName:@"MyCroniesViewController" bundle:nil])) {
    self.constants = constants;
    
    self.healingQueue = [NSMutableArray array];
    
    self.myMonsters = [NSMutableArray array];
    
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterId = 1;
    um.monsterId = constants.startingMonsterId;
    um.teamSlot = 1;
    um.isComplete = YES;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um]-damageDealt;
    [self.myMonsters addObject:um];
    
    _hospitalHealSpeed = hospSpeed;
  }
  return self;
}

- (void) allowCardClick {
  _allowCardClick = YES;
  self.inventoryTable.userInteractionEnabled = YES;
  
  UIView *v = self.inventoryTable.visibleViews[0];
  [Globals createUIArrowForView:v.superview.superview.superview.superview atAngle:-M_PI_2];
}

- (void) allowSpeedup {
  self.queueView.userInteractionEnabled = YES;
  
  [Globals createUIArrowForView:self.queueView.speedupButton atAngle:M_PI_2];
}

- (void) allowClose {
  _allowClose = YES;
  
  [Globals createUIArrowForView:self.menuCloseButton atAngle:M_PI];
}

- (NSIndexPath *) indexPathForUserMonsterId:(uint64_t)userMonsterId {
  [self reloadMonstersArray];
  NSArray *arrs = @[self.injuredMonsters, self.recentlyHealedMonsters, self.healthyMonsters, self.unavailableMonsters];
  for (int i = 0; i < arrs.count; i++) {
    NSArray *ums = arrs[i];
    for (int j = 0; j < ums.count; j++) {
      UserMonster *um = ums[j];
      if (um.userMonsterId == userMonsterId) {
        return [NSIndexPath indexPathForRow:j inSection:i];
      }
    }
  }
  return nil;
}

- (void) moveToMonster:(uint64_t)userMonsterId {
  self.clickableUserMonsterId = userMonsterId;
  NSIndexPath *ip = [self indexPathForUserMonsterId:userMonsterId];
  [self.inventoryTable.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) unequipSlotThree {
  [self minusClickedForTeamSlotView:[self teamSlotViewForSlotNum:3]];
}

- (void) highlightTeamView {
  CGRect hole = [self.navigationController.view convertRect:self.teamSlotsContainer.frame fromView:self.teamSlotsContainer.superview];
  self.holeView = [[RectHoleView alloc] initWithFrame:self.view.bounds holeRect:hole];
  self.holeView.surroundingColor = [UIColor colorWithWhite:0.f alpha:0.7f];
  [self.view addSubview:self.holeView];
  
  self.darkenedTopBarView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
  self.darkenedTopBarView.backgroundColor = self.holeView.surroundingColor;
  [self.navigationController.navigationBar addSubview:self.darkenedTopBarView];
  
  self.holeView.alpha = 0.f;
  self.darkenedTopBarView.alpha = 0.f;
  [UIView animateWithDuration:0.3 animations:^{
    self.holeView.alpha = 1.f;
    self.darkenedTopBarView.alpha = 1.f;
  }];
}

- (void) removeHighlightView {
  [UIView animateWithDuration:0.3 animations:^{
    self.holeView.alpha = 0.f;
    self.darkenedTopBarView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.holeView removeFromSuperview];
    [self.darkenedTopBarView removeFromSuperview];
  }];
}

- (void) allowEquip:(uint64_t)userMonsterId {
  [self removeHighlightView];
  
  self.clickableUserMonsterId = userMonsterId;
  self.inventoryTable.userInteractionEnabled = YES;
  
  [self arrowOverMonster:userMonsterId];
}

- (void) arrowOverMonster:(uint64_t)userMonsterId {
  if (!_arrowOverPlusCreated) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    NSIndexPath *ip = [self indexPathForUserMonsterId:userMonsterId];
    MyCroniesCardCell *cell = (MyCroniesCardCell *)[self.inventoryTable viewAtIndexPath:ip];
    if (cell) {
      _arrowOverPlusCreated = YES;
      [Globals createUIArrowForView:cell.onTeamIcon atAngle:-M_PI_4];
    }
  }
}

#pragma mark - Overwritten methods

- (void) easyTableViewDidEndScrollingAnimation:(EasyTableView *)easyTableView {
  if (self.clickableUserMonsterId) {
    [self arrowOverMonster:self.clickableUserMonsterId];
  }
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.inventoryTable.userInteractionEnabled = NO;
  self.inventoryTable.tableView.scrollEnabled = NO;
  self.queueView.userInteractionEnabled = NO;
  self.queueView.queueTable.tableView.scrollEnabled = NO;
  self.teamSlotsContainer.userInteractionEnabled = NO;
}

- (NSMutableSet *) recentlyHealedMonsterIds {
  return nil;
}

- (NSMutableArray *) monsterHealingQueue {
  return self.healingQueue;
}

- (UserMonster *) monsterForSlot:(NSInteger)slot {
  for (UserMonster *um in self.myMonsters) {
    if (um.teamSlot == slot) {
      return um;
    }
  }
  return nil;
}

- (NSArray *) monsterList {
  return self.myMonsters;
}

- (int) maxInventorySlots {
  return 1;
}

- (MSDate *) monsterHealingQueueEndTime {
  if (self.healingQueue.count > 0) {
    UserMonsterHealingItem *hi = self.healingQueue[0];
    return hi.endTime;
  }
  return nil;
}

- (int) maxQueueSize {
  return 1;
}

- (int) numValidHospitals {
  return 1;
}

- (BOOL) userMonsterIsUnavailable:(UserMonster *)um {
  for (UserMonsterHealingItem *hi in self.healingQueue) {
    if (hi.userMonsterId == um.userMonsterId) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) addMonsterToHealingQueue:(int)umId useGems:(BOOL)useGems {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.myMonsters[0];
  int maxHp = [gl calculateMaxHealthForMonster:um];
  UserMonsterHealingItem *hi = [[UserMonsterHealingItem alloc] init];
  hi.userMonsterId = umId;
  hi.queueTime = [MSDate date];
  hi.endTime = [hi.queueTime dateByAddingTimeInterval:(maxHp-um.curHealth)/_hospitalHealSpeed];
  hi.timeDistribution = @[@(hi.endTime.timeIntervalSinceNow), @(maxHp-um.curHealth)];
  [self.healingQueue addObject:hi];
  
  int cashCost = [gl calculateCostToHealMonster:um];
  [self.delegate queuedUpMonster:cashCost];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.inventoryTable.userInteractionEnabled = NO;
  return YES;
}

- (BOOL) speedupHealingQueue {
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  [self.monsterHealingQueue removeAllObjects];
  UserMonster *um = self.myMonsters[0];
  um.curHealth = [gl calculateMaxHealthForMonster:um];
  
  [self.delegate spedUpQueue:gemCost];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.queueView.userInteractionEnabled = NO;
  return YES;
}

- (void) updateLabels {
  [super updateLabels];
  
  if (self.monsterHealingQueueEndTime.timeIntervalSinceNow < 0) {
    [self speedupButtonClicked];
  }
}

- (void) infoClicked:(MyCroniesCardCell *)cell {
  // Do nothing
}

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  // Do nothing
}

- (void) cardClicked:(MyCroniesCardCell *)cell {
  if (_allowCardClick) {
    _allowCardClick = NO;
    [super cardClicked:cell];
  }
}

- (void) menuCloseClicked:(id)sender {
  if (_allowClose) {
    [super menuCloseClicked:sender];
    [self.delegate exitedMyCronies];
  }
}

- (void) plusClicked:(MyCroniesCardCell *)cell {
  if (cell.monster.userMonsterId == self.clickableUserMonsterId) {
    [super plusClicked:cell];
    [self.delegate addedMobsterToTeam];
    [Globals removeUIArrowFromViewRecursively:self.view];
  }
}

@end
