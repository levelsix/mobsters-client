//
//  QuestDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestDetailsViewController.h"
#import "Globals.h"

@implementation QuestDetailsCell

@end

@implementation QuestDetailsViewController

- (void) loadWithQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest {
  BOOL reloadRewards = ![quest.data isEqualToData:self.quest.data];
  self.quest = quest;
  self.userQuest = userQuest;
  
  self.title = self.quest.name;
  
  NSString *file = [quest.questGiverImagePrefix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:file withView:self.questGiverIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  file = [Globals imageNameForElement:quest.monsterElement suffix:@"team.png"];
  [Globals imageNamed:file withView:self.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.questGiverNameLabel.text = self.quest.questGiverName;
  [self setDescriptionString:self.quest.description];
//  self.jobLabel.text = self.quest.jobDescription;
//  
//    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", userQuest.progress, quest.quantity];
//  
//  if (quest.questType == FullQuestProto_QuestTypeDonateMonster && userQuest.progress >= quest.quantity) {
//    self.visitLabel.text = @"Donate";
//  } else {
//    self.visitLabel.text = @"Visit";
//  }
}

- (void) setDescriptionString:(NSString *)labelText {
  self.descriptionLabel.text = labelText;
  
  CGRect r = self.descriptionLabel.frame;
  CGSize s = [labelText sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(r.size.width, 999)];
  r.size.height = s.height+2;
  self.descriptionLabel.frame = r;
}

#pragma mark - UITableView dataSource/delegate

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuestDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestDetailsCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestDetailsCell" owner:self options:nil];
    cell = self.taskCell;
  }
  
  return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

#pragma mark - IBAction methods

- (IBAction)collectClicked:(id)sender {
  [self.delegate collectClickedWithDetailsVC:self];
}

- (IBAction)visitClicked:(id)sender {
#warning fix this
//  [self.delegate visitOrDonateClickedWithDetailsVC:self];
}

@end
