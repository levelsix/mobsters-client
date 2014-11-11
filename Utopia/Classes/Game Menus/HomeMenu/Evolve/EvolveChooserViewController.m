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

#import "DailyEventViewController.h"

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
  
  self.title = [NSString stringWithFormat:@"EVOLVE %@S", MONSTER_NAME.uppercaseString];
  self.titleImageName = @"evolutionlabmenuheader.png";
  
  self.leftCornerView = [[NSBundle mainBundle] loadNibNamed:@"DailyEventCornerView" owner:self options:nil][0];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.collectionView.contentOffset = ccp(0,0);
  
  [self reloadListViewAnimated:NO];
  
  [self updateBottomView];
  
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  cv.delegate = self;
  [cv updateForEvo];
}

- (void) waitTimeComplete {
  [self reloadListViewAnimated:YES];
  [self updateBottomView];
}

- (void) updateBottomView {
  GameState *gs = [GameState sharedGameState];
  UserEvolution *ue = gs.userEvolution;
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:ue.userMonsterUuid1];
  
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

- (void) eventCornerViewClicked:(id)sender {
  DailyEventViewController *evc = [[DailyEventViewController alloc] init];
  [self.parentViewController pushViewController:evc animated:YES];
  [evc updateForEvo];
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
  
  DailyEventCornerView *cv = (DailyEventCornerView *)self.leftCornerView;
  [cv updateLabels];
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
  
  // validMonsters will be a dictionary of monsterId -> sorted array of monsters from highest level to lowest
  // catalysts will be a dictionary of monsterId -> sorted array of catalysts with that monsterId from highest to lowest level
  // Catalyst monsters can be in both dictionaries (assuming they can be evolved).
  NSMutableDictionary *validMonsters = [NSMutableDictionary dictionary];
  NSMutableArray *ready = [NSMutableArray array];
  NSMutableArray *notReady = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isAvailable && um.staticMonster.evolutionMonsterId) {
      int monsterId = um.staticMonster.monsterId;
      NSMutableArray *arr = validMonsters[@(monsterId)];
      
      if (!arr) {
        arr = [NSMutableArray array];
        validMonsters[@(monsterId)] = arr;
      }
      
      [arr addObject:um];
    }
  }
  
  NSMutableDictionary *catalyts = [NSMutableDictionary dictionary];
  for (NSNumber *num in validMonsters) {
    NSMutableArray *arr = validMonsters[num];
    [arr sortUsingSelector:@selector(compare:)];
    
    catalyts[num] = [arr copy];
  }
  
  // Now go through every array in validMonsters and pair up with highest and lowest monsters (first and last object).
  for (NSMutableArray *arr in validMonsters.allValues) {
    while (arr.count) {
      UserMonster *um1 = [arr firstObject];
      UserMonster *um2 = arr.count > 1 ? [arr lastObject] : nil;
      UserMonster *cata = nil;
      
      // Go backwards through the cata array since its ordered from highest to lowest
      NSMutableArray *catas = catalyts[@(um1.staticMonster.evolutionCatalystMonsterId)];
      for (UserMonster *um in catas.reverseObjectEnumerator) {
        if (um.userMonsterId != um1.userMonsterId && um.userMonsterId != um2.userMonsterId) {
          cata = um;
          break;
        }
      }
      
      [arr removeObject:um1];
      [arr removeObject:um2];
      
      EvoItem *evo = [[EvoItem alloc] initWithUserMonster:um1 andUserMonster:um2 catalystMonster:cata suggestedMonster:nil];
      if ([evo isReadyForEvolution]) {
        [ready addObject:evo];
      } else {
        [notReady addObject:evo];
      }
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
    
    for (UIView *sv in yellow.subviews) {
      if ([sv isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)sv;
        label.text = [label.text stringByReplacingOccurrencesOfString:@"mobster" withString:MONSTER_NAME];
      }
    }
    
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
  Globals *gl = [Globals sharedGlobals];
  int reqEvoChamberLevel = [gl evoChamberLevelToEvolveMonster:ei.userMonster1.monsterId];
  EvoChamberProto *ecp = (EvoChamberProto *)gs.myEvoChamber.staticStructForCurrentConstructionLevel;
  BOOL evoChamberHighEnough = reqEvoChamberLevel <= ecp.structInfo.level;
  
  if (evoChamberHighEnough) {
    EvolveDetailsViewController *vc = [[EvolveDetailsViewController alloc] initWithEvoItem:ei allowEvolution:(gs.userEvolution == nil)];
    
    [self.parentViewController pushViewController:vc animated:YES];
  } else {
    [Globals addAlertNotification:[NSString stringWithFormat:@"%@ %@s require a Level %d %@", [Globals stringForRarity:ei.userMonster1.staticMonster.quality], MONSTER_NAME, reqEvoChamberLevel, ecp.structInfo.name]];
  }
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
