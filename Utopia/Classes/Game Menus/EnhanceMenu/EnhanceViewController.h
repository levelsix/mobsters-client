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

@interface EnhanceViewController : GenViewController <EasyTableViewDelegate>

@property (nonatomic, strong) IBOutlet EnhanceQueueView *queueView;
@property (nonatomic, strong) IBOutlet EnhanceBaseView *baseView;

@property (nonatomic, strong) IBOutlet UILabel *selectBaseLabel;
@property (nonatomic, strong) IBOutlet UILabel *selectFeedersLabel;

@property (nonatomic, strong) IBOutlet EnhanceCardCell *monsterCardCell;

@property (nonatomic, strong) EasyTableView *inventoryTable;

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) NSArray *monsterArray;

@end
