//
//  EvolveChooserViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvolveChooserViewController.h"

#import "Globals.h"
#import "GameState.h"

#import "MonsterPopUpViewController.h"
#import "GameViewController.h"

#define NIB_NAME @"EvolveCardCell"

@implementation EvolveChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.collectionView registerNib:[UINib nibWithNibName:NIB_NAME bundle:nil] forCellWithReuseIdentifier:NIB_NAME];
  NSLog(@"%@", NSStringFromUIEdgeInsets([(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset]));
  
  self.title = @"EVOLVE MOBSTERS";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(waitTimeComplete) name:EVOLUTION_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
}

#pragma mark - Reloading collection view

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *validMonsters = [NSMutableArray array];
  NSMutableArray *ready = [NSMutableArray array];
  NSMutableArray *notReady = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && um.staticMonster.evolutionMonsterId) {
      [validMonsters addObject:um];
    }
  }
  
  [validMonsters sortUsingSelector:@selector(compare:)];
  
  while (validMonsters.count) {
    UserMonster *um = validMonsters[0];
    UserMonster *um2 = nil;
    UserMonster *cata = nil;
    int cataId = um.staticMonster.evolutionCatalystMonsterId;
    
    for (int i = 1; i < validMonsters.count; i++) {
      UserMonster *temp = validMonsters[i];
      if (!um2 && um.level >= um.staticMonster.maxLevel && temp.monsterId == um.monsterId && temp.level >= temp.staticMonster.maxLevel) {
        um2 = temp;
      } else if (temp.monsterId == cataId) {
        cata = temp;
      }
    }
    
    // Check if there is a cata within the already created evo items
    for (NSArray *arr in @[ready, notReady]) {
      for (EvoItem *evo in arr) {
        if (evo.userMonster1.monsterId == cataId) {
          cata = evo.userMonster1;
        } else if (evo.userMonster2.monsterId == cataId) {
          cata = evo.userMonster2;
        }
      }
    }
    
    [validMonsters removeObject:um];
    [validMonsters removeObject:um2];
    EvoItem *evo = [[EvoItem alloc] initWithUserMonster:um andUserMonster:um2 catalystMonster:cata];
    if (um2 && cata) {
      [ready addObject:evo];
    } else {
      [notReady addObject:evo];
    }
  }
  
  self.evoItems = @[ready, notReady];
}

- (void) reloadListViewAnimated:(BOOL)animated {
  NSArray *old = self.evoItems;
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  [self reloadMonstersArray];
  
  if (animated && old.count == self.evoItems.count) {
    for (int i = 0; i < old.count; i++) {
      [Globals calculateDifferencesBetweenOldArray:old[i] newArray:self.evoItems[i] removalIps:remove additionIps:add section:0];
    }
    
    if (add.count || remove.count) {
      [self.collectionView performBatchUpdates:^{
        if (add.count) {
          [self.collectionView insertItemsAtIndexPaths:add];
        }
        if (remove.count) {
          [self.collectionView deleteItemsAtIndexPaths:remove];
        }
      } completion:nil];
    }
  } else {
    [self.collectionView reloadData];
  }
}

#pragma mark - UICollectionView dataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.evoItems.count;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.evoItems[section] count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  EvolveCardCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NIB_NAME forIndexPath:indexPath];
  EvoItem *ei = self.evoItems[indexPath.section][indexPath.row];
  
  cell.delegate = self;
  [cell updateForEvoItem:ei];
  
  return cell;
}

#pragma EnhanceCard delegate

- (void) cardClicked:(id)sender {
  
}

- (void) infoClicked:(id)sender {
  NSIndexPath *ip = [self.collectionView indexPathForCell:sender];
  EvoItem *ei = self.evoItems[ip.section][ip.row];
  UserMonster *um = ei.userMonster1;
  MonsterPopUpViewController *mpvc = [[MonsterPopUpViewController alloc] initWithMonsterProto:um allowSell:YES];
  UIViewController *parent = [GameViewController baseController];
  mpvc.view.frame = parent.view.bounds;
  [parent.view addSubview:mpvc.view];
  [parent addChildViewController:mpvc];
}

@end
