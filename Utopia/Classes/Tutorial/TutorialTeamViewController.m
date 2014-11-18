//
//  TutorialTeamViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialTeamViewController.h"

#import "Globals.h"

@implementation TutorialTeamViewController

- (id) init {
  if ((self = [super initWithNibName:@"TeamViewController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self unequipSlotThree];
  [self.listView.collectionView reloadData];
  [self.listView.collectionView layoutIfNeeded];
  
  [self.teamSlotViews[0] superview].userInteractionEnabled = NO;
  self.listView.collectionView.scrollEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.delegate teamOpened];
}

- (NSIndexPath *) indexPathForUserMonsterUuid:(NSString *)userMonsterUuid {
  for (UserMonster *um in self.userMonsters) {
    if ([um.userMonsterUuid isEqualToString:userMonsterUuid]) {
      return [NSIndexPath indexPathForItem:[self.userMonsters indexOfObject:um] inSection:0];
    }
  }
  return nil;
}

- (void) moveToMonster:(NSString *)userMonsterUuid {
  NSIndexPath *ip = [self indexPathForUserMonsterUuid:userMonsterUuid];
  [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void) unequipSlotThree {
  [self teamSlotMinusClicked:self.teamSlotViews[2]];
}

- (void) allowEquip:(NSString *)userMonsterUuid {
  self.clickableUserMonsterUuid = userMonsterUuid;
  self.listView.userInteractionEnabled = YES;
  
  [self moveToMonster:userMonsterUuid];
  [self arrowOverMonster:userMonsterUuid];
}

- (void) arrowOverMonster:(NSString *)userMonsterUuid {
  if (!_arrowOverPlusCreated) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    NSIndexPath *ip = [self indexPathForUserMonsterUuid:userMonsterUuid];
    MonsterListCell *cell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
    if (cell) {
      _arrowOverPlusCreated = YES;
      float angle = cell.center.x > cell.superview.frame.size.width/2 ? M_PI : 0;
      [Globals createUIArrowForView:cell atAngle:angle];
    }
  }
}

- (void) allowClose {
  _allowClose = YES;
  
  [Globals createUIArrowForView:self.parentViewController.closeButton atAngle:M_PI];
}


- (BOOL) canClose {
  if (_allowClose) {
    [self.delegate teamClosed];
  }
  return _allowClose;
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  if ([um.userMonsterUuid isEqualToString:self.clickableUserMonsterUuid]) {
    [super listView:listView cardClickedAtIndexPath:indexPath];
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate addedMobsterToTeam];
    self.clickableUserMonsterUuid = nil;
  }
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  // Do nothing
}

@end
