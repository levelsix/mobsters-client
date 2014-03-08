//
//  TutorialMyCroniesViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialMyCroniesViewController.h"
#import "Globals.h"

@implementation TutorialMyCroniesViewController

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

#pragma mark - Overwritten methods

- (void) viewDidLoad {
  [super viewDidLoad];
  self.inventoryTable.userInteractionEnabled = NO;
  self.queueView.userInteractionEnabled = NO;
}

- (NSMutableSet *) recentlyHealedMonsterIds {
  return nil;
}

- (NSMutableArray *) monsterHealingQueue {
  return self.healingQueue;
}

- (UserMonster *) monsterForSlot:(int)slot {
  return slot == 1 ? self.myMonsters[0] : nil;
}

- (NSArray *) monsterList {
  return self.myMonsters;
}

- (int) maxInventorySlots {
  return 1;
}

- (NSDate *) monsterHealingQueueEndTime {
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
  hi.queueTime = [NSDate date];
  hi.endTime = [hi.queueTime dateByAddingTimeInterval:(maxHp-um.curHealth)/_hospitalHealSpeed];
  hi.timeDistribution = @[@(hi.endTime.timeIntervalSinceNow), @(maxHp-um.curHealth)];
  [self.healingQueue addObject:hi];
  
  [self.delegate queuedUpMonster];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.inventoryTable.userInteractionEnabled = NO;
  return YES;
}

- (BOOL) speedupHealingQueue {
  Globals *gl = [Globals sharedGlobals];
  [self.monsterHealingQueue removeAllObjects];
  UserMonster *um = self.myMonsters[0];
  um.curHealth = [gl calculateMaxHealthForMonster:um];
  
  [self.delegate spedUpQueue];
  
  [Globals removeUIArrowFromViewRecursively:self.view];
  self.queueView.userInteractionEnabled = NO;
  return YES;
}

- (void) infoClicked:(MyCroniesCardCell *)cell {
  // Do nothing
}

- (void) minusClickedForTeamSlotView:(MonsterTeamSlotView *)mv {
  // Do nothing
}

- (void) cellRequestsRemovalFromHealQueue:(MyCroniesQueueCell *)cell {
  // Do nothing
}

- (void) menuCloseClicked:(id)sender {
  if (_allowClose) {
    [super menuCloseClicked:sender];
    [self.delegate exitedMyCronies];
  }
}

@end
