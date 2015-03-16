//
//  MonsterListView.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ListCollectionView.h"

#import "Globals.h"
#import "GameState.h"

#define TREE_WIDTH 200
#define TREE_HEIGHT 180

@implementation ListCollectionViewCell

- (void) updateForListObject:(id)listObject {
  
}

- (void) monsterCardSelected:(MonsterCardView *)view {
  [self.delegate cardClicked:self];
}

- (IBAction) cardClicked:(id)sender {
  [self.delegate cardClicked:self];
}

- (IBAction) infoClicked:(id)sender {
  [self.delegate infoClicked:self];
}

- (IBAction) speedupClicked:(id)sender {
  [self.delegate speedupClicked:self];
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate minusClicked:self];
}

@end

@implementation MonsterQueueCell

- (void) updateForListObject:(UserMonster *)um {
  if ([um isKindOfClass:[BattleItemQueueObject class]]) {
    [self updateForBattleItemQueueObject:(BattleItemQueueObject *)um];
  } else {
    [self.monsterView updateForMonsterId:um.monsterId];
    
    self.botLabel.hidden = YES;
    self.timerView.hidden = YES;
    self.minusButton.hidden = NO;
    self.checkView.hidden = YES;
  }
}

- (void) updateForBattleItemQueueObject:(BattleItemQueueObject *)obj {
  BattleItemProto *bip = obj.staticBattleItem;
  [self.monsterView updateForElement:ElementNoElement imgName:bip.imgName greyscale:NO];
  
  [Globals imageNamed:@"ifitemsquaresmall.png" withView:self.monsterView.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  // Make the icon a bit smaller so that the images aren't stretched to the edge
  CGPoint center = self.monsterView.monsterIcon.center;
  self.monsterView.monsterIcon.size = CGSizeMake(36, 36);
  self.monsterView.monsterIcon.center = center;
  
  self.botLabel.hidden = YES;
  self.timerView.hidden = YES;
  self.minusButton.hidden = NO;
  self.checkView.hidden = YES;
}

- (void) updateTimeWithTimeLeft:(int)timeLeft percent:(float)percentage {
  self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
  self.progressBar.percentage = percentage;
  
  self.timerView.hidden = NO;
}

@end

@implementation MonsterListCell

- (void) setDelegate:(id<ListCellDelegate>)delegate {
  [super setDelegate:delegate];
  
  // Refresh the monster card
  self.cardContainer.monsterCardView.delegate = self;
}

- (BOOL) respondsToSelector:(SEL)aSelector {
  if (aSelector == @selector(infoClicked:)) {
    return [self.delegate respondsToSelector:@selector(infoClicked:)];
  } else if (aSelector == @selector(monsterCardSelected:)) {
    return [self.delegate respondsToSelector:@selector(cardClicked:)];
  }
  return [super respondsToSelector:aSelector];
}

- (void) updateForListObject:(UserMonster *)um greyscale:(BOOL)greyscale {
  Globals *gl = [Globals sharedGlobals];
  
  [self.cardContainer.monsterCardView updateForMonster:um backupString:@"" greyscale:greyscale];
  self.sellCostLabel.text = [Globals cashStringForNumber:[um sellPrice]];
  
  self.healCostLabel.text = [Globals cashStringForNumber:[gl calculateCostToHealMonster:um]];
  
  if (um.level >= um.staticMonster.maxLevel) {
    self.enhancePercentLabel.text = @"Max";
  } else {
    float baseLevel = [gl calculateLevelForMonster:um.monsterId experience:um.experience];
    float curPerc = baseLevel-(int)baseLevel;
    self.enhancePercentLabel.text = [NSString stringWithFormat:@"%d%%", (int)floorf(curPerc*100)];
  }
  
  self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:um.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]]];
  self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
  
  // For selling
  self.lockIcon.hidden = !um.isProtected;
  self.sellCostLabel.hidden = um.isProtected;
  
  if ([um isAvailable] && !greyscale) {
    self.availableView.hidden = NO;
    self.unavailableView.hidden = YES;
    self.combiningView.hidden = YES;
  } else {
    self.statusLabel.text = [um statusString];
    
    if ([um isCombining]) {
      self.combiningView.hidden = NO;
      [self updateCombineTimeForUserMonster:um];
      self.statusLabel.text = nil;
    } else {
      self.combiningView.hidden = YES;
    }
    
    self.unavailableView.hidden = NO;
    self.availableView.hidden = YES;
  }
}

