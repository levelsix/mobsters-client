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

@interface ItemFactoryViewController : PopupSubViewController


@property (nonatomic, retain) IBOutlet ListCollectionView *listView;
@property (nonatomic, strong) IBOutlet ListCollectionView *queueView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;

@property (nonatomic, retain) IBOutlet UIImageView *queueArrow;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

@end
