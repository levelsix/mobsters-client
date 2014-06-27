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

@protocol MonsterListCellDelegate <NSObject>

- (void) minusClicked:(id)cell;

@end

@interface MonsterListCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet MonsterCardContainerView *cardContainer;
@property (nonatomic, retain) IBOutlet UILabel *sellCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *healCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *enhancePercentLabel;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@property (nonatomic, strong) IBOutlet UIView *mainView;

@property (nonatomic, assign) id<MonsterListCellDelegate> delegate;

- (void) updateForListObject:(id)listObject;
- (void) updateForListObject:(id)listObject greyscale:(BOOL)greyscale;

@end

@interface MonsterQueueCell : MonsterListCell

@property (nonatomic, strong) IBOutlet MiniMonsterView *monsterView;

@property (nonatomic, strong) IBOutlet UIView *timerView;
@property (nonatomic, strong) IBOutlet SplitImageProgressBar *progressBar;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

- (void) updateTimeWithTimeLeft:(int)timeLeft percent:(float)percentage;

@end

@class MonsterListView;

@protocol MonsterListDelegate <NSObject>

@optional
- (void) listView:(MonsterListView *)listView infoClickedAtIndexPath:(NSIndexPath *)indexPath;
- (void) listView:(MonsterListView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath;
- (void) listView:(MonsterListView *)listView minusClickedAtIndexPath:(NSIndexPath *)indexPath;

- (void) listView:(MonsterListView *)listView updateCell:(MonsterListCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id)listObject;
- (void) listView:(MonsterListView *)listView updateFooterView:(UICollectionReusableView *)footerView;

@end

@interface MonsterListView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, MonsterCardViewDelegate, MonsterListCellDelegate> {
  void (^_scrollingComplete)(void);
}

@property (nonatomic, strong) IBOutlet UIView *emptyListView;
@property (nonatomic, strong) IBOutlet UIView *notEmptyListView;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *listObjects;

@property (nonatomic, assign) BOOL isFlipped;
@property (nonatomic, strong) NSString *cellClassName;
@property (nonatomic, strong) NSString *footerClassName;

@property (nonatomic, weak) IBOutlet id<MonsterListDelegate> delegate;

- (void) reloadTableAnimated:(BOOL)animated listObjects:(NSArray *)listObjects;

- (void) scrollToItemAtIndexPath:(NSIndexPath *)ip completionBlock:(void (^)(void))completed;
- (void) scrollToContentOffset:(CGPoint)contentOffset completionBlock:(void (^)(void))completed;

@end
