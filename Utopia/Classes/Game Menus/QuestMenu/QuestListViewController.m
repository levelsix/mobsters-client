//
//  QuestListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestListViewController.h"
#import "Globals.h"

@implementation QuestListCell

- (void) updateQuest:(FullQuestProto *)fqp {
  self.nameLabel.text = fqp.name;
  self.quest = fqp;
  
  if (fqp.questGiverImageSuffix) {
    NSString *file = [@"dialogue" stringByAppendingString:fqp.questGiverImageSuffix];
    [Globals imageNamed:file withView:self.questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  }
}

- (void) loadingForQuest:(FullQuestProto *)quest {
  [self updateQuest:quest];
  self.userQuest = nil;
  
  self.spinner.hidden = NO;
  self.progressLabel.hidden = YES;
}

- (void) updateForQuest:(FullQuestProto *)quest withUserQuestData:(FullUserQuestDataLargeProto *)userQuest {
  [self updateQuest:quest];
  self.userQuest = userQuest;
  
  self.spinner.hidden = YES;
  self.progressLabel.hidden = NO;
  
  self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", userQuest.numComponentsComplete, quest.numComponentsForGood];
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate questListCellClicked:self];
}

@end

@implementation QuestListViewController

- (id) init {
  if ((self = [super init])) {
    self.title = @"Quests";
  }
  return self;
}

- (void) reloadWithQuests:(NSArray *)quests userQuests:(NSArray *)userQuests {
  self.quests = quests;
  self.userQuests = userQuests;
  [self.questListTable reloadData];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.quests.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuestListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestListCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestListCell" owner:self options:nil];
    cell = self.questListCell;
    cell.delegate = (id<QuestListCellDelegate>)self.parentViewController;
  }
  
  FullQuestProto *quest = [self.quests objectAtIndex:indexPath.row];
  FullUserQuestDataLargeProto *userQuest = nil;
  for (FullUserQuestDataLargeProto *uq in self.userQuests) {
    if (uq.questId == quest.questId) {
      userQuest = uq;
    }
  }
  
  if (userQuest) {
    [cell updateForQuest:quest withUserQuestData:userQuest];
  } else {
    [cell loadingForQuest:quest];
  }
  
  return cell;
}

@end
