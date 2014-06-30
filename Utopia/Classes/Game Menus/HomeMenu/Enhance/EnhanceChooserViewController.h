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

@interface EnhanceChooserViewController : PopupSubViewController <ListCollectionDelegate>

@property (nonatomic, retain) IBOutlet ListCollectionView *listView;

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *monsterNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;

@property (nonatomic, retain) IBOutlet UIView *notEnhancingView;
@property (nonatomic, retain) IBOutlet UIView *enhancingView;
@property (nonatomic, retain) IBOutlet UIButton *bottomBarButton;

@property (nonatomic, retain) NSMutableArray *userMonsters;

@property (nonatomic, retain) NSTimer *updateTimer;

- (void) reloadListViewAnimated:(BOOL)animated;

@end
