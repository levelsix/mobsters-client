//
//  MiniJobsDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "TopBarViewController.h"

@interface MiniJobsDetailsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *hpProgressBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *attackProgressBar;

@property (nonatomic, assign) UserMonster *userMonster;

- (void) updateForUserMonster:(UserMonster *)um requiredHp:(int)reqHp requiredAttack:(int)reqAtk;

@end

@protocol MiniJobsDetailsDelegate <NSObject>

@end

@interface MiniJobsDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UITableView *monstersTable;

@property (nonatomic, retain) IBOutletCollection(MiniMonsterView) NSArray *monsterViews;

@property (nonatomic, retain) IBOutlet MiniJobsDetailsCell *detailsCell;

@property (nonatomic, retain) NSArray *monsterArray;
@property (nonatomic, retain) NSArray *pickedMonsters;

@property (nonatomic, assign) id<MiniJobsDetailsDelegate> delegate;

@end
