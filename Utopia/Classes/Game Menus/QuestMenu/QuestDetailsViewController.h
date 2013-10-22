//
//  QuestDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@class QuestDetailsViewController;

@protocol QuestDetailsViewControllerDelegate <NSObject>

- (void) collectClickedDetailsVC:(QuestDetailsViewController *)detailsVC;
- (void) visitClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC;

@end

@interface QuestDetailsViewController : UIViewController

@property (nonatomic, strong) FullQuestProto *quest;
@property (nonatomic, strong) FullUserQuestDataLargeProto *userQuest;

@property (nonatomic, weak) id<QuestDetailsViewControllerDelegate> delegate;

- (void) reloadWithQuest:(FullQuestProto *)quest userQuest:(FullUserQuestDataLargeProto *)userQuest;

@end
