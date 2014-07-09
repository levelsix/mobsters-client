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
  
  [self.teamSlotViews[0] superview].userInteractionEnabled = NO;
  self.listView.collectionView.scrollEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.delegate teamOpened];
}

- (NSIndexPath *) indexPathForUserMonsterId:(uint64_t)userMonsterId {
  for (UserMonster *um in self.userMonsters) {
    if (um.userMonsterId == userMonsterId) {
      return [NSIndexPath indexPathForItem:[self.userMonsters indexOfObject:um] inSection:0];
    }
  }
  return nil;
}

- (void) moveToMonster:(uint64_t)userMonsterId {
  NSIndexPath *ip = [self indexPathForUserMonsterId:userMonsterId];
  [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void) unequipSlotThree {
  [self teamSlotMinusClicked:self.teamSlotViews[2]];
}

- (void) allowEquip:(uint64_t)userMonsterId {
  self.clickableUserMonsterId = userMonsterId;
  self.listView.userInteractionEnabled = YES;
  
  [self moveToMonster:userMonsterId];
  [self arrowOverMonster:userMonsterId];
}

- (void) arrowOverMonster:(uint64_t)userMonsterId {
  if (!_arrowOverPlusCreated) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    NSIndexPath *ip = [self indexPathForUserMonsterId:userMonsterId];
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
  if (um.userMonsterId == self.clickableUserMonsterId) {
    [super listView:listView cardClickedAtIndexPath:indexPath];
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate addedMobsterToTeam];
    self.clickableUserMonsterId = 0;
  }
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  // Do nothing
}

@end
