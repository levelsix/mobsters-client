//
//  ItemFactoryViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "ListCollectionView.h"

#import "ResourceItemsFiller.h"
#import "SpeedupItemsFiller.h"

#import "ItemFactoryViews.h"

typedef enum {
  ItemFactoryScopeAll,
  ItemFactoryScopePotions,
  ItemFactoryScopePuzzle
} ItemFactoryScope;

@interface ItemFactoryViewController : PopupSubViewController <ResourceItemsFillerDelegate, SpeedupItemsFillerDelegate, UICollectionViewDelegate> {
  ItemFactoryScope _scope;
  
  BattleItemProto *_tempBattleItem;
  UIImageView *_tempBgdImageView;
  
  BOOL _waitingForResponse;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;
@property (nonatomic, strong) IBOutlet ListCollectionView *queueView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *buttonSpinner;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;
@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;

@property (nonatomic, retain) NSArray *itemList;

@end
