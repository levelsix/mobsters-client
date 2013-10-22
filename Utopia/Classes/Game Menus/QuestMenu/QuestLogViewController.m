//
//  QuestLogViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestLogViewController.h"
#import "GameState.h"

@interface QuestLogViewController ()

@end

@implementation QuestLogViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.questListViewController = [[QuestListViewController alloc] init];
  [self addChildViewController:self.questListViewController];
  [self.containerView addSubview:self.questListViewController.view];
  
  GameState *gs = [GameState sharedGameState];
  [self.questListViewController reloadWithQuests:gs.inProgressIncompleteQuests.allValues userQuests:nil];
  
  self.titleLabel.text = self.questListViewController.title;
  self.backView.hidden = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - QuestListCellDelegate methods

- (void) questListCellClicked:(QuestListCell *)cell {
  self.questDetailsViewController = [[QuestDetailsViewController alloc] init];
  self.questDetailsViewController.delegate = self;
  [self addChildViewController:self.questDetailsViewController];
  [self.containerView addSubview:self.questDetailsViewController.view];
  [self.questDetailsViewController reloadWithQuest:cell.quest userQuest:cell.userQuest];
  
  self.questDetailsViewController.view.center = ccp(self.containerView.frame.size.width+
                                                    self.questDetailsViewController.view.frame.size.width/2,
                                                    self.questDetailsViewController.view.center.y);
  self.backView.hidden = NO;
  self.backView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.questDetailsViewController.view.center = self.questListViewController.view.center;
    self.questListViewController.view.center = ccp(-self.questListViewController.view.center.x,
                                                   self.questListViewController.view.center.y);
    self.backView.alpha = 1.f;
  }];
  
  [UIView transitionWithView:self.titleLabel duration:0.3f options:UIViewAnimationOptionTransitionNone animations:^{
    self.titleLabel.text = self.questDetailsViewController.title;
  } completion:nil];
}

- (IBAction)backClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.questListViewController.view.center = self.questDetailsViewController.view.center;
    self.questDetailsViewController.view.center = ccp(self.containerView.frame.size.width+
                                                      self.questDetailsViewController.view.frame.size.width/2,
                                                      self.questDetailsViewController.view.center.y);
    self.backView.alpha = 0.f;
  } completion:^(BOOL finished) {
    self.backView.hidden = YES;
    
    [self.questDetailsViewController.view removeFromSuperview];
    [self.questDetailsViewController removeFromParentViewController];
    self.questDetailsViewController = nil;
  }];
  
  [UIView transitionWithView:self.titleLabel duration:0.3f options:UIViewAnimationOptionTransitionNone animations:^{
    self.titleLabel.text = self.questListViewController.title;
  } completion:nil];
}

#pragma mark - QuestDetailsViewControllerDelegate methods {

- (void) visitClickedWithDetailsVC:(QuestDetailsViewController *)detailsVC {
  
}

- (void) collectClickedDetailsVC:(QuestDetailsViewController *)detailsVC {
  
}

@end
