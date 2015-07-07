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

@interface SellViewController : PopupSubViewController <ListCollectionDelegate> {
  UserMonster *_confirmUserMonster;
}

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;
@property (nonatomic, strong) IBOutlet ListCollectionView *queueView;
@property (nonatomic, strong) IBOutlet UILabel *sellTotalValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *sellCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *sellCostIcon;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) NSMutableArray *userMonsters;
@property (nonatomic, retain) NSMutableArray *sellQueue;

@property (nonatomic, retain) IBOutlet UILabel *noMobstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueEmptyLabel;

@end
