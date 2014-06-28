//
//  EvolveChooserViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "EvolveChooserViewController.h"
#import "EvolveDetailsViewController.h"

#import "Globals.h"
#import "GameState.h"

#import "MonsterPopUpViewController.h"
#import "GameViewController.h"

#define NIB_NAME @"EvolveCardCell"
#define HEADER_NAME @"EvolveHeaderView"
#define DESCRIPTION_HEADER_NAME @"EvolveDescriptionHeaderView"

@implementation EvolveChooserViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.collectionView registerNib:[UINib nibWithNibName:NIB_NAME bundle:nil] forCellWithReuseIdentifier:NIB_NAME];
  [self.collectionView registerNib:[UINib nibWithNibName:HEADER_NAME bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_NAME];
  [self.collectionView registerNib:[UINib nibWithNibName:DESCRIPTION_HEADER_NAME bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DESCRIPTION_HEADER_NAME];
  
  self.enhancingView.frame = self.bottomView.frame;
  [self.bottomView.superview addSubview:self.enhancingView];
  
  self.title = @"EVOLVE MOBSTERS";
  self.titleImageName = @"";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  
  [self updateBottomView];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self updateBottomView];
}

- (void) updateBottomView {
  GameState *gs = [GameState sharedGameState];
  UserEvolution *ue = gs.userEvolution;
  UserMonster *um = [gs myMonsterWithUserMonsterId:ue.userMonsterId1];
  
  if (ue) {
    [self.monsterView updateForMonsterId:um.monsterId];
    self.monsterNameLabel.text = [NSString stringWithFormat:@"Evolving: %@", um.staticMonster.displayName];
    
    [self updateLabels];
    
    self.bottomBarButton.enabled = YES;
    self.enhancingView.hidden = NO;
    self.bottomView.hidden = YES;
  } else {
    self.bottomBarButton.enabled = NO;
    self.enhancingView.hidden = YES;
    self.bottomView.hidden = NO;
  }
}

#pragma mark - Current enhancement

- (IBAction)bottomBarClicked:(id)sender {
  EvolveDetailsViewController *eqvc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [self.parentViewController pushViewController:eqvc animated:YES];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
  self.timeLeftLabel.text = [NSString stringWithFormat:@"Time Left: %@", [Globals convertTimeToShortString:timeLeft]];
}

#pragma mark - Reloading collection view

- (void) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *avail = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if ([um isAvailable]) {
      [avail addObject:um];
    }
  }
  [self.bottomView updateWithUserMonsters:avail];
  
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
      // Because it's already sorted, we can assume that the first one found will be the next highest level
      if (!um2 && temp.monsterId == um.monsterId) {
        um2 = temp;
      } else if (temp.monsterId == cataId) {
        cata = temp;
      }
    }
    
    // Check if there is a cata within the already created evo items
    // Also check if we can find a higher level suggested monster
    for (NSArray *arr in @[ready, notReady]) {
      for (EvoItem *evo in arr) {
        NSArray *ums = evo.userMonsters;
        for (UserMonster *temp in ums) {
          if (temp.monsterId == cataId) {
            cata = temp;
          }
        }
      }
    }
    
    [validMonsters removeObject:um];
    [validMonsters removeObject:um2];
    EvoItem *evo = [[EvoItem alloc] initWithUserMonster:um andUserMonster:um2 catalystMonster:cata suggestedMonster:nil];
    if ([evo isReadyForEvolution]) {
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
      [Globals calculateDifferencesBetweenOldArray:old[i] newArray:self.evoItems[i] removalIps:remove additionIps:add section:i];
    }
    
    if (add.count || remove.count) {
      [self.collectionView performBatchUpdates:^{
        if (add.count) {
          [self.collectionView insertItemsAtIndexPaths:add];
        }
        if (remove.count) {
          [self.collectionView deleteItemsAtIndexPaths:remove];
        }
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
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

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
  CGFloat width = collectionView.frame.size.width;
  if (section == 0) {
    if (![self.evoItems[0] count]) {
      return CGSizeMake(width, 77.f);
    } else {
      return CGSizeMake(width, 25.f);
    }
  } else {
    if ([self.evoItems[1] count]) {
      return CGSizeMake(width, 25.f);
    } else {
      return CGSizeMake(0.f, 0.f);
    }
  }
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  if (!(indexPath.section == 0 && [self.evoItems[0] count] == 0)) {
    UICollectionReusableView *rv = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_NAME forIndexPath:indexPath];
    
    EasyTableHeaderView *hv = rv.subviews[0];
    
    NSString *text = nil;
    UIColor *color = nil;
    if (indexPath.section == 0) {
      text = @"READY FOR EVOLUTION";
      color = [UIColor colorWithRed:48/255.f green:144/255.f blue:0.f alpha:1.f];
    } else {
      text = @"MISSING PIECES FOR EVOLUTION";
      color = [UIColor colorWithRed:239/255.f green:1/255.f blue:0.f alpha:1.f];
    }
    
    [hv setLabelText:text];
    [hv.button setTitleColor:color forState:UIControlStateNormal];
    
    return rv;
  } else {
    UICollectionReusableView *rv = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DESCRIPTION_HEADER_NAME forIndexPath:indexPath];
    UIView *yellow = rv.subviews[0];
    yellow.layer.cornerRadius = 5.f;
    yellow.layer.borderColor = [UIColor colorWithRed:1.f green:211/255.f blue:145/255.f alpha:1.f].CGColor;
    yellow.layer.borderWidth = 0.5f;
    return rv;
  }
}

- (void) headerClicked:(UIView *)sender {
  [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:sender.tag] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma EnhanceCard delegate

- (void) cardClicked:(id)sender {
  NSIndexPath *ip = [self.collectionView indexPathForCell:sender];
  EvoItem *ei = self.evoItems[ip.section][ip.row];
  
  GameState *gs = [GameState sharedGameState];
  EvolveDetailsViewController *vc = [[EvolveDetailsViewController alloc] initWithEvoItem:ei allowEvolution:(gs.userEvolution == nil)];
  
  [self.parentViewController pushViewController:vc animated:YES];
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
