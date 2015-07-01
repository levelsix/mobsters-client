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

#import "DailyEventViewController.h"

@implementation EnhanceChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"EnhanceCardCell";
  
  self.title = [NSString stringWithFormat:@"ENHANCE %@S", MONSTER_NAME.uppercaseString];
  self.titleImageName = @"enhancelabmenuheader.png";
  
  self.noMobstersLabel.text = [NSString stringWithFormat:@"You have no available %@s.", MONSTER_NAME];
  self.queueEmptyLabel.text = [NSString stringWithFormat:@"Select a %@ to enhance.", MONSTER_NAME];
  
  self.leftCornerView = [[NSBundle mainBundle] loadNibNamed:@"DailyEventCornerView" owner:self options:nil][0];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.listView.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  cv.delegate = self;
  [cv updateForEnhance];
  
  [self reloadTitleView];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self reloadTitleView];
}

- (void) reloadTitleView {
  GameState *gs = [GameState sharedGameState];
  
  int cur = [gs currentlyUsedInventorySlots];
  int max = [gs maxInventorySlots];
  
  NSString *s1 = [NSString stringWithFormat:@"ENHANCE %@S ", MONSTER_NAME.uppercaseString];
  NSString *s2 = cur > max ? [NSString stringWithFormat:@"(%d/%d)", cur, max] : @"";
  NSString *str = [NSString stringWithFormat:@"%@%@", s1, s2];
  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
  
  if (cur > max) {
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.f green:1/255.f blue:0.f alpha:1.f] range:NSMakeRange(s1.length, str.length-s1.length)];
  }
  self.attributedTitle = attrStr;
}

- (void) updateLabels {
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  [cv updateLabels];
}

- (void) eventCornerViewClicked:(id)sender {
  if ([Globals shouldShowFatKidDungeon]) {
    DailyEventViewController *evc = [[DailyEventViewController alloc] init];
    [self.parentViewController pushViewController:evc animated:YES];
    [evc updateForEnhance];
  } else {
    GameState *gs = [GameState sharedGameState];
    UserStruct *us = gs.myLaboratory;
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must upgrade your %@ to Level %d to access Cake Kid events.", us.staticStruct.structInfo.name, FAT_KID_DUNGEON_LEVEL]];
  }
}

#pragma mark - Current enhancement

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
  BOOL greyscale = listObject.staticMonster.maxLevel <= listObject.level;
  
  [cell updateForListObject:listObject greyscale:greyscale];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.userMonsters[indexPath.row];
  
  EnhanceQueueViewController *eqvc = nil;
  
  if (um.level >= um.staticMonster.maxLevel) {
    NSString *name = um.staticMonster.monsterName;
    if (um.staticMonster.evolutionMonsterId) {
      [Globals addAlertNotification:[NSString stringWithFormat:@"%@ is at max level. Use the evolution lab to create the next form.", name]];
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"Oops, %@ is at max enhancement level.", name]];
    }
  } else {
    GameState *gs = [GameState sharedGameState];
    if (gs.userEnhancement) {
      eqvc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
    } else {
      eqvc = [[EnhanceQueueViewController alloc] initWithBaseMonster:um];
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
