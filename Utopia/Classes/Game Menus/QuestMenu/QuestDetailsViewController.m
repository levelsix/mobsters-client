//
//  QuestDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestDetailsViewController.h"
#import "Globals.h"

@implementation QuestDetailsViewController

- (void) viewDidLoad {
  self.completeView.frame = self.visitView.frame;
  [self.view addSubview:self.completeView];
}

- (void) loadWithQuest:(QuestProto *)quest userQuest:(UserQuest *)userQuest {
  self.quest = quest;
  self.userQuest = userQuest;
  
  self.title = self.quest.name;
  
  self.descriptionLabel.text = self.quest.description;
  self.jobLabel.text = self.quest.jobDescription;
  
  if (quest.quantity < 100) {
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", userQuest.progress, quest.quantity];
  } else {
    self.progressLabel.text = [NSString stringWithFormat:@"%@", [Globals commafyNumber:userQuest.progress]];
  }
  
  if (quest.questType == QuestProto_QuestTypeDonateMonster && userQuest.progress >= quest.quantity) {
    self.visitLabel.text = @"Donate";
  } else {
    self.visitLabel.text = @"Visit";
  }
  
  if (userQuest.isComplete) {
    self.completeView.hidden = NO;
    self.collectView.hidden = NO;
    self.visitView.hidden = YES;
    
    CGRect r = self.rewardsViewContainer.frame;
    r.size.width = self.collectView.frame.origin.x-r.origin.x;
    self.rewardsViewContainer.frame = r;
  } else {
    self.completeView.hidden = YES;
    self.collectView.hidden = YES;
    self.visitView.hidden = NO;
    
    CGRect r = self.rewardsViewContainer.frame;
    r.size.width = CGRectGetMaxX(self.collectView.frame)-r.origin.x;
    self.rewardsViewContainer.frame = r;
  }
  
  NSArray *rewards = [Reward createRewardsForQuest:quest];
  [self.rewardsViewContainer.rewardsView updateForRewards:rewards];
}

#pragma mark - IBAction methods

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClickedWithDetailsVC:self];
}

- (IBAction)visitClicked:(id)sender {
  [self.delegate visitOrDonateClickedWithDetailsVC:self];
}

@end
