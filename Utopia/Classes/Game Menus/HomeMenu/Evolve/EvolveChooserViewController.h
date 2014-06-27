//
//  EvolveChooserViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "EvolveChooserViews.h"

@interface EvolveChooserViewController : PopupSubViewController <UICollectionViewDataSource, UICollectionViewDelegate, EvolveCardDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

@property (nonatomic, retain) NSArray *evoItems;

@end
