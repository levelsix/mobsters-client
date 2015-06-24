//
//  MonsterListView.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MonsterCardView.h"
#import "NibUtils.h"

@protocol ListCellDelegate <NSObject>

- (void) cardClicked:(id)cell;
- (void) infoClicked:(id)cell;
- (void) minusClicked:(id)cell;
- (void) speedupClicked:(id)cell;

@end

@interface ListCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<ListCellDelegate> delegate;

- (void) updateForListObject:(id)listObject;

- (void) monsterCardSelected:(MonsterCardView *)view;
- (IBAction) cardClicked:(id)sender;
- (IBAction) infoClicked:(id)sender;
- (IBAction) speedupClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;

@end

@interface MonsterListCell : ListCollectionViewCell <MonsterCardViewDelegate>

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *cardContainer;
@property (nonatomic, retain) IBOutlet UILabel *sellCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *healCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *healCostMoneyIcon;
@property (nonatomic, retain) IBOutlet UILabel *enhancePercentLabel;

@property (nonatomic, retain) IBOutlet UILabel *combineTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *combineCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *combineFreeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *combineSpeedupIcon;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

@property (nonatomic, retain) IBOutlet UIView *availableView;
@property (nonatomic, retain) IBOutlet UIView *unavailableView;
@property (nonatomic, retain) IBOutlet UIView *combiningView;

- (void) updateForListObject:(id)listObject greyscale:(BOOL)greyscale;
- (void) updateCombineTimeForUserMonster:(UserMonster *)um;

@end

@interface MonsterQueueCell : ListCollectionViewCell

@property (nonatomic, strong) IBOutlet MiniMonsterView *monsterView;

@property (nonatomic, strong) IBOutlet UIView *timerView;
@property (nonatomic, strong) IBOutlet SplitImageProgressBar *progressBar;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) IBOutlet UIView *checkView;

@property (nonatomic, strong) IBOutlet UILabel *botLabel;

@property (nonatomic, strong) IBOutlet UIButton *minusButton;

- (void) updateTimeWithTimeLeft:(int)timeLeft percent:(float)percentage;

@end

@class ListCollectionView;

@protocol ListCollectionDelegate <NSObject>

@optional
- (void) listView:(ListCollectionView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath;
- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath;
- (void) listView:(ListCollectionView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath;
- (void) listView:(ListCollectionView *)listView speedupClickedAtIndexPath:(NSIndexPath *)indexPath;

- (void) listView:(ListCollectionView *)listView updateCell:(ListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id)listObject;
- (void) listView:(ListCollectionView *)listView updateFooterView:(UICollectionReusableView *)footerView;
- (void) listView:(ListCollectionView *)listView updateHeaderView:(UICollectionReusableView *)headerView;

- (CGSize) specialCellSizeWithIndex:(NSInteger)index;

@end

@interface ListCollectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ListCellDelegate> {
  void (^_scrollingComplete)(void);
}

@property (nonatomic, strong) IBOutlet UIView *emptyListView;
@property (nonatomic, strong) IBOutlet UIView *notEmptyListView;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *listObjects;

@property (nonatomic, assign) BOOL isFlipped;
@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, strong) NSString *footerClassName;
@property (nonatomic, strong) NSString *headerClassName;

@property (nonatomic, weak) IBOutlet id<ListCollectionDelegate> delegate;

- (void) reloadTableAnimated:(BOOL)animated listObjects:(NSArray *)listObjects;

- (void) scrollToItemAtIndexPath:(NSIndexPath *)ip completionBlock:(void (^)(void))completed;
- (void) scrollToContentOffset:(CGPoint)contentOffset completionBlock:(void (^)(void))completed;

@end
