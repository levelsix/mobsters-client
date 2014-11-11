//
//  QuestDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestDetailsViewController.h"
#import "Globals.h"
#import "FullQuestProto+JobAccess.h"
#import "GameState.h"

#define SPACING_PER_NODE 38.f

@implementation QuestDetailsCell

- (void) updateForJob:(QuestJobProto *)job userJob:(UserQuestJob *)userJob {
  self.taskNumLabel.text = [NSString stringWithFormat:@"%d", job.priority];
  self.descriptionLabel.text = job.description;
  int progress = userJob.isComplete ? job.quantity : userJob.progress;
  self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", progress, job.quantity];
  
  self.donateCompleteView.hidden = YES;
  self.donateView.hidden = YES;
  self.goView.hidden = NO;
  if (job.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
    self.goView.hidden = YES;
    if (userJob.isComplete) {
      self.donateCompleteView.hidden = NO;
    } else if (userJob.progress >= job.quantity) {
      self.donateView.hidden = NO;;
    } else {
      self.goView.hidden = NO;
    }
  }
}

@end

@implementation QuestDetailsViewController

- (void) loadWithQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest {
  GameState *gs = [GameState sharedGameState];
  self.skipView.hidden = !gs.allowQuestSkipping;
  
  self.quest = quest;
  self.userQuest = userQuest;
  
  self.title = self.quest.name;
  
  [self.monsterView updateForElement:quest.monsterElement imgPrefix:quest.questGiverImagePrefix greyscale:NO];
  
  self.questGiverNameLabel.text = self.quest.questGiverName;
  [self setDescriptionString:self.quest.description];
  
  NSArray *rewards = [Reward createRewardsForQuest:quest];
  if (rewards.count > 2) rewards = [rewards subarrayWithRange:NSMakeRange(0, 2)];
  
  for (int i = 0; i < rewards.count; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestRewardView" owner:self options:nil];
    [self.rewardView loadForReward:rewards[i]];
    self.rewardView.center = ccp((2*i+1-(int)rewards.count)/2.f*SPACING_PER_NODE+self.rewardsBox.frame.size.width/2,
                        self.rewardsBox.frame.size.height/2);
    [self.rewardsBox addSubview:self.rewardView];
  }
}

- (void) setDescriptionString:(NSString *)labelText {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.5];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
  self.descriptionLabel.attributedText = attributedString;
  
  CGRect r = self.descriptionLabel.frame;
  CGSize s = [labelText getSizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(r.size.width, 999)];
  r.size.height = s.height+4;
  self.descriptionLabel.frame = r;
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.quest.jobsList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuestDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestDetailsCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestDetailsCell" owner:self options:nil];
    cell = self.taskCell;
  }
  
  NSArray *orderedJobs = [self.quest.jobsList sortedArrayUsingComparator:^NSComparisonResult(QuestJobProto *obj1, QuestJobProto *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  }];
  
  QuestJobProto *job = orderedJobs[indexPath.row];
  [cell updateForJob:job userJob:[self.userQuest jobForId:job.questJobId]];
  cell.tag = job.questJobId;
  
  return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

#pragma mark - IBAction methods

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClickedWithDetailsVC:self];
}

- (IBAction)visitClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[QuestDetailsCell class]]) {
    sender = sender.superview;
  }
  
  if (sender) {
    QuestDetailsCell *cell = (QuestDetailsCell *)sender;
    [self.delegate visitClickedWithDetailsVC:self jobId:(int)cell.tag];
  }
}

- (IBAction)donateClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[QuestDetailsCell class]]) {
    sender = sender.superview;
  }
  
  if (sender) {
    QuestDetailsCell *cell = (QuestDetailsCell *)sender;
    [self.delegate donateClickedWithDetailsVC:self jobId:(int)cell.tag];
  }
}

- (IBAction) skipClicked:(UIView *)sender {
  [self.delegate skipClickedWithDetailsVC:self];
}

@end
