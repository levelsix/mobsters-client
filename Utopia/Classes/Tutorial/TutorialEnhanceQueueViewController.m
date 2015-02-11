//
//  TutorialEnhanceQueueViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/10/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TutorialEnhanceQueueViewController.h"
#import "EnhanceQueueViewController+Animations.h"

#import "Globals.h"
#import "GameState.h"

@implementation TutorialEnhanceQueueViewController

- (id) init {
  if ((self = [super initWithNibName:@"EnhanceQueueViewController" bundle:nil])) {
    
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
  [self.delegate queueOpened];
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
  [self.listView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void) arrowOverMonster:(NSString *)userMonsterUuid {
  if (!_arrowOverMonsterCreated) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    NSIndexPath *ip = [self indexPathForUserMonsterUuid:userMonsterUuid];
    MonsterListCell *cell = (MonsterListCell *)[self.listView.collectionView cellForItemAtIndexPath:ip];
    if (cell) {
      _arrowOverMonsterCreated = YES;
      float angle = M_PI_2;
      [Globals createUIArrowForView:cell atAngle:angle inSuperview:self.view];
    }
  }
}


- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  if ([um.userMonsterUuid isEqualToString:self.clickableUserMonsterUuid]) {
    [super listView:listView cardClickedAtIndexPath:indexPath];
    [Globals removeUIArrowFromViewRecursively:self.view];
    self.clickableUserMonsterUuid = nil;
    [self.delegate choseFeeder];
  }
}

- (void) checkUserMonsterOnTeam {
  [self confirmationAccepted];
}

- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath {
  // Do nothing
}

- (void) allowEnhance {
  _allowEnhance = YES;
  
  [Globals createUIArrowForView:self.enhanceButtonView atAngle:M_PI inSuperview:self.view];
}

- (void) allowFinish {
  _allowFinish = YES;
  
  [Globals createUIArrowForView:self.finishButtonView atAngle:M_PI inSuperview:self.view];
}

- (IBAction) enhanceButtonClicked:(id)sender {
  if (_allowEnhance) {
    [super enhanceButtonClicked:sender];
    
    [Globals removeUIArrowFromViewRecursively:self.view];
    
    _allowEnhance = NO;
  }
}
- (void) handleSubmitMonsterEnhancementResponseProto:(FullEvent *)fe {
  [super handleSubmitMonsterEnhancementResponseProto:fe];
  
  [self.delegate beganEnhance];
}

- (IBAction)finishClicked:(id)sender {
  if (_allowFinish) {
    [super finishClicked:sender];
    
    [Globals removeUIArrowFromViewRecursively:self.view];
    
    // Need to allow collect to do it
    //_allowFinish = NO;
  }
}

- (IBAction)collectClicked:(id)sender {
  if (_allowFinish) {
    [super collectClicked:sender];
    
    [Globals removeUIArrowFromViewRecursively:self.view];
    
    _allowFinish = NO;
  }
}

- (void) enhancementAnimationComplete {
  [super enhancementAnimationComplete];
  
  [self.delegate finishedEnhance];
}

- (void) allowClose {
  _allowClose = YES;
  
  [Globals createUIArrowForView:self.parentViewController.closeButton atAngle:M_PI inSuperview:self.parentViewController.view];
}


- (BOOL) canClose {
  if (_allowClose) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate queueClosed];
  }
  return _allowClose;
}

- (BOOL) canGoBack {
  return NO;
}

@end
