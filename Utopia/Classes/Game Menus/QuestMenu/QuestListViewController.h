//
//  QuestListViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobstersEventProtocol.pb.h"
#import "UserData.h"

@class QuestListCell;

@protocol QuestListCellDelegate <NSObject>

- (void) questListCellClicked:(QuestListCell *)cell;

@end

@interface QuestListCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) IBOutlet UIImageView *questGiverImageView;

@property (nonatomic, strong) IBOutlet UIView *badgeView;

@property (nonatomic, strong) IBOutlet UIView *completeView;
@property (nonatomic, strong) IBOutlet UIView *inProgressView;

@property (nonatomic, strong) QuestProto *quest;
@property (nonatomic, strong) UserQuest *userQuest;

@property (nonatomic, weak) id<QuestListCellDelegate> delegate;

- (void) updateForQuest:(QuestProto *)quest withUserQuestData:(UserQuest *)userQuest;

@end

@interface QuestListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *quests;
@property (nonatomic, strong) NSDictionary *userQuests;

@property (nonatomic, strong) IBOutlet UITableView *questListTable;

@property (nonatomic, strong) IBOutlet QuestListCell *questListCell;

- (void) reloadWithQuests:(NSArray *)quests userQuests:(NSDictionary *)userQuests;

@end