- (void) updateForListObject:(id)listObject {
  [self updateForListObject:listObject greyscale:NO];
}

- (void) updateCombineTimeForUserMonster:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  if (!um.isComplete && um.numPieces >= um.staticMonster.numPuzzlePieces) {
    int timeLeft = [um timeLeftForCombining];
    self.combineTimeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (gemCost > 0) {
      self.combineCostLabel.text = [Globals commafyNumber:gemCost];
      [Globals adjustViewForCentering:self.combineCostLabel.superview withLabel:self.combineCostLabel];
      
      self.combineCostLabel.superview.hidden = NO;
      self.combineSpeedupIcon.hidden = NO;
      self.combineFreeLabel.hidden = YES;
    } else {
      self.combineCostLabel.superview.hidden = YES;
      self.combineSpeedupIcon.hidden = YES;
      self.combineFreeLabel.hidden = NO;
    }
  }
}

@end

@implementation ListCollectionView

- (void) awakeFromNib {
  self.collectionView.layer.cornerRadius = 5.f;
  self.collectionView.backgroundColor = [UIColor clearColor];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
}

- (void) setIsFlipped:(BOOL)isFlipped {
  _isFlipped = isFlipped;
  if (isFlipped) {
    self.collectionView.transform = CGAffineTransformMakeScale(-1, 1);
  } else {
    self.collectionView.transform = CGAffineTransformIdentity;
  }
}

- (void) setCellClassName:(NSString *)cellClassName {
  _cellClassName = cellClassName;
  [self.collectionView registerNib:[UINib nibWithNibName:cellClassName bundle:nil] forCellWithReuseIdentifier:cellClassName];
}

