//
//  TutorialHealViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialHealViewController.h"

#import "Globals.h"

@implementation TutorialHealViewController

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants damageDealt:(int)damageDealt hospitalHealSpeed:(float)hospSpeed {
  if ((self = [super initWithNibName:@"HealViewController" bundle:nil])) {
    self.constants = constants;
    
    self.healingQueue = [NSMutableArray array];
    
    self.myMonsters = [NSMutableArray array];
    
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterUuid = @"1";
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
  self.listView.userInteractionEnabled = YES;
  
  UIView *v = self.listView.collectionView.visibleCells[0];
  [Globals createUIArrowForView:v atAngle:0];
}

- (void) allowSpeedup {
  self.queueView.userInteractionEnabled = YES;
  
  [Globals createUIArrowForView:self.speedupCostLabel.superview.superview atAngle:M_PI_2];
}

- (void) allowClose {
  _allowClose = YES;
  
  [Globals createUIArrowForView:self.parentViewController.closeButton atAngle:M_PI];
}

#pragma mark - Overwritten methods

- (void) viewDidLoad {
  [super viewDidLoad];
  self.listView.userInteractionEnabled = NO;
  self.listView.collectionView.scrollEnabled = NO;
  self.queueView.userInteractionEnabled = NO;
  self.queueView.collectionView.scrollEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.delegate healOpened];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.delegate healClosed];
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
  return 2;
}

- (int) numValidHospitals {
  return 1;
}

- (BOOL) userMonsterIsAvailable:(UserMonster *)um {
  for (UserMonsterHealingItem *hi in self.healingQueue) {
    if ([hi.userMonsterUuid isEqualToString:um.userMonsterUuid]) {
      return NO;
    }
  }
  Globals *gl = [Globals sharedGlobals];
  return um.curHealth < [gl calculateMaxHealthForMonster:um];
}

- (BOOL) addMonsterToHealingQueue:(NSString *)umUuid itemsDict:(NSDictionary *)itemsDict useGems:(BOOL)useGems {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.myMonsters[0];
  int maxHp = [gl calculateMaxHealthForMonster:um];
  UserMonsterHealingItem *hi = [[UserMonsterHealingItem alloc] init];
  hi.userMonsterUuid = umUuid;
  hi.queueTime = [MSDate date];
  hi.endTime = [hi.queueTime dateByAddingTimeInterval:(maxHp-um.curHealth)/_hospitalHealSpeed];
  hi.timeDistribution = @[@(hi.endTime.timeIntervalSinceNow), @(maxHp-um.curHealth)];
  [self.healingQueue addObject:hi];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.listView.userInteractionEnabled = NO;
  
  int cashCost = [gl calculateCostToHealMonster:um];
  [self.delegate queuedUpMonster:cashCost];
  
  return YES;
}

- (BOOL) sendSpeedupHealingQueue {
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = self.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  [self.monsterHealingQueue removeAllObjects];
  UserMonster *um = self.myMonsters[0];
  um.curHealth = [gl calculateMaxHealthForMonster:um];
  
  [self.delegate spedUpQueue:gemCost];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.queueView.userInteractionEnabled = NO;
  
  [self handleHealMonsterResponseProto:nil];
  
  // Return no so that the spinner doesn't appear
  return NO;
}

- (void) updateLabels {
  [super updateLabels];
  
  if (self.monsterHealingQueueEndTime.timeIntervalSinceNow < 0) {
    [self speedupButtonClicked:nil];
  }
}

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  // Do nothing
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  if (_allowCardClick) {
    _allowCardClick = NO;
    [super listView:listView cardClickedAtIndexPath:indexPath];
  }
}

- (BOOL) canClose {
  return _allowClose;
}

@end