//
//  QuestDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "RewardsView.h"
#import "NibUtils.h"

@class QuestDetailsViewController;

@interface QuestDetailsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *taskNumLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;

@end

@protocol QuestDetailsViewControllerDelegate <NSObject>

- (void) collectClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;
- (void) visitOrDonateClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC jobId:(int)jobId;

@end

@interface QuestDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) FullQuestProto *quest;
@property (nonatomic, strong) UserQuest *userQuest;

@property (nonatomic, strong) IBOutlet UILabel *questGiverNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, strong) IBOutlet UIView *rewardsBox;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UITableView *taskTable;
@property (nonatomic, strong) IBOutlet QuestDetailsCell *taskCell;

@property (nonatomic, strong) IBOutlet RewardView *rewardView;

@property (nonatomic, weak) id<QuestDetailsViewControllerDelegate> delegate;

- (void) loadWithQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest;

@end
