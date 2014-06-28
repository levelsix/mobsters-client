//
//  TeamViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

#import "NibUtils.h"
#import "MonsterListView.h"

@protocol TeamSlotDelegate <NSObject>

- (void) teamSlotMinusClicked:(id)sender;
- (void) teamSlotRightSideClicked:(id)sender;

@end

@interface TeamSlotView : UIView

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;
@property (nonatomic, retain) IBOutlet UIView *healthBarView;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;
@property (nonatomic, retain) IBOutlet UILabel *slotNumLabel;
@property (nonatomic, retain) IBOutlet UIImageView *unavailableBorder;

@property (nonatomic, retain) IBOutlet UIView *emptyView;
@property (nonatomic, retain) IBOutlet UIView *notEmptyView;

@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIView *rightView;

@property (nonatomic, assign) id<TeamSlotDelegate> delegate;

@end

@interface TeamViewController : PopupSubViewController <MonsterListDelegate, TeamSlotDelegate>

@property (nonatomic, retain) IBOutlet MonsterListView *listView;

@property (nonatomic, strong) IBOutlet MonsterListCell *cardCell;
@property (nonatomic, strong) IBOutlet TeamSlotView *teamCell;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *teamSlotViews;

@property (nonatomic, retain) NSArray *userMonsters;

@property (nonatomic, strong) NSTimer *updateTimer;

@end
