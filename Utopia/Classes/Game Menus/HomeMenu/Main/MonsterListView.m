//
//  MonsterListView.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MonsterListView.h"

#import "Globals.h"
#import "GameState.h"

@implementation MonsterQueueCell

- (void) updateForListObject:(UserMonster *)um {
  [self.monsterView updateForMonsterId:um.monsterId];
  
  self.timerView.hidden = YES;
}

- (void) updateTimeWithTimeLeft:(int)timeLeft percent:(float)percentage {
  self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
  self.progressBar.percentage = percentage;

  self.timerView.hidden = NO;
}

- (IBAction)minusClicked:(id)sender {
  [self.delegate minusClicked:self];
}

@end

@implementation MonsterListCell

- (void) updateForListObject:(UserMonster *)um greyscale:(BOOL)greyscale {
  Globals *gl = [Globals sharedGlobals];
  
  [self.cardContainer.monsterCardView updateForMonster:um backupString:@"" greyscale:greyscale];
  self.sellCostLabel.text = [Globals cashStringForNumber:[um sellPrice]];
  
  self.healCostLabel.text = [Globals cashStringForNumber:[gl calculateCostToHealMonster:um]];
  
  float baseLevel = [gl calculateLevelForMonster:um.monsterId experience:um.experience];
  float curPerc = baseLevel-(int)baseLevel;
  self.enhancePercentLabel.text = [NSString stringWithFormat:@"%d%%", (int)floorf(curPerc*100)];
  
  self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:um.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]]];
  self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
}

- (void) updateForListObject:(id)listObject {
  [self updateForListObject:listObject greyscale:NO];
}

@end

@implementation MonsterListView

- (void) awakeFromNib {
  self.collectionView.layer.cornerRadius = 5.f;
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

- (void) reloadTableAnimated:(BOOL)animated listObjects:(NSArray *)listObjects {
  NSArray *rec = self.listObjects;
  self.listObjects = [listObjects copy];
  NSMutableArray *remove = [NSMutableArray array], *add = [NSMutableArray array];
  
  if (animated) {
    [Globals calculateDifferencesBetweenOldArray:rec newArray:self.listObjects removalIps:remove additionIps:add section:0];
    
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
    
    for (MonsterListCell *cell in self.collectionView.visibleCells) {
      NSIndexPath *ip = [self.collectionView indexPathForCell:cell];
      id listObject = self.listObjects[ip.row];
      if ([self.delegate respondsToSelector:@selector(listView:updateCell:forIndexPath:listObject:)]) {
        [self.delegate listView:self updateCell:cell forIndexPath:ip listObject:listObject];
      } else {
        [cell updateForListObject:listObject];
      }
    }
  } else {
    [self.collectionView reloadData];
  }
}

#pragma mark - Monster card delegate

- (BOOL) respondsToSelector:(SEL)aSelector {
  if (aSelector == @selector(infoClicked:)) {
    return [self.delegate respondsToSelector:@selector(listView:infoClickedAtIndexPath:)];
  } else if (aSelector == @selector(monsterCardSelected:)) {
    return [self.delegate respondsToSelector:@selector(listView:cardClickedAtIndexPath:)];
  }
  return [super respondsToSelector:aSelector];
}

- (void) monsterCardSelected:(id)sender {
  while (sender && ![sender isKindOfClass:[MonsterListCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:cardClickedAtIndexPath:)]) {
      [self.delegate listView:self cardClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

- (void) infoClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[MonsterListCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:infoClickedAtIndexPath:)]) {
      [self.delegate listView:self infoClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
    }
  }
}

- (void) minusClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[MonsterQueueCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    if ([self.delegate respondsToSelector:@selector(listView:minusClickedAtIndexPath:)]) {
      [self.delegate listView:self minusClickedAtIndexPath:[self.collectionView indexPathForCell:sender]];
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
  MonsterListCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:self.cellClassName forIndexPath:indexPath];
  cell.cardContainer.monsterCardView.delegate = self;
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
