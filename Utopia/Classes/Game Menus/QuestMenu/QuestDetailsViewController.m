//
//  QuestDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestDetailsViewController.h"

@implementation QuestDetailsViewController

- (void) reloadWithQuest:(FullQuestProto *)quest userQuest:(FullUserQuestDataLargeProto *)userQuest {
  self.quest = quest;
  self.userQuest = userQuest;
  
  self.title = self.quest.name;
}

#pragma mark - IBAction methods

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClickedDetailsVC:self];
}

- (IBAction)visitClicked:(id)sender {
  [self.delegate visitClickedWithDetailsVC:self];
}

@end