- (void) setFooterClassName:(NSString *)footerClassName {
  _footerClassName = footerClassName;
  [self.collectionView registerNib:[UINib nibWithNibName:footerClassName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:self.footerClassName];
}

- (void) setHeaderClassName:(NSString *)headerClassName {
  _headerClassName = headerClassName;
  [self.collectionView registerNib:[UINib nibWithNibName:headerClassName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.headerClassName];
}

- (void) reloadTableAnimated:(BOOL)animated listObjects:(NSArray *)listObjects {
  NSArray *rec = self.listObjects;
  self.listObjects = [listObjects copy];
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  NSMutableDictionary *moves = [NSMutableDictionary dictionary];
  
  if (animated) {
    [Globals calculateDifferencesBetweenOldArray:rec newArray:self.listObjects removalIps:remove additionIps:add movedIps:moves section:0];
    
    if (add.count || remove.count || moves.count) {
      [self.collectionView performBatchUpdates:^{
        if (add.count) {
          [self.collectionView insertItemsAtIndexPaths:add];
        }
        if (remove.count) {
          [self.collectionView deleteItemsAtIndexPaths:remove];
        }
        for (NSIndexPath *old in moves) {
          NSIndexPath *new = moves[old];
          [self.collectionView moveItemAtIndexPath:old toIndexPath:new];
        }
      } completion:nil];
    }
    
    for (ListCollectionViewCell *cell in self.collectionView.visibleCells) {
      NSIndexPath *ip = [self.collectionView indexPathForCell:cell];
      id listObject = self.listObjects[ip.row];
      if ([self.delegate respondsToSelector:@selector(listView:updateCell:forIndexPath:listObject:)]) {
        [self.delegate listView:self updateCell:cell forIndexPath:ip listObject:listObject];
      } else {
        [cell updateForListObject:listObject];
      }
    }
  } else {
    [self getQueueCountAndUpdateOpacitiesAnimated:NO];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
  }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  //special size for the money tree card
  if([self.delegate respondsToSelector:@selector(specialCellSizeWithIndex:)]) {
    CGSize specialSize = [self.delegate specialCellSizeWithIndex:indexPath.row];
    if(specialSize.width != 0.f && specialSize.width != 0.f) {
      return specialSize;
    }
  }
  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
  return layout.itemSize;
}

#pragma mark - Monster card delegate

- (BOOL) respondsToSelector:(SEL)aSelector {
  if (aSelector == @selector(infoClicked:)) {
    return [self.delegate respondsToSelector:@selector(listView:infoClickedAtIndexPath:)];
  } else if (aSelector == @selector(cardClicked:)) {
    return [self.delegate respondsToSelector:@selector(listView:cardClickedAtIndexPath:)];
  }
  return [super respondsToSelector:aSelector];
}

- (void) cardClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ListCollectionViewCell class]];
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:cardClickedAtIndexPath:)]) {
      [self.delegate listView:self cardClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

- (void) infoClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ListCollectionViewCell class]];
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:infoClickedAtIndexPath:)]) {
      [self.delegate listView:self infoClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

- (void) minusClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ListCollectionViewCell class]];
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:minusClickedAtIndexPath:)]) {
      [self.delegate listView:self minusClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

- (void) speedupClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ListCollectionViewCell class]];
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:speedupClickedAtIndexPath:)]) {
      [self.delegate listView:self speedupClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

#pragma mark - CollectionView dataSource/delegate

- (int) getQueueCountAndUpdateOpacitiesAnimated:(BOOL)animated {
  NSArray *queue = self.listObjects;
  if (queue.count == 0) {
    if (animated) {
      if (self.emptyListView.alpha == 0.f) {
        [UIView animateWithDuration:0.3f animations:^{
          self.notEmptyListView.alpha = 0.f;
          self.emptyListView.alpha = 1.f;
        }];
      } else {
        // Have to do this in case queue starts without items
        self.notEmptyListView.alpha = 0.f;
      }
    } else {
      [self.notEmptyListView.layer removeAllAnimations];
      [self.emptyListView.layer removeAllAnimations];
      self.notEmptyListView.alpha = 0.f;
      self.emptyListView.alpha = 1.f;
    }
  } else {
    if (animated) {
      if (self.notEmptyListView.alpha == 0.f) {
        [UIView animateWithDuration:0.3f animations:^{
          self.notEmptyListView.alpha = 1.f;
          self.emptyListView.alpha = 0.f;
        }];
      } else if (self.emptyListView.alpha == 1.f) {
        // Have to do this in case queue starts with items
        self.emptyListView.alpha = 0.f;
      }
    } else {
      [self.notEmptyListView.layer removeAllAnimations];
      [self.emptyListView.layer removeAllAnimations];
      self.notEmptyListView.alpha = 1.f;
      self.emptyListView.alpha = 0.f;
    }
  }
  return (int)queue.count;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self getQueueCountAndUpdateOpacitiesAnimated:YES];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ListCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.cellClassName forIndexPath:indexPath];
  cell.delegate = self;
  
  for (UIView *v in cell.subviews) {
    v.transform = self.isFlipped ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
  }
  
  id listObject = self.listObjects[indexPath.row];
  if ([self.delegate respondsToSelector:@selector(listView:updateCell:forIndexPath:listObject:)]) {
    [self.delegate listView:self updateCell:cell forIndexPath:indexPath listObject:listObject];
  } else {
    [cell updateForListObject:listObject];
  }
  
  return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  if ([kind isEqual:UICollectionElementKindSectionFooter]) {
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.footerClassName forIndexPath:indexPath];
    
    for (UIView *v in footerView.subviews) {
      v.transform = self.isFlipped ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
    }
    
    if ([self.delegate respondsToSelector:@selector(listView:updateFooterView:)]) {
      [self.delegate listView:self updateFooterView:footerView];
    }
    
    return footerView;
  } else if ([kind isEqual:UICollectionElementKindSectionHeader]) {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.headerClassName forIndexPath:indexPath];
    
    for (UIView *v in headerView.subviews) {
      v.transform = self.isFlipped ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
    }
    
    if ([self.delegate respondsToSelector:@selector(listView:updateHeaderView:)]) {
      [self.delegate listView:self updateHeaderView:headerView];
    }
    
    return headerView;
  }
  return nil;
}

#pragma mark - Scrolling animation completion

- (void) scrollToItemAtIndexPath:(NSIndexPath *)ip completionBlock:(void (^)(void))completed {
  _scrollingComplete = completed;
  [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void) scrollToContentOffset:(CGPoint)contentOffset completionBlock:(void (^)(void))completed {
  _scrollingComplete = completed;
  [self.collectionView setContentOffset:contentOffset animated:YES];
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if (_scrollingComplete) {
    _scrollingComplete();
  }
}

@end
