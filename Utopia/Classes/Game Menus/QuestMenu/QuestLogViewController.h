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

@protocol QuestLogDelegate <NSObject>

@optional
- (void) questLogClosed;

@end

@interface QuestTopBar : ButtonTopBar

@end

@interface QuestLogViewController : UIViewController <QuestListCellDelegate, QuestDetailsViewControllerDelegate>

@property (nonatomic, strong) NSArray *userMonsterIds;

@property (nonatomic, strong) QuestListViewController *questListViewController;
@property (nonatomic, strong) QuestDetailsViewController *questDetailsViewController;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *listContainerView;
@property (nonatomic, strong) IBOutlet UIView *detailsContainerView;
@property (nonatomic, strong) IBOutlet UIView *backView;
@property (nonatomic, strong) IBOutlet UIImageView *questGiverImageView;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *bgdView;

@property (nonatomic, strong) IBOutlet QuestTopBar *topBar;

@property (nonatomic, assign) id<QuestLogDelegate> delegate;

- (IBAction)backClicked:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)close;
- (void) loadDetailsViewForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)uq animated:(BOOL)animated;
- (void) questListCellClicked:(QuestListCell *)cell;
- (void) visitOrDonateClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;
- (void) collectClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;

@end
