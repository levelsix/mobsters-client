//
//  EvoViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTableView.h"
#import "GenViewController.h"
#import "EvoViews.h"

@interface EvoViewController : GenViewController <EasyTableViewDelegate, EvoCardCellDelegate>

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UIView *leftHeaderUnderlay;

@property (nonatomic, strong) IBOutlet UIView *readyHeaderView;
@property (nonatomic, strong) IBOutlet UIView *missingCataHeaderView;
@property (nonatomic, strong) IBOutlet UIView *notReadyHeaderView;

@property (nonatomic, strong) IBOutlet UIView *teamSlotsContainer;
@property (nonatomic, strong) IBOutlet EvoBottomView *bottomView;
@property (nonatomic, strong) IBOutlet EvoMiddleView *middleView;

@property (nonatomic, strong) IBOutlet EvoCardCell *evoCardCell;

@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSArray *readyMonsters;
@property (nonatomic, strong) NSArray *missingCataMonsters;
@property (nonatomic, strong) NSArray *notReadyMonsters;

@property (nonatomic, strong) IBOutlet UIView *backButton;

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) EvoItem *curEvoItem;

@end
