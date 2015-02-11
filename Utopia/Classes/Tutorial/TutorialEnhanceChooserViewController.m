//
//  TutorialEnhanceViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TutorialEnhanceChooserViewController.h"

#import "Globals.h"

@implementation TutorialEnhanceChooserViewController

- (id) init {
  if ((self = [super initWithNibName:@"EnhanceChooserViewController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.listView.collectionView reloadData];
  [self.listView.collectionView layoutIfNeeded];
  
  self.listView.collectionView.scrollEnabled = NO;
  
  [self.leftCornerView removeFromSuperview];
  self.leftCornerView = nil;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.delegate chooserOpened];
}

- (void) allowChoose:(NSString *)userMonsterUuid {
  self.clickableUserMonsterUuid = userMonsterUuid;
  self.listView.userInteractionEnabled = YES;
  
  [self moveToMonster:userMonsterUuid];
  [self arrowOverMonster:userMonsterUuid];
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

- (void) arrowOverMonster:(NSString *)userMonsterUuid {
  if (!_arrowOverMonsterCreated) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    NSIndexPath *ip = [self indexPathForUserMonsterUuid:userMonsterUuid];
    MonsterListCell *cell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
    if (cell) {
      _arrowOverMonsterCreated = YES;
      float angle = cell.center.x > cell.superview.frame.size.width/2 ? M_PI : 0;
      [Globals createUIArrowForView:cell atAngle:angle];
    }
  }
}


- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  if ([um.userMonsterUuid isEqualToString:self.clickableUserMonsterUuid]) {
    [self.delegate choseMonster];
    [Globals removeUIArrowFromViewRecursively:self.view];
    self.clickableUserMonsterUuid = nil;
  }
}

- (BOOL) canClose {
  return NO;
}

@end
