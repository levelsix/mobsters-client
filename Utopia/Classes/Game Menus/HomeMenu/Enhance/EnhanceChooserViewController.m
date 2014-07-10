//
//  EnhanceChooserViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EnhanceChooserViewController.h"
#import "EnhanceQueueViewController.h"

#import "MonsterPopUpViewController.h"
#import "GameViewController.h"

#import "GameState.h"
#import "Globals.h"

@implementation EnhanceChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"EnhanceCardCell";
  
  self.title = [NSString stringWithFormat:@"ENHANCE %@S", MONSTER_NAME.uppercaseString];
  self.titleImageName = @"enhancelabmenuheader.png";
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no available %@s.", MONSTER_NAME.lowercaseString];
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ to enhance.", MONSTER_NAME.lowercaseString];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  
  [self updateBottomView];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self updateBottomView];
}

- (void) updateBottomView {
  GameState *gs = [GameState sharedGameState];
  UserEnhancement *ue = gs.userEnhancement;
  
  if (ue) {
    [self.monsterView updateForMonsterId:ue.baseMonster.userMonster.monsterId];
    self.monsterNameLabel.text = [NSString stringWithFormat:@"Enhancing: %@", ue.baseMonster.userMonster.staticMonster.displayName];
    
    [self updateLabels];
    
    self.bottomBarButton.enabled = YES;
    self.enhancingView.hidden = NO;
    self.notEnhancingView.hidden = YES;
  } else {
    self.bottomBarButton.enabled = NO;
    self.enhancingView.hidden = YES;
    self.notEnhancingView.hidden = NO;
  }
}

#pragma mark - Current enhancement

- (IBAction)bottomBarClicked:(id)sender {
  EnhanceQueueViewController *eqvc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [self.parentViewController pushViewController:eqvc animated:YES];
}

- (void) updateLabels {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserEnhancement *ue = gs.userEnhancement;
  int timeLeft = [gl calculateTimeLeftForEnhancement:ue];
  self.timeLeftLabel.text = [NSString stringWithFormat:@"Time Left: %@", [Globals convertTimeToShortString:timeLeft]];
}

#pragma mark - Reloading collection view

- (void) reloadListViewAnimated:(BOOL)animated {
  [self reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.userMonsters];
}

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *avail = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    // Only get the monster that is enhancing, not the sacrificial ones
    if (um.isAvailable || um.isEnhancing) {
      [avail addObject:um];
    }
  }
  
  NSComparator comp = ^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    BOOL isMax1 = obj1.level >= obj1.staticMonster.maxLevel;
    BOOL isMax2 = obj2.level >= obj2.staticMonster.maxLevel;
    if (isMax1 != isMax2) {
      return [@(isMax1) compare:@(isMax2)];
    } else if (obj1.isEnhancing != obj2.isEnhancing) {
      return [@(obj2.isEnhancing) compare:@(obj1.isEnhancing)];
    } else {
      return [obj1 compare:obj2];
    }
  };
  [avail sortUsingComparator:comp];
  self.userMonsters = avail;
}

#pragma mark - Monster card delegate

- (void) listView:(ListCollectionView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)ip listObject:(UserMonster *)listObject {
  GameState *gs = [GameState sharedGameState];
  BOOL greyscale = NO;
  if ((gs.userEnhancement && !listObject.isEnhancing) || listObject.staticMonster.maxLevel <= listObject.level) {
    greyscale = YES;
  }
  
  [cell updateForListObject:listObject greyscale:greyscale];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  EnhanceQueueViewController *eqvc = nil;
  
  GameState *gs = [GameState sharedGameState];
  if (gs.userEnhancement && um.userMonsterId == gs.userEnhancement.baseMonster.userMonsterId) {
    eqvc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  } else {
    if (um.level >= um.staticMonster.maxLevel) {
      NSString *name = um.staticMonster.monsterName;
      if (um.staticMonster.evolutionMonsterId) {
        [Globals addAlertNotification:[NSString stringWithFormat:@"%@ is at max level. Use the evolution lab to create the next form.", name]];
      } else {
        [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, %@ is at max enhancement level.", name]];
      }
    } else {
      eqvc = [[EnhanceQueueViewController alloc] initWithBaseMonster:um allowAddingToQueue:(gs.userEnhancement == nil)];
    }
  }
  
  if (eqvc) {
    [self.parentViewController pushViewController:eqvc animated:YES];
  }
}

- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:YES];
  UIViewController *parent = [GameViewController baseController];
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

@end
