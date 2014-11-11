//
//  EnhanceChooserViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupSubViewController.h"

#import "MonsterCardView.h"
#import "ListCollectionView.h"

#import "DailyEventCornerView.h"

@interface EnhanceChooserViewController : PopupSubViewController <ListCollectionDelegate, DailyEventCornerDelegate>

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) IBOutlet UIView *notEnhancingView;
@property (nonatomic, retain) IBOutlet UIButton *bottomBarButton;

@property (nonatomic, retain) IBOutlet UILabel *noMobstersLabel;
@property (nonatomic, retain) IBOutlet UILabel *queueEmptyLabel;

@property (nonatomic, retain) DailyEventCornerView *dailyEventView;

@property (nonatomic, retain) NSMutableArray *userMonsters;

- (void) reloadListViewAnimated:(BOOL)animated;

@end
