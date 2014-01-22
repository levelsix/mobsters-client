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

- (void) loadWithQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest {
  BOOL reloadRewards = ![quest.data isEqualToData:self.quest.data];
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
  
  if (quest.questType == FullQuestProto_QuestTypeDonateMonster && userQuest.progress >= quest.quantity) {
    self.visitLabel.text = @"Donate";
  } else {
    self.visitLabel.text = @"Visit";
  }
  
  // Only reload if necessary so that animation can work
  if (reloadRewards) {
    NSArray *rewards = [Reward createRewardsForQuest:quest];
    [self.rewardsViewContainer.rewardsView updateForRewards:rewards];
  }
  
  if (userQuest.isComplete) {
    self.completeView.alpha = 1.f;
    self.collectView.alpha = 1.f;
    self.visitView.alpha = 0.f;
    
    CGRect r = self.rewardsViewContainer.frame;
    r.size.width = self.collectView.frame.origin.x-r.origin.x;
    self.rewardsViewContainer.frame = r;
  } else {
    self.completeView.alpha = 0.f;
    self.collectView.alpha = 0.f;
    self.visitView.alpha = 1.f;
    
    CGRect r = self.rewardsViewContainer.frame;
    r.size.width = CGRectGetMaxX(self.collectView.frame)-r.origin.x;
    self.rewardsViewContainer.frame = r;
  }
}

#pragma mark - IBAction methods

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClickedWithDetailsVC:self];
}

- (IBAction)visitClicked:(id)sender {
  [self.delegate visitOrDonateClickedWithDetailsVC:self];
}

@end
