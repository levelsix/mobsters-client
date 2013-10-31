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

- (IBAction)backClicked:(id)sender;

@end
