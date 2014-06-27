//
//  SellViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"
#import "NibUtils.h"
#import "MonsterListView.h"

@interface SellViewController : PopupSubViewController <MonsterListDelegate>

@property (nonatomic, retain) IBOutlet MonsterListView *listView;
@property (nonatomic, strong) IBOutlet MonsterListView *queueView;
@property (nonatomic, strong) IBOutlet UILabel *sellCostLabel;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet MonsterQueueCell *queueCell;

@property (nonatomic, retain) NSMutableArray *userMonsters;
@property (nonatomic, retain) NSMutableArray *sellQueue;

@end
