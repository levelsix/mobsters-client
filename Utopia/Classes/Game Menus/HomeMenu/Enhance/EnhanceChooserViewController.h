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
#import "MonsterListView.h"

@interface EnhanceChooserViewController : PopupSubViewController <MonsterListDelegate>

@property (nonatomic, retain) IBOutlet MonsterListView *listView;

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
