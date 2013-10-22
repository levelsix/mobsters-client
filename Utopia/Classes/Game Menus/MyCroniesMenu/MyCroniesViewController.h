//
//  MyCroniesViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/17/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "MyCroniesMonsterViews.h"

@interface MyCroniesViewController : GenViewController <EasyTableViewDelegate, MyCroniesCardDelegate, MyCroniesQueueDelegate> {
  float _baseMyReservesHeaderX;
}

@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet UIView *tableSeperatorView;

@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, strong) IBOutlet MyCroniesHeaderView *myTeamHeaderView;
@property (nonatomic, strong) IBOutlet MyCroniesHeaderView *myReservesHeaderView;

@property (nonatomic, strong) IBOutlet MyCroniesQueueView *queueView;

@property (nonatomic, strong) IBOutlet MyCroniesCardCell *monsterCardCell;

@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSArray *monstersNotOnTeam;

@property (nonatomic, strong) NSTimer *updateTimer;

@end
