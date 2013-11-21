//
//  EnhanceViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "EnhanceViews.h"
#import "MonsterTeamSlotView.h"

@interface EnhanceViewController : GenViewController <EasyTableViewDelegate, EnhanceCardDelegate>

@property (nonatomic, strong) IBOutlet EnhanceQueueView *queueView;

@property (nonatomic, strong) IBOutlet EnhanceBaseView *baseView;
@property (nonatomic, strong) IBOutlet UIView *enhancingHeader;
@property (nonatomic, strong) IBOutlet UIView *myMobstersHeader;
@property (nonatomic, strong) IBOutlet UIView *baseViewContainer;

@property (nonatomic, strong) IBOutlet EnhanceCardCell *monsterCardCell;
@property (nonatomic, strong) IBOutlet UIView *teamSlotsContainer;

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) NSArray *monsterArray;

@property (nonatomic, copy, readonly) NSString *confirmUserMonsterUuid;

- (IBAction) baseViewMinusClicked:(id)sender;
- (IBAction) headerClicked:(id)sender;

@end
