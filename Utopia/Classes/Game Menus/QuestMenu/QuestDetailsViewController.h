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

@class QuestDetailsViewController;

@protocol QuestDetailsViewControllerDelegate <NSObject>

- (void) collectClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;
- (void) visitOrDonateClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;

@end

@interface QuestDetailsViewController : UIViewController

@property (nonatomic, strong) FullQuestProto *quest;
@property (nonatomic, strong) UserQuest *userQuest;

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *jobLabel;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) IBOutlet UILabel *visitLabel;
@property (nonatomic, strong) IBOutlet RewardsViewContainer *rewardsViewContainer;

@property (nonatomic, strong) IBOutlet UILabel *collectLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) IBOutlet UIView *collectView;
@property (nonatomic, strong) IBOutlet UIView *visitView;
@property (nonatomic, strong) IBOutlet UIView *completeView;

@property (nonatomic, strong) IBOutlet UIButton *collectButton;
@property (nonatomic, strong) IBOutlet UIButton *visitButton;

@property (nonatomic, weak) id<QuestDetailsViewControllerDelegate> delegate;

- (void) loadWithQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest;

@end
