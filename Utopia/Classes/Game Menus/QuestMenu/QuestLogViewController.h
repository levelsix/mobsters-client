//
//  QuestLogViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestListViewController.h"
#import "QuestDetailsViewController.h"
#import "NibUtils.h"
#import "AchievementsViewController.h"

@protocol QuestLogDelegate <NSObject>

@optional
- (void) questLogClosed;

@end

@interface QuestLogViewController : UIViewController <QuestListCellDelegate, QuestDetailsViewControllerDelegate, TabBarDelegate> {
  int _donateJobId;
}

@property (nonatomic, strong) NSArray *userMonsterIds;

@property (nonatomic, strong) QuestListViewController *questListViewController;
@property (nonatomic, strong) QuestDetailsViewController *questDetailsViewController;
@property (nonatomic, strong) AchievementsViewController *achievementsViewController;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *backView;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *bgdView;

@property (nonatomic, strong) IBOutlet ButtonTopBar *topBar;
@property (nonatomic, strong) IBOutlet BadgeIcon *questBadge;
@property (nonatomic, strong) IBOutlet BadgeIcon *achievementBadge;

@property (nonatomic, assign) id<QuestLogDelegate> delegate;

- (IBAction)backClicked:(id)sender;
- (IBAction)close:(id)sender;
- (void) close;
- (void) loadDetailsViewForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)uq animated:(BOOL)animated;
- (void) questListCellClicked:(QuestListCell *)cell;

@end
