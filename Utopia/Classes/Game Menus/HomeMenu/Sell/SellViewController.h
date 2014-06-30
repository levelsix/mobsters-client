//
//  SellViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"
#import "NibUtils.h"
#import "ListCollectionView.h"

@interface SellViewController : PopupSubViewController <ListCollectionDelegate>

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;
@property (nonatomic, strong) IBOutlet ListCollectionView *queueView;
@property (nonatomic, strong) IBOutlet UILabel *sellCostLabel;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) NSMutableArray *userMonsters;
@property (nonatomic, retain) NSMutableArray *sellQueue;

@end
