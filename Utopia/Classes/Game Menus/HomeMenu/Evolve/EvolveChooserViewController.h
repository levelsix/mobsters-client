//
//  EvolveChooserViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "EvolveChooserViews.h"

@interface EvolveChooserViewController : PopupSubViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EvolveCardDelegate>

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *monsterNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;

@property (nonatomic, retain) IBOutlet EvolveChooserBottomView *bottomView;
@property (nonatomic, retain) IBOutlet UIView *enhancingView;
@property (nonatomic, retain) IBOutlet UIButton *bottomBarButton;

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

@property (nonatomic, retain) NSArray *evoItems;

@end
